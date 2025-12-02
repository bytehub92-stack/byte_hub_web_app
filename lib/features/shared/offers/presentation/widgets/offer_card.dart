// lib/features/offers/presentation/widgets/offer_card.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final Function(bool) onToggleStatus;

  const OfferCard({
    super.key,
    required this.offer,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Column(
        children: [
          // Header with Image and Basic Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.defaultRadius),
                  bottomLeft: Radius.circular(AppConstants.defaultRadius),
                ),
                child: CachedNetworkImage(
                  imageUrl: offer.imageUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 120,
                    height: 120,
                    color: AppColors.grey200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 120,
                    height: 120,
                    color: AppColors.grey200,
                    child: const Icon(Icons.local_offer, size: 40),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Status Badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              offer.getTitle('en'),
                              style: AppTextStyles.bodyLargeLight.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(offer.isActive),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Type Badge
                      _buildTypeBadge(offer.type),

                      const SizedBox(height: 8),

                      // Description
                      Text(
                        offer.getDescription('en'),
                        style: AppTextStyles.bodySmallLight,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // Date Range
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColors.grey600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormat.yMMMd().format(offer.startDate)} - ${DateFormat.yMMMd().format(offer.endDate)}',
                            style: AppTextStyles.bodySmallLight.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 1),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.smallPadding,
              vertical: AppConstants.smallPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Active/Inactive Toggle
                TextButton.icon(
                  onPressed: () => onToggleStatus(!offer.isActive),
                  icon: Icon(
                    offer.isActive ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                  ),
                  label: Text(offer.isActive ? 'Deactivate' : 'Activate'),
                  style: TextButton.styleFrom(
                    foregroundColor: offer.isActive
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),

                const SizedBox(width: 8),

                // Edit Button
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),

                const SizedBox(width: 8),

                // Delete Button
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.grey300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.success : AppColors.grey700,
        ),
      ),
    );
  }

  Widget _buildTypeBadge(OfferType type) {
    String label;
    Color color;
    IconData icon;

    switch (type) {
      case OfferType.bundle:
        label = 'Bundle';
        color = AppColors.primary;
        icon = Icons.inventory_2;
        break;
      case OfferType.bogo:
        label = 'BOGO';
        color = AppColors.secondary;
        icon = Icons.card_giftcard;
        break;
      case OfferType.discount:
        label = 'Discount';
        color = AppColors.accent;
        icon = Icons.discount;
        break;
      case OfferType.minPurchase:
        label = 'Min Purchase';
        color = AppColors.info;
        icon = Icons.shopping_cart;
        break;
      case OfferType.freeItem:
        label = 'Free Item';
        color = AppColors.success;
        icon = Icons.redeem;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
