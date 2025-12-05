import 'package:uuid/uuid.dart';

class Borrower {
  final String borrowerId;
  final String userId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Borrower({
    String? borrowerId,
    required this.userId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : borrowerId = borrowerId ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'borrower_id': borrowerId,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Borrower.fromMap(Map<String, dynamic> map) {
    return Borrower(
      borrowerId: map['borrower_id'],
      userId: map['user_id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Borrower copyWith({
    String? borrowerId,
    String? userId,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Borrower(
      borrowerId: borrowerId ?? this.borrowerId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
