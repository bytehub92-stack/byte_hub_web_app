// lib/features/offers/presentation/widgets/offer_badge_widget.dart
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/offers/services/offer_indicator_service.dart';
import 'package:flutter/material.dart';

class OfferBadgeWidget extends StatelessWidget {
  final OfferInfo offerInfo;
  final bool isSmall;

  const OfferBadgeWidget({
    super.key,
    required this.offerInfo,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(isSmall ? 4 : 6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: isSmall ? 12 : 14, color: Colors.white),
          SizedBox(width: isSmall ? 3 : 4),
          Text(
            offerInfo.label,
            style:
                (isSmall
                        ? AppTextStyles.bodySmallLight
                        : AppTextStyles.bodyMediumLight)
                    .copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmall ? 10 : 12,
                    ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (offerInfo.color) {
      case OfferColor.red:
        return AppColors.error;
      case OfferColor.green:
        return AppColors.success;
      case OfferColor.purple:
        return Colors.purple;
      case OfferColor.orange:
        return AppColors.warning;
      case OfferColor.blue:
        return AppColors.info;
    }
  }

  IconData _getIcon() {
    switch (offerInfo.color) {
      case OfferColor.red:
        return Icons.local_offer;
      case OfferColor.green:
        return Icons.add_shopping_cart;
      case OfferColor.purple:
        return Icons.inventory;
      case OfferColor.orange:
        return Icons.card_giftcard;
      case OfferColor.blue:
        return Icons.shopping_bag;
    }
  }
}

/// Widget that shows multiple offer badges
class OfferBadgesStack extends StatelessWidget {
  final List<OfferInfo> offers;
  final bool isSmall;
  final int maxVisible;

  const OfferBadgesStack({
    super.key,
    required this.offers,
    this.isSmall = false,
    this.maxVisible = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();

    final visibleOffers = offers.take(maxVisible).toList();
    final hasMore = offers.length > maxVisible;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...visibleOffers.map(
          (offer) => OfferBadgeWidget(offerInfo: offer, isSmall: isSmall),
        ),
        if (hasMore)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 6 : 8,
              vertical: isSmall ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.grey600,
              borderRadius: BorderRadius.circular(isSmall ? 4 : 6),
            ),
            child: Text(
              '+${offers.length - maxVisible}',
              style:
                  (isSmall
                          ? AppTextStyles.bodySmallLight
                          : AppTextStyles.bodyMediumLight)
                      .copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmall ? 10 : 12,
                      ),
            ),
          ),
      ],
    );
  }
}

/// Future builder widget for product offers
class ProductOfferBadge extends StatelessWidget {
  final String productId;
  final OfferIndicatorService offerService;
  final bool isSmall;

  const ProductOfferBadge({
    super.key,
    required this.productId,
    required this.offerService,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OfferInfo?>(
      future: offerService.getProductOfferInfo(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: isSmall ? 12 : 16,
            height: isSmall ? 12 : 16,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return OfferBadgeWidget(offerInfo: snapshot.data!, isSmall: isSmall);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Future builder widget for category offers
class CategoryOfferBadges extends StatelessWidget {
  final String categoryId;
  final OfferIndicatorService offerService;
  final bool isSmall;

  const CategoryOfferBadges({
    super.key,
    required this.categoryId,
    required this.offerService,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OfferInfo>>(
      future: offerService.getCategoryOfferInfo(categoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: isSmall ? 12 : 16,
            height: isSmall ? 12 : 16,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return OfferBadgesStack(offers: snapshot.data!, isSmall: isSmall);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Future builder widget for sub-category offers
class SubCategoryOfferBadges extends StatelessWidget {
  final String subCategoryId;
  final OfferIndicatorService offerService;
  final bool isSmall;

  const SubCategoryOfferBadges({
    super.key,
    required this.subCategoryId,
    required this.offerService,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OfferInfo>>(
      future: offerService.getSubCategoryOfferInfo(subCategoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: isSmall ? 12 : 16,
            height: isSmall ? 12 : 16,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return OfferBadgesStack(offers: snapshot.data!, isSmall: isSmall);
        }

        return const SizedBox.shrink();
      },
    );
  }
}
