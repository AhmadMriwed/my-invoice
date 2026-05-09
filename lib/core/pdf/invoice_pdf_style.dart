import 'dart:typed_data';

import '../../features/invoices/model/invoice.dart';
import '../../features/settings/model/app_settings.dart';
import '../../features/shop/model/shop_info.dart';
import 'pdf_options.dart';

typedef InvoicePdfStyleBuilder =
    Future<Uint8List> Function(
      Invoice invoice, {
      ShopInfo? shopInfo,
      required InvoicePdfTheme theme,
      required PaperSizeOption paperSize,
      AppSettings? settings,
    });

class InvoicePdfStyle {
  const InvoicePdfStyle({required this.option, required this.builder});

  final InvoicePdfStyleOption option;
  final InvoicePdfStyleBuilder builder;
}
