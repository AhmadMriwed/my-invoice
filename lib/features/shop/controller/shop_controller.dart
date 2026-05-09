import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/image_editor/image_editor_result.dart';
import '../../../core/image_editor/image_editor_service.dart';
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
  final coverPathController = TextEditingController();
  final sealPathController = TextEditingController();
  final signaturePathController = TextEditingController();
  final currencyController = TextEditingController();
  final notesController = TextEditingController();

  final shopInfo = ShopInfo.fromMap(null).obs;
  final isSaving = false.obs;
  final logoPreviewPath = ''.obs;
  final coverPreviewPath = ''.obs;
  final sealPreviewPath = ''.obs;
  final signaturePreviewPath = ''.obs;

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
    coverPathController.text = info.coverPath;
    sealPathController.text = info.sealPath;
    signaturePathController.text = info.signaturePath;
    logoPreviewPath.value = info.logoPath.isEmpty
        ? AppImages.defaultShopLogo
        : info.logoPath;
    coverPreviewPath.value = info.coverPath.isEmpty
        ? AppImages.banner
        : info.coverPath;
    sealPreviewPath.value = info.sealPath.isEmpty
        ? AppImages.defaultSeal
        : info.sealPath;
    signaturePreviewPath.value = info.signaturePath.isEmpty
        ? AppImages.defaultSignature
        : info.signaturePath;
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
      coverPath: coverPathController.text.trim(),
      sealPath: sealPathController.text.trim(),
      signaturePath: signaturePathController.text.trim(),
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
    logoPathController.text = AppImages.defaultShopLogo;
    logoPreviewPath.value = AppImages.defaultShopLogo;
  }

  void useCoverPlaceholder() {
    coverPathController.text = AppImages.banner;
    coverPreviewPath.value = AppImages.banner;
  }

  void useSealPlaceholder() {
    sealPathController.text = AppImages.defaultSeal;
    sealPreviewPath.value = AppImages.defaultSeal;
  }

  void useSignaturePlaceholder() {
    signaturePathController.text = AppImages.defaultSignature;
    signaturePreviewPath.value = AppImages.defaultSignature;
  }

  Future<void> pickLogoImage(BuildContext context) async {
    final path = await ImageEditorService.pickEditAndSave(
      context: context,
      folderName: 'shop_media',
      filePrefix: 'logo',
      initialPreset: ImageCropPreset.square,
    );
    if (path != null) {
      logoPathController.text = path;
      logoPreviewPath.value = path;
    }
  }

  Future<void> pickCoverImage(BuildContext context) async {
    final path = await ImageEditorService.pickEditAndSave(
      context: context,
      folderName: 'shop_media',
      filePrefix: 'cover',
      initialPreset: ImageCropPreset.ratio16x9,
    );
    if (path != null) {
      coverPathController.text = path;
      coverPreviewPath.value = path;
    }
  }

  Future<void> pickSealImage(BuildContext context) async {
    final path = await ImageEditorService.pickEditAndSave(
      context: context,
      folderName: 'shop_media',
      filePrefix: 'seal',
      initialPreset: ImageCropPreset.square,
    );
    if (path != null) {
      sealPathController.text = path;
      sealPreviewPath.value = path;
    }
  }

  Future<void> pickSignatureImage(BuildContext context) async {
    final path = await ImageEditorService.pickEditAndSave(
      context: context,
      folderName: 'shop_media',
      filePrefix: 'signature',
      initialPreset: ImageCropPreset.ratio16x9,
    );
    if (path != null) {
      signaturePathController.text = path;
      signaturePreviewPath.value = path;
    }
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
    coverPathController.dispose();
    sealPathController.dispose();
    signaturePathController.dispose();
    currencyController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
