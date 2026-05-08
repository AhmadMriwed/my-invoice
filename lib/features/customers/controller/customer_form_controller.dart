import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/storage/hive_service.dart';
import '../model/customer.dart';

class CustomerFormController extends GetxController {
  final _hiveService = Get.find<HiveService>();
  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final alternativePhoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final notesController = TextEditingController();

  final isSaving = false.obs;
  Customer? editingCustomer;

  bool get isEditing => editingCustomer != null;

  @override
  void onInit() {
    super.onInit();
    final customerId = Get.arguments?.toString();
    if (customerId != null && customerId.isNotEmpty) {
      _loadCustomer(customerId);
    }
  }

  void _loadCustomer(String customerId) {
    final raw = _hiveService.customersBox.get(customerId);
    if (raw is! Map<dynamic, dynamic>) {
      return;
    }

    final customer = Customer.fromMap(raw);
    editingCustomer = customer;
    fullNameController.text = customer.fullName;
    phoneController.text = customer.phone;
    alternativePhoneController.text = customer.alternativePhone;
    emailController.text = customer.email;
    addressController.text = customer.address;
    cityController.text = customer.city;
    notesController.text = customer.notes;
  }

  Future<void> saveCustomer() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isSaving.value = true;
    final now = DateTime.now();
    final customer = Customer(
      id: editingCustomer?.id ?? now.microsecondsSinceEpoch.toString(),
      fullName: fullNameController.text.trim(),
      phone: phoneController.text.trim(),
      alternativePhone: alternativePhoneController.text.trim(),
      email: emailController.text.trim(),
      address: addressController.text.trim(),
      city: cityController.text.trim(),
      notes: notesController.text.trim(),
      createdAt: editingCustomer?.createdAt ?? now,
      updatedAt: now,
    );

    await _hiveService.customersBox.put(customer.id, customer.toMap());
    isSaving.value = false;
    Get.back(result: customer);
    Get.snackbar('saved'.tr, 'customer_information_saved'.tr);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    alternativePhoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
