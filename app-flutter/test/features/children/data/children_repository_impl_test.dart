import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/features/children/children.dart';
import 'package:mesada/features/children/data/datasources/children_firestore_datasource.dart';
import 'package:mesada/features/children/data/models/child_dto.dart';
import 'package:mesada/features/children/data/repositories/children_repository_impl.dart';

class _FakeDataSource implements ChildrenFirestoreDataSource {
  Object? error;
  final calls = <String>[];

  void _call(String call) {
    calls.add(call);
    if (error != null) throw error!;
  }

  @override
  Stream<List<ChildDto>> watchChildren(String familyId) => Stream.value(const [
    ChildDto(id: 'c1', name: 'Lucas', email: '', allowanceCents: 10000),
    ChildDto(id: 'c2', name: 'Ana', email: 'ana@x.com', allowanceCents: 6000),
  ]);

  @override
  Future<String> addChild(
    String familyId, {
    required String name,
    required String email,
    required int allowanceCents,
  }) async {
    _call('add:[$name]:[$email]:$allowanceCents');
    return 'novo-id';
  }

  @override
  Future<void> updateChild(
    String familyId,
    String childId, {
    required String name,
    required String email,
    required int allowanceCents,
  }) async => _call('update:$childId:[$name]:[$email]:$allowanceCents');

  @override
  Future<void> deleteChild(String familyId, String childId) async =>
      _call('delete:$childId');

  @override
  Future<void> reorder(String familyId, List<String> orderedIds) async =>
      _call('reorder:${orderedIds.join(',')}');
}

void main() {
  late _FakeDataSource remote;
  late ChildrenRepositoryImpl repository;

  setUp(() {
    remote = _FakeDataSource();
    repository = ChildrenRepositoryImpl(remote);
  });

  test('traduz DTOs em entidades, na ordem recebida', () async {
    final children = await repository.watchChildren('f1').first;
    expect(children.map((c) => c.name), ['Lucas', 'Ana']);
    expect(children.last.email, 'ana@x.com');
    expect(children.first.allowanceCents, 10000);
  });

  test('criar apara nome e e-mail e devolve o id gerado', () async {
    final result = await repository.addChild(
      'f1',
      name: '  Lucas ',
      email: ' a@b.co ',
      allowanceCents: 5000,
    );
    expect((result as Ok<String>).value, 'novo-id');
    expect(remote.calls, ['add:[Lucas]:[a@b.co]:5000']);
  });

  test('editar apara os textos e mantém o id', () async {
    await repository.updateChild(
      'f1',
      const Child(id: 'c1', name: ' Lu ', allowanceCents: 1, email: ' '),
    );
    expect(remote.calls, ['update:c1:[Lu]:[]:1']);
  });

  test('repassa excluir e reordenar', () async {
    expect(await repository.deleteChild('f1', 'c1'), isA<Ok<void>>());
    expect(await repository.reorder('f1', ['c2', 'c1']), isA<Ok<void>>());
    expect(remote.calls, ['delete:c1', 'reorder:c2,c1']);
  });

  test('exceção do Firestore vira falha de domínio', () async {
    remote.error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unavailable',
    );
    final created = await repository.addChild(
      'f1',
      name: 'X',
      email: '',
      allowanceCents: 0,
    );
    expect((created as Err).failure, isA<NoConnection>());

    remote.error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
    );
    final deleted = await repository.deleteChild('f1', 'c1');
    expect((deleted as Err).failure, isA<PermissionDenied>());
  });
}
