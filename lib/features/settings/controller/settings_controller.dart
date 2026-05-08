import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../core/storage/hive_service.dart';
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
    _syncControllers();
    _applyRuntimeSettings();
  }

  Future<void> saveSettings(
    AppSettings next, {
    bool showSnackbar = true,
  }) async {
    isSaving.value = true;
    settings.value = next;
    await _hiveService.settingsBox.put(HiveBoxes.settings, next.toMap());
    _syncControllers();
    _applyRuntimeSettings();
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
        final file = File(pickedPath);
        if (!await file.exists()) {
          await file.writeAsBytes(bytes);
        }
        Get.snackbar('backup_exported'.tr, pickedPath);
        return pickedPath;
      }

      final directory = await getApplicationDocumentsDirectory();
      final fallbackPath = '${directory.path}/$fileName';
      await File(fallbackPath).writeAsString(raw);
      Get.snackbar('backup_exported'.tr, fallbackPath);
      return fallbackPath;
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

  void updateSettings(AppSettings Function(AppSettings current) update) {
    settings.value = update(settings.value);
  }

  void _syncControllers() {
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
