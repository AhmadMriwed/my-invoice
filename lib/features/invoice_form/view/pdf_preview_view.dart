import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

import '../../../core/pdf/pdf_options.dart';
import '../../../core/pdf/invoice_pdf_styles.dart';
import '../controller/pdf_preview_controller.dart';

class PdfPreviewView extends GetView<PdfPreviewController> {
  const PdfPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'pdf_preview_title'.trParams({
            'number': controller.invoice.invoiceNumber,
          }),
        ),
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'save_pdf'.tr,
              onPressed: controller.isSaving.value ? null : controller.savePdf,
              icon: controller.isSaving.value
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt_outlined),
            ),
          ),
          Obx(
            () => IconButton(
              tooltip: 'share_pdf'.tr,
              onPressed: controller.isSharing.value
                  ? null
                  : controller.sharePdf,
              icon: controller.isSharing.value
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share_outlined),
            ),
          ),
          Obx(
            () => IconButton(
              tooltip: 'print_pdf'.tr,
              onPressed: controller.isPrinting.value
                  ? null
                  : controller.printPdf,
              icon: controller.isPrinting.value
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.print_outlined),
            ),
          ),
          Obx(
            () => IconButton(
              tooltip: 'open_saved_pdf'.tr,
              onPressed: controller.savedPdfPath.value == null
                  ? null
                  : () => controller.openSavedPdf(),
              icon: const Icon(Icons.open_in_new_outlined),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: [
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(controller.selectedStyleId.value),
                        initialValue: controller.selectedStyleId.value,
                        decoration: InputDecoration(
                          labelText: 'pdf_style'.tr,
                          prefixIcon: const Icon(Icons.article_outlined),
                        ),
                        items: InvoicePdfStyles.options
                            .map(
                              (style) => DropdownMenuItem(
                                value: style.id,
                                child: Text(
                                  InvoicePdfStyles.displayName(style),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedStyleId.value = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SegmentedButton<InvoicePdfTheme>(
                      segments: [
                        ButtonSegment(
                          value: InvoicePdfTheme.modern,
                          label: Text('modern'.tr),
                          icon: const Icon(Icons.auto_awesome_outlined),
                        ),
                        ButtonSegment(
                          value: InvoicePdfTheme.minimal,
                          label: Text('minimal'.tr),
                          icon: const Icon(Icons.article_outlined),
                        ),
                        ButtonSegment(
                          value: InvoicePdfTheme.dark,
                          label: Text('dark'.tr),
                          icon: const Icon(Icons.dark_mode_outlined),
                        ),
                      ],
                      selected: {controller.selectedTheme.value},
                      onSelectionChanged: (value) =>
                          controller.selectedTheme.value = value.first,
                    ),
                    const SizedBox(width: 12),
                    SegmentedButton<PaperSizeOption>(
                      segments: [
                        ButtonSegment(
                          value: PaperSizeOption.a4,
                          label: Text('a4'.tr),
                          icon: const Icon(Icons.description_outlined),
                        ),
                        ButtonSegment(
                          value: PaperSizeOption.thermal,
                          label: Text('thermal'.tr),
                          icon: const Icon(Icons.receipt_outlined),
                        ),
                      ],
                      selected: {controller.selectedPaperSize.value},
                      onSelectionChanged: (value) =>
                          controller.selectedPaperSize.value = value.first,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => PdfPreview(
                key: ValueKey(
                  '${controller.selectedStyleId.value}-${controller.selectedTheme.value.name}-${controller.selectedPaperSize.value.name}',
                ),
                canChangeOrientation: false,
                canChangePageFormat: false,
                build: (_) => InvoicePdfStyles.build(
                  controller.invoice,
                  shopInfo: controller.shopInfo,
                  styleId: controller.selectedStyleId.value,
                  theme: controller.selectedTheme.value,
                  paperSize: controller.selectedPaperSize.value,
                  settings: controller.appSettings,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
