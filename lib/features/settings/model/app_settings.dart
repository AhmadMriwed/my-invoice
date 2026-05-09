import '../../../core/pdf/pdf_options.dart';

enum CurrencyPosition { before, after }

enum AppLanguage { en, ar }

enum AppThemeMode { light, dark, system }

class AppSettings {
  const AppSettings({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.businessName = 'تطبيق الفواتير',
    this.defaultCurrency = 'USD',
    this.currencySymbol = r'$',
    this.currencyPosition = CurrencyPosition.before,
    this.decimalDigits = 2,
    this.language = AppLanguage.ar,
    this.themeMode = AppThemeMode.system,
    this.invoicePrefix = 'INV',
    this.startingInvoiceNumber = 1,
    this.nextInvoiceNumber = 1,
    this.autoIncrementEnabled = true,
    this.defaultTaxPercent = 0,
    this.defaultDiscountPercent = 0,
    this.notesTemplate = '',
    this.paymentInstructions = '',
    this.showLogoInPdf = true,
    this.showCustomerNotes = true,
    this.showFooter = true,
    this.showSealInPdf = true,
    this.showSignatureInPdf = false,
    this.defaultPdfTheme = InvoicePdfTheme.modern,
    this.defaultPdfStyleId = InvoicePdfStyleIds.defaultStyleId,
    this.paperSize = PaperSizeOption.a4,
    this.fontSizeScale = 1,
    this.compactPdfMode = false,
  });

  factory AppSettings.defaults() {
    final now = DateTime.now();
    return AppSettings(id: 'app_settings', createdAt: now, updatedAt: now);
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return AppSettings.defaults();
    }
    final defaults = AppSettings.defaults();
    return AppSettings(
      id: map['id']?.toString() ?? defaults.id,
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          defaults.createdAt,
      updatedAt:
          DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          defaults.updatedAt,
      businessName: map['businessName']?.toString() ?? defaults.businessName,
      defaultCurrency:
          map['defaultCurrency']?.toString() ?? defaults.defaultCurrency,
      currencySymbol:
          map['currencySymbol']?.toString() ?? defaults.currencySymbol,
      currencyPosition: _enumValue(
        CurrencyPosition.values,
        map['currencyPosition'],
        defaults.currencyPosition,
      ),
      decimalDigits: (map['decimalDigits'] as num?)?.toInt() ?? 2,
      language: _enumValue(
        AppLanguage.values,
        map['language'],
        defaults.language,
      ),
      themeMode: _enumValue(
        AppThemeMode.values,
        map['themeMode'],
        defaults.themeMode,
      ),
      invoicePrefix: map['invoicePrefix']?.toString() ?? defaults.invoicePrefix,
      startingInvoiceNumber:
          (map['startingInvoiceNumber'] as num?)?.toInt() ?? 1,
      nextInvoiceNumber: (map['nextInvoiceNumber'] as num?)?.toInt() ?? 1,
      autoIncrementEnabled: map['autoIncrementEnabled'] as bool? ?? true,
      defaultTaxPercent: (map['defaultTaxPercent'] as num?)?.toDouble() ?? 0,
      defaultDiscountPercent:
          (map['defaultDiscountPercent'] as num?)?.toDouble() ?? 0,
      notesTemplate: map['notesTemplate']?.toString() ?? '',
      paymentInstructions: map['paymentInstructions']?.toString() ?? '',
      showLogoInPdf: map['showLogoInPdf'] as bool? ?? true,
      showCustomerNotes: map['showCustomerNotes'] as bool? ?? true,
      showFooter: map['showFooter'] as bool? ?? true,
      showSealInPdf: map['showSealInPdf'] as bool? ?? true,
      showSignatureInPdf: map['showSignatureInPdf'] as bool? ?? false,
      defaultPdfTheme: _enumValue(
        InvoicePdfTheme.values,
        map['defaultPdfTheme'],
        defaults.defaultPdfTheme,
      ),
      defaultPdfStyleId:
          map['defaultPdfStyleId']?.toString() ??
          _legacyStyleId(map['defaultPdfTheme']) ??
          defaults.defaultPdfStyleId,
      paperSize: _enumValue(
        PaperSizeOption.values,
        map['paperSize'],
        defaults.paperSize,
      ),
      fontSizeScale: (map['fontSizeScale'] as num?)?.toDouble() ?? 1,
      compactPdfMode: map['compactPdfMode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'businessName': businessName,
      'defaultCurrency': defaultCurrency,
      'currencySymbol': currencySymbol,
      'currencyPosition': currencyPosition.name,
      'decimalDigits': decimalDigits,
      'language': language.name,
      'themeMode': themeMode.name,
      'invoicePrefix': invoicePrefix,
      'startingInvoiceNumber': startingInvoiceNumber,
      'nextInvoiceNumber': nextInvoiceNumber,
      'autoIncrementEnabled': autoIncrementEnabled,
      'defaultTaxPercent': defaultTaxPercent,
      'defaultDiscountPercent': defaultDiscountPercent,
      'notesTemplate': notesTemplate,
      'paymentInstructions': paymentInstructions,
      'showLogoInPdf': showLogoInPdf,
      'showCustomerNotes': showCustomerNotes,
      'showFooter': showFooter,
      'showSealInPdf': showSealInPdf,
      'showSignatureInPdf': showSignatureInPdf,
      'defaultPdfTheme': defaultPdfTheme.name,
      'defaultPdfStyleId': defaultPdfStyleId,
      'paperSize': paperSize.name,
      'fontSizeScale': fontSizeScale,
      'compactPdfMode': compactPdfMode,
    };
  }

  AppSettings copyWith({
    String? businessName,
    String? defaultCurrency,
    String? currencySymbol,
    CurrencyPosition? currencyPosition,
    int? decimalDigits,
    AppLanguage? language,
    AppThemeMode? themeMode,
    String? invoicePrefix,
    int? startingInvoiceNumber,
    int? nextInvoiceNumber,
    bool? autoIncrementEnabled,
    double? defaultTaxPercent,
    double? defaultDiscountPercent,
    String? notesTemplate,
    String? paymentInstructions,
    bool? showLogoInPdf,
    bool? showCustomerNotes,
    bool? showFooter,
    bool? showSealInPdf,
    bool? showSignatureInPdf,
    InvoicePdfTheme? defaultPdfTheme,
    String? defaultPdfStyleId,
    PaperSizeOption? paperSize,
    double? fontSizeScale,
    bool? compactPdfMode,
  }) {
    return AppSettings(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      businessName: businessName ?? this.businessName,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyPosition: currencyPosition ?? this.currencyPosition,
      decimalDigits: decimalDigits ?? this.decimalDigits,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      startingInvoiceNumber:
          startingInvoiceNumber ?? this.startingInvoiceNumber,
      nextInvoiceNumber: nextInvoiceNumber ?? this.nextInvoiceNumber,
      autoIncrementEnabled: autoIncrementEnabled ?? this.autoIncrementEnabled,
      defaultTaxPercent: defaultTaxPercent ?? this.defaultTaxPercent,
      defaultDiscountPercent:
          defaultDiscountPercent ?? this.defaultDiscountPercent,
      notesTemplate: notesTemplate ?? this.notesTemplate,
      paymentInstructions: paymentInstructions ?? this.paymentInstructions,
      showLogoInPdf: showLogoInPdf ?? this.showLogoInPdf,
      showCustomerNotes: showCustomerNotes ?? this.showCustomerNotes,
      showFooter: showFooter ?? this.showFooter,
      showSealInPdf: showSealInPdf ?? this.showSealInPdf,
      showSignatureInPdf: showSignatureInPdf ?? this.showSignatureInPdf,
      defaultPdfTheme: defaultPdfTheme ?? this.defaultPdfTheme,
      defaultPdfStyleId: defaultPdfStyleId ?? this.defaultPdfStyleId,
      paperSize: paperSize ?? this.paperSize,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      compactPdfMode: compactPdfMode ?? this.compactPdfMode,
    );
  }

  String formatInvoiceNumber([int? number]) {
    final value = number ?? nextInvoiceNumber;
    return '$invoicePrefix-${value.toString().padLeft(4, '0')}';
  }

  static T _enumValue<T extends Enum>(List<T> values, Object? raw, T fallback) {
    return values.firstWhere(
      (value) => value.name == raw?.toString(),
      orElse: () => fallback,
    );
  }

  static String? _legacyStyleId(Object? rawTheme) {
    if (rawTheme == null) {
      return null;
    }
    if (rawTheme.toString() == InvoicePdfTheme.modern.name) {
      return InvoicePdfStyleIds.defaultStyleId;
    }
    return null;
  }

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String businessName;
  final String defaultCurrency;
  final String currencySymbol;
  final CurrencyPosition currencyPosition;
  final int decimalDigits;
  final AppLanguage language;
  final AppThemeMode themeMode;
  final String invoicePrefix;
  final int startingInvoiceNumber;
  final int nextInvoiceNumber;
  final bool autoIncrementEnabled;
  final double defaultTaxPercent;
  final double defaultDiscountPercent;
  final String notesTemplate;
  final String paymentInstructions;
  final bool showLogoInPdf;
  final bool showCustomerNotes;
  final bool showFooter;
  final bool showSealInPdf;
  final bool showSignatureInPdf;
  final InvoicePdfTheme defaultPdfTheme;
  final String defaultPdfStyleId;
  final PaperSizeOption paperSize;
  final double fontSizeScale;
  final bool compactPdfMode;
}
