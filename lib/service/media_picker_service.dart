import 'package:image_picker/image_picker.dart';

/// Encapsula o [ImagePicker] e expõe métodos simples para selecionar
/// fotos/vídeos da galeria ou capturá-los pela câmera.
class MediaPickerService {
  MediaPickerService() : _picker = ImagePicker();

  final ImagePicker _picker;

  /// Abre a galeria e retorna até [maxItems] fotos.
  Future<List<XFile>> pickPhotos({int maxItems = 10}) async {
    final result = await _picker.pickMultiImage(
      imageQuality: 85,
      limit: maxItems,
    );
    return result;
  }

  /// Abre a câmera e captura uma foto.
  Future<XFile?> capturePhoto() =>
      _picker.pickImage(source: ImageSource.camera, imageQuality: 85);

  /// Abre a galeria e retorna um vídeo.
  Future<XFile?> pickVideo() =>
      _picker.pickVideo(source: ImageSource.gallery);

  /// Abre a câmera e grava um vídeo.
  Future<XFile?> captureVideo() =>
      _picker.pickVideo(source: ImageSource.camera);

  /// Galeria mista (fotos + vídeos).
  Future<List<XFile>> pickMedia({int maxItems = 10}) async {
    final result = await _picker.pickMultipleMedia(limit: maxItems);
    return result;
  }
}
