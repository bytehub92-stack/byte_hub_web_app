// lib/features/orders/presentation/widgets/order_filters.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';

class OrderFilters extends StatelessWidget {
  final String? selectedStatus;
  final String? selectedPaymentStatus;
  final Function(String?) onStatusChanged;
  final Function(String?) onPaymentStatusChanged;
  final VoidCallback onClearFilters;

  const OrderFilters({
    super.key,
    this.selectedStatus,
    this.selectedPaymentStatus,
    required this.onStatusChanged,
    required this.onPaymentStatusChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedStatus != null || selectedPaymentStatus != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Filters', style: AppTextStyles.getH4(context)),
                const Spacer(),
                if (hasFilters)
                  TextButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Clear All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Order Status Filter
            Text(
              'Order Status',
              style: AppTextStyles.getBodyMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(
                  context,
                  label: 'All',
                  isSelected: selectedStatus == null,
                  onTap: () => onStatusChanged(null),
                ),
                _buildFilterChip(
                  context,
                  label: 'Pending',
                  isSelected: selectedStatus == 'pending',
                  onTap: () => onStatusChanged('pending'),
                ),
                _buildFilterChip(
                  context,
                  label: 'Confirmed',
                  isSelected: selectedStatus == 'confirmed',
                  onTap: () => onStatusChanged('confirmed'),
                ),
                _buildFilterChip(
                  context,
                  label: 'Preparing',
                  isSelected: selectedStatus == 'preparing',
                  onTap: () => onStatusChanged('preparing'),
                ),
                _buildFilterChip(
                  context,
                  label: 'On the Way',
                  isSelected: selectedStatus == 'on_the_way',
                  onTap: () => onStatusChanged('on_the_way'),
                ),
                _buildFilterChip(
                  context,
                  label: 'Delivered',
                  isSelected: selectedStatus == 'delivered',
                  onTap: () => onStatusChanged('delivered'),
                ),
                _buildFilterChip(
                  context,
                  label: 'Cancelled',
                  isSelected: selectedStatus == 'cancelled',
                  onTap: () => onStatusChanged('cancelled'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Payment Status Filter
            Text(
              'Payment Status',
              style: AppTextStyles.getBodyMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(
                  context,
                  label: 'All',
                  isSelected: selectedPaymentStatus == null,
                  onTap: () => onPaymentStatusChanged(null),
                ),
                _buildFilterChip(
                  context,
                  label: 'Pending',
                  isSelected: selectedPaymentStatus == 'pending',
                  onTap: () => onPaymentStatusChanged('pending'),
                ),
                _buildFilterChip(
                  context,
                  label: 'Paid',
                  isSelected: selectedPaymentStatus == 'paid',
                  onTap: () => onPaymentStatusChanged('paid'),
                ),
                _buildFilterChip(
                  context,
                  label: 'Failed',
                  isSelected: selectedPaymentStatus == 'failed',
                  onTap: () => onPaymentStatusChanged('failed'),
                ),
                _buildFilterChip(
                  context,
                  label: 'Refunded',
                  isSelected: selectedPaymentStatus == 'refunded',
                  onTap: () => onPaymentStatusChanged('refunded'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.grey700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
