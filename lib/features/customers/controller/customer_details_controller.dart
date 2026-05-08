import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/storage/hive_service.dart';
import '../../invoices/model/invoice.dart';
import '../model/customer.dart';

class CustomerDetailsController extends GetxController {
  final _hiveService = Get.find<HiveService>();
  final customer = Rxn<Customer>();
  final invoices = <Invoice>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomer();
  }

  void loadCustomer() {
    final customerId = Get.arguments?.toString();
    final raw = _hiveService.customersBox.get(customerId);
    if (raw is Map<dynamic, dynamic>) {
      customer.value = Customer.fromMap(raw);
      invoices.assignAll(
        _hiveService.invoicesBox.values
            .whereType<Map<dynamic, dynamic>>()
            .map(Invoice.fromMap)
            .where((invoice) => invoice.customerId == customerId)
            .toList(),
      );
    }
  }

  void editCustomer() {
    final current = customer.value;
    if (current == null) {
      return;
    }
    Get.toNamed(
      AppRoutes.customerForm,
      arguments: current.id,
    )?.then((_) => loadCustomer());
  }

  Future<void> deleteCustomer() async {
    final current = customer.value;
    if (current == null) {
      return;
    }

    await _hiveService.customersBox.delete(current.id);
    Get.back();
    Get.snackbar(
      'deleted'.tr,
      'customer_removed_message'.trParams({'name': current.fullName}),
    );
  }
}
