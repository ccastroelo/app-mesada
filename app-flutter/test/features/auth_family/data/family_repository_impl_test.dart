import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/features/auth_family/data/datasources/family_firestore_datasource.dart';
import 'package:mesada/features/auth_family/data/models/family_dto.dart';
import 'package:mesada/features/auth_family/data/models/invite_dto.dart';
import 'package:mesada/features/auth_family/data/repositories/family_repository_impl.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';
import 'package:mesada/features/rules/rules.dart';

import '../../../support/fakes.dart';

class _FakeDataSource implements FamilyFirestoreDataSource {
  InviteDto? invite;
  Object? joinError;
  Object? createFamilyError;
  final inviteErrors = <Object>[];
  final createdInvites =
      <({String code, String familyId, DateTime expiresAt})>[];
  final joined = <({String code, String familyId, String uid})>[];
  ({String name, int rules})? createdFamily;

  @override
  Stream<String?> watchFamilyId(String uid) => Stream.value('f1');

  @override
  Stream<FamilyDto?> watchFamily(String familyId) =>
      Stream.value(FamilyDto(id: familyId, name: 'Família'));

  @override
  Future<void> createFamily({
    required String uid,
    required String email,
    required String name,
    required List<RuleSeed> rules,
  }) async {
    if (createFamilyError != null) throw createFamilyError!;
    createdFamily = (name: name, rules: rules.length);
  }

  @override
  Future<void> createInvite({
    required String code,
    required String familyId,
    required String uid,
    required DateTime expiresAt,
  }) async {
    if (inviteErrors.isNotEmpty) throw inviteErrors.removeAt(0);
    createdInvites.add((code: code, familyId: familyId, expiresAt: expiresAt));
  }

  @override
  Future<InviteDto?> getInvite(String code) async => invite;

  @override
  Future<void> joinFamily({
    required String uid,
    required String email,
    required String code,
    required String familyId,
  }) async {
    if (joinError != null) throw joinError!;
    joined.add((code: code, familyId: familyId, uid: uid));
  }
}

FirebaseException _firestoreError(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code);

void main() {
  final now = DateTime(2026, 10, 28, 12);
  late _FakeDataSource remote;
  late FamilyRepositoryImpl repository;
  const family = Family(id: 'f1', name: 'Família');

  setUp(() {
    remote = _FakeDataSource();
    repository = FamilyRepositoryImpl(
      remote,
      random: Random(1),
      clock: () => now,
    );
  });

  Failure failureOf(Result<Object?> result) => (result as Err).failure;

  group('createFamily', () {
    test('apara o nome e repassa as regras iniciais', () async {
      final result = await repository.createFamily(
        user: testUser,
        name: '  Família Castro  ',
        rules: defaultRulesFor('pt'),
      );
      expect(result, isA<Ok<void>>());
      expect(remote.createdFamily, (name: 'Família Castro', rules: 20));
    });

    test('traduz erro do Firestore em falha', () async {
      remote.createFamilyError = _firestoreError('unavailable');
      final result = await repository.createFamily(
        user: testUser,
        name: 'X',
        rules: const [],
      );
      expect(failureOf(result), isA<NoConnection>());
    });
  });

  group('createInvite', () {
    test('cria convite que vence em 47 h com código válido', () async {
      final result = await repository.createInvite(
        user: testUser,
        family: family,
      );
      final code = (result as Ok<String>).value;
      expect(code, hasLength(6));
      final created = remote.createdInvites.single;
      expect(created.code, code);
      expect(created.familyId, 'f1');
      expect(created.expiresAt, now.add(const Duration(hours: 47)));
    });

    test('tenta outro código se o primeiro colidir', () async {
      remote.inviteErrors.add(_firestoreError('permission-denied'));
      final result = await repository.createInvite(
        user: testUser,
        family: family,
      );
      expect(result, isA<Ok<String>>());
      expect(remote.createdInvites, hasLength(1));
    });

    test('desiste depois de 3 colisões', () async {
      remote.inviteErrors.addAll([
        _firestoreError('permission-denied'),
        _firestoreError('permission-denied'),
        _firestoreError('permission-denied'),
      ]);
      final result = await repository.createInvite(
        user: testUser,
        family: family,
      );
      expect(failureOf(result), isA<PermissionDenied>());
      expect(remote.createdInvites, isEmpty);
    });

    test('outro erro não é repetido', () async {
      remote.inviteErrors.add(_firestoreError('unavailable'));
      final result = await repository.createInvite(
        user: testUser,
        family: family,
      );
      expect(failureOf(result), isA<NoConnection>());
    });
  });

  group('joinWithCode', () {
    InviteDto invite({
      String? usedBy,
      Duration expiresIn = const Duration(hours: 5),
    }) => InviteDto(
      familyId: 'f9',
      usedBy: usedBy,
      expiresAt: now.add(expiresIn),
    );

    test('entra com o código normalizado na família do convite', () async {
      remote.invite = invite();
      final result = await repository.joinWithCode(
        user: testUser,
        code: ' abc-234 ',
      );
      expect(result, isA<Ok<void>>());
      expect(remote.joined.single, (code: 'ABC234', familyId: 'f9', uid: 'u1'));
    });

    test('código malformado nem consulta o banco', () async {
      remote.invite = invite();
      final result = await repository.joinWithCode(user: testUser, code: '123');
      expect(failureOf(result), isA<InvalidInvite>());
      expect(remote.joined, isEmpty);
    });

    test('convite inexistente, usado ou expirado é inválido', () async {
      remote.invite = null;
      expect(
        failureOf(
          await repository.joinWithCode(user: testUser, code: 'ABC234'),
        ),
        isA<InvalidInvite>(),
      );
      remote.invite = invite(usedBy: 'outro');
      expect(
        failureOf(
          await repository.joinWithCode(user: testUser, code: 'ABC234'),
        ),
        isA<InvalidInvite>(),
      );
      remote.invite = invite(expiresIn: const Duration(minutes: -1));
      expect(
        failureOf(
          await repository.joinWithCode(user: testUser, code: 'ABC234'),
        ),
        isA<InvalidInvite>(),
      );
      expect(remote.joined, isEmpty);
    });

    test('corrida: se o lote for negado, o convite virou inválido', () async {
      remote.invite = invite();
      remote.joinError = _firestoreError('permission-denied');
      final result = await repository.joinWithCode(
        user: testUser,
        code: 'ABC234',
      );
      expect(failureOf(result), isA<InvalidInvite>());
    });

    test('sem rede continua sendo falha de conexão', () async {
      remote.invite = invite();
      remote.joinError = _firestoreError('unavailable');
      final result = await repository.joinWithCode(
        user: testUser,
        code: 'ABC234',
      );
      expect(failureOf(result), isA<NoConnection>());
    });
  });
}
