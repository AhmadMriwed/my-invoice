import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../core/storage/hive_service.dart';
import '../model/shop_info.dart';

class ShopController extends GetxController {
  final _hiveService = Get.find<HiveService>();
  final formKey = GlobalKey<FormState>();

  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final taxNumberController = TextEditingController();
  final logoPathController = TextEditingController();
  final currencyController = TextEditingController();
  final notesController = TextEditingController();

  final shopInfo = ShopInfo.fromMap(null).obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadShopInfo();
  }

  void loadShopInfo() {
    final raw = _hiveService.shopInfoBox.get(HiveBoxes.shopInfo);
    final info = ShopInfo.fromMap(raw as Map<dynamic, dynamic>?);
    shopInfo.value = info;
    shopNameController.text = info.shopName;
    ownerNameController.text = info.ownerName;
    phoneController.text = info.phoneNumber;
    emailController.text = info.email;
    addressController.text = info.address;
    taxNumberController.text = info.taxNumber;
    logoPathController.text = info.logoPath;
    currencyController.text = info.currency;
    notesController.text = info.notes;
  }

  Future<void> saveShopInfo() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isSaving.value = true;
    final now = DateTime.now();
    final info = ShopInfo(
      id: shopInfo.value.id,
      createdAt: shopInfo.value.createdAt,
      updatedAt: now,
      shopName: shopNameController.text.trim(),
      ownerName: ownerNameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      email: emailController.text.trim(),
      address: addressController.text.trim(),
      taxNumber: taxNumberController.text.trim(),
      logoPath: logoPathController.text.trim(),
      currency: currencyController.text.trim().isEmpty
          ? r'$'
          : currencyController.text.trim(),
      notes: notesController.text.trim(),
    );

    await _hiveService.shopInfoBox.put(HiveBoxes.shopInfo, info.toMap());
    shopInfo.value = info;
    isSaving.value = false;
    Get.snackbar('saved'.tr, 'shop_information_saved'.tr);
  }

  void useLogoPlaceholder() {
    logoPathController.text = 'assets/images/splash_logo.png';
  }

  @override
  void onClose() {
    shopNameController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    taxNumberController.dispose();
    logoPathController.dispose();
    currencyController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
