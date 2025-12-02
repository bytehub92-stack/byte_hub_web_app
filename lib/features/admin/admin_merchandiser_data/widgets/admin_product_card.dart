import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/helpers/localization_helper.dart';

class AdminProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const AdminProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  image: product.images.isNotEmpty
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(product.images[0]),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    // Placeholder icon if no image
                    if (product.images.isEmpty)
                      const Center(
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: AppColors.grey500,
                        ),
                      ),

                    // Top badges
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Featured badge
                          if (product.isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Featured',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          // Discount badge
                          if (product.hasActiveDiscount != null &&
                              product.hasActiveDiscount == true)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Sale',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Status badge (top right)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              product.isAvailable &&
                                  (product.isInStock ?? false)
                              ? AppColors.success
                              : AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.isAvailable && (product.isInStock ?? false)
                              ? 'Available'
                              : 'Out of Stock',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      LocalizationHelper.getLocalizedString(product.name),
                      style: AppTextStyles.getBodyMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Price section
                    Row(
                      children: [
                        // Current price
                        Text(
                          product.formattedPrice,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        // Original price (if on sale)
                        if (product.hasActiveDiscount ?? false) ...[
                          const SizedBox(width: 4),
                          Text(
                            product.formattedOriginalPrice,
                            style: const TextStyle(
                              color: AppColors.grey500,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Stock, Unit and rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Stock quantity with unit
                        Expanded(
                          child: Text(
                            _getStockText(),
                            style: TextStyle(
                              fontSize: 11,
                              color: product.stockQuantity > 0
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Rating
                        if (product.rating > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // SKU and Unit on separate line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // SKU
                        if (product.sku != null)
                          Expanded(
                            child: Text(
                              'SKU: ${product.sku}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.grey500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        // Unit badge
                        if (product.unitName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.getUnitDisplay('en'),
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.grey700,
                                fontWeight: FontWeight.w500,
                              ),
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
      ),
    );
  }

  String _getStockText() {
    final unitName = product.unitName?['en'] ?? 'units';
    return 'Stock: ${product.stockQuantity} $unitName';
  }
}
