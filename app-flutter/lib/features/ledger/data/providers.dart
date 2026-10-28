import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/ledger_repository.dart';
import 'datasources/ledger_firestore_datasource.dart';
import 'repositories/ledger_repository_impl.dart';

/// Raiz de composição da feature; os testes trocam por um repositório falso.
final ledgerRepositoryProvider = Provider<LedgerRepository>(
  (ref) => LedgerRepositoryImpl(
    LedgerFirestoreDataSource(FirebaseFirestore.instance),
  ),
);
