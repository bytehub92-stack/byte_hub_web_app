// lib/features/shared/domain/entities/customer.dart

class Customer {
  final String id;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? avatarUrl;
  final String preferredLanguage;
  final String? merchandiserId;
  final int totalOrders;
  final double totalSpent;
  final DateTime? lastOrderDate;

  const Customer({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
    this.avatarUrl,
    required this.preferredLanguage,
    this.merchandiserId,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.lastOrderDate,
  });
}
