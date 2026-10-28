/// Foto do filho guardada **só neste aparelho** (ADR-0006): nada de imagem de
/// criança na nuvem. Cada responsável escolhe a foto no próprio aparelho.
abstract class ChildPhotoStore {
  /// Caminho do arquivo da foto, ou null se o filho não tem foto aqui.
  Future<String?> photoPath(String childId);

  /// Copia a imagem de [sourcePath] para o armazenamento do app, no lugar da
  /// anterior.
  Future<void> savePhoto(String childId, String sourcePath);

  Future<void> deletePhoto(String childId);
}

/// Escolhe uma imagem da galeria.
abstract class PhotoPicker {
  /// Caminho da imagem escolhida (já reduzida), ou null se a pessoa cancelou.
  Future<String?> pickFromGallery();
}
