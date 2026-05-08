import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/storage/hive_boxes.dart';
import '../../../core/storage/hive_service.dart';
import '../../customers/model/customer.dart';
import '../../invoices/model/invoice.dart';
import '../../invoices/model/invoice_item.dart';
import '../../settings/controller/settings_controller.dart';
import '../../shop/model/shop_info.dart';
import '../widgets/temporary_customer_dialog.dart';

class InvoiceFormController extends GetxController {
  final _hiveService = Get.find<HiveService>();
  final _settingsController = Get.find<SettingsController>();

  final customers = <Customer>[].obs;
  final selectedCustomer = Rxn<Customer>();
  final shopInfo = ShopInfo.fromMap(null).obs;
  final items = <InvoiceItem>[].obs;
  final invoiceDate = DateTime.now().obs;
  final discountController = TextEditingController(text: '0');
  final taxController = TextEditingController(text: '0');
  final notesController = TextEditingController();
  final isSaving = false.obs;

  Invoice? editingInvoice;
  late String invoiceNumber;

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);

  double get discount =>
      _nonNegative(double.tryParse(discountController.text.trim()) ?? 0);

  double get tax =>
      _nonNegative(double.tryParse(taxController.text.trim()) ?? 0);

  double get finalTotal => subtotal - discount + tax;

  @override
  void onInit() {
    super.onInit();
    loadData();
    invoiceNumber = _settingsController.allocateInvoiceNumber();
    final invoiceId = Get.arguments?.toString();
    if (invoiceId != null && invoiceId.isNotEmpty) {
      loadInvoice(invoiceId);
    }
  }

  void loadData() {
    shopInfo.value = ShopInfo.fromMap(
      _hiveService.shopInfoBox.get(HiveBoxes.shopInfo)
          as Map<dynamic, dynamic>?,
    );
    customers.assignAll(
      _hiveService.customersBox.values
          .whereType<Map<dynamic, dynamic>>()
          .map(Customer.fromMap)
          .toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName)),
    );
    if (editingInvoice == null) {
      final appSettings = _settingsController.settings.value;
      taxController.text = '${appSettings.defaultTaxPercent}';
      discountController.text = '${appSettings.defaultDiscountPercent}';
      notesController.text = appSettings.notesTemplate;
    }
  }

  void loadInvoice(String invoiceId) {
    final raw = _hiveService.invoicesBox.get(invoiceId);
    if (raw is! Map<dynamic, dynamic>) {
      return;
    }
    final invoice = Invoice.fromMap(raw);
    editingInvoice = invoice;
    invoiceNumber = invoice.invoiceNumber;
    invoiceDate.value = invoice.date;
    items.assignAll(invoice.items);
    discountController.text = invoice.discount.toStringAsFixed(2);
    taxController.text = invoice.tax.toStringAsFixed(2);
    notesController.text = invoice.notes;
    final persistedCustomer = customers.firstWhereOrNull(
      (customer) => customer.id == invoice.customerId,
    );
    selectedCustomer.value =
        persistedCustomer ??
        Customer(
          id: invoice.customerId.isEmpty
              ? 'temp-${invoice.id}'
              : invoice.customerId,
          fullName: invoice.customerName,
          createdAt: invoice.createdAt,
          updatedAt: invoice.updatedAt,
        );
  }

  void selectCustomer(Customer? customer) {
    selectedCustomer.value = customer;
  }

  Future<void> createTemporaryCustomer() async {
    final choice = await Get.dialog<String>(
      AlertDialog(
        title: Text('create_customer'.tr),
        content: Text('save_customer_choice'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: 'temporary'),
            child: Text('use_only_invoice'.tr),
          ),
          FilledButton(
            onPressed: () => Get.back(result: 'save'),
            child: Text('save_permanently'.tr),
          ),
        ],
      ),
    );

    if (choice == 'save') {
      final customer = await Get.toNamed<Customer>(AppRoutes.customerForm);
      if (customer != null) {
        loadData();
        selectedCustomer.value = customer;
      }
      return;
    }

    if (choice == 'temporary') {
      final customer = await Get.dialog<Customer>(
        const TemporaryCustomerDialog(),
      );
      if (customer != null) {
        selectedCustomer.value = customer;
      }
    }
  }

  void editSelectedCustomer() {
    final customer = selectedCustomer.value;
    if (customer == null) {
      return;
    }
    if (customer.id.startsWith('temp-')) {
      Get.snackbar('temporary_customer'.tr, 'temporary_customer_message'.tr);
      return;
    }
    Get.toNamed(AppRoutes.customerForm, arguments: customer.id)?.then((_) {
      loadData();
      selectedCustomer.value = customers.firstWhereOrNull(
        (item) => item.id == customer.id,
      );
    });
  }

  void editShopInfo() {
    Get.toNamed(AppRoutes.shop)?.then((_) => loadData());
  }

  Future<void> pickDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: invoiceDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      invoiceDate.value = selectedDate;
    }
  }

  void addOrUpdateItem(InvoiceItem item) {
    final index = items.indexWhere((current) => current.id == item.id);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.add(item);
    }
    items.refresh();
  }

  void deleteItem(InvoiceItem item) {
    items.removeWhere((current) => current.id == item.id);
  }

  void updateQuantity(InvoiceItem item, String value) {
    final quantity = double.tryParse(value.trim());
    if (quantity == null || quantity <= 0) {
      return;
    }
    addOrUpdateItem(
      item.copyWith(quantity: quantity, updatedAt: DateTime.now()),
    );
  }

  void increaseQuantity(InvoiceItem item) {
    addOrUpdateItem(
      item.copyWith(quantity: item.safeQuantity + 1, updatedAt: DateTime.now()),
    );
  }

  void decreaseQuantity(InvoiceItem item) {
    if (item.safeQuantity <= 1) {
      return;
    }
    addOrUpdateItem(
      item.copyWith(quantity: item.safeQuantity - 1, updatedAt: DateTime.now()),
    );
  }

  Invoice buildInvoice({InvoiceStatus status = InvoiceStatus.saved}) {
    final now = DateTime.now();
    final customer = selectedCustomer.value;
    return Invoice(
      id: editingInvoice?.id ?? now.microsecondsSinceEpoch.toString(),
      invoiceNumber: invoiceNumber,
      customerId: customer?.id ?? '',
      customerName: customer?.fullName ?? 'walk_in_customer'.tr,
      date: invoiceDate.value,
      createdAt: editingInvoice?.createdAt ?? now,
      updatedAt: now,
      items: items.toList(),
      status: status,
      discount: discount,
      tax: tax,
      notes: notesController.text.trim(),
    );
  }

  Future<void> saveInvoice({InvoiceStatus status = InvoiceStatus.saved}) async {
    if (selectedCustomer.value == null) {
      Get.snackbar('select_customer'.tr, 'customer_required'.tr);
      return;
    }
    if (items.isEmpty) {
      Get.snackbar('add_products'.tr, 'product_required'.tr);
      return;
    }

    isSaving.value = true;
    final invoice = buildInvoice(status: status);
    await _hiveService.invoicesBox.put(invoice.id, invoice.toMap());
    await _hiveService.box(HiveBoxes.draftInvoices).delete(invoice.id);
    if (editingInvoice == null) {
      await _settingsController.markInvoiceNumberUsed(invoice.invoiceNumber);
    }
    isSaving.value = false;
    Get.back(result: invoice);
    Get.snackbar(
      'saved'.tr,
      'invoice_saved_message'.trParams({'number': invoice.invoiceNumber}),
    );
  }

  Future<void> saveDraft() async {
    if (selectedCustomer.value == null) {
      Get.snackbar('select_customer'.tr, 'customer_required'.tr);
      return;
    }
    if (items.isEmpty) {
      Get.snackbar('add_products'.tr, 'product_required'.tr);
      return;
    }
    final invoice = buildInvoice(status: InvoiceStatus.draft);
    await _hiveService.draftInvoicesBox.put(invoice.id, invoice.toMap());
    Get.snackbar('draft_saved'.tr, 'draft_saved_message'.tr);
  }

  void openPdfPreview() {
    if (selectedCustomer.value == null) {
      Get.snackbar('select_customer'.tr, 'customer_required'.tr);
      return;
    }
    if (items.isEmpty) {
      Get.snackbar('add_products'.tr, 'product_required'.tr);
      return;
    }
    Get.toNamed(AppRoutes.pdfPreview, arguments: buildInvoice());
  }

  double _nonNegative(double value) {
    if (value.isNaN || value.isInfinite || value < 0) {
      return 0;
    }
    return value;
  }

  @override
  void onClose() {
    discountController.dispose();
    taxController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
