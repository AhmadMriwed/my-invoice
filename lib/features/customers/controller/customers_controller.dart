import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/storage/hive_service.dart';
import '../../invoices/model/invoice.dart';
import '../model/customer.dart';

class CustomersController extends GetxController {
  final _hiveService = Get.find<HiveService>();

  final customers = <Customer>[].obs;
  final query = ''.obs;

  List<Customer> get filteredCustomers {
    final value = query.value.trim().toLowerCase();
    if (value.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      return customer.fullName.toLowerCase().contains(value) ||
          customer.phone.toLowerCase().contains(value) ||
          customer.city.toLowerCase().contains(value);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  void loadCustomers() {
    customers.assignAll(
      _hiveService.customersBox.values
          .whereType<Map<dynamic, dynamic>>()
          .map(Customer.fromMap)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  int invoiceCountFor(String customerId) {
    return _hiveService.invoicesBox.values
        .whereType<Map<dynamic, dynamic>>()
        .map(Invoice.fromMap)
        .where((invoice) => invoice.customerId == customerId)
        .length;
  }

  void openCreate() {
    Get.toNamed(AppRoutes.customerForm)?.then((_) => loadCustomers());
  }

  void openEdit(Customer customer) {
    Get.toNamed(
      AppRoutes.customerForm,
      arguments: customer.id,
    )?.then((_) => loadCustomers());
  }

  void openDetails(Customer customer) {
    Get.toNamed(
      AppRoutes.customerDetails,
      arguments: customer.id,
    )?.then((_) => loadCustomers());
  }

  Future<void> deleteCustomer(Customer customer) async {
    await _hiveService.customersBox.delete(customer.id);
    loadCustomers();
    Get.snackbar(
      'deleted'.tr,
      'customer_removed_message'.trParams({'name': customer.fullName}),
    );
  }
}
