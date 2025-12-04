// lib/features/admin/data/models/admin_stats_model.dart

import '../../domain/entities/admin_stats.dart';

class AdminStatsModel extends AdminStats {
  const AdminStatsModel({
    required super.totalMerchandisers,
    required super.totalCustomers,
    required super.totalCategories,
    required super.totalProducts,
    super.activeMerchandisers,
    super.inactiveCustomers,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalMerchandisers: json['total_merchandisers'] as int? ?? 0,
      totalCustomers: json['total_customers'] as int? ?? 0,
      totalCategories: json['total_categories'] as int? ?? 0,
      totalProducts: json['total_products'] as int? ?? 0,
      activeMerchandisers: json['active_merchandisers'] as int? ?? 0,
      inactiveCustomers: json['inactive_customers'] as int? ?? 0,
    );
  }
}
