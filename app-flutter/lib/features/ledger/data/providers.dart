import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/providers.dart';
import '../domain/repositories/ledger_repository.dart';
import 'datasources/ledger_firestore_datasource.dart';
import 'repositories/ledger_local_repository.dart';
import 'repositories/ledger_repository_impl.dart';

/// Raiz de composição da feature; os testes trocam por um repositório falso.
/// Uma fonte de verdade por vez (ADR-0014).
final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  return switch (ref.watch(appModeProvider)) {
    AppMode.local => LedgerLocalRepository(ref.watch(localStoreProvider)),
    AppMode.cloud => LedgerRepositoryImpl(
      LedgerFirestoreDataSource(FirebaseFirestore.instance),
    ),
  };
});
