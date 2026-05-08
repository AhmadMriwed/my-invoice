import 'invoice_item.dart';

enum InvoiceStatus { draft, saved, paid, overdue, cancelled }

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
    this.status = InvoiceStatus.saved,
    this.discount = 0,
    this.tax = 0,
    this.notes = '',
  });

  factory Invoice.fromMap(Map<dynamic, dynamic> map) {
    final itemMaps = (map['items'] as List<dynamic>? ?? const []);

    return Invoice(
      id: map['id']?.toString() ?? '',
      invoiceNumber: map['invoiceNumber']?.toString() ?? '',
      customerId: map['customerId']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
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
    );
  }

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);

  double get safeDiscount => _nonNegative(discount);

  double get safeTax => _nonNegative(tax);

  double get finalTotal => subtotal - safeDiscount + safeTax;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'customerName': customerName,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'status': status.name,
      'discount': safeDiscount,
      'tax': safeTax,
      'notes': notes,
    };
  }

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<InvoiceItem>? items,
    InvoiceStatus? status,
    double? discount,
    double? tax,
    String? notes,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      status: status ?? this.status,
      discount: _nonNegative(discount ?? this.discount),
      tax: _nonNegative(tax ?? this.tax),
      notes: notes ?? this.notes,
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
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<InvoiceItem> items;
  final InvoiceStatus status;
  final double discount;
  final double tax;
  final String notes;
}
