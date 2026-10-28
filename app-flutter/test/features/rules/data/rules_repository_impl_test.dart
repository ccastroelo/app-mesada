import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/features/rules/data/datasources/rules_firestore_datasource.dart';
import 'package:mesada/features/rules/data/models/rule_dto.dart';
import 'package:mesada/features/rules/data/repositories/rules_repository_impl.dart';
import 'package:mesada/features/rules/rules.dart';

class _FakeDataSource implements RulesFirestoreDataSource {
  Object? error;
  final calls = <String>[];

  void _call(String call) {
    calls.add(call);
    if (error != null) throw error!;
  }

  @override
  Stream<List<RuleDto>> watchRules(String familyId) => Stream.value(const [
    RuleDto(id: 'r1', description: 'Mentir', valueCents: -100),
    RuleDto(id: 'r2', description: 'Arrumar a cama', valueCents: 50),
  ]);

  @override
  Future<void> addRule(
    String familyId, {
    required String description,
    required int valueCents,
  }) async => _call('add:$familyId:[$description]:$valueCents');

  @override
  Future<void> updateRule(
    String familyId,
    String ruleId, {
    required String description,
    required int valueCents,
  }) async => _call('update:$ruleId:[$description]:$valueCents');

  @override
  Future<void> deleteRule(String familyId, String ruleId) async =>
      _call('delete:$ruleId');

  @override
  Future<void> reorder(String familyId, List<String> orderedIds) async =>
      _call('reorder:${orderedIds.join(',')}');

  @override
  Future<void> addSuggestions(String familyId, List<RuleSeed> seeds) async =>
      _call('suggestions:${seeds.length}');
}

void main() {
  late _FakeDataSource remote;
  late RulesRepositoryImpl repository;

  setUp(() {
    remote = _FakeDataSource();
    repository = RulesRepositoryImpl(remote);
  });

  test('traduz DTOs em entidades, na ordem recebida', () async {
    final rules = await repository.watchRules('f1').first;
    expect(rules.map((r) => r.id), ['r1', 'r2']);
    expect(rules.first.isDiscount, isTrue);
    expect(rules.last.valueCents, 50);
  });

  test('apara a descrição ao criar e ao editar', () async {
    await repository.addRule('f1', description: '  Mentir  ', valueCents: -100);
    await repository.updateRule(
      'f1',
      const Rule(id: 'r1', description: ' Xingar ', valueCents: -150),
    );
    expect(remote.calls, ['add:f1:[Mentir]:-100', 'update:r1:[Xingar]:-150']);
  });

  test('repassa excluir, reordenar e sugestões', () async {
    expect(await repository.deleteRule('f1', 'r1'), isA<Ok<void>>());
    expect(await repository.reorder('f1', ['r2', 'r1']), isA<Ok<void>>());
    expect(
      await repository.addSuggestions('f1', defaultRulesFor('pt')),
      isA<Ok<void>>(),
    );
    expect(remote.calls, ['delete:r1', 'reorder:r2,r1', 'suggestions:20']);
  });

  test('exceção do Firestore vira falha de domínio', () async {
    remote.error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unavailable',
    );
    final result = await repository.deleteRule('f1', 'r1');
    expect((result as Err).failure, isA<NoConnection>());

    remote.error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
    );
    final denied = await repository.reorder('f1', ['r1']);
    expect((denied as Err).failure, isA<PermissionDenied>());
  });
}
