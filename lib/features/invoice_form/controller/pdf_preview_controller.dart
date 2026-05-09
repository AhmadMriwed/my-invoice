import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:printing/printing.dart';

import '../../../core/pdf/pdf_options.dart';
import '../../../core/pdf/invoice_pdf_styles.dart';
import '../../../core/storage/hive_boxes.dart';
import '../../../core/storage/hive_service.dart';
import '../../invoices/model/invoice.dart';
import '../../settings/controller/settings_controller.dart';
import '../../settings/model/app_settings.dart';
import '../../shop/model/shop_info.dart';

class PdfPreviewController extends GetxController {
  final _hiveService = Get.find<HiveService>();
  final _settingsController = Get.find<SettingsController>();
  late final Invoice invoice;
  late final ShopInfo shopInfo;
  late final AppSettings appSettings;
  final selectedStyleId = InvoicePdfStyles.defaultStyleId.obs;
  final selectedTheme = InvoicePdfTheme.modern.obs;
  final selectedPaperSize = PaperSizeOption.a4.obs;
  final isSaving = false.obs;
  final isSharing = false.obs;
  final isPrinting = false.obs;
  final savedPdfPath = RxnString();

  @override
  void onInit() {
    super.onInit();
    invoice = Get.arguments as Invoice;
    shopInfo = ShopInfo.fromMap(
      _hiveService.shopInfoBox.get(HiveBoxes.shopInfo)
          as Map<dynamic, dynamic>?,
    );
    appSettings = _settingsController.settings.value;
    selectedStyleId.value = InvoicePdfStyles.normalize(
      appSettings.defaultPdfStyleId,
    );
    selectedTheme.value = appSettings.defaultPdfTheme;
    selectedPaperSize.value = appSettings.paperSize;
  }

  Future<void> savePdf() async {
    isSaving.value = true;
    String? path;
    try {
      final bytes = await InvoicePdfStyles.build(
        invoice,
        shopInfo: shopInfo,
        styleId: selectedStyleId.value,
        theme: selectedTheme.value,
        paperSize: selectedPaperSize.value,
        settings: appSettings,
      );
      final fileName = '${invoice.invoiceNumber}.pdf';
      path = await FilePicker.platform.saveFile(
        dialogTitle: 'save_pdf'.tr,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        bytes: bytes,
      );

      if (path == null) {
        return;
      }
      savedPdfPath.value = path;
    } finally {
      isSaving.value = false;
    }

    Get.snackbar(
      'pdf_saved'.tr,
      path,
      mainButton: TextButton(
        onPressed: () => openSavedPdf(path),
        child: Text('open'.tr),
      ),
    );

    final shouldSaveInvoice = await Get.dialog<bool>(
      AlertDialog(
        title: Text('pdf_saved'.tr),
        content: Text('save_invoice_storage_question'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('do_not_save'.tr),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text('save_invoice'.tr),
          ),
        ],
      ),
    );

    if (shouldSaveInvoice ?? false) {
      await _hiveService.invoicesBox.put(invoice.id, invoice.toMap());
      Get.snackbar('saved'.tr, 'invoice_saved_storage'.tr);
    }
  }

  Future<void> sharePdf() async {
    isSharing.value = true;
    try {
      final bytes = await InvoicePdfStyles.build(
        invoice,
        shopInfo: shopInfo,
        styleId: selectedStyleId.value,
        theme: selectedTheme.value,
        paperSize: selectedPaperSize.value,
        settings: appSettings,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${invoice.invoiceNumber}.pdf',
      );
    } finally {
      isSharing.value = false;
    }
  }

  Future<void> printPdf() async {
    isPrinting.value = true;
    try {
      await Printing.layoutPdf(
        name: invoice.invoiceNumber,
        onLayout: (_) => InvoicePdfStyles.build(
          invoice,
          shopInfo: shopInfo,
          styleId: selectedStyleId.value,
          theme: selectedTheme.value,
          paperSize: selectedPaperSize.value,
          settings: appSettings,
        ),
      );
    } finally {
      isPrinting.value = false;
    }
  }

  Future<void> openSavedPdf([String? path]) async {
    final target = path ?? savedPdfPath.value;
    if (target == null || target.isEmpty) {
      Get.snackbar('no_file'.tr, 'save_pdf_first'.tr);
      return;
    }
    await OpenFilex.open(target);
  }
}
