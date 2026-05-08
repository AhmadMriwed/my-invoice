import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../utils/screen_utils.dart';
import 'image_background_tools.dart';
import 'image_cropper_widget.dart';
import 'image_editor_controller.dart';
import 'image_editor_result.dart';
import 'image_transform_tools.dart';

class ImageEditorView extends StatefulWidget {
  const ImageEditorView({
    required this.bytes,
    required this.sourceName,
    this.initialPreset = ImageCropPreset.free,
    super.key,
  });

  final Uint8List bytes;
  final String sourceName;
  final ImageCropPreset initialPreset;

  static Future<ImageEditorResult?> open({
    required BuildContext context,
    required Uint8List bytes,
    required String sourceName,
    ImageCropPreset initialPreset = ImageCropPreset.free,
  }) async {
    final editor = ImageEditorView(
      bytes: bytes,
      sourceName: sourceName,
      initialPreset: initialPreset,
    );
    if (ScreenUtils.isMobile(context)) {
      return Get.dialog<ImageEditorResult>(
        Dialog.fullscreen(child: editor),
        barrierDismissible: false,
      );
    }
    return Get.dialog<ImageEditorResult>(
      Dialog(
        insetPadding: const EdgeInsets.all(24),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080, maxHeight: 820),
          child: editor,
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  State<ImageEditorView> createState() => _ImageEditorViewState();
}

class _ImageEditorViewState extends State<ImageEditorView> {
  late final ImageEditorController controller;

  @override
  void initState() {
    super.initState();
    controller = ImageEditorController(
      sourceBytes: widget.bytes,
      sourceName: widget.sourceName,
      initialPreset: widget.initialPreset,
    )..onInit();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenUtils.isDesktop(context);
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4A64A),
          brightness: Brightness.dark,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF09090B),
        appBar: AppBar(
          backgroundColor: const Color(0xFF09090B),
          title: Text('edit_image'.tr),
          leading: IconButton(
            tooltip: 'cancel'.tr,
            onPressed: Get.back,
            icon: const Icon(Icons.close),
          ),
          actions: [
            TextButton.icon(
              onPressed: controller.reset,
              icon: const Icon(Icons.restart_alt),
              label: Text('reset'.tr),
            ),
            const SizedBox(width: 8),
            Obx(
              () => FilledButton.icon(
                onPressed: controller.isExporting.value ? null : _apply,
                icon: controller.isExporting.value
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text('apply'.tr),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: isDesktop
              ? Row(
                  children: [
                    Expanded(
                      child: _Preview(controller: controller, widget: widget),
                    ),
                    SizedBox(
                      width: 330,
                      child: _ToolsPanel(controller: controller),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: _Preview(controller: controller, widget: widget),
                    ),
                    _ToolsPanel(controller: controller),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _apply() async {
    HapticFeedback.mediumImpact();
    final result = await controller.export();
    if (result != null) {
      Get.back(result: result);
    }
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.controller, required this.widget});

  final ImageEditorController controller;
  final ImageEditorView widget;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(18),
      child: ImageCropperWidget(controller: controller, bytes: widget.bytes),
    );
  }
}

class _ToolsPanel extends StatelessWidget {
  const _ToolsPanel({required this.controller});

  final ImageEditorController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF121217),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          left: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('crop'.tr, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            CropPresetTools(controller: controller),
            const SizedBox(height: 18),
            Text('transform'.tr, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            ImageTransformTools(controller: controller),
            const SizedBox(height: 18),
            Text(
              'background'.tr,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            ImageBackgroundTools(controller: controller),
          ],
        ),
      ),
    );
  }
}
