// lib/features/shared/data/models/merchandiser_model.dart

import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/entities/merchandiser.dart';

class MerchandiserModel extends Merchandiser {
  const MerchandiserModel({
    required super.id,
    required super.profileId,
    required super.businessName,
    super.businessType,
    super.description,
    super.logoUrl,
    super.website,
    super.address,
    super.city,
    super.state,
    super.country,
    super.postalCode,
    super.taxId,
    required super.isActive,
    required super.subscriptionPlan,
    super.subscriptionExpiresAt,
    super.settings,
    required super.createdAt,
    required super.updatedAt,
    super.contactName,
    super.email,
    super.phoneNumber,
    super.lastLogin,
    super.totalCustomers,
    super.totalCategories,
    super.totalProducts,
    super.totalOrders,
    super.totalRevenue,
  });

  factory MerchandiserModel.fromJson(Map<String, dynamic> json) {
    return MerchandiserModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      businessName: _parseJsonbField(json['business_name']),
      businessType: json['business_type'] != null
          ? _parseJsonbField(json['business_type'])
          : null,
      description: json['description'] != null
          ? _parseJsonbField(json['description'])
          : null,
      logoUrl: json['logo_url'] as String?,
      website: json['website'] as String?,
      address: json['address'] != null
          ? _parseJsonbField(json['address'])
          : null,
      city: json['city'] != null ? _parseJsonbField(json['city']) : null,
      state: json['state'] != null ? _parseJsonbField(json['state']) : null,
      country: json['country'] != null
          ? _parseJsonbField(json['country'])
          : null,
      postalCode: json['postal_code'] as String?,
      taxId: json['tax_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      subscriptionPlan: json['subscription_plan'] as String? ?? 'basic',
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'] as String)
          : null,
      settings: json['settings'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      contactName: json['contact_name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      totalCustomers: json['total_customers'] as int? ?? 0,
      totalCategories: json['total_categories'] as int? ?? 0,
      totalProducts: json['total_products'] as int? ?? 0,
      totalOrders: json['total_orders'] as int? ?? 0,
      totalRevenue: _parseNumeric(json['total_revenue'] ?? 0),
    );
  }

  static Map<String, String> _parseJsonbField(dynamic field) {
    if (field == null) return {};
    if (field is Map) {
      return field.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    if (field is String) {
      return {'en': field};
    }
    return {};
  }

  static double _parseNumeric(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
