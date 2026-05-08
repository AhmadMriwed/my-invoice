import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_validator.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controller/customer_form_controller.dart';

class CustomerFormView extends GetView<CustomerFormController> {
  const CustomerFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isEditing ? 'edit_customer'.tr : 'new_customer'.tr,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          ScreenUtils.responsiveHorizontalPadding(context),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      _FormGrid(
                        children: [
                          AppTextField(
                            controller: controller.fullNameController,
                            label: 'full_name'.tr,
                            validator: (value) => AppValidator.required(
                              value,
                              fieldName: 'customer_name'.tr,
                            ),
                          ),
                          AppTextField(
                            controller: controller.phoneController,
                            label: 'phone'.tr,
                            keyboardType: TextInputType.phone,
                            validator: (value) => AppValidator.required(
                              value,
                              fieldName: 'phone'.tr,
                            ),
                          ),
                          AppTextField(
                            controller: controller.alternativePhoneController,
                            label: 'alternative_phone'.tr,
                            keyboardType: TextInputType.phone,
                          ),
                          AppTextField(
                            controller: controller.emailController,
                            label: 'email'.tr,
                            keyboardType: TextInputType.emailAddress,
                            validator: AppValidator.email,
                          ),
                          AppTextField(
                            controller: controller.cityController,
                            label: 'city'.tr,
                          ),
                          AppTextField(
                            controller: controller.addressController,
                            label: 'address'.tr,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: controller.notesController,
                        label: 'notes'.tr,
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => AppButton(
                          label: 'save_customer'.tr,
                          icon: const Icon(Icons.save_outlined),
                          isLoading: controller.isSaving.value,
                          onPressed: controller.saveCustomer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormGrid extends StatelessWidget {
  const _FormGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: ScreenUtils.isDesktop(context) ? 2 : 1,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: ScreenUtils.isDesktop(context) ? 5.4 : 5.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
