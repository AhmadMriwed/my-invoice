import 'dart:typed_data';

import 'package:get/get.dart';

import '../constants/app_images.dart';
import '../../features/invoice_form/widgets/invoice_pdf_builder.dart';
import '../../features/invoices/model/invoice.dart';
import '../../features/settings/model/app_settings.dart';
import '../../features/shop/model/shop_info.dart';
import 'custom_invoice_pdf_styles.dart';
import 'invoice_pdf_style.dart';
import 'pdf_options.dart';

class InvoicePdfStyles {
  const InvoicePdfStyles._();

  static const defaultStyleId = InvoicePdfStyleIds.defaultStyleId;

  static final List<InvoicePdfStyle> all = [
    InvoicePdfStyle(
      option: const InvoicePdfStyleOption(
        id: defaultStyleId,
        nameKey: 'default_pdf_style_name',
        nameFallback: 'Default',
      ),
      builder:
          (invoice, {shopInfo, required theme, required paperSize, settings}) =>
              InvoicePdfBuilder.build(
                invoice,
                shopInfo: shopInfo,
                theme: theme,
                paperSize: paperSize,
                settings: settings,
              ),
    ),
    InvoicePdfStyle(
      option: const InvoicePdfStyleOption(
        id: 'banner_light',
        nameKey: 'banner_light_pdf_style_name',
        nameFallback: 'Banner light',
      ),
      builder:
          (invoice, {shopInfo, required theme, required paperSize, settings}) =>
              InvoicePdfBuilder.build(
                invoice,
                shopInfo: shopInfo,
                theme: theme,
                paperSize: paperSize,
                settings: settings,
                headerBannerAsset: AppImages.bannerLight,
              ),
    ),
    ...customInvoicePdfStyles,
  ];

  static List<InvoicePdfStyleOption> get options =>
      all.map((style) => style.option).toList(growable: false);

  static String normalize(String? id) {
    if (id == null || id.trim().isEmpty) {
      return defaultStyleId;
    }
    final trimmed = id.trim();
    return all.any((style) => style.option.id == trimmed)
        ? trimmed
        : defaultStyleId;
  }

  static String displayName(InvoicePdfStyleOption option) {
    final translated = option.nameKey.tr;
    return translated == option.nameKey ? option.nameFallback : translated;
  }

  static Future<Uint8List> build(
    Invoice invoice, {
    ShopInfo? shopInfo,
    String? styleId,
    InvoicePdfTheme theme = InvoicePdfTheme.modern,
    PaperSizeOption paperSize = PaperSizeOption.a4,
    AppSettings? settings,
  }) {
    final normalized = normalize(styleId);
    final style = all.firstWhere(
      (style) => style.option.id == normalized,
      orElse: () => all.first,
    );
    return style.builder(
      invoice,
      shopInfo: shopInfo,
      theme: theme,
      paperSize: paperSize,
      settings: settings,
    );
  }
}
