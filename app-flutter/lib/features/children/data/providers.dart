import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/repositories/child_photo_store.dart';
import '../domain/repositories/children_repository.dart';
import 'datasources/children_firestore_datasource.dart';
import 'datasources/image_picker_photo_picker.dart';
import 'repositories/child_photo_store_impl.dart';
import 'repositories/children_repository_impl.dart';

/// Raiz de composição da feature; os testes trocam por versões falsas.
final childrenRepositoryProvider = Provider<ChildrenRepository>(
  (ref) => ChildrenRepositoryImpl(
    ChildrenFirestoreDataSource(FirebaseFirestore.instance),
  ),
);

final childPhotoStoreProvider = Provider<ChildPhotoStore>(
  (ref) => ChildPhotoStoreImpl(getApplicationDocumentsDirectory),
);

final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => ImagePickerPhotoPicker(),
);
