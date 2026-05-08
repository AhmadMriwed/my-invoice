import 'dart:typed_data';

class ImageEditorResult {
  const ImageEditorResult({
    required this.bytes,
    required this.extension,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final String extension;
  final int width;
  final int height;
}

enum ImageCropPreset { free, square, ratio4x3, ratio16x9, circle }

enum ImageEditorBackground { transparent, black, white, gold, darkGold, blue }
