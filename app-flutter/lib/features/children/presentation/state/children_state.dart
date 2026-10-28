import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/state/action_controller.dart';
import '../../../auth_family/auth_family.dart';
import '../../../ledger/ledger.dart';
import '../../../ledger/ledger_providers.dart';
import '../../../rules/rules_providers.dart';
import '../../data/providers.dart';
import '../../domain/entities/child.dart';

final _familyIdProvider = Provider<String?>((ref) {
  final gate = ref.watch(gateProvider);
  return gate is GateReady ? gate.family.id : null;
});

/// Filhos da família, na ordem de exibição.
final childrenProvider = StreamProvider<List<Child>>((ref) {
  final familyId = ref.watch(_familyIdProvider);
  if (familyId == null) return Stream.value(const <Child>[]);
  return ref.watch(childrenRepositoryProvider).watchChildren(familyId);
});

/// Filho com o saldo já calculado (mesada + Σ quantidade × valor da regra).
class ChildSummary {
  const ChildSummary(this.child, this.balanceCents);

  final Child child;
  final int balanceCents;
}

/// Junta filhos, regras e lançamentos. Fica em carregando até os três chegarem
/// e em erro se qualquer um falhar.
final childSummariesProvider = Provider<AsyncValue<List<ChildSummary>>>((ref) {
  final children = ref.watch(childrenProvider);
  final rules = ref.watch(rulesProvider);
  final entries = ref.watch(entriesProvider);

  for (final source in [children, rules, entries]) {
    if (source.hasError) {
      return AsyncValue.error(
        source.error!,
        source.stackTrace ?? StackTrace.empty,
      );
    }
  }
  if (!children.hasValue || !rules.hasValue || !entries.hasValue) {
    return const AsyncValue.loading();
  }
  return AsyncValue.data([
    for (final child in children.value!)
      ChildSummary(
        child,
        calculateBalanceCents(
          child: child,
          rules: rules.value!,
          entries: entries.value!,
        ),
      ),
  ]);
});

/// Caminho da foto local do filho, ou null.
final childPhotoPathProvider = FutureProvider.family<String?, String>(
  (ref, childId) => ref.watch(childPhotoStoreProvider).photoPath(childId),
);

class ChildrenActions extends ActionController {
  Future<bool> _withFamily(
    Future<Result<void>> Function(String familyId) action,
  ) => run(() async {
    final familyId = ref.read(_familyIdProvider);
    if (familyId == null) return const Err(Unexpected());
    try {
      return await action(familyId);
    } on FileSystemException catch (error) {
      return Err(Unexpected(error));
    }
  });

  /// Aplica a foto escolhida (ou a remoção) e atualiza o que está na tela.
  Future<void> _applyPhoto(
    String childId, {
    String? newPhotoPath,
    bool removePhoto = false,
  }) async {
    final store = ref.read(childPhotoStoreProvider);
    if (newPhotoPath != null) {
      await store.savePhoto(childId, newPhotoPath);
    } else if (removePhoto) {
      await store.deletePhoto(childId);
    } else {
      return;
    }
    final path = await store.photoPath(childId);
    // A imagem anterior pode estar no cache de imagens com o mesmo caminho.
    if (path != null) await FileImage(File(path)).evict();
    if (ref.mounted) ref.invalidate(childPhotoPathProvider(childId));
  }

  Future<bool> add({
    required String name,
    required String email,
    required int allowanceCents,
    String? photoPath,
  }) => _withFamily((familyId) async {
    final result = await ref
        .read(childrenRepositoryProvider)
        .addChild(
          familyId,
          name: name,
          email: email,
          allowanceCents: allowanceCents,
        );
    switch (result) {
      case Ok(:final value):
        await _applyPhoto(value, newPhotoPath: photoPath);
        return const Ok(null);
      case Err(:final failure):
        return Err(failure);
    }
  });

  Future<bool> edit(
    Child child, {
    String? newPhotoPath,
    bool removePhoto = false,
  }) => _withFamily((familyId) async {
    final result = await ref
        .read(childrenRepositoryProvider)
        .updateChild(familyId, child);
    if (result is Err) return result;
    await _applyPhoto(
      child.id,
      newPhotoPath: newPhotoPath,
      removePhoto: removePhoto,
    );
    return const Ok(null);
  });

  Future<bool> delete(String childId) => _withFamily((familyId) async {
    final result = await ref
        .read(childrenRepositoryProvider)
        .deleteChild(familyId, childId);
    if (result is Err) return result;
    await _applyPhoto(childId, removePhoto: true);
    return const Ok(null);
  });

  Future<bool> reorder(List<String> orderedIds) => _withFamily(
    (familyId) =>
        ref.read(childrenRepositoryProvider).reorder(familyId, orderedIds),
  );
}

final childrenActionsProvider =
    NotifierProvider.autoDispose<ChildrenActions, ActionState>(
      ChildrenActions.new,
    );
