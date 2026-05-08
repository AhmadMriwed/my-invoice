import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/shop/view/shop_view.dart';
import 'image_editor_controller.dart';
import 'image_editor_result.dart';

class ImageCropperWidget extends StatelessWidget {
  const ImageCropperWidget({
    required this.controller,
    required this.bytes,
    super.key,
  });

  final ImageEditorController controller;
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Obx(() {
          final preset = controller.cropPreset.value;
          final background = controller.background.value;
          final offset = controller.offset.value;
          final rotationTurns = controller.rotationTurns.value;
          final tiltDegrees = controller.tiltDegrees.value;
          final zoom = controller.zoom.value;
          final cropSize = _cropSize(size, preset);
          final bg = ImageEditorController.backgroundColor(background);
          return GestureDetector(
            onPanUpdate: (details) => controller.updateOffset(details.delta),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    painter: const CheckerboardPainter(),
                    child:      AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: cropSize.width,
                      height: cropSize.height,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: preset == ImageCropPreset.circle
                            ? BorderRadius.circular(cropSize.shortestSide / 2)
                            : BorderRadius.circular(18),
                      ),

                      clipBehavior: Clip.antiAlias,
                      child: ClipPath(
                        clipper: _CropClipper(preset),
                        child: Transform.translate(
                          offset: offset,
                          child: Transform.rotate(
                            angle:
                            (rotationTurns * math.pi / 2) +
                                (tiltDegrees * math.pi / 180),
                            child: Transform.scale(
                              scale: zoom,
                              child: Hero(
                                tag: 'image-editor-${controller.sourceName}',
                                child: Image.memory(bytes, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Positioned.fill(
                  //   child: ColoredBox(
                  //     color: Colors.white.withValues(alpha: 0.42),
                  //   ),
                  // ),

                  IgnorePointer(
                    child: SizedBox(
                      width: cropSize.width,
                      height: cropSize.height,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blueGrey.withValues(alpha: 0.92),
                            width: 4.4,
                            // width: 1.4,
                          ),
                          borderRadius: preset == ImageCropPreset.circle
                              ? BorderRadius.circular(cropSize.shortestSide / 2)
                              : BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Size _cropSize(Size available, ImageCropPreset preset) {
    final maxWidth = available.width * 0.88;
    final maxHeight = available.height * 0.84;
    final aspect =
        ImageEditorController.cropAspectRatio(preset) ??
        controller.sourceAspectRatio;
    var width = maxWidth;
    var height = width / aspect;
    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspect;
    }
    return Size(width, height);
  }
}

class _CropClipper extends CustomClipper<Path> {
  const _CropClipper(this.preset);

  final ImageCropPreset preset;

  @override
  Path getClip(Size size) {
    if (preset == ImageCropPreset.circle) {
      return Path()..addOval(
        Rect.fromCircle(
          center: size.center(Offset.zero),
          radius: size.shortestSide / 2,
        ),
      );
    }
    return Path()..addRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)),
    );
  }

  @override
  bool shouldReclip(covariant _CropClipper oldClipper) {
    return oldClipper.preset != preset;
  }
}
