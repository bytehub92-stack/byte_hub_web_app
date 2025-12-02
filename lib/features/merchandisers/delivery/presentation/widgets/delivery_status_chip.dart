// lib/features/delivery/presentation/widgets/delivery_status_chip.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';

class DeliveryStatusChip extends StatelessWidget {
  final String status;

  const DeliveryStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor().withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: 16, color: _getStatusColor()),
          const SizedBox(width: 6),
          Text(
            _getStatusLabel(),
            style: TextStyle(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'assigned':
        return AppColors.info;
      case 'picked_up':
        return Colors.orange;
      case 'on_the_way':
        return Colors.purple;
      case 'delivered':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'assigned':
        return Icons.assignment;
      case 'picked_up':
        return Icons.shopping_bag;
      case 'on_the_way':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case 'assigned':
        return 'Assigned';
      case 'picked_up':
        return 'Picked Up';
      case 'on_the_way':
        return 'On the Way';
      case 'delivered':
        return 'Delivered';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }
}
