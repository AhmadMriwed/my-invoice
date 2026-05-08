import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;

import 'image_editor_result.dart';

class ImageEditorController extends GetxController {
  ImageEditorController({
    required this.sourceBytes,
    required this.sourceName,
    this.initialPreset = ImageCropPreset.free,
  });

  final Uint8List sourceBytes;
  final String sourceName;
  final ImageCropPreset initialPreset;

  final cropPreset = ImageCropPreset.free.obs;
  final background = ImageEditorBackground.transparent.obs;
  final zoom = 1.0.obs;
  final rotationTurns = 0.obs;
  final tiltDegrees = 0.0.obs;
  final offset = Offset.zero.obs;
  final isExporting = false.obs;
  double sourceAspectRatio = 1;

  @override
  void onInit() {
    super.onInit();
    cropPreset.value = initialPreset;
    final decoded = img.decodeImage(sourceBytes);
    if (decoded != null && decoded.height > 0) {
      sourceAspectRatio = decoded.width / decoded.height;
    }
  }

  void setPreset(ImageCropPreset value) {
    cropPreset.value = value;
  }

  void rotateLeft() {
    rotationTurns.value = (rotationTurns.value - 1) % 4;
  }

  void rotateRight() {
    rotationTurns.value = (rotationTurns.value + 1) % 4;
  }

  void updateOffset(Offset delta) {
    offset.value += delta;
  }

  void reset() {
    cropPreset.value = initialPreset;
    background.value = ImageEditorBackground.transparent;
    zoom.value = 1;
    rotationTurns.value = 0;
    tiltDegrees.value = 0;
    offset.value = Offset.zero;
  }

  Future<ImageEditorResult?> export() async {
    isExporting.value = true;
    try {
      final decoded = img.decodeImage(sourceBytes);
      if (decoded == null) {
        return null;
      }

      var image = img.bakeOrientation(decoded);
      final totalAngle = (rotationTurns.value * 90) + tiltDegrees.value;
      if (totalAngle.abs() > 0.01) {
        image = img.copyRotate(
          image,
          angle: totalAngle,
          interpolation: img.Interpolation.cubic,
        );
      }

      image = _cropForCurrentTransform(image);
      if (cropPreset.value == ImageCropPreset.circle) {
        image = _applyCircleMask(image);
      }
      image = _applyBackground(image);

      final encoded = Uint8List.fromList(img.encodePng(image));
      return ImageEditorResult(
        bytes: encoded,
        extension: 'png',
        width: image.width,
        height: image.height,
      );
    } finally {
      isExporting.value = false;
    }
  }

  img.Image _cropForCurrentTransform(img.Image source) {
    final aspect = cropAspectRatio(cropPreset.value);
    var cropWidth = source.width / zoom.value.clamp(1, 4);
    var cropHeight = source.height / zoom.value.clamp(1, 4);

    if (aspect != null) {
      if (cropWidth / cropHeight > aspect) {
        cropWidth = cropHeight * aspect;
      } else {
        cropHeight = cropWidth / aspect;
      }
    }

    final maxDx = (source.width - cropWidth) / 2;
    final maxDy = (source.height - cropHeight) / 2;
    final dx = offset.value.dx.clamp(-120.0, 120.0) / 120.0 * maxDx;
    final dy = offset.value.dy.clamp(-120.0, 120.0) / 120.0 * maxDy;
    final x = ((source.width - cropWidth) / 2 - dx)
        .clamp(0.0, source.width - 1.0)
        .round();
    final y = ((source.height - cropHeight) / 2 - dy)
        .clamp(0.0, source.height - 1.0)
        .round();

    return img.copyCrop(
      source,
      x: x,
      y: y,
      width: math.max(1, cropWidth.round()),
      height: math.max(1, cropHeight.round()),
    );
  }

  img.Image _applyBackground(img.Image source) {
    final color = backgroundColor(background.value);
    if (color == null) {
      return source;
    }
    final canvas = img.Image(
      width: source.width,
      height: source.height,
      numChannels: 4,
    );
    canvas.clear(_toImageColor(color));
    return img.compositeImage(canvas, source);
  }

  img.Image _applyCircleMask(img.Image source) {
    final side = math.min(source.width, source.height);
    final cropped = img.copyCrop(
      source,
      x: ((source.width - side) / 2).round(),
      y: ((source.height - side) / 2).round(),
      width: side,
      height: side,
    );
    final radius = side / 2;
    final center = radius - 0.5;
    for (var y = 0; y < side; y++) {
      for (var x = 0; x < side; x++) {
        final dx = x - center;
        final dy = y - center;
        if ((dx * dx) + (dy * dy) > radius * radius) {
          cropped.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }
    }
    return cropped;
  }

  static double? cropAspectRatio(ImageCropPreset preset) {
    return switch (preset) {
      ImageCropPreset.free => null,
      ImageCropPreset.square => 1,
      ImageCropPreset.ratio4x3 => 4 / 3,
      ImageCropPreset.ratio16x9 => 16 / 9,
      ImageCropPreset.circle => 1,
    };
  }

  static Color? backgroundColor(ImageEditorBackground value) {
    return switch (value) {
      ImageEditorBackground.transparent => null,
      ImageEditorBackground.black => Colors.black,
      ImageEditorBackground.white => Colors.white,
      ImageEditorBackground.gold => const Color(0xFFD4A64A),
      ImageEditorBackground.darkGold => const Color(0xFF9E6F1D),
      ImageEditorBackground.blue => const Color(0xFF1E88E5),
    };
  }

  static img.ColorRgba8 _toImageColor(Color color) {
    return img.ColorRgba8(
      (color.r * 255).round(),
      (color.g * 255).round(),
      (color.b * 255).round(),
      (color.a * 255).round(),
    );
  }
}
