enum InvoicePdfTheme { modern, minimal, dark }

enum PaperSizeOption { a4, thermal }

class InvoicePdfStyleIds {
  const InvoicePdfStyleIds._();

  static const defaultStyleId = 'default';
}

class InvoicePdfStyleOption {
  const InvoicePdfStyleOption({
    required this.id,
    required this.nameKey,
    required this.nameFallback,
  });

  final String id;
  final String nameKey;
  final String nameFallback;
}
