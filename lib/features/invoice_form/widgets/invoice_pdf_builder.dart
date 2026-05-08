import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
  }) async {
    final pdf = pw.Document();
    final shop = shopInfo ?? ShopInfo.fromMap(null);
    final appSettings = settings ?? AppSettings.defaults();
    final colors = _PdfThemeColors.fromTheme(theme);
    final labels = _PdfLabels(appSettings.language);
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
        footer: appSettings.showFooter
            ? (context) => _footer(context, colors, labels)
            : null,
        build: (context) => [
          pw.Container(
            padding: pw.EdgeInsets.all(compact ? 12 : 22),
            decoration: pw.BoxDecoration(
              color: colors.headerBackground,
              borderRadius: pw.BorderRadius.circular(compact ? 8 : 14),
            ),
            child: pw.Row(
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
                        child: pw.Text(
                          shopInitial,
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
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
                            color: colors.headerText,
                            fontSize: (compact ? 16 : 24) * scale,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        _headerLine(shop.phoneNumber, colors),
                        _headerLine(shop.email, colors),
                        _headerLine(shop.address, colors),
                        if (shop.taxNumber.isNotEmpty)
                          _headerLine(labels.taxNumber(shop.taxNumber), colors),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      paperSize == PaperSizeOption.thermal
                          ? labels.receipt.toUpperCase()
                          : labels.invoice.toUpperCase(),
                      style: pw.TextStyle(
                        color: colors.headerMuted,
                        fontSize: (compact ? 9 : 12) * scale,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      invoice.invoiceNumber,
                      style: pw.TextStyle(
                        color: colors.headerText,
                        fontSize: (compact ? 12 : 18) * scale,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      DateTimeUtils.formatDate(invoice.date),
                      style: pw.TextStyle(color: colors.headerMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: compact ? 14 : 30),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _partyBlock(
                  title: labels.billTo,
                  lines: [invoice.customerName],
                  colors: colors,
                ),
              ),
              pw.SizedBox(width: 18),
              pw.Expanded(
                child: _partyBlock(
                  title: labels.invoiceDetails,
                  lines: [
                    '${labels.number}: ${invoice.invoiceNumber}',
                    '${labels.date}: ${DateTimeUtils.formatDate(invoice.date)}',
                    '${labels.status}: ${labels.statusValue(invoice.status)}',
                  ],
                  colors: colors,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: compact ? 12 : 24),
          pw.TableHelper.fromTextArray(
            headers: [
              labels.product,
              labels.qty,
              labels.unitPrice,
              labels.total,
            ],
            data: invoice.items
                .map(
                  (item) => [
                    item.name,
                    item.safeQuantity.toStringAsFixed(2),
                    CurrencyUtils.format(item.safeUnitPrice),
                    CurrencyUtils.format(item.total),
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
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: pw.EdgeInsets.symmetric(
              vertical: compact ? 6 : 11,
              horizontal: compact ? 5 : 10,
            ),
            cellStyle: pw.TextStyle(color: colors.bodyText),
            cellAlignments: {
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: compact ? 12 : 24),
          pw.Align(
            alignment: pw.Alignment.centerRight,
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
                  _totalRow(labels.subtotal, invoice.subtotal, colors: colors),
                  _totalRow(
                    labels.discount,
                    invoice.safeDiscount,
                    colors: colors,
                  ),
                  _totalRow(labels.tax, invoice.safeTax, colors: colors),
                  pw.Divider(color: colors.divider),
                  _totalRow(
                    labels.finalTotal,
                    invoice.finalTotal,
                    colors: colors,
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
          pw.Text(CurrencyUtils.format(value), style: style),
        ],
      ),
    );
  }

  static pw.Widget _footer(
    pw.Context context,
    _PdfThemeColors colors,
    _PdfLabels labels,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: colors.divider)),
      ),
      child: pw.Row(
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
        accent: PdfColor.fromInt(0xFF2563EB),
        headerBackground: PdfColor.fromInt(0xFFF3F7FF),
        headerText: PdfColor.fromInt(0xFF111827),
        headerMuted: PdfColor.fromInt(0xFF475569),
        bodyText: PdfColor.fromInt(0xFF111827),
        mutedText: PdfColor.fromInt(0xFF64748B),
        divider: PdfColor.fromInt(0xFFE2E8F0),
        tableHeader: PdfColor.fromInt(0xFFEFF6FF),
        totalBackground: PdfColor.fromInt(0xFFF8FAFC),
      ),
      InvoicePdfTheme.minimal => const _PdfThemeColors(
        accent: PdfColor.fromInt(0xFF111827),
        headerBackground: PdfColors.white,
        headerText: PdfColor.fromInt(0xFF111827),
        headerMuted: PdfColor.fromInt(0xFF6B7280),
        bodyText: PdfColor.fromInt(0xFF111827),
        mutedText: PdfColor.fromInt(0xFF6B7280),
        divider: PdfColor.fromInt(0xFFD1D5DB),
        tableHeader: PdfColor.fromInt(0xFFF9FAFB),
        totalBackground: PdfColors.white,
      ),
      InvoicePdfTheme.dark => const _PdfThemeColors(
        accent: PdfColor.fromInt(0xFF14B8A6),
        headerBackground: PdfColor.fromInt(0xFF111827),
        headerText: PdfColors.white,
        headerMuted: PdfColor.fromInt(0xFFCBD5E1),
        bodyText: PdfColor.fromInt(0xFF111827),
        mutedText: PdfColor.fromInt(0xFF64748B),
        divider: PdfColor.fromInt(0xFFE2E8F0),
        tableHeader: PdfColor.fromInt(0xFFE0F2FE),
        totalBackground: PdfColor.fromInt(0xFFF0FDFA),
      ),
    };
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
  String get receipt => _ar ? 'إيصال' : 'Receipt';
  String get billTo => _ar ? 'فاتورة إلى' : 'Bill To';
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
  String get thankYou =>
      _ar ? 'شكراً لتعاملكم معنا.' : 'Thank you for your business.';

  String taxNumber(String value) =>
      _ar ? 'الرقم الضريبي: $value' : 'Tax number: $value';

  String pageOf(int page, int pages) =>
      _ar ? 'صفحة $page من $pages' : 'Page $page of $pages';

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
