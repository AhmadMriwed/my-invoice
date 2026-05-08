import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_validator.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../customers/model/customer.dart';

class TemporaryCustomerDialog extends StatefulWidget {
  const TemporaryCustomerDialog({super.key});

  @override
  State<TemporaryCustomerDialog> createState() =>
      _TemporaryCustomerDialogState();
}

class _TemporaryCustomerDialogState extends State<TemporaryCustomerDialog> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('one_time_customer'.tr),
      content: SizedBox(
        width: 480,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: nameController,
                label: 'full_name'.tr,
                validator: (value) =>
                    AppValidator.required(value, fieldName: 'customer_name'.tr),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: phoneController,
                label: 'phone'.tr,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              AppTextField(controller: addressController, label: 'address'.tr),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
        AppButton(
          label: 'use_only_invoice'.tr,
          isExpanded: false,
          onPressed: _submit,
        ),
      ],
    );
  }

  void _submit() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final now = DateTime.now();
    Get.back(
      result: Customer(
        id: 'temp-${now.microsecondsSinceEpoch}',
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
