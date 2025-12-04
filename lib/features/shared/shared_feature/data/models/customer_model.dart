// lib/features/shared/data/models/customer_model.dart

import 'package:admin_panel/features/shared/shared_feature/domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.email,
    super.phoneNumber,
    required super.fullName,
    required super.isActive,
    required super.createdAt,
    super.lastLogin,
    super.avatarUrl,
    required super.preferredLanguage,
    super.merchandiserId,
    super.totalOrders,
    super.totalSpent,
    super.lastOrderDate,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      fullName: json['full_name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      avatarUrl: json['avatar_url'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      merchandiserId: json['merchandiser_id'] as String?,
      totalOrders: json['total_orders'] as int? ?? 0,
      totalSpent: _parseNumeric(json['total_spent'] ?? 0),
      lastOrderDate: json['last_order_date'] != null
          ? DateTime.parse(json['last_order_date'] as String)
          : null,
    );
  }

  static double _parseNumeric(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
