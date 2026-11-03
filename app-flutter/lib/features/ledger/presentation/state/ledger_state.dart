import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/state/action_controller.dart';
import '../../../auth_family/auth_family.dart';
import '../../data/providers.dart';
import '../../domain/entities/entry.dart';

/// Id da família atual; null enquanto a entrada não terminou.
final _familyIdProvider = Provider<String?>((ref) {
  final gate = ref.watch(gateProvider);
  return gate is GateReady ? gate.family.id : null;
});

/// Todos os lançamentos da família (poucas dezenas de documentos).
final entriesProvider = StreamProvider<List<Entry>>((ref) {
  final familyId = ref.watch(_familyIdProvider);
  if (familyId == null) return Stream.value(const <Entry>[]);
  return ref.watch(ledgerRepositoryProvider).watchEntries(familyId);
});

/// Escritas de lançamento. Não esperam o servidor por desenho: no modo local a
/// gravação é imediata e, na nuvem, o SDK enfileira e o stream já reflete
/// (ADR-0014 e `tech-debt.md`).
class LedgerActions extends ActionController {
  Future<bool> increment({required String childId, required String ruleId}) =>
      _withFamily(
        (familyId) => ref
            .read(ledgerRepositoryProvider)
            .increment(familyId, childId: childId, ruleId: ruleId),
      );

  Future<bool> decrement({required String childId, required String ruleId}) =>
      _withFamily(
        (familyId) => ref
            .read(ledgerRepositoryProvider)
            .decrement(familyId, childId: childId, ruleId: ruleId),
      );

  Future<bool> setEnabled({
    required String childId,
    required String ruleId,
    required bool enabled,
  }) => _withFamily(
    (familyId) => ref
        .read(ledgerRepositoryProvider)
        .setEnabled(
          familyId,
          childId: childId,
          ruleId: ruleId,
          enabled: enabled,
        ),
  );

  /// Zera as quantidades de um filho (ou de todos, se [childId] for nulo) e
  /// devolve o que havia antes, para a tela oferecer "Desfazer". **Nulo quando
  /// falha**; lista vazia quando não havia nada lançado.
  Future<List<Entry>?> zero({String? childId}) async {
    final previous = [
      for (final entry in ref.read(entriesProvider).value ?? const <Entry>[])
        if (entry.quantity > 0 && (childId == null || entry.childId == childId))
          entry,
    ];
    final ok = await _withFamily(
      (familyId) =>
          ref.read(ledgerRepositoryProvider).zero(familyId, childId: childId),
    );
    return ok ? previous : null;
  }

  Future<bool> restore(Iterable<Entry> entries) => _withFamily(
    (familyId) => ref.read(ledgerRepositoryProvider).restore(familyId, entries),
  );

  Future<bool> _withFamily(
    Future<Result<void>> Function(String familyId) action,
  ) => run(() async {
    final familyId = ref.read(_familyIdProvider);
    if (familyId == null) return const Err(Unexpected());
    return action(familyId);
  });
}

/// Compartilhado pela tela do filho, pela de regras do filho e pela aba
/// Filhos (zerar de todos).
final ledgerActionsProvider =
    NotifierProvider.autoDispose<LedgerActions, ActionState>(LedgerActions.new);
