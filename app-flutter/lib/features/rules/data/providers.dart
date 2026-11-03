import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/providers.dart';
import '../domain/repositories/rules_repository.dart';
import 'datasources/rules_firestore_datasource.dart';
import 'repositories/rules_local_repository.dart';
import 'repositories/rules_repository_impl.dart';

/// Raiz de composição da feature; os testes trocam por um repositório falso.
/// Uma fonte de verdade por vez (ADR-0014).
final rulesRepositoryProvider = Provider<RulesRepository>((ref) {
  return switch (ref.watch(appModeProvider)) {
    AppMode.local => RulesLocalRepository(ref.watch(localStoreProvider)),
    AppMode.cloud => RulesRepositoryImpl(
      RulesFirestoreDataSource(FirebaseFirestore.instance),
    ),
  };
});
