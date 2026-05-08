import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'image_editor_controller.dart';
import 'image_editor_result.dart';

class ImageTransformTools extends StatelessWidget {
  const ImageTransformTools({required this.controller, super.key});

  final ImageEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _ToolButton(
                icon: Icons.rotate_left,
                tooltip: 'rotate_left'.tr,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  controller.rotateLeft();
                },
              ),
              _ToolButton(
                icon: Icons.rotate_right,
                tooltip: 'rotate_right'.tr,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  controller.rotateRight();
                },
              ),
              _ToolButton(
                icon: Icons.center_focus_strong_outlined,
                tooltip: 'reset_transform'.tr,
                onPressed: controller.reset,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SliderRow(
            icon: Icons.zoom_in_outlined,
            value: controller.zoom.value,
            min: 1,
            max: 4,
            onChanged: (value) => controller.zoom.value = value,
          ),
          _SliderRow(
            icon: Icons.straighten_outlined,
            value: controller.tiltDegrees.value,
            min: -18,
            max: 18,
            onChanged: (value) => controller.tiltDegrees.value = value,
          ),
        ],
      ),
    );
  }
}

class CropPresetTools extends StatelessWidget {
  const CropPresetTools({required this.controller, super.key});

  final ImageEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SegmentedButton<ImageCropPreset>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(value: ImageCropPreset.free, label: Text('free'.tr)),
          const ButtonSegment(
            value: ImageCropPreset.square,
            label: Text('1:1'),
          ),
          const ButtonSegment(
            value: ImageCropPreset.ratio4x3,
            label: Text('4:3'),
          ),
          const ButtonSegment(
            value: ImageCropPreset.ratio16x9,
            label: Text('16:9'),
          ),
          ButtonSegment(
            value: ImageCropPreset.circle,
            label: Text('circle'.tr),
          ),
        ],
        selected: {controller.cropPreset.value},
        onSelectionChanged: (value) => controller.setPreset(value.first),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final IconData icon;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
