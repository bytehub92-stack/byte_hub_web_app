// lib/features/orders/presentation/widgets/order_timeline.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';

class OrderTimeline extends StatelessWidget {
  final String currentStatus;

  const OrderTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = _getOrderSteps();
    final currentIndex = steps.indexWhere((s) => s.status == currentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Timeline',
          style: AppTextStyles.getH4(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          itemBuilder: (context, index) {
            final step = steps[index];
            final isCompleted = index <= currentIndex;
            final isCurrent = index == currentIndex;
            final isLast = index == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.primary
                            : AppColors.grey300,
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.grey400,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : step.icon,
                        color: isCompleted ? Colors.white : AppColors.grey600,
                        size: 20,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 50,
                        color: isCompleted
                            ? AppColors.primary
                            : AppColors.grey300,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: AppTextStyles.getBodyMedium(context).copyWith(
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isCompleted
                                ? AppColors.textDark
                                : AppColors.grey500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.description,
                          style: AppTextStyles.getBodySmall(
                            context,
                          ).copyWith(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<_TimelineStep> _getOrderSteps() {
    return [
      _TimelineStep(
        status: 'pending',
        label: 'Order Placed',
        description: 'Your order has been received',
        icon: Icons.receipt_long,
      ),
      _TimelineStep(
        status: 'confirmed',
        label: 'Order Confirmed',
        description: 'Order has been confirmed by merchandiser',
        icon: Icons.check_circle_outline,
      ),
      _TimelineStep(
        status: 'preparing',
        label: 'Preparing',
        description: 'Your order is being prepared',
        icon: Icons.kitchen,
      ),
      _TimelineStep(
        status: 'on_the_way',
        label: 'On the Way',
        description: 'Your order is out for delivery',
        icon: Icons.local_shipping,
      ),
      _TimelineStep(
        status: 'delivered',
        label: 'Delivered',
        description: 'Order has been delivered',
        icon: Icons.check_circle,
      ),
    ];
  }
}

class _TimelineStep {
  final String status;
  final String label;
  final String description;
  final IconData icon;

  _TimelineStep({
    required this.status,
    required this.label,
    required this.description,
    required this.icon,
  });
}
