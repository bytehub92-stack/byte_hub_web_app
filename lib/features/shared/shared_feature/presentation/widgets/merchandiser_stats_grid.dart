import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/merchandiser_stats.dart';
import 'package:admin_panel/features/shared/shared_feature/presentation/widgets/stat_card.dart';
import 'package:flutter/material.dart';

class MerchandiserStatsGrid extends StatelessWidget {
  final MerchandiserStats stats;
  final bool isLoading;

  const MerchandiserStatsGrid({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        StatCard(
          title: 'Categories',
          value: stats.categoriesCount.toString(),
          icon: Icons.category,
          color: AppColors.primary,
        ),
        StatCard(
          title: 'Products',
          value: stats.productsCount.toString(),
          icon: Icons.inventory,
          color: AppColors.secondary,
        ),
        StatCard(
          title: 'Active Customers',
          value: stats.customersCount.toString(),
          icon: Icons.people,
          color: AppColors.info,
        ),
        StatCard(
          title: 'Completed Orders',
          value: stats.completedOrdersCount.toString(),
          icon: Icons.done_all,
          color: AppColors.warning,
        ),
        StatCard(
          title: 'Pending Orders',
          value: stats.pendingOrdersCount.toString(),
          icon: Icons.pending_actions,
          color: AppColors.error,
        ),
      ],
    );
  }
}
