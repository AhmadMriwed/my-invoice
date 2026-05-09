import 'invoice_item.dart';

enum InvoiceStatus { draft, saved, paid, overdue, cancelled }

enum InvoiceDocumentType { invoice, quote, custom }

enum InvoicePaymentMethod { cash, credit, custom }

class Invoice {
  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.customerId = '',
    this.customerName = '',
    this.currencyCode = 'USD',
    this.currencySymbol = r'$',
    this.status = InvoiceStatus.saved,
    this.discount = 0,
    this.tax = 0,
    this.notes = '',
    this.documentType = InvoiceDocumentType.invoice,
    this.customDocumentType = '',
    this.paymentMethod = InvoicePaymentMethod.cash,
    this.customPaymentMethod = '',
  });

  factory Invoice.fromMap(Map<dynamic, dynamic> map) {
    final itemMaps = (map['items'] as List<dynamic>? ?? const []);

    return Invoice(
      id: map['id']?.toString() ?? '',
      invoiceNumber: map['invoiceNumber']?.toString() ?? '',
      customerId: map['customerId']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
      currencyCode: map['currencyCode']?.toString() ?? 'USD',
      currencySymbol: map['currencySymbol']?.toString() ?? r'$',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      items: itemMaps
          .whereType<Map<dynamic, dynamic>>()
          .map(InvoiceItem.fromMap)
          .toList(),
      status: InvoiceStatus.values.firstWhere(
        (status) => status.name == map['status']?.toString(),
        orElse: () => InvoiceStatus.saved,
      ),
      discount: _nonNegative((map['discount'] as num?)?.toDouble() ?? 0),
      tax: _nonNegative((map['tax'] as num?)?.toDouble() ?? 0),
      notes: map['notes']?.toString() ?? '',
      documentType: _enumValue(
        InvoiceDocumentType.values,
        map['documentType'],
        InvoiceDocumentType.invoice,
      ),
      customDocumentType: map['customDocumentType']?.toString() ?? '',
      paymentMethod: _enumValue(
        InvoicePaymentMethod.values,
        map['paymentMethod'],
        InvoicePaymentMethod.cash,
      ),
      customPaymentMethod: map['customPaymentMethod']?.toString() ?? '',
    );
  }

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);

  double get safeDiscount => _nonNegative(discount);

  double get safeTax => _nonNegative(tax);

  double get finalTotal => subtotal - safeDiscount + safeTax;

  String get effectiveDocumentType {
    final custom = customDocumentType.trim();
    if (documentType == InvoiceDocumentType.custom && custom.isNotEmpty) {
      return custom;
    }
    return documentType.name;
  }

  String get effectivePaymentMethod {
    if (documentType != InvoiceDocumentType.invoice) {
      return '';
    }
    final custom = customPaymentMethod.trim();
    if (paymentMethod == InvoicePaymentMethod.custom && custom.isNotEmpty) {
      return custom;
    }
    return paymentMethod.name;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'customerName': customerName,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'status': status.name,
      'discount': safeDiscount,
      'tax': safeTax,
      'notes': notes,
      'documentType': documentType.name,
      'customDocumentType': customDocumentType,
      'paymentMethod': paymentMethod.name,
      'customPaymentMethod': customPaymentMethod,
    };
  }

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    String? currencyCode,
    String? currencySymbol,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<InvoiceItem>? items,
    InvoiceStatus? status,
    double? discount,
    double? tax,
    String? notes,
    InvoiceDocumentType? documentType,
    String? customDocumentType,
    InvoicePaymentMethod? paymentMethod,
    String? customPaymentMethod,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      status: status ?? this.status,
      discount: _nonNegative(discount ?? this.discount),
      tax: _nonNegative(tax ?? this.tax),
      notes: notes ?? this.notes,
      documentType: documentType ?? this.documentType,
      customDocumentType: customDocumentType ?? this.customDocumentType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customPaymentMethod: customPaymentMethod ?? this.customPaymentMethod,
    );
  }

  static T _enumValue<T extends Enum>(List<T> values, Object? raw, T fallback) {
    return values.firstWhere(
      (value) => value.name == raw?.toString(),
      orElse: () => fallback,
    );
  }

  static double _nonNegative(double value) {
    if (value.isNaN || value.isInfinite || value < 0) {
      return 0;
    }
    return value;
  }

  final String id;
  final String invoiceNumber;
  final String customerId;
  final String customerName;
  final String currencyCode;
  final String currencySymbol;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<InvoiceItem> items;
  final InvoiceStatus status;
  final double discount;
  final double tax;
  final String notes;
  final InvoiceDocumentType documentType;
  final String customDocumentType;
  final InvoicePaymentMethod paymentMethod;
  final String customPaymentMethod;
}
