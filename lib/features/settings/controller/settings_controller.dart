import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/storage/hive_boxes.dart';
import '../../../core/storage/hive_service.dart';
import '../../invoices/model/invoice.dart';
import '../../invoices/model/invoice_item.dart';
import '../../shop/controller/shop_controller.dart';
import '../../shop/model/shop_info.dart';
import '../model/app_settings.dart';

class SettingsController extends GetxController {
  SettingsController({HiveService? hiveService})
    : _hiveService = hiveService ?? Get.find<HiveService>();

  final HiveService _hiveService;
  final settings = AppSettings.defaults().obs;
  final isSaving = false.obs;
  final isExporting = false.obs;
  final isImporting = false.obs;
  final isClearing = false.obs;
  final isResetting = false.obs;
  final isApplyingDefaultProfile = false.obs;
  final hasUnsavedChanges = false.obs;
  late AppSettings _savedSettings;
  bool _syncingControllers = false;

  final businessNameController = TextEditingController();
  final defaultCurrencyController = TextEditingController();
  final currencySymbolController = TextEditingController();
  final decimalDigitsController = TextEditingController();
  final invoicePrefixController = TextEditingController();
  final startingInvoiceNumberController = TextEditingController();
  final defaultTaxController = TextEditingController();
  final defaultDiscountController = TextEditingController();
  final notesTemplateController = TextEditingController();
  final paymentInstructionsController = TextEditingController();
  final fontSizeScaleController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    final raw = _hiveService.settingsBox.get(HiveBoxes.settings);
    settings.value = AppSettings.fromMap(raw as Map<dynamic, dynamic>?);
    _savedSettings = settings.value;
    _syncControllers();
    _applyRuntimeSettings();
    hasUnsavedChanges.value = false;
  }

  Future<void> saveSettings(
    AppSettings next, {
    bool showSnackbar = true,
  }) async {
    isSaving.value = true;
    settings.value = next;
    await _hiveService.settingsBox.put(HiveBoxes.settings, next.toMap());
    _savedSettings = next;
    _syncControllers();
    _applyRuntimeSettings();
    hasUnsavedChanges.value = false;
    isSaving.value = false;
    if (showSnackbar) {
      Get.snackbar('saved'.tr, 'business_settings_saved'.tr);
    }
  }

  Future<void> saveFromForm() async {
    final current = settings.value;
    final next = current.copyWith(
      businessName: businessNameController.text.trim(),
      defaultCurrency: defaultCurrencyController.text.trim().isEmpty
          ? 'USD'
          : defaultCurrencyController.text.trim(),
      currencySymbol: currencySymbolController.text.trim().isEmpty
          ? r'$'
          : currencySymbolController.text.trim(),
      decimalDigits: _int(decimalDigitsController.text, current.decimalDigits),
      invoicePrefix: invoicePrefixController.text.trim().isEmpty
          ? 'INV'
          : invoicePrefixController.text.trim(),
      startingInvoiceNumber: _int(
        startingInvoiceNumberController.text,
        current.startingInvoiceNumber,
      ),
      nextInvoiceNumber:
          current.nextInvoiceNumber <
              _int(
                startingInvoiceNumberController.text,
                current.startingInvoiceNumber,
              )
          ? _int(
              startingInvoiceNumberController.text,
              current.startingInvoiceNumber,
            )
          : current.nextInvoiceNumber,
      defaultTaxPercent: _double(defaultTaxController.text, 0),
      defaultDiscountPercent: _double(defaultDiscountController.text, 0),
      notesTemplate: notesTemplateController.text.trim(),
      paymentInstructions: paymentInstructionsController.text.trim(),
      fontSizeScale: _double(
        fontSizeScaleController.text,
        1,
      ).clamp(0.8, 1.4).toDouble(),
    );
    await saveSettings(next);
  }

  Future<bool> confirmDiscardChanges() async {
    if (!hasUnsavedChanges.value) {
      return true;
    }
    final result = await Get.dialog<String>(
      AlertDialog(
        title: Text('unsaved_settings_title'.tr),
        content: Text('unsaved_settings_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: 'stay'),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: 'discard'),
            child: Text('discard'.tr),
          ),
          FilledButton(
            onPressed: () => Get.back(result: 'save'),
            child: Text('save'.tr),
          ),
        ],
      ),
    );

    if (result == 'save') {
      await saveFromForm();
      return true;
    }
    if (result == 'discard') {
      settings.value = _savedSettings;
      _syncControllers();
      _applyRuntimeSettings();
      hasUnsavedChanges.value = false;
      return true;
    }
    return false;
  }

  void previewDefaultInvoice() {
    final now = DateTime.now();
    final invoice = Invoice(
      id: 'preview-default-invoice',
      invoiceNumber: settings.value.formatInvoiceNumber(),
      customerName: 'walk_in_customer'.tr,
      currencyCode: settings.value.defaultCurrency,
      currencySymbol: settings.value.currencySymbol,
      date: now,
      createdAt: now,
      updatedAt: now,
      items: [
        InvoiceItem(
          id: 'preview-item-1',
          name: 'طاقة شمسية',
          createdAt: now,
          updatedAt: now,
          quantity: 1,
          unitPrice: 250000,
        ),
        InvoiceItem(
          id: 'preview-item-2',
          name: 'إنارة داخلية',
          createdAt: now,
          updatedAt: now,
          quantity: 2,
          unitPrice: 45000,
        ),
      ],
      discount: _double(defaultDiscountController.text, 0),
      tax: _double(defaultTaxController.text, 0),
      notes: notesTemplateController.text.trim(),
    );
    Get.toNamed(AppRoutes.pdfPreview, arguments: invoice);
  }

  String allocateInvoiceNumber() => settings.value.formatInvoiceNumber();

  Future<void> markInvoiceNumberUsed(String invoiceNumber) async {
    final current = settings.value;
    if (!current.autoIncrementEnabled) {
      return;
    }
    if (invoiceNumber != current.formatInvoiceNumber()) {
      return;
    }
    await saveSettings(
      current.copyWith(nextInvoiceNumber: current.nextInvoiceNumber + 1),
      showSnackbar: false,
    );
  }

  Future<String?> exportBackup() async {
    isExporting.value = true;
    try {
      final fileName =
          'invoice_app_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final raw = const JsonEncoder.withIndent('  ').convert(_backupPayload());
      final bytes = utf8.encode(raw);
      final pickedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'export_backup_title'.tr,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['json'],
        bytes: bytes,
      );

      if (pickedPath != null) {
        Get.snackbar('backup_exported'.tr, pickedPath);
        return pickedPath;
      }

      return null;
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> importBackupFromFile() async {
    isImporting.value = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'import_backup_title'.tr,
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final file = result.files.single;
      final raw = file.bytes != null
          ? utf8.decode(file.bytes!)
          : await File(file.path!).readAsString();
      await _importBackupFromJson(raw, manageLoading: false);
    } finally {
      isImporting.value = false;
    }
  }

  Future<void> importBackupFromJson(String rawJson) async {
    await _importBackupFromJson(rawJson, manageLoading: true);
  }

  Future<void> _importBackupFromJson(
    String rawJson, {
    bool manageLoading = true,
  }) async {
    if (manageLoading) {
      isImporting.value = true;
    }
    try {
      final decoded = jsonDecode(rawJson);
      final backup = _validateBackup(decoded);
      await _hiveService.settingsBox.put(
        HiveBoxes.settings,
        AppSettings.fromMap(
          backup['settings'] as Map<dynamic, dynamic>?,
        ).toMap(),
      );
      final shop = backup['shopInfo'];
      if (shop is Map) {
        await _hiveService.shopInfoBox.put(
          HiveBoxes.shopInfo,
          ShopInfo.fromMap(shop).toMap(),
        );
      }
      await _replaceBox(_hiveService.customersBox, backup['customers']);
      await _replaceBox(_hiveService.invoicesBox, backup['invoices']);
      await _replaceBox(_hiveService.draftInvoicesBox, backup['draftInvoices']);
      loadSettings();
      Get.snackbar('backup_imported'.tr, 'backup_imported_message'.tr);
    } finally {
      if (manageLoading) {
        isImporting.value = false;
      }
    }
  }

  Future<void> clearAllLocalData() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('clear_all_local_data_question'.tr),
        content: Text('clear_all_local_data_warning'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text('clear_data'.tr),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) {
      return;
    }
    isClearing.value = true;
    await _hiveService.customersBox.clear();
    await _hiveService.invoicesBox.clear();
    await _hiveService.draftInvoicesBox.clear();
    await _hiveService.shopInfoBox.clear();
    await _hiveService.settingsBox.clear();
    loadSettings();
    isClearing.value = false;
    Get.snackbar('cleared'.tr, 'all_data_removed'.tr);
  }

  Future<void> resetSettingsToDefaults() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('reset_settings_question'.tr),
        content: Text('reset_settings_warning'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text('reset'.tr),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) {
      return;
    }
    isResetting.value = true;
    await saveSettings(AppSettings.defaults(), showSnackbar: false);
    isResetting.value = false;
    Get.snackbar('reset'.tr, 'settings_reset_message'.tr);
  }

  Future<void> applyDefaultBusinessProfile() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        icon: const Icon(Icons.storefront_outlined),
        title: Text('quick_setup'.tr),
        content: Text('apply_default_store_information_question'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          FilledButton.icon(
            onPressed: () => Get.back(result: true),
            icon: const Icon(Icons.check_circle_outline),
            label: Text('apply'.tr),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) {
      return;
    }

    isApplyingDefaultProfile.value = true;
    try {
      final nextSettings = settings.value.copyWith(
        businessName: 'غانم لعالم الإنارة',
        defaultCurrency: 'SYP',
        currencySymbol: 'ل.س',
        language: AppLanguage.ar,
        showLogoInPdf: true,
        showFooter: true,
        showSealInPdf: true,
        showSignatureInPdf: false,
      );
      final currentShop = ShopInfo.fromMap(
        _hiveService.shopInfoBox.get(HiveBoxes.shopInfo)
            as Map<dynamic, dynamic>?,
      );
      final nextShop = currentShop.copyWith(
        updatedAt: DateTime.now(),
        shopName: 'غانم لعالم الإنارة',
        phoneNumber: '0991205976',
        address: 'خان أرنبة، مفرق الصمدانية',
        logoPath: AppImages.defaultShopLogo,
        coverPath: AppImages.banner,
        sealPath: AppImages.defaultSeal,
        signaturePath: AppImages.defaultSignature,
        currency: 'SYP',
      );

      await _hiveService.settingsBox.put(
        HiveBoxes.settings,
        nextSettings.toMap(),
      );
      await _hiveService.shopInfoBox.put(HiveBoxes.shopInfo, nextShop.toMap());

      settings.value = nextSettings;
      _savedSettings = nextSettings;
      _syncControllers();
      _applyRuntimeSettings();
      hasUnsavedChanges.value = false;
      if (Get.isRegistered<ShopController>()) {
        Get.find<ShopController>().loadShopInfo();
      }
      Get.snackbar('saved'.tr, 'default_business_profile_applied'.tr);
    } finally {
      isApplyingDefaultProfile.value = false;
    }
  }

  void updateSettings(AppSettings Function(AppSettings current) update) {
    settings.value = update(settings.value);
    _applyRuntimeSettings();
    hasUnsavedChanges.value = true;
  }

  void _syncControllers() {
    _syncingControllers = true;
    final current = settings.value;
    businessNameController.text = current.businessName;
    defaultCurrencyController.text = current.defaultCurrency;
    currencySymbolController.text = current.currencySymbol;
    decimalDigitsController.text = '${current.decimalDigits}';
    invoicePrefixController.text = current.invoicePrefix;
    startingInvoiceNumberController.text = '${current.startingInvoiceNumber}';
    defaultTaxController.text = '${current.defaultTaxPercent}';
    defaultDiscountController.text = '${current.defaultDiscountPercent}';
    notesTemplateController.text = current.notesTemplate;
    paymentInstructionsController.text = current.paymentInstructions;
    fontSizeScaleController.text = '${current.fontSizeScale}';
    _syncingControllers = false;
  }

  void applyFormDraft() {
    if (_syncingControllers) {
      return;
    }
    final current = settings.value;
    settings.value = current.copyWith(
      businessName: businessNameController.text.trim(),
      defaultCurrency: defaultCurrencyController.text.trim().isEmpty
          ? 'USD'
          : defaultCurrencyController.text.trim(),
      currencySymbol: currencySymbolController.text.trim().isEmpty
          ? r'$'
          : currencySymbolController.text.trim(),
      decimalDigits: _int(decimalDigitsController.text, current.decimalDigits),
      invoicePrefix: invoicePrefixController.text.trim().isEmpty
          ? 'INV'
          : invoicePrefixController.text.trim(),
      startingInvoiceNumber: _int(
        startingInvoiceNumberController.text,
        current.startingInvoiceNumber,
      ),
      defaultTaxPercent: _double(defaultTaxController.text, 0),
      defaultDiscountPercent: _double(defaultDiscountController.text, 0),
      notesTemplate: notesTemplateController.text.trim(),
      paymentInstructions: paymentInstructionsController.text.trim(),
      fontSizeScale: _double(
        fontSizeScaleController.text,
        1,
      ).clamp(0.8, 1.4).toDouble(),
    );
    _applyRuntimeSettings();
    hasUnsavedChanges.value = true;
  }

  void _applyRuntimeSettings() {
    final current = settings.value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.updateLocale(
        current.language == AppLanguage.ar
            ? const Locale('ar', 'SA')
            : const Locale('en', 'US'),
      );
      Get.changeThemeMode(switch (current.themeMode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      });
    });
  }

  Future<void> _replaceBox(dynamic box, Object? raw) async {
    if (raw is! Map) {
      return;
    }
    await box.clear();
    for (final entry in raw.entries) {
      await box.put(entry.key, entry.value);
    }
  }

  Map<String, Object?> _backupPayload() {
    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings.value.toMap(),
      'shopInfo': _hiveService.shopInfoBox.get(HiveBoxes.shopInfo),
      'customers': _hiveService.customersBox.toMap(),
      'invoices': _hiveService.invoicesBox.toMap(),
      'draftInvoices': _hiveService.draftInvoicesBox.toMap(),
    };
  }

  Map<String, dynamic> _validateBackup(Object? decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup file');
    }
    if (decoded['version'] == null ||
        decoded['settings'] is! Map ||
        decoded['customers'] is! Map ||
        decoded['invoices'] is! Map) {
      throw const FormatException('Backup file is missing required sections');
    }
    return decoded;
  }

  int _int(String value, int fallback) =>
      int.tryParse(value.trim()) ?? fallback;

  double _double(String value, double fallback) =>
      double.tryParse(value.trim()) ?? fallback;

  @override
  void onClose() {
    businessNameController.dispose();
    defaultCurrencyController.dispose();
    currencySymbolController.dispose();
    decimalDigitsController.dispose();
    invoicePrefixController.dispose();
    startingInvoiceNumberController.dispose();
    defaultTaxController.dispose();
    defaultDiscountController.dispose();
    notesTemplateController.dispose();
    paymentInstructionsController.dispose();
    fontSizeScaleController.dispose();
    super.onClose();
  }
}
