class Customer {
  const Customer({
    required this.id,
    required this.fullName,
    required this.createdAt,
    required this.updatedAt,
    this.phone = '',
    this.alternativePhone = '',
    this.email = '',
    this.address = '',
    this.city = '',
    this.notes = '',
  });

  factory Customer.fromMap(Map<dynamic, dynamic> map) {
    return Customer(
      id: map['id']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      alternativePhone: map['alternativePhone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'alternativePhone': alternativePhone,
      'email': email,
      'address': address,
      'city': city,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? alternativePhone,
    String? email,
    String? address,
    String? city,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      alternativePhone: alternativePhone ?? this.alternativePhone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  final String id;
  final String fullName;
  final String phone;
  final String alternativePhone;
  final String email;
  final String address;
  final String city;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}
