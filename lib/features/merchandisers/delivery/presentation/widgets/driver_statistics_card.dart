// lib/features/delivery/presentation/widgets/driver_statistics_card.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../domain/entities/driver.dart';

class DriverStatisticsCard extends StatelessWidget {
  final Driver driver;

  const DriverStatisticsCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            'Active Orders',
            '${driver.activeOrdersCount ?? 0}',
            Icons.local_shipping,
            AppColors.primary,
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: AppColors.grey300,
        ),
        Expanded(
          child: _buildStatItem(
            context,
            'Completed',
            '${driver.completedOrdersCount ?? 0}',
            Icons.check_circle,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.getH3(context).copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.getBodySmall(context),
        ),
      ],
    );
  }
}
