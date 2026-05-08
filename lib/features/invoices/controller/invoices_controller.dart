import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/storage/hive_service.dart';
import '../../settings/controller/settings_controller.dart';
import '../model/invoice.dart';

class InvoicesController extends GetxController {
  final _hiveService = Get.find<HiveService>();
  final _settingsController = Get.find<SettingsController>();

  final invoices = <Invoice>[].obs;
  final query = ''.obs;
  final statusFilter = 'all'.obs;
  final minPrice = RxnDouble();
  final maxPrice = RxnDouble();

  List<Invoice> get filteredInvoices {
    final value = query.value.trim().toLowerCase();
    return invoices.where((invoice) {
      final matchesQuery =
          value.isEmpty ||
          invoice.invoiceNumber.toLowerCase().contains(value) ||
          invoice.customerName.toLowerCase().contains(value);
      final matchesStatus =
          statusFilter.value == 'all' ||
          invoice.status.name == statusFilter.value;
      final matchesMin =
          minPrice.value == null || invoice.finalTotal >= minPrice.value!;
      final matchesMax =
          maxPrice.value == null || invoice.finalTotal <= maxPrice.value!;
      return matchesQuery && matchesStatus && matchesMin && matchesMax;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
  }

  void loadInvoices() {
    invoices.assignAll(
      _hiveService.invoicesBox.values
          .whereType<Map<dynamic, dynamic>>()
          .map(Invoice.fromMap)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  void openCreate() {
    Get.toNamed(AppRoutes.invoiceForm)?.then((_) => loadInvoices());
  }

  void openEdit(Invoice invoice) {
    Get.toNamed(
      AppRoutes.invoiceForm,
      arguments: invoice.id,
    )?.then((_) => loadInvoices());
  }

  void openDetails(Invoice invoice) {
    Get.toNamed(
      AppRoutes.invoiceDetails,
      arguments: invoice.id,
    )?.then((_) => loadInvoices());
  }

  Future<void> duplicateInvoice(Invoice invoice) async {
    final now = DateTime.now();
    final duplicate = invoice.copyWith(
      id: now.microsecondsSinceEpoch.toString(),
      invoiceNumber: _settingsController.allocateInvoiceNumber(),
      createdAt: now,
      updatedAt: now,
      date: now,
      status: InvoiceStatus.draft,
    );
    await _hiveService.invoicesBox.put(duplicate.id, duplicate.toMap());
    await _settingsController.markInvoiceNumberUsed(duplicate.invoiceNumber);
    loadInvoices();
    Get.snackbar(
      'duplicated'.tr,
      'invoice_duplicated_message'.trParams({'number': invoice.invoiceNumber}),
    );
  }

  Future<void> deleteInvoice(Invoice invoice) async {
    await _hiveService.invoicesBox.delete(invoice.id);
    loadInvoices();
    Get.snackbar(
      'deleted'.tr,
      'invoice_deleted_message'.trParams({'number': invoice.invoiceNumber}),
    );
  }

  void exportPdf(Invoice invoice) {
    Get.toNamed(AppRoutes.pdfPreview, arguments: invoice);
  }
}
