// lib/features/orders/presentation/widgets/order_status_chip.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';

class OrderStatusChip extends StatelessWidget {
  final String status;
  final bool isCompact;

  const OrderStatusChip({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: isCompact ? 14 : 16, color: config.color),
          SizedBox(width: isCompact ? 4 : 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: isCompact ? 11 : 13,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusConfig(
          label: 'Pending',
          color: AppColors.warning,
          icon: Icons.schedule,
        );
      case 'confirmed':
        return _StatusConfig(
          label: 'Confirmed',
          color: AppColors.info,
          icon: Icons.check_circle_outline,
        );
      case 'preparing':
        return _StatusConfig(
          label: 'Preparing',
          color: Colors.orange,
          icon: Icons.kitchen,
        );
      case 'on_the_way':
        return _StatusConfig(
          label: 'On the Way',
          color: Colors.purple,
          icon: Icons.local_shipping,
        );
      case 'delivered':
        return _StatusConfig(
          label: 'Delivered',
          color: AppColors.success,
          icon: Icons.check_circle,
        );
      case 'cancelled':
        return _StatusConfig(
          label: 'Cancelled',
          color: AppColors.error,
          icon: Icons.cancel,
        );
      default:
        return _StatusConfig(
          label: status,
          color: AppColors.grey500,
          icon: Icons.info,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig({required this.label, required this.color, required this.icon});
}
