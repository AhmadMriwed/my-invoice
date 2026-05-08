import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/pdf/pdf_options.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_action_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_navigation_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controller/settings_controller.dart';
import '../model/app_settings.dart';
import '../widgets/settings_section.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigationScaffold(
      currentRoute: AppRoutes.settings,
      title: 'business_settings'.tr,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          ScreenUtils.responsiveHorizontalPadding(context),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Obx(
              () => Column(
                children: [
                  SettingsSection(
                    title: 'general_settings'.tr,
                    children: [
                      _ResponsiveGrid(
                        children: [
                          AppTextField(
                            controller: controller.businessNameController,
                            label: 'business_name'.tr,
                          ),
                          AppTextField(
                            controller: controller.defaultCurrencyController,
                            label: 'default_currency'.tr,
                          ),
                          AppTextField(
                            controller: controller.currencySymbolController,
                            label: 'currency_symbol'.tr,
                          ),
                          _EnumDropdown<CurrencyPosition>(
                            label: 'currency_position'.tr,
                            value: controller.settings.value.currencyPosition,
                            values: CurrencyPosition.values,
                            onChanged: (value) => controller.updateSettings(
                              (current) =>
                                  current.copyWith(currencyPosition: value),
                            ),
                          ),
                          AppTextField(
                            controller: controller.decimalDigitsController,
                            label: 'decimal_digits'.tr,
                            keyboardType: TextInputType.number,
                          ),
                          _EnumDropdown<AppLanguage>(
                            label: 'language'.tr,
                            value: controller.settings.value.language,
                            values: AppLanguage.values,
                            onChanged: (value) => controller.updateSettings(
                              (current) => current.copyWith(language: value),
                            ),
                          ),
                          _EnumDropdown<AppThemeMode>(
                            label: 'theme_mode'.tr,
                            value: controller.settings.value.themeMode,
                            values: AppThemeMode.values,
                            onChanged: (value) => controller.updateSettings(
                              (current) => current.copyWith(themeMode: value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SettingsSection(
                    title: 'invoice_settings'.tr,
                    children: [
                      _ResponsiveGrid(
                        children: [
                          AppTextField(
                            controller: controller.invoicePrefixController,
                            label: 'invoice_prefix'.tr,
                          ),
                          AppTextField(
                            controller:
                                controller.startingInvoiceNumberController,
                            label: 'starting_invoice_number'.tr,
                            keyboardType: TextInputType.number,
                          ),
                          _SwitchTile(
                            title: 'auto_increment_enabled'.tr,
                            value:
                                controller.settings.value.autoIncrementEnabled,
                            onChanged: (value) => controller.updateSettings(
                              (current) =>
                                  current.copyWith(autoIncrementEnabled: value),
                            ),
                          ),
                          AppTextField(
                            controller: controller.defaultTaxController,
                            label: 'default_tax'.tr,
                            keyboardType: TextInputType.number,
                          ),
                          AppTextField(
                            controller: controller.defaultDiscountController,
                            label: 'default_discount'.tr,
                            keyboardType: TextInputType.number,
                          ),
                          _SwitchTile(
                            title: 'show_logo_pdf'.tr,
                            value: controller.settings.value.showLogoInPdf,
                            onChanged: (value) => controller.updateSettings(
                              (current) =>
                                  current.copyWith(showLogoInPdf: value),
                            ),
                          ),
                          _SwitchTile(
                            title: 'show_customer_notes'.tr,
                            value: controller.settings.value.showCustomerNotes,
                            onChanged: (value) => controller.updateSettings(
                              (current) =>
                                  current.copyWith(showCustomerNotes: value),
                            ),
                          ),
                          _SwitchTile(
                            title: 'show_footer'.tr,
                            value: controller.settings.value.showFooter,
                            onChanged: (value) => controller.updateSettings(
                              (current) => current.copyWith(showFooter: value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: controller.notesTemplateController,
                        label: 'notes_template'.tr,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: controller.paymentInstructionsController,
                        label: 'payment_instructions'.tr,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SettingsSection(
                    title: 'pdf_settings'.tr,
                    children: [
                      _ResponsiveGrid(
                        children: [
                          _EnumDropdown<InvoicePdfTheme>(
                            label: 'default_pdf_theme'.tr,
                            value: controller.settings.value.defaultPdfTheme,
                            values: InvoicePdfTheme.values,
                            onChanged: (value) => controller.updateSettings(
                              (current) =>
                                  current.copyWith(defaultPdfTheme: value),
                            ),
                          ),
                          _EnumDropdown<PaperSizeOption>(
                            label: 'paper_size'.tr,
                            value: controller.settings.value.paperSize,
                            values: PaperSizeOption.values,
                            onChanged: (value) => controller.updateSettings(
                              (current) => current.copyWith(paperSize: value),
                            ),
                          ),
                          AppTextField(
                            controller: controller.fontSizeScaleController,
                            label: 'font_size_scale'.tr,
                            keyboardType: TextInputType.number,
                          ),
                          _SwitchTile(
                            title: 'compact_mode'.tr,
                            value: controller.settings.value.compactPdfMode,
                            onChanged: (value) => controller.updateSettings(
                              (current) =>
                                  current.copyWith(compactPdfMode: value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SettingsSection(
                    title: 'backup_settings'.tr,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          Obx(
                            () => AppActionButton(
                              icon: Icons.upload_file_outlined,
                              label: controller.isExporting.value
                                  ? 'exporting'.tr
                                  : 'export_backup'.tr,
                              onPressed: controller.isExporting.value
                                  ? null
                                  : controller.exportBackup,
                            ),
                          ),
                          Obx(
                            () => AppActionButton(
                              icon: Icons.download_outlined,
                              label: controller.isImporting.value
                                  ? 'importing'.tr
                                  : 'import_backup'.tr,
                              onPressed: controller.isImporting.value
                                  ? null
                                  : controller.importBackupFromFile,
                            ),
                          ),
                          AppActionButton(
                            icon: Icons.content_paste_outlined,
                            label: 'paste_json_fallback'.tr,
                            onPressed: () => _showImportDialog(context),
                          ),
                          Obx(
                            () => AppActionButton(
                              icon: Icons.delete_forever_outlined,
                              label: controller.isClearing.value
                                  ? 'clearing'.tr
                                  : 'clear_all_local_data'.tr,
                              onPressed: controller.isClearing.value
                                  ? null
                                  : controller.clearAllLocalData,
                            ),
                          ),
                          Obx(
                            () => AppActionButton(
                              icon: Icons.restart_alt_outlined,
                              label: controller.isResetting.value
                                  ? 'resetting'.tr
                                  : 'reset_settings'.tr,
                              onPressed: controller.isResetting.value
                                  ? null
                                  : controller.resetSettingsToDefaults,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => AppButton(
                      label: 'save_settings'.tr,
                      isLoading: controller.isSaving.value,
                      icon: const Icon(Icons.save_outlined),
                      onPressed: controller.saveFromForm,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImportDialog(BuildContext context) async {
    final textController = TextEditingController();
    final raw = await Get.dialog<String>(
      AlertDialog(
        title: Text('import_backup_json'.tr),
        content: SizedBox(
          width: 560,
          child: TextField(
            controller: textController,
            minLines: 8,
            maxLines: 12,
            decoration: InputDecoration(hintText: 'paste_backup_json_here'.tr),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          FilledButton(
            onPressed: () => Get.back(result: textController.text),
            child: Text('import'.tr),
          ),
        ],
      ),
    );
    textController.dispose();
    if (raw != null && raw.trim().isNotEmpty) {
      await controller.importBackupFromJson(raw);
    }
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: ScreenUtils.isDesktop(context) ? 2 : 1,
      childAspectRatio: ScreenUtils.isDesktop(context) ? 5.2 : 5.8,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class _EnumDropdown<T extends Enum> extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: values
          .map(
            (item) => DropdownMenuItem(value: item, child: Text(item.name.tr)),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
