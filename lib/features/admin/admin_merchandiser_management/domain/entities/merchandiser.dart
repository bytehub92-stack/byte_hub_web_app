// lib/features/shared/domain/entities/merchandiser.dart

class Merchandiser {
  final String id;
  final String profileId;
  final Map<String, String> businessName;
  final Map<String, String>? businessType;
  final Map<String, String>? description;
  final String? logoUrl;
  final String? website;
  final Map<String, String>? address;
  final Map<String, String>? city;
  final Map<String, String>? state;
  final Map<String, String>? country;
  final String? postalCode;
  final String? taxId;
  final bool isActive;
  final String subscriptionPlan;
  final DateTime? subscriptionExpiresAt;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  // From view
  final String? contactName;
  final String? email;
  final String? phoneNumber;
  final DateTime? lastLogin;
  final int totalCustomers;
  final int totalCategories;
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;

  const Merchandiser({
    required this.id,
    required this.profileId,
    required this.businessName,
    this.businessType,
    this.description,
    this.logoUrl,
    this.website,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.taxId,
    required this.isActive,
    required this.subscriptionPlan,
    this.subscriptionExpiresAt,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
    this.contactName,
    this.email,
    this.phoneNumber,
    this.lastLogin,
    this.totalCustomers = 0,
    this.totalCategories = 0,
    this.totalProducts = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0.0,
  });

  String getLocalizedBusinessName(String languageCode) {
    return businessName[languageCode] ??
        businessName['en'] ??
        'Unknown Business';
  }

  String? getLocalizedDescription(String languageCode) {
    if (description == null) return null;
    return description![languageCode] ?? description!['en'];
  }
}
