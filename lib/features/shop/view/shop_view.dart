import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_input_formatters.dart';
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
                      _MediaPickers(controller: controller),
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
                            keyboardType: TextInputType.number,
                            inputFormatters: AppInputFormatters.digitsOnly,
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

class _MediaPickers extends StatelessWidget {
  const _MediaPickers({required this.controller});

  final ShopController controller;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenUtils.isDesktop(context);
    final children = [
      Obx(
        () => _ImagePickerCard(
          title: 'shop_logo'.tr,
          imagePath: controller.logoPreviewPath.value,
          aspectRatio: 1,
          onPick: () => controller.pickLogoImage(context),
          onUseDefault: controller.useLogoPlaceholder,
        ),
      ),
      Obx(
        () => _ImagePickerCard(
          title: 'shop_cover'.tr,
          imagePath: controller.coverPreviewPath.value,
          aspectRatio: 2.8,
          onPick: () => controller.pickCoverImage(context),
          onUseDefault: controller.useCoverPlaceholder,
        ),
      ),
      Obx(
        () => _ImagePickerCard(
          title: 'shop_seal'.tr,
          imagePath: controller.sealPreviewPath.value,
          aspectRatio: 1,
          onPick: () => controller.pickSealImage(context),
          onUseDefault: controller.useSealPlaceholder,
        ),
      ),
      Obx(
        () => _ImagePickerCard(
          title: 'shop_signature'.tr,
          imagePath: controller.signaturePreviewPath.value,
          aspectRatio: 2.8,
          onPick: () => controller.pickSignatureImage(context),
          onUseDefault: controller.useSignaturePlaceholder,
        ),
      ),
    ];

    if (!isDesktop) {
      return Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(height: 16),
            children[index],
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({
    required this.title,
    required this.imagePath,
    required this.aspectRatio,
    required this.onPick,
    required this.onUseDefault,
  });

  final String title;
  final String imagePath;
  final double aspectRatio;
  final VoidCallback onPick;
  final VoidCallback onUseDefault;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.25),
              ),
            ),
            child: _PickedImage(path: imagePath),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text('choose_image'.tr),
            ),
            TextButton.icon(
              onPressed: onUseDefault,
              icon: const Icon(Icons.restart_alt_outlined),
              label: Text('use_default_image'.tr),
            ),
          ],
        ),
      ],
    );
  }
}

class _PickedImage extends StatelessWidget {
  const _PickedImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final file = path.startsWith('assets/') ? null : File(path);
    final image = path.startsWith('assets/')
        ? Image.asset(path, fit: BoxFit.contain)
        : file?.existsSync() ?? false
        ? Image.file(file!, fit: BoxFit.contain)
        : Icon(
            Icons.broken_image_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 38,
          );

    return CustomPaint(
      painter: const CheckerboardPainter(),
      child: Center(child: image),
    );
  }
}

class CheckerboardPainter extends CustomPainter {
  const CheckerboardPainter();

  static const double _size = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()..color = const Color(0xFFFFFFFF);
    final dark = Paint()..color = const Color(0xFFE5E5E5);
    canvas.drawRect(Offset.zero & size, light);

    for (double y = 0; y < size.height; y += _size) {
      for (double x = 0; x < size.width; x += _size) {
        final isDark = ((x / _size).floor() + (y / _size).floor()).isEven;
        if (isDark) {
          canvas.drawRect(Rect.fromLTWH(x, y, _size, _size), dark);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
