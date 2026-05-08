import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'image_editor_controller.dart';
import 'image_editor_result.dart';

class ImageBackgroundTools extends StatelessWidget {
  const ImageBackgroundTools({required this.controller, super.key});

  final ImageEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: ImageEditorBackground.values.map((option) {
          final selected = controller.background.value == option;
          final color = ImageEditorController.backgroundColor(option);
          return Tooltip(
            message: option.name.tr,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => controller.background.value = option,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: selected ? const Color(0xFFD4A64A) : Colors.white24,
                    width: selected ? 2.2 : 1,
                  ),
                ),
                child: color == null
                    ? const Icon(Icons.texture, color: Colors.white70, size: 18)
                    : selected
                    ? const Icon(Icons.check, color: Colors.black, size: 16)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
