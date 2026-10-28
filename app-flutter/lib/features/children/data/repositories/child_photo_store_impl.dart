import 'dart:io';

import '../../domain/repositories/child_photo_store.dart';

/// Guarda a foto em `<pasta do app>/child_photos/<childId>.jpg`. A pasta base
/// vem de fora (`path_provider` no app, uma pasta temporária nos testes).
class ChildPhotoStoreImpl implements ChildPhotoStore {
  ChildPhotoStoreImpl(this._baseDirectory);

  final Future<Directory> Function() _baseDirectory;

  Future<File> _file(String childId) async {
    final base = await _baseDirectory();
    return File(
      '${base.path}${Platform.pathSeparator}child_photos'
      '${Platform.pathSeparator}$childId.jpg',
    );
  }

  @override
  Future<String?> photoPath(String childId) async {
    final file = await _file(childId);
    return await file.exists() ? file.path : null;
  }

  @override
  Future<void> savePhoto(String childId, String sourcePath) async {
    final target = await _file(childId);
    await target.parent.create(recursive: true);
    await File(sourcePath).copy(target.path);
  }

  @override
  Future<void> deletePhoto(String childId) async {
    final file = await _file(childId);
    if (await file.exists()) await file.delete();
  }
}
