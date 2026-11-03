import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/providers.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/family_repository.dart';
import 'datasources/family_firestore_datasource.dart';
import 'datasources/firebase_auth_datasource.dart';
import 'repositories/auth_repository_impl.dart';
import 'repositories/family_repository_impl.dart';
import 'repositories/local_family_source.dart';

/// Raiz de composição da feature: é aqui que o SDK entra. Os testes
/// substituem estes dois providers por repositórios falsos.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(FirebaseAuthDataSource(FirebaseAuth.instance)),
);

final familyRepositoryProvider = Provider<FamilyRepository>(
  (ref) => FamilyRepositoryImpl(
    FamilyFirestoreDataSource(FirebaseFirestore.instance),
  ),
);

/// Família do modo local: sem conta, lida do arquivo do aparelho (ADR-0014).
final localFamilySourceProvider = Provider<LocalFamilySource>(
  (ref) => LocalFamilySource(ref.watch(localStoreProvider)),
);
