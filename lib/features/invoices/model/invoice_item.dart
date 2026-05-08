class InvoiceItem {
  const InvoiceItem({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath = '',
    this.quantity = 1,
    this.unitPrice = 0,
    this.notes = '',
  });

  factory InvoiceItem.fromMap(Map<dynamic, dynamic> map) {
    return InvoiceItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      imagePath: map['imagePath']?.toString() ?? '',
      quantity: _positive((map['quantity'] as num?)?.toDouble() ?? 1, 1),
      unitPrice: _positive((map['unitPrice'] as num?)?.toDouble() ?? 0, 0),
      notes: map['notes']?.toString() ?? '',
    );
  }

  double get total => safeQuantity * safeUnitPrice;

  double get safeQuantity => _positive(quantity, 1);

  double get safeUnitPrice => _positive(unitPrice, 0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imagePath': imagePath,
      'quantity': safeQuantity,
      'unitPrice': safeUnitPrice,
      'notes': notes,
    };
  }

  InvoiceItem copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imagePath,
    double? quantity,
    double? unitPrice,
    String? notes,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imagePath: imagePath ?? this.imagePath,
      quantity: _positive(quantity ?? this.quantity, 1),
      unitPrice: _positive(unitPrice ?? this.unitPrice, 0),
      notes: notes ?? this.notes,
    );
  }

  static double _positive(double value, double fallback) {
    if (value.isNaN || value.isInfinite || value < 0) {
      return fallback;
    }
    return value;
  }

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String imagePath;
  final double quantity;
  final double unitPrice;
  final String notes;
}
