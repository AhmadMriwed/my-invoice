import 'package:flutter/material.dart';
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
  final customerFilter = ''.obs;
  final statusFilter = 'all'.obs;
  final minPrice = RxnDouble();
  final maxPrice = RxnDouble();
  final dateFrom = Rxn<DateTime>();
  final dateTo = Rxn<DateTime>();
  final queryController = TextEditingController();
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();

  List<String> get customerOptions {
    final names =
        invoices
            .map((invoice) => invoice.customerName.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return names;
  }

  List<Invoice> get filteredInvoices {
    final value = query.value.trim().toLowerCase();
    final customerValue = customerFilter.value.trim().toLowerCase();
    return invoices.where((invoice) {
      final matchesQuery =
          value.isEmpty ||
          invoice.invoiceNumber.toLowerCase().contains(value) ||
          invoice.customerName.toLowerCase().contains(value);
      final matchesCustomer =
          customerValue.isEmpty ||
          invoice.customerName.toLowerCase().contains(customerValue);
      final matchesStatus =
          statusFilter.value == 'all' ||
          invoice.status.name == statusFilter.value;
      final matchesMin =
          minPrice.value == null || invoice.finalTotal >= minPrice.value!;
      final matchesMax =
          maxPrice.value == null || invoice.finalTotal <= maxPrice.value!;
      final invoiceDate = _dateOnly(invoice.date);
      final matchesDateFrom =
          dateFrom.value == null ||
          !invoiceDate.isBefore(_dateOnly(dateFrom.value!));
      final matchesDateTo =
          dateTo.value == null ||
          !invoiceDate.isAfter(_dateOnly(dateTo.value!));
      return matchesQuery &&
          matchesCustomer &&
          matchesStatus &&
          matchesMin &&
          matchesMax &&
          matchesDateFrom &&
          matchesDateTo;
    }).toList();
  }

  void setDateFrom(DateTime? value) {
    dateFrom.value = value;
    if (value != null &&
        dateTo.value != null &&
        dateTo.value!.isBefore(value)) {
      dateTo.value = value;
    }
  }

  void setDateTo(DateTime? value) {
    dateTo.value = value;
    if (value != null &&
        dateFrom.value != null &&
        dateFrom.value!.isAfter(value)) {
      dateFrom.value = value;
    }
  }

  void resetFilters() {
    queryController.clear();
    query.value = '';
    resetAdvancedFilters();
  }

  void resetAdvancedFilters() {
    minPriceController.clear();
    maxPriceController.clear();
    customerFilter.value = '';
    statusFilter.value = 'all';
    minPrice.value = null;
    maxPrice.value = null;
    dateFrom.value = null;
    dateTo.value = null;
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
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
    if (customerFilter.value.isNotEmpty &&
        !customerOptions.contains(customerFilter.value)) {
      customerFilter.value = '';
    }
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

  @override
  void onClose() {
    queryController.dispose();
    minPriceController.dispose();
    maxPriceController.dispose();
    super.onClose();
  }
}
