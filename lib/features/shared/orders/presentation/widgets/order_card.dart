// lib/features/orders/presentation/widgets/order_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/order.dart';
import 'order_status_chip.dart';
import 'payment_status_chip.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: AppTextStyles.getH4(
                            context,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'MMM dd, yyyy - hh:mm a',
                          ).format(order.createdAt),
                          style: AppTextStyles.getBodySmall(
                            context,
                          ).copyWith(color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'EGP${order.totalAmount.toStringAsFixed(2)}',
                        style: AppTextStyles.getH4(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Customer Info
              if (order.customerName != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: AppColors.grey600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.customerName!,
                        style: AppTextStyles.getBodyMedium(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              if (order.customerPhone != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 18,
                      color: AppColors.grey600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.customerPhone!,
                      style: AppTextStyles.getBodyMedium(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Merchandiser Info (for admin view)
              if (order.merchandiserName != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.store_outlined,
                      size: 18,
                      color: AppColors.grey600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.merchandiserName!,
                      style: AppTextStyles.getBodyMedium(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              if (order.appliedOfferId != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_offer,
                        size: 12,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.offerDetails?['title']?['en'] ?? 'Offer Applied',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 4.0),
              // Status Chips
              Row(
                children: [
                  OrderStatusChip(status: order.status),
                  const SizedBox(width: 8),
                  PaymentStatusChip(paymentStatus: order.paymentStatus),
                  const Spacer(),
                  if (order.paymentMethod != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPaymentMethodIcon(order.paymentMethod!),
                            size: 14,
                            color: AppColors.grey700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPaymentMethodLabel(order.paymentMethod!),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash_on_delivery':
        return Icons.money;
      case 'visa':
        return Icons.credit_card;
      case 'instapay':
        return Icons.account_balance;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'cash_on_delivery':
        return 'COD';
      case 'visa':
        return 'Visa';
      case 'instapay':
        return 'InstaPay';
      case 'wallet':
        return 'Wallet';
      default:
        return method;
    }
  }
}
