// lib/features/admin/domain/entities/admin_stats.dart

class AdminStats {
  final int totalMerchandisers;
  final int totalCustomers;
  final int totalCategories;
  final int totalProducts;
  final int activeMerchandisers;
  final int inactiveCustomers;

  const AdminStats({
    required this.totalMerchandisers,
    required this.totalCustomers,
    required this.totalCategories,
    required this.totalProducts,
    this.activeMerchandisers = 0,
    this.inactiveCustomers = 0,
  });
}
