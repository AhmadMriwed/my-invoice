import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_validator.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../invoices/model/invoice_item.dart';

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({this.item, super.key});

  final InvoiceItem? item;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController imagePathController;
  late final TextEditingController quantityController;
  late final TextEditingController unitPriceController;
  late final TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    nameController = TextEditingController(text: item?.name ?? '');
    imagePathController = TextEditingController(text: item?.imagePath ?? '');
    quantityController = TextEditingController(text: '${item?.quantity ?? 1}');
    unitPriceController = TextEditingController(
      text: '${item?.unitPrice ?? 0}',
    );
    notesController = TextEditingController(text: item?.notes ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'add_product'.tr : 'edit_product'.tr),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: nameController,
                  label: 'product_name'.tr,
                  validator: (value) => AppValidator.required(
                    value,
                    fieldName: 'product_name'.tr,
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: imagePathController,
                  label: 'product_image_path'.tr,
                  prefixIcon: const Icon(Icons.image_outlined),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: quantityController,
                  label: 'quantity'.tr,
                  keyboardType: TextInputType.number,
                  validator: (value) => _positiveValidator(
                    value,
                    fieldName: 'quantity'.tr,
                    allowZero: false,
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: unitPriceController,
                  label: 'unit_price'.tr,
                  keyboardType: TextInputType.number,
                  validator: (value) => _positiveValidator(
                    value,
                    fieldName: 'unit_price'.tr,
                    allowZero: false,
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(controller: notesController, label: 'notes'.tr),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
        AppButton(
          label: 'save_product'.tr,
          isExpanded: false,
          onPressed: _save,
        ),
      ],
    );
  }

  void _save() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final now = DateTime.now();
    Get.back(
      result: InvoiceItem(
        id: widget.item?.id ?? now.microsecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        createdAt: widget.item?.createdAt ?? now,
        updatedAt: now,
        imagePath: imagePathController.text.trim(),
        quantity: double.tryParse(quantityController.text.trim()) ?? 1,
        unitPrice: double.tryParse(unitPriceController.text.trim()) ?? 0,
        notes: notesController.text.trim(),
      ),
    );
  }

  String? _positiveValidator(
    String? value, {
    required String fieldName,
    bool allowZero = true,
  }) {
    final requiredMessage = AppValidator.required(value, fieldName: fieldName);
    if (requiredMessage != null) {
      return requiredMessage;
    }

    final number = double.tryParse(value!.trim());
    if (number == null || number.isNaN || number.isInfinite) {
      return 'invalid_number'.trParams({'field': fieldName});
    }
    if (allowZero ? number < 0 : number <= 0) {
      return allowZero
          ? 'negative_number'.trParams({'field': fieldName})
          : 'positive_number'.trParams({'field': fieldName});
    }
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    imagePathController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
