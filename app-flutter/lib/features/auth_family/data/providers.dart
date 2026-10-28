import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/family_repository.dart';
import 'datasources/family_firestore_datasource.dart';
import 'datasources/firebase_auth_datasource.dart';
import 'repositories/auth_repository_impl.dart';
import 'repositories/family_repository_impl.dart';

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
