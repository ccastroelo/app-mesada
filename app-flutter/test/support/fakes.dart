import 'dart:async';

import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/features/auth_family/domain/entities/app_user.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';
import 'package:mesada/features/auth_family/domain/repositories/auth_repository.dart';
import 'package:mesada/features/auth_family/domain/repositories/family_repository.dart';
import 'package:mesada/features/auth_family/domain/usecases/invite_code.dart';
import 'package:mesada/features/rules/rules.dart';

const testUser = AppUser(uid: 'u1', email: 'ana@example.com');

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this._user});

  AppUser? _user;
  final _changes = StreamController<AppUser?>.broadcast();

  /// Resultado devolvido pelas próximas chamadas.
  Result<void> nextResult = const Ok(null);
  final calls = <String>[];

  void _emit(AppUser? user) {
    _user = user;
    _changes.add(user);
  }

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
    yield* _changes.stream;
  }

  Future<Result<void>> _signedIn(String call, String email) async {
    calls.add(call);
    if (nextResult is Ok) _emit(AppUser(uid: 'u1', email: email));
    return nextResult;
  }

  @override
  Future<Result<void>> signInWithEmail(String email, String password) =>
      _signedIn('signIn:$email', email);

  @override
  Future<Result<void>> signUpWithEmail(String email, String password) =>
      _signedIn('signUp:$email', email);

  @override
  Future<Result<void>> signInWithGoogle() =>
      _signedIn('google', 'google@example.com');

  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    calls.add('reset:$email');
    return nextResult;
  }

  @override
  Future<Result<void>> signOut() async {
    calls.add('signOut');
    _emit(null);
    return const Ok(null);
  }
}

class FakeFamilyRepository implements FamilyRepository {
  FakeFamilyRepository({this._family, this.validCodes = const {}});

  Family? _family;
  final Set<String> validCodes;
  final _idChanges = StreamController<String?>.broadcast();
  final _familyChanges = StreamController<Family?>.broadcast();

  String? lastName;
  List<RuleSeed>? lastSeeds;
  Result<void>? createError;

  void _set(Family? family) {
    _family = family;
    _familyChanges.add(family);
    _idChanges.add(family?.id);
  }

  @override
  Stream<String?> watchFamilyId(String uid) async* {
    yield _family?.id;
    yield* _idChanges.stream;
  }

  @override
  Stream<Family?> watchFamily(String familyId) async* {
    yield _family;
    yield* _familyChanges.stream;
  }

  @override
  Future<Result<void>> createFamily({
    required AppUser user,
    required String name,
    required List<RuleSeed> rules,
  }) async {
    lastName = name;
    lastSeeds = rules;
    final error = createError;
    if (error != null) return error;
    _set(Family(id: 'f1', name: name));
    return const Ok(null);
  }

  @override
  Future<Result<String>> createInvite({
    required AppUser user,
    required Family family,
  }) async => const Ok('ABC234');

  @override
  Future<Result<void>> joinWithCode({
    required AppUser user,
    required String code,
  }) async {
    final normalized = normalizeInviteCode(code);
    if (normalized == null || !validCodes.contains(normalized)) {
      return const Err(InvalidInvite());
    }
    _set(const Family(id: 'f1', name: 'Família Castro'));
    return const Ok(null);
  }
}
