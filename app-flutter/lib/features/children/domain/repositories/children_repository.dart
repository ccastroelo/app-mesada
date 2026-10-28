import '../../../../core/error/result.dart';
import '../entities/child.dart';

/// Filhos da família. A ordem da lista é a de exibição na aba Filhos.
abstract class ChildrenRepository {
  Stream<List<Child>> watchChildren(String familyId);

  /// Entra no fim da lista e devolve o id gerado (a foto local usa esse id).
  Future<Result<String>> addChild(
    String familyId, {
    required String name,
    required String email,
    required int allowanceCents,
  });

  Future<Result<void>> updateChild(String familyId, Child child);

  /// Apaga o filho e os lançamentos dele.
  Future<Result<void>> deleteChild(String familyId, String childId);

  /// [orderedIds] é a nova ordem completa.
  Future<Result<void>> reorder(String familyId, List<String> orderedIds);
}
