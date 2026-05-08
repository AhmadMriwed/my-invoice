import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_validator.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_navigation_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controller/shop_controller.dart';

class ShopView extends GetView<ShopController> {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigationScaffold(
      currentRoute: AppRoutes.shop,
      title: 'shop_information'.tr,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          ScreenUtils.responsiveHorizontalPadding(context),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'business_profile'.tr,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      _LogoPicker(controller: controller),
                      const SizedBox(height: 24),
                      _ResponsiveFormGrid(
                        children: [
                          AppTextField(
                            controller: controller.shopNameController,
                            label: 'shop_name'.tr,
                            validator: (value) => AppValidator.required(
                              value,
                              fieldName: 'shop_name'.tr,
                            ),
                          ),
                          AppTextField(
                            controller: controller.ownerNameController,
                            label: 'owner_name'.tr,
                          ),
                          AppTextField(
                            controller: controller.phoneController,
                            label: 'phone_number'.tr,
                            keyboardType: TextInputType.phone,
                          ),
                          AppTextField(
                            controller: controller.emailController,
                            label: 'email'.tr,
                            keyboardType: TextInputType.emailAddress,
                            validator: AppValidator.email,
                          ),
                          AppTextField(
                            controller: controller.taxNumberController,
                            label: 'tax_number'.tr,
                          ),
                          AppTextField(
                            controller: controller.currencyController,
                            label: 'currency'.tr,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: controller.addressController,
                        label: 'address'.tr,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: controller.notesController,
                        label: 'notes'.tr,
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => AppButton(
                          label: 'save_shop_information'.tr,
                          icon: const Icon(Icons.save_outlined),
                          isLoading: controller.isSaving.value,
                          onPressed: controller.saveShopInfo,
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

class _LogoPicker extends StatelessWidget {
  const _LogoPicker({required this.controller});

  final ShopController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.storefront_outlined,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 36,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppTextField(
            controller: controller.logoPathController,
            label: 'logo_image_path'.tr,
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          tooltip: 'use_placeholder_logo'.tr,
          onPressed: controller.useLogoPlaceholder,
          icon: const Icon(Icons.image_outlined),
        ),
      ],
    );
  }
}

class _ResponsiveFormGrid extends StatelessWidget {
  const _ResponsiveFormGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenUtils.isDesktop(context);
    return GridView.count(
      crossAxisCount: isDesktop ? 2 : 1,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isDesktop ? 5.4 : 5.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
