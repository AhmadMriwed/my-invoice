import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/constants/app_images.dart';
import '../../../core/pdf/pdf_font_loader.dart';
import '../../../core/pdf/pdf_options.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../invoices/model/invoice.dart';
import '../../settings/model/app_settings.dart';
import '../../shop/model/shop_info.dart';

class InvoicePdfBuilder {
  const InvoicePdfBuilder._();

  static Future<Uint8List> build(
    Invoice invoice, {
    ShopInfo? shopInfo,
    InvoicePdfTheme theme = InvoicePdfTheme.modern,
    PaperSizeOption paperSize = PaperSizeOption.a4,
    AppSettings? settings,
    String? headerBannerAsset,
  }) async {
    final pdf = pw.Document();
    final shop = shopInfo ?? ShopInfo.fromMap(null);
    final appSettings = settings ?? AppSettings.defaults();
    final colors = _PdfThemeColors.fromTheme(theme);
    final labels = _PdfLabels(appSettings.language);
    final documentTitle = labels.documentTitle(invoice);
    final shopName = shop.shopName.isEmpty ? labels.appName : shop.shopName;
    final shopInitial = shopName.substring(0, 1).toUpperCase();
    final arabicFont = await PdfFontLoader.arabicFont();
    final unicodeFont = await PdfFontLoader.unicodeFont();
    final isRtl =
        appSettings.language == AppLanguage.ar ||
        _containsArabic('$shopName ${invoice.customerName} ${invoice.notes}');
    final pageFormat = paperSize == PaperSizeOption.thermal
        ? PdfPageFormat(
            80 * PdfPageFormat.mm,
            220 * PdfPageFormat.mm,
            marginAll: 5 * PdfPageFormat.mm,
          )
        : PdfPageFormat.a4;
    final margin = paperSize == PaperSizeOption.thermal
        ? const pw.EdgeInsets.all(10)
        : const pw.EdgeInsets.all(34);
    final compact =
        appSettings.compactPdfMode || paperSize == PaperSizeOption.thermal;
    final scale = appSettings.fontSizeScale;
    final logoImage = await _loadLogoImage(shop.logoPath);
    final sealImage = await _loadShopImage(
      shop.sealPath,
      AppImages.defaultSeal,
    );
    final signatureImage = await _loadShopImage(
      shop.signaturePath,
      AppImages.defaultSignature,
    );
    final headerBannerImage = headerBannerAsset == null
        ? null
        : await _loadImageProvider(headerBannerAsset);
    final canShowInvoiceMarks =
        invoice.documentType == InvoiceDocumentType.invoice &&
        (appSettings.showSealInPdf || appSettings.showSignatureInPdf);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat,
          margin: margin,
          textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          theme: pw.ThemeData.withFont(
            base: unicodeFont,
            bold: unicodeFont,
            fontFallback: [arabicFont],
          ),
        ),
        footer: appSettings.showFooter || canShowInvoiceMarks
            ? (context) => _footer(
                context,
                colors,
                labels,
                showFooterText: appSettings.showFooter,
                showInvoiceMarks: canShowInvoiceMarks,
                showSeal: appSettings.showSealInPdf,
                showSignature: appSettings.showSignatureInPdf,
                sealImage: sealImage,
                signatureImage: signatureImage,
                compact: compact,
              )
            : null,
        build: (context) => [
          _header(
            shop: shop,
            shopName: shopName,
            shopInitial: shopInitial,
            invoice: invoice,
            logoImage: logoImage,
            bannerImage: headerBannerImage,
            colors: colors,
            labels: labels,
            documentTitle: documentTitle,
            appSettings: appSettings,
            paperSize: paperSize,
            compact: compact,
            scale: scale,
          ),
          pw.SizedBox(height: compact ? 14 : 30),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _partyBlock(
                  title: labels.billTo(invoice),
                  lines: [invoice.customerName],
                  colors: colors,
                ),
              ),
              pw.SizedBox(width: 18),
              pw.Expanded(
                child: _partyBlock(
                  title: labels.documentDetails(invoice),
                  lines: [
                    '${labels.number}: ${invoice.invoiceNumber}',
                    '${labels.date}: ${DateTimeUtils.formatDate(invoice.date)}',
                    if (invoice.documentType == InvoiceDocumentType.invoice)
                      '${labels.paymentMethod}: ${labels.paymentMethodValue(invoice)}',
                  ],
                  colors: colors,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: compact ? 12 : 24),

          pw.TableHelper.fromTextArray(
            // headerAlignment: pw.AlignmentDirectional.centerEnd,
            headers: isRtl
                ? [labels.total, labels.unitPrice, labels.qty, labels.product]
                : [labels.product, labels.qty, labels.unitPrice, labels.total],
            data: invoice.items
                .map(
                  (item) => isRtl
                      ? [
                          CurrencyUtils.format(
                            item.total,
                            symbol: invoice.currencySymbol,
                          ),
                          CurrencyUtils.format(
                            item.safeUnitPrice,
                            symbol: invoice.currencySymbol,
                          ),
                          item.safeQuantity.toStringAsFixed(2),
                          item.name,
                        ]
                      : [
                          item.name,
                          item.safeQuantity.toStringAsFixed(2),
                          CurrencyUtils.format(
                            item.safeUnitPrice,
                            symbol: invoice.currencySymbol,
                          ),
                          CurrencyUtils.format(
                            item.total,
                            symbol: invoice.currencySymbol,
                          ),
                        ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              color: colors.bodyText,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: pw.BoxDecoration(color: colors.tableHeader),
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(
                color: colors.divider,
                width: 0.5,
              ),
              bottom: pw.BorderSide(color: colors.divider),
            ),
            headerAlignment: pw.AlignmentDirectional.center,
            cellAlignment: pw.AlignmentDirectional.center,

            cellPadding: pw.EdgeInsets.symmetric(
              vertical: compact ? 6 : 11,
              horizontal: compact ? 5 : 10,
            ),
            cellStyle: pw.TextStyle(color: colors.bodyText),
            cellAlignments: {
              1: pw.AlignmentDirectional.centerStart,
              2: pw.AlignmentDirectional.centerStart,
              3: pw.AlignmentDirectional.centerStart,
            },
          ),
          pw.SizedBox(height: compact ? 12 : 24),
          pw.Align(
            alignment: pw.AlignmentDirectional.centerStart,
            child: pw.Container(
              width: paperSize == PaperSizeOption.thermal ? 180 : 255,
              padding: pw.EdgeInsets.all(compact ? 10 : 16),
              decoration: pw.BoxDecoration(
                color: colors.totalBackground,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: colors.divider),
              ),
              child: pw.Column(
                children: [
                  _totalRow(
                    labels.subtotal,
                    invoice.subtotal,
                    colors: colors,
                    symbol: invoice.currencySymbol,
                  ),
                  _totalRow(
                    labels.discount,
                    invoice.safeDiscount,
                    colors: colors,
                    symbol: invoice.currencySymbol,
                  ),
                  _totalRow(
                    labels.tax,
                    invoice.safeTax,
                    colors: colors,
                    symbol: invoice.currencySymbol,
                  ),
                  pw.Divider(color: colors.divider),
                  _totalRow(
                    labels.finalTotal,
                    invoice.finalTotal,
                    colors: colors,
                    symbol: invoice.currencySymbol,
                    isStrong: true,
                  ),
                ],
              ),
            ),
          ),
          if (invoice.notes.isNotEmpty) ...[
            pw.SizedBox(height: compact ? 12 : 24),
            _partyBlock(
              title: labels.notes,
              lines: [invoice.notes],
              colors: colors,
            ),
          ],
          if (appSettings.paymentInstructions.isNotEmpty) ...[
            pw.SizedBox(height: compact ? 10 : 18),
            _partyBlock(
              title: labels.payment,
              lines: [appSettings.paymentInstructions],
              colors: colors,
            ),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _headerLine(String value, _PdfThemeColors colors) {
    if (value.trim().isEmpty) {
      return pw.SizedBox();
    }
    return pw.Text(value, style: pw.TextStyle(color: colors.headerMuted));
  }

  static pw.Widget _header({
    required ShopInfo shop,
    required String shopName,
    required String shopInitial,
    required Invoice invoice,
    required pw.ImageProvider? logoImage,
    required pw.ImageProvider? bannerImage,
    required _PdfThemeColors colors,
    required _PdfLabels labels,
    required String documentTitle,
    required AppSettings appSettings,
    required PaperSizeOption paperSize,
    required bool compact,
    required double scale,
  }) {
    final headerContent = pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (appSettings.showLogoInPdf)
              pw.Container(
                width: compact ? 34 : 50,
                height: compact ? 34 : 50,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: colors.accent,
                  borderRadius: pw.BorderRadius.circular(13),
                ),
                child: logoImage == null
                    ? pw.Text(
                        shopInitial,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      )
                    : pw.ClipRRect(
                        horizontalRadius: 13,
                        verticalRadius: 13,
                        child: pw.Image(
                          logoImage,
                          fit: pw.BoxFit.cover,
                          width: compact ? 34 : 50,
                          height: compact ? 34 : 50,
                        ),
                      ),
              ),
            if (appSettings.showLogoInPdf) pw.SizedBox(width: 14),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  shopName,
                  style: pw.TextStyle(
                    color: bannerImage == null
                        ? colors.headerText
                        : colors.bodyText,
                    fontSize: (compact ? 16 : 24) * scale,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                _headerLine(
                  shop.phoneNumber,
                  bannerImage == null ? colors : colors.forLightHeader(),
                ),
                _headerLine(
                  shop.email,
                  bannerImage == null ? colors : colors.forLightHeader(),
                ),
                _headerLine(
                  shop.address,
                  bannerImage == null ? colors : colors.forLightHeader(),
                ),
                if (shop.taxNumber.isNotEmpty)
                  _headerLine(
                    labels.taxNumber(shop.taxNumber),
                    bannerImage == null ? colors : colors.forLightHeader(),
                  ),
              ],
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              documentTitle.toUpperCase(),
              style: pw.TextStyle(
                color: bannerImage == null ? colors.headerMuted : colors.accent,
                fontSize: (compact ? 9 : 12) * scale,
                letterSpacing: 2,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              invoice.invoiceNumber,
              style: pw.TextStyle(
                color: bannerImage == null
                    ? colors.headerText
                    : colors.bodyText,
                fontSize: (compact ? 12 : 18) * scale,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              DateTimeUtils.formatDate(invoice.date),
              style: pw.TextStyle(
                color: bannerImage == null
                    ? colors.headerMuted
                    : colors.mutedText,
              ),
            ),
          ],
        ),
      ],
    );

    if (bannerImage == null) {
      return pw.Container(
        padding: pw.EdgeInsets.all(compact ? 12 : 22),
        decoration: pw.BoxDecoration(
          color: colors.headerBackground,
          borderRadius: pw.BorderRadius.circular(compact ? 8 : 14),
        ),
        child: headerContent,
      );
    }

    return pw.Container(
      height: paperSize == PaperSizeOption.thermal ? 98 : 250,
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(compact ? 8 : 14),
      ),
      child: pw.ClipRRect(
        horizontalRadius: compact ? 8 : 14,
        verticalRadius: compact ? 8 : 14,
        child: pw.Image(bannerImage, fit: pw.BoxFit.cover),
      ),
    );
  }

  static Future<pw.ImageProvider?> _loadLogoImage(String logoPath) async {
    final path = logoPath.trim().isEmpty
        ? AppImages.defaultShopLogo
        : logoPath.trim();
    return _loadImageProvider(path, fallbackAsset: AppImages.defaultShopLogo);
  }

  static Future<pw.ImageProvider?> _loadShopImage(
    String imagePath,
    String defaultAsset,
  ) {
    final path = imagePath.trim().isEmpty ? defaultAsset : imagePath.trim();
    return _loadImageProvider(path, fallbackAsset: defaultAsset);
  }

  static Future<pw.ImageProvider?> _loadImageProvider(
    String path, {
    String? fallbackAsset,
  }) async {
    if (!path.startsWith('assets/')) {
      try {
        final file = File(path);
        if (!await file.exists()) {
          return null;
        }
        return pw.MemoryImage(await file.readAsBytes());
      } catch (_) {
        return null;
      }
    }

    try {
      final data = await rootBundle.load(path);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      if (fallbackAsset == null || path == fallbackAsset) {
        return null;
      }
      try {
        final data = await rootBundle.load(fallbackAsset);
        return pw.MemoryImage(data.buffer.asUint8List());
      } catch (_) {
        return null;
      }
    }
  }

  static pw.Widget _partyBlock({
    required String title,
    required List<String> lines,
    required _PdfThemeColors colors,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: colors.divider),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              color: colors.mutedText,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          for (final line in lines.where((line) => line.trim().isNotEmpty))
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(line, style: pw.TextStyle(color: colors.bodyText)),
            ),
        ],
      ),
    );
  }

  static pw.Widget _totalRow(
    String label,
    double value, {
    required _PdfThemeColors colors,
    String symbol = r'$',
    bool isStrong = false,
  }) {
    final style = pw.TextStyle(
      color: colors.bodyText,
      fontSize: isStrong ? 15 : 11,
      fontWeight: isStrong ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(CurrencyUtils.format(value, symbol: symbol), style: style),
        ],
      ),
    );
  }

  static pw.Widget _footer(
    pw.Context context,
    _PdfThemeColors colors,
    _PdfLabels labels, {
    required bool showFooterText,
    required bool showInvoiceMarks,
    required bool showSeal,
    required bool showSignature,
    required pw.ImageProvider? sealImage,
    required pw.ImageProvider? signatureImage,
    required bool compact,
  }) {
    final isLastPage = context.pageNumber == context.pagesCount;
    final marks = showInvoiceMarks && isLastPage
        ? _invoiceMarks(
            showSeal: showSeal,
            showSignature: showSignature,
            sealImage: sealImage,
            signatureImage: signatureImage,
            compact: compact,
          )
        : null;

    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: colors.divider)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          if (marks != null) ...[
            pw.Align(alignment: pw.Alignment.centerLeft, child: marks),
            pw.SizedBox(height: 8),
          ],
          if (showFooterText)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  labels.thankYou,
                  style: pw.TextStyle(color: colors.mutedText, fontSize: 10),
                ),
                pw.Text(
                  labels.pageOf(context.pageNumber, context.pagesCount),
                  style: pw.TextStyle(color: colors.mutedText, fontSize: 10),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static pw.Widget? _invoiceMarks({
    required bool showSeal,
    required bool showSignature,
    required pw.ImageProvider? sealImage,
    required pw.ImageProvider? signatureImage,
    required bool compact,
  }) {
    final children = <pw.Widget>[];
    if (showSeal && sealImage != null) {
      children.add(
        pw.Image(
          sealImage,
          width: compact ? 48 : 76,
          height: compact ? 48 : 76,
          fit: pw.BoxFit.contain,
        ),
      );
    }
    if (showSignature && signatureImage != null) {
      if (children.isNotEmpty) {
        children.add(pw.SizedBox(height: 3));
      }
      children.add(
        pw.Image(
          signatureImage,
          width: compact ? 70 : 118,
          height: compact ? 28 : 46,
          fit: pw.BoxFit.contain,
        ),
      );
    }
    if (children.isEmpty) {
      return null;
    }
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  static bool _containsArabic(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }
}

class _PdfThemeColors {
  const _PdfThemeColors({
    required this.accent,
    required this.headerBackground,
    required this.headerText,
    required this.headerMuted,
    required this.bodyText,
    required this.mutedText,
    required this.divider,
    required this.tableHeader,
    required this.totalBackground,
  });

  factory _PdfThemeColors.fromTheme(InvoicePdfTheme theme) {
    return switch (theme) {
      InvoicePdfTheme.modern => const _PdfThemeColors(
        accent: PdfColor.fromInt(0xFF000000),
        // accent: PdfColor.fromInt(0xFF8A8A8A),
        // accent: PdfColor.fromInt(0xFFD4A64A),
        headerBackground: PdfColor.fromInt(0xFF17181C),
        headerText: PdfColors.white,
        headerMuted: PdfColor.fromInt(0xFFF4D28C),
        bodyText: PdfColor.fromInt(0xFF1A1A1A),
        mutedText: PdfColor.fromInt(0xFF8A8A8A),
        divider: PdfColor.fromInt(0xFFE7E0D4),
        tableHeader: PdfColor.fromInt(0xFFFFF4D6),
        totalBackground: PdfColor.fromInt(0xFFF7F5F1),
      ),
      InvoicePdfTheme.minimal => const _PdfThemeColors(
        accent: PdfColor.fromInt(0xFF000000),
        headerBackground: PdfColors.white,
        headerText: PdfColor.fromInt(0xFF1A1A1A),
        headerMuted: PdfColor.fromInt(0xFF8A8A8A),
        bodyText: PdfColor.fromInt(0xFF1A1A1A),
        mutedText: PdfColor.fromInt(0xFF8A8A8A),
        divider: PdfColor.fromInt(0xFFE7E0D4),
        tableHeader: PdfColor.fromInt(0xFFF7F5F1),
        totalBackground: PdfColors.white,
      ),
      InvoicePdfTheme.dark => const _PdfThemeColors(
        accent: PdfColor.fromInt(0xFF1E88E5),
        headerBackground: PdfColor.fromInt(0xFF0B0B0D),
        headerText: PdfColors.white,
        headerMuted: PdfColor.fromInt(0xFFF4D28C),
        bodyText: PdfColor.fromInt(0xFF1A1A1A),
        mutedText: PdfColor.fromInt(0xFF8A8A8A),
        divider: PdfColor.fromInt(0xFFE7E0D4),
        tableHeader: PdfColor.fromInt(0xFFFFF4D6),
        totalBackground: PdfColor.fromInt(0xFFF7F5F1),
      ),
    };
  }

  _PdfThemeColors forLightHeader() {
    return _PdfThemeColors(
      accent: accent,
      headerBackground: headerBackground,
      headerText: bodyText,
      headerMuted: mutedText,
      bodyText: bodyText,
      mutedText: mutedText,
      divider: divider,
      tableHeader: tableHeader,
      totalBackground: totalBackground,
    );
  }

  final PdfColor accent;
  final PdfColor headerBackground;
  final PdfColor headerText;
  final PdfColor headerMuted;
  final PdfColor bodyText;
  final PdfColor mutedText;
  final PdfColor divider;
  final PdfColor tableHeader;
  final PdfColor totalBackground;
}

class _PdfLabels {
  const _PdfLabels(this.language);

  final AppLanguage language;

  bool get _ar => language == AppLanguage.ar;

  String get appName => _ar ? 'تطبيق الفواتير' : 'Invoice App';
  String get invoice => _ar ? 'فاتورة' : 'Invoice';
  String get quote => _ar ? 'عرض سعر' : 'Quotation';
  String get receipt => _ar ? 'إيصال' : 'Receipt';
  String billTo(Invoice invoice) {
    final title = documentTitle(invoice);
    return _ar ? '$title إلى' : '$title To';
  }

  String get invoiceDetails => _ar ? 'تفاصيل الفاتورة' : 'Invoice Details';
  String get number => _ar ? 'الرقم' : 'Number';
  String get date => _ar ? 'التاريخ' : 'Date';
  String get status => _ar ? 'الحالة' : 'Status';
  String get product => _ar ? 'المنتج' : 'Product';
  String get qty => _ar ? 'الكمية' : 'Qty';
  String get unitPrice => _ar ? 'سعر الوحدة' : 'Unit price';
  String get total => _ar ? 'الإجمالي' : 'Total';
  String get subtotal => _ar ? 'المجموع الفرعي' : 'Subtotal';
  String get discount => _ar ? 'الخصم' : 'Discount';
  String get tax => _ar ? 'الضريبة' : 'Tax';
  String get finalTotal => _ar ? 'الإجمالي النهائي' : 'Final total';
  String get notes => _ar ? 'ملاحظات' : 'Notes';
  String get payment => _ar ? 'الدفع' : 'Payment';
  String get paymentMethod => _ar ? 'طريقة الدفع' : 'Payment method';
  String get thankYou =>
      _ar ? 'شكراً لتعاملكم معنا.' : 'Thank you for your business.';

  String taxNumber(String value) =>
      _ar ? 'الرقم الضريبي: $value' : 'Tax number: $value';

  String pageOf(int page, int pages) =>
      _ar ? 'صفحة $page من $pages' : 'Page $page of $pages';

  String documentTitle(Invoice invoice) {
    return switch (invoice.documentType) {
      InvoiceDocumentType.invoice => this.invoice,
      InvoiceDocumentType.quote => quote,
      InvoiceDocumentType.custom =>
        invoice.customDocumentType.trim().isEmpty
            ? this.invoice
            : invoice.customDocumentType.trim(),
    };
  }

  String documentDetails(Invoice invoice) {
    return switch (invoice.documentType) {
      InvoiceDocumentType.invoice => invoiceDetails,
      InvoiceDocumentType.quote =>
        _ar ? 'تفاصيل عرض السعر' : 'Quotation Details',
      InvoiceDocumentType.custom => _ar ? 'تفاصيل المستند' : 'Document Details',
    };
  }

  String paymentMethodValue(Invoice invoice) {
    if (invoice.paymentMethod == InvoicePaymentMethod.custom) {
      return invoice.customPaymentMethod.trim();
    }
    return switch (invoice.paymentMethod) {
      InvoicePaymentMethod.cash => _ar ? 'نقداً' : 'Cash',
      InvoicePaymentMethod.credit => _ar ? 'آجل' : 'Credit',
      InvoicePaymentMethod.custom => invoice.customPaymentMethod.trim(),
    };
  }

  String statusValue(InvoiceStatus status) {
    if (!_ar) {
      return status.name;
    }
    return switch (status) {
      InvoiceStatus.draft => 'مسودة',
      InvoiceStatus.saved => 'محفوظة',
      InvoiceStatus.paid => 'مدفوعة',
      InvoiceStatus.overdue => 'متأخرة',
      InvoiceStatus.cancelled => 'ملغاة',
    };
  }
}
