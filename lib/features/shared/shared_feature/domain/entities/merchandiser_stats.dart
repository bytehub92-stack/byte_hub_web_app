class MerchandiserStats {
  final int categoriesCount;
  final int productsCount;
  final int customersCount;
  final int completedOrdersCount;
  final int pendingOrdersCount;

  const MerchandiserStats({
    required this.categoriesCount,
    required this.productsCount,
    required this.customersCount,
    required this.completedOrdersCount,
    required this.pendingOrdersCount,
  });
}
