import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/rules_repository.dart';
import 'datasources/rules_firestore_datasource.dart';
import 'repositories/rules_repository_impl.dart';

/// Raiz de composição da feature; os testes trocam por um repositório falso.
final rulesRepositoryProvider = Provider<RulesRepository>(
  (ref) =>
      RulesRepositoryImpl(RulesFirestoreDataSource(FirebaseFirestore.instance)),
);
