import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'image_editor_result.dart';
import 'image_editor_view.dart';

class ImageEditorService {
  const ImageEditorService._();

  static Future<String?> pickEditAndSave({
    required BuildContext context,
    required String folderName,
    required String filePrefix,
    ImageCropPreset initialPreset = ImageCropPreset.free,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final bytes =
        file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());
    if (bytes == null) {
      return null;
    }
    if (!context.mounted) {
      return null;
    }

    final edited = await ImageEditorView.open(
      context: context,
      bytes: bytes,
      sourceName: file.name,
      initialPreset: initialPreset,
    );
    if (edited == null) {
      return null;
    }

    final directory = await getApplicationDocumentsDirectory();
    final mediaDirectory = Directory('${directory.path}/$folderName');
    if (!await mediaDirectory.exists()) {
      await mediaDirectory.create(recursive: true);
    }
    final path =
        '${mediaDirectory.path}/${filePrefix}_${DateTime.now().microsecondsSinceEpoch}.${edited.extension}';
    await File(path).writeAsBytes(edited.bytes);
    return path;
  }
}
