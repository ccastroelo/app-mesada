import '../../../../core/error/result.dart';
import '../../../../core/storage/local_store.dart';
import '../../../../core/utils/local_id.dart';
import '../../domain/entities/child.dart';
import '../../domain/repositories/children_repository.dart';
import '../models/child_dto.dart';

/// Filhos guardados no aparelho (ADR-0014). Espelha
/// `ChildrenRepositoryImpl`, trocando o Firestore pelo arquivo local;
/// [familyId] não é usado (no modo local existe uma família só).
class ChildrenLocalRepository implements ChildrenRepository {
  ChildrenLocalRepository(this._store);

  final LocalStore _store;

  @override
  Stream<List<Child>> watchChildren(String familyId) =>
      _store.watch().map((document) => _ordered(document.children));

  @override
  Future<Result<String>> addChild(
    String familyId, {
    required String name,
    required String email,
    required int allowanceCents,
  }) async {
    final id = newLocalId();
    final result = await _store.update(
      (document) => document.copyWith(
        children: [
          ...document.children,
          {
            'id': id,
            'name': name,
            'email': email,
            'allowanceCents': allowanceCents,
            'order': DateTime.now().millisecondsSinceEpoch,
          },
        ],
      ),
    );
    return switch (result) {
      Ok() => Ok(id),
      Err(:final failure) => Err(failure),
    };
  }

  @override
  Future<Result<void>> updateChild(String familyId, Child child) {
    return _store.update(
      (document) => document.copyWith(
        children: [
          for (final map in document.children)
            if (map['id'] == child.id)
              {
                ...map,
                'name': child.name,
                'email': child.email,
                'allowanceCents': child.allowanceCents,
              }
            else
              map,
        ],
      ),
    );
  }

  /// Apaga o filho e os lançamentos dele.
  @override
  Future<Result<void>> deleteChild(String familyId, String childId) {
    return _store.update(
      (document) => document.copyWith(
        children: [
          for (final map in document.children)
            if (map['id'] != childId) map,
        ],
        entries: [
          for (final map in document.entries)
            if (map['childId'] != childId) map,
        ],
      ),
    );
  }

  @override
  Future<Result<void>> reorder(String familyId, List<String> orderedIds) {
    return _store.update(
      (document) => document.copyWith(
        children: [
          for (final map in document.children)
            if (orderedIds.indexOf(map['id'] as String) case final index
                when index >= 0)
              {...map, 'order': index}
            else
              map,
        ],
      ),
    );
  }

  List<Child> _ordered(List<Map<String, dynamic>> maps) {
    // Dois itens podem empatar no milissegundo de `order`; o id desempata
    // (começa pelo relógio), e `List.sort` não é estável.
    final sorted = [...maps]
      ..sort((a, b) {
        final byOrder = _order(a).compareTo(_order(b));
        return byOrder != 0 ? byOrder : _id(a).compareTo(_id(b));
      });
    return [
      for (final map in sorted)
        ChildDto.fromMap(map['id'] as String, map).toEntity(),
    ];
  }

  int _order(Map<String, dynamic> map) => (map['order'] as num?)?.toInt() ?? 0;

  String _id(Map<String, dynamic> map) => map['id'] as String? ?? '';
}
