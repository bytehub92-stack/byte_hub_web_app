import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/offers/presentation/widgets/offer_badge_widget.dart';
import 'package:admin_panel/features/shared/offers/services/offer_indicator_service.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final offerService = sl<OfferIndicatorService>();

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(offerService),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name['en'] ?? 'N/A',
                    style: AppTextStyles.bodyMediumLight.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name['ar'] ?? 'غير متوفر',
                    style: AppTextStyles.bodySmallLight.copyWith(
                      color: AppColors.grey500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                  const Spacer(),
                  _buildPriceRow(),
                  const SizedBox(height: 8),
                  _buildStockStatus(),
                  const SizedBox(height: 8),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(OfferIndicatorService offerService) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: product.images.isNotEmpty
              ? CachedNetworkImage(
                  height: 300,
                  imageUrl: product.images.first,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorWidget: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
                )
              : _buildPlaceholder(),
        ),
        if (!product.isAvailable)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(
                child: Chip(
                  label: Text(
                    'Unavailable',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppColors.error,
                ),
              ),
            ),
          ),

        // Featured badge
        if (product.isFeatured)
          const Positioned(
            top: 8,
            right: 8,
            child: Icon(Icons.star, color: AppColors.accent, size: 24),
          ),

        // Discount badge (from product's own discount)
        if (product.discountPrice != null && product.discountPrice! > 0)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_calculateDiscountPercentage()}% OFF',
                style: AppTextStyles.bodySmallLight.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Offer badge (from offers system)
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: ProductOfferBadge(
            productId: product.id,
            offerService: offerService,
            isSmall: false,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.grey200,
      child: const Icon(Icons.image, size: 48, color: AppColors.grey400),
    );
  }

  Widget _buildPriceRow() {
    if (product.discountPrice != null && product.discountPrice! > 0) {
      return Row(
        children: [
          Text(
            'EGP${product.discountPrice!.toStringAsFixed(2)}',
            style: AppTextStyles.bodyMediumLight.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'EGP${product.price.toStringAsFixed(2)}',
            style: AppTextStyles.bodySmallLight.copyWith(
              decoration: TextDecoration.lineThrough,
              color: AppColors.grey500,
            ),
          ),
        ],
      );
    }

    return Text(
      'EGP${product.price.toStringAsFixed(2)}',
      style: AppTextStyles.bodyMediumLight.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildStockStatus() {
    final inStock = product.stockQuantity > 0;
    final isLowStock = product.stockQuantity > 0 && product.stockQuantity <= 10;
    final unitName = product.unitName?['en'] ?? 'units';

    return Row(
      children: [
        Icon(
          inStock ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: inStock
              ? (isLowStock ? AppColors.warning : AppColors.success)
              : AppColors.error,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            inStock
                ? '${product.stockQuantity} $unitName in stock'
                : 'Out of stock',
            style: AppTextStyles.bodySmallLight.copyWith(
              color: inStock
                  ? (isLowStock ? AppColors.warning : AppColors.success)
                  : AppColors.error,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Icon(Icons.edit, size: 16),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: onDelete,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              side: const BorderSide(color: AppColors.error),
            ),
            child: const Icon(Icons.delete, size: 16, color: AppColors.error),
          ),
        ),
      ],
    );
  }

  int _calculateDiscountPercentage() {
    if (product.discountPrice == null || product.discountPrice! <= 0) {
      return 0;
    }
    return (((product.price - product.discountPrice!) / product.price) * 100)
        .round();
  }
}
