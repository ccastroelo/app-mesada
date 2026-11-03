import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/features/ledger/data/datasources/ledger_firestore_datasource.dart';
import 'package:mesada/features/ledger/data/repositories/ledger_repository_impl.dart';
import 'package:mesada/features/ledger/ledger.dart';

class _FakeDataSource implements LedgerFirestoreDataSource {
  Object? error;
  final calls = <String>[];

  void _call(String call) {
    calls.add(call);
    if (error != null) throw error!;
  }

  @override
  Stream<List<Entry>> watchEntries(String familyId) =>
      Stream.value(const [Entry(childId: 'c1', ruleId: 'r1', quantity: 2)]);

  @override
  Future<void> addQuantity(
    String familyId, {
    required String childId,
    required String ruleId,
    required int by,
  }) async => _call('add:$familyId:${childId}_$ruleId:$by');

  @override
  Future<void> setEnabled(
    String familyId, {
    required String childId,
    required String ruleId,
    required bool enabled,
  }) async => _call('enabled:${childId}_$ruleId:$enabled');

  @override
  Future<void> zero(String familyId, {String? childId}) async =>
      _call('zero:${childId ?? 'todos'}');

  @override
  Future<void> setQuantities(
    String familyId,
    Iterable<Entry> entries,
  ) async => _call(
    'restore:${[for (final e in entries) '${e.id}=${e.quantity}'].join(',')}',
  );
}

void main() {
  late _FakeDataSource remote;
  late LedgerRepositoryImpl repository;

  setUp(() {
    remote = _FakeDataSource();
    repository = LedgerRepositoryImpl(remote);
  });

  test('a leitura entrega as entidades do datasource', () async {
    final entries = await repository.watchEntries('f1').first;

    expect(entries.single.childId, 'c1');
    expect(entries.single.quantity, 2);
  });

  test('+ e − somam no servidor (sem ler antes)', () async {
    await repository.increment('f1', childId: 'c1', ruleId: 'r1');
    await repository.decrement('f1', childId: 'c1', ruleId: 'r1');

    expect(remote.calls, ['add:f1:c1_r1:1', 'add:f1:c1_r1:-1']);
  });

  test('ativar/desativar e zerar chegam ao datasource', () async {
    await repository.setEnabled(
      'f1',
      childId: 'c1',
      ruleId: 'r1',
      enabled: false,
    );
    await repository.zero('f1', childId: 'c1');
    await repository.zero('f1');

    expect(remote.calls, ['enabled:c1_r1:false', 'zero:c1', 'zero:todos']);
  });

  test('desfazer grava as quantidades exatas', () async {
    await repository.restore('f1', const [
      Entry(childId: 'c1', ruleId: 'r1', quantity: 3),
    ]);

    expect(remote.calls, ['restore:c1_r1=3']);
  });

  test('falha do SDK vira Failure', () async {
    remote.error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
    );

    final result = await repository.increment(
      'f1',
      childId: 'c1',
      ruleId: 'r1',
    );

    expect(result, isA<Err<void>>());
    expect((result as Err<void>).failure, isA<PermissionDenied>());
  });
}
