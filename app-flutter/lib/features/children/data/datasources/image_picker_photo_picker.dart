import 'package:image_picker/image_picker.dart';

import '../../domain/repositories/child_photo_store.dart';

/// Galeria do sistema. A imagem já volta reduzida (512 px, JPEG 80), então o
/// arquivo guardado no aparelho fica pequeno.
class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    return file?.path;
  }
}
