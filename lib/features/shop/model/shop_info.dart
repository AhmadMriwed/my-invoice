class ShopInfo {
  const ShopInfo({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.shopName = '',
    this.ownerName = '',
    this.phoneNumber = '',
    this.email = '',
    this.address = '',
    this.taxNumber = '',
    this.logoPath = '',
    this.currency = r'$',
    this.notes = '',
  });

  factory ShopInfo.fromMap(Map<dynamic, dynamic>? map) {
    final now = DateTime.now();
    if (map == null) {
      return ShopInfo(id: 'default_shop', createdAt: now, updatedAt: now);
    }

    return ShopInfo(
      id: map['id']?.toString() ?? 'default_shop',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? now,
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? now,
      shopName: map['shopName']?.toString() ?? '',
      ownerName: map['ownerName']?.toString() ?? '',
      phoneNumber: map['phoneNumber']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      taxNumber: map['taxNumber']?.toString() ?? '',
      logoPath: map['logoPath']?.toString() ?? '',
      currency: map['currency']?.toString() ?? r'$',
      notes: map['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'shopName': shopName,
      'ownerName': ownerName,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'taxNumber': taxNumber,
      'logoPath': logoPath,
      'currency': currency,
      'notes': notes,
    };
  }

  ShopInfo copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? shopName,
    String? ownerName,
    String? phoneNumber,
    String? email,
    String? address,
    String? taxNumber,
    String? logoPath,
    String? currency,
    String? notes,
  }) {
    return ShopInfo(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      logoPath: logoPath ?? this.logoPath,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
    );
  }

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String shopName;
  final String ownerName;
  final String phoneNumber;
  final String email;
  final String address;
  final String taxNumber;
  final String logoPath;
  final String currency;
  final String notes;
}
