import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/storage/providers.dart';
import '../domain/repositories/child_photo_store.dart';
import '../domain/repositories/children_repository.dart';
import 'datasources/children_firestore_datasource.dart';
import 'datasources/image_picker_photo_picker.dart';
import 'repositories/child_photo_store_impl.dart';
import 'repositories/children_local_repository.dart';
import 'repositories/children_repository_impl.dart';

/// Raiz de composição da feature; os testes trocam por versões falsas.
/// Uma fonte de verdade por vez (ADR-0014).
final childrenRepositoryProvider = Provider<ChildrenRepository>((ref) {
  return switch (ref.watch(appModeProvider)) {
    AppMode.local => ChildrenLocalRepository(ref.watch(localStoreProvider)),
    AppMode.cloud => ChildrenRepositoryImpl(
      ChildrenFirestoreDataSource(FirebaseFirestore.instance),
    ),
  };
});

/// A foto é sempre local, com ou sem assinatura (ADR-0006).
final childPhotoStoreProvider = Provider<ChildPhotoStore>(
  (ref) => ChildPhotoStoreImpl(getApplicationDocumentsDirectory),
);

final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => ImagePickerPhotoPicker(),
);
