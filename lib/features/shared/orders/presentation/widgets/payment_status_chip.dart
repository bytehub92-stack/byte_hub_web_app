// lib/features/orders/presentation/widgets/payment_status_chip.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';

class PaymentStatusChip extends StatelessWidget {
  final String paymentStatus;
  final bool isCompact;

  const PaymentStatusChip({
    super.key,
    required this.paymentStatus,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getPaymentConfig(paymentStatus);

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

  _PaymentConfig _getPaymentConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _PaymentConfig(
          label: 'Pending',
          color: AppColors.warning,
          icon: Icons.pending,
        );
      case 'paid':
        return _PaymentConfig(
          label: 'Paid',
          color: AppColors.success,
          icon: Icons.check_circle,
        );
      case 'failed':
        return _PaymentConfig(
          label: 'Failed',
          color: AppColors.error,
          icon: Icons.error,
        );
      case 'refunded':
        return _PaymentConfig(
          label: 'Refunded',
          color: AppColors.info,
          icon: Icons.refresh,
        );
      default:
        return _PaymentConfig(
          label: status,
          color: AppColors.grey500,
          icon: Icons.payment,
        );
    }
  }
}

class _PaymentConfig {
  final String label;
  final Color color;
  final IconData icon;

  _PaymentConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}
