// lib/features/orders/presentation/widgets/order_offer_display_widget.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

class OrderOfferDisplayWidget extends StatelessWidget {
  final Map<String, dynamic>? offerDetails;
  final double discountAmount;

  const OrderOfferDisplayWidget({
    super.key,
    required this.offerDetails,
    required this.discountAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (offerDetails == null) return const SizedBox.shrink();

    // Handle both single offer and multiple offers structure
    final offers = offerDetails!['offers'] as List?;

    // If we have multiple offers, display them all
    if (offers != null && offers.isNotEmpty) {
      return Column(
        children: offers.map((offer) {
          final offerMap = offer as Map<String, dynamic>;
          final offerDiscount =
              (offerMap['discount_amount'] as num?)?.toDouble() ?? 0;
          return _buildSingleOffer(context, offerMap, offerDiscount);
        }).toList(),
      );
    }

    // Fallback to single offer format (for backward compatibility)
    final offerType =
        offerDetails!['type'] as String? ??
        offerDetails!['offer_type'] as String?;

    return _buildOfferCard(context, offerType);
  }

  Widget _buildSingleOffer(
    BuildContext context,
    Map<String, dynamic> offer,
    double offerDiscount,
  ) {
    final offerTitle = offer['offer_title'] as String? ?? 'Special Offer';
    final offerType = offer['offer_type'] as String?;
    final freeShipping = offer['free_shipping'] as bool? ?? false;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withValues(alpha: 0.1),
              AppColors.success.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_offer,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      offerTitle,
                      style: AppTextStyles.h4Light.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getOfferTypeLabel(offerType),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Display badges for special features
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (offerDiscount > 0)
                    _buildFeatureBadge(
                      'Saved: EGP ${offerDiscount.toStringAsFixed(0)}',
                      Icons.discount,
                      AppColors.success,
                    ),
                  if (freeShipping)
                    _buildFeatureBadge(
                      'Free Shipping',
                      Icons.local_shipping,
                      AppColors.info,
                    ),
                  if (offerType == 'bogo' || offerType == 'free_item')
                    _buildFeatureBadge(
                      'Free Items Included',
                      Icons.card_giftcard,
                      AppColors.secondary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, String? offerType) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withValues(alpha: 0.1),
              AppColors.success.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: _buildOfferContent(context, offerType),
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferContent(BuildContext context, String? offerType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_offer,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offerDetails!['title']?['en'] ??
                        offerDetails!['offer_title'] as String? ??
                        'Special Offer',
                    style: AppTextStyles.h4Light.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (offerDetails!['description']?['en'] != null)
                    Text(
                      offerDetails!['description']['en'],
                      style: AppTextStyles.bodySmallLight.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getOfferTypeLabel(offerType),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const Divider(height: 24),

        // Offer Type Specific Display
        if (offerType == 'bundle') ...[
          _buildBundleOfferDisplay(),
        ] else if (offerType == 'bogo') ...[
          _buildBogoOfferDisplay(),
        ] else if (offerType == 'discount') ...[
          _buildDiscountOfferDisplay(),
        ] else if (offerType == 'minPurchase' ||
            offerType == 'min_purchase') ...[
          _buildMinPurchaseOfferDisplay(),
        ] else if (offerType == 'freeItem' || offerType == 'free_item') ...[
          _buildFreeItemOfferDisplay(),
        ],

        const Divider(height: 24),

        // Savings Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.savings, color: AppColors.success, size: 28),
              const SizedBox(width: 12),
              Column(
                children: [
                  const Text(
                    'Total Savings',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'EGP ${discountAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getOfferTypeLabel(String? type) {
    switch (type?.toLowerCase()) {
      case 'bundle':
        return 'BUNDLE DEAL';
      case 'bogo':
        return 'BOGO';
      case 'discount':
        return 'DISCOUNT';
      case 'minpurchase':
      case 'min_purchase':
        return 'MIN PURCHASE';
      case 'freeitem':
      case 'free_item':
        return 'FREE ITEM';
      default:
        return 'OFFER';
    }
  }

  Widget _buildBundleOfferDisplay() {
    final details = offerDetails!['details'] as Map<String, dynamic>?;
    if (details == null) return const SizedBox.shrink();

    final items = details['items'] as List? ?? [];
    final bundlePrice = (details['bundlePrice'] as num?)?.toDouble() ?? 0.0;
    final originalPrice =
        (details['originalTotalPrice'] as num?)?.toDouble() ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bundle Items',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.grey700,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'EGP ${originalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.grey500,
                  ),
                ),
                Text(
                  'EGP ${bundlePrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey300),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _buildBundleItem(items[i] as Map<String, dynamic>),
                if (i < items.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBundleItem(Map<String, dynamic> item) {
    final productName = item['productName'] as String? ?? 'Product';
    final quantity = item['quantity'] as int? ?? 1;
    final price = (item['productPrice'] as num?)?.toDouble() ?? 0.0;
    final imageUrl = item['productImage'] as String?;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          color: AppColors.grey400,
                        );
                      },
                    ),
                  )
                : const Icon(Icons.shopping_bag, color: AppColors.grey400),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Qty: $quantity × EGP ${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBogoOfferDisplay() {
    final details = offerDetails!['details'] as Map<String, dynamic>?;
    if (details == null) return const SizedBox.shrink();

    final buyProductName = details['buyProductName'] as String? ?? 'Product';
    final buyQuantity = details['buyQuantity'] as int? ?? 1;
    final getProductName = details['getProductName'] as String? ?? 'Product';
    final getQuantity = details['getQuantity'] as int? ?? 1;
    final buyImage = details['buyProductImage'] as String?;
    final getImage = details['getProductImage'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        children: [
          // Buy Section
          _buildBogoSection(
            label: 'BUY',
            productName: buyProductName,
            quantity: buyQuantity,
            imageUrl: buyImage,
            color: AppColors.primary,
          ),

          const SizedBox(height: 12),

          // Divider with icon
          Row(
            children: [
              const Expanded(child: Divider()),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
              const Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 12),

          // Get Section
          _buildBogoSection(
            label: 'GET FREE',
            productName: getProductName,
            quantity: getQuantity,
            imageUrl: getImage,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildBogoSection({
    required String label,
    required String productName,
    required int quantity,
    String? imageUrl,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, size: 20);
                    },
                  ),
                )
              : const Icon(Icons.shopping_bag, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Quantity: $quantity',
                style: const TextStyle(fontSize: 11, color: AppColors.grey600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountOfferDisplay() {
    final details = offerDetails!['details'] as Map<String, dynamic>?;
    if (details == null) return const SizedBox.shrink();

    final discountValue = (details['discountValue'] as num?)?.toDouble() ?? 0.0;
    final isPercentage = details['isPercentage'] as bool? ?? false;
    final minPurchaseAmount = (details['minPurchaseAmount'] as num?)
        ?.toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.discount, color: AppColors.accent, size: 32),
              const SizedBox(width: 12),
              Text(
                isPercentage
                    ? '${discountValue.toStringAsFixed(0)}% OFF'
                    : 'EGP ${discountValue.toStringAsFixed(2)} OFF',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (minPurchaseAmount != null) ...[
            const SizedBox(height: 8),
            Text(
              'On purchases above EGP ${minPurchaseAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: AppColors.grey600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMinPurchaseOfferDisplay() {
    final details = offerDetails!['details'] as Map<String, dynamic>?;
    if (details == null) return const SizedBox.shrink();

    final minPurchaseAmount =
        (details['minPurchaseAmount'] as num?)?.toDouble() ?? 0.0;
    final freeShipping = details['freeShipping'] as bool? ?? false;
    final discountValue = (details['discountValue'] as num?)?.toDouble();
    final isPercentage = details['isPercentage'] as bool? ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_cart_checkout,
                color: AppColors.info,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Minimum Purchase Offer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Spend EGP ${minPurchaseAmount.toStringAsFixed(2)} or more',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (freeShipping)
            _buildBenefitChip(
              icon: Icons.local_shipping,
              label: 'Free Shipping',
            ),
          if (discountValue != null) ...[
            const SizedBox(height: 8),
            _buildBenefitChip(
              icon: Icons.discount,
              label: isPercentage
                  ? '${discountValue.toStringAsFixed(0)}% Discount'
                  : 'EGP ${discountValue.toStringAsFixed(2)} Off',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeItemOfferDisplay() {
    final details = offerDetails!['details'] as Map<String, dynamic>?;
    if (details == null) return const SizedBox.shrink();

    final minPurchaseAmount =
        (details['minPurchaseAmount'] as num?)?.toDouble() ?? 0.0;
    final freeItems = details['freeItems'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.redeem, color: AppColors.secondary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Free Item with Purchase',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'On orders above EGP ${minPurchaseAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Free Items:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          ...freeItems.map((item) {
            final itemMap = item as Map<String, dynamic>;
            return _buildFreeItemCard(itemMap);
          }),
        ],
      ),
    );
  }

  Widget _buildFreeItemCard(Map<String, dynamic> item) {
    final productName = item['productName'] as String? ?? 'Product';
    final quantity = item['quantity'] as int? ?? 1;
    final imageUrl = item['productImage'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, size: 20);
                      },
                    ),
                  )
                : const Icon(Icons.redeem, size: 20, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Quantity: $quantity',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'FREE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
