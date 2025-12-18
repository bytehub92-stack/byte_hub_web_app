// lib/features/offers/data/services/offer_indicator_service.dart

import 'package:admin_panel/features/merchandisers/offers/data/datasource/offers_remote_datasource.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/entities/offer.dart';

class OfferIndicatorService {
  final OffersRemoteDataSource offersDataSource;

  // Cache to avoid repeated API calls
  List<Offer>? _cachedOffers;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  OfferIndicatorService(this.offersDataSource);

  /// Get all active offers (with caching)
  Future<List<Offer>> _getActiveOffers() async {
    final now = DateTime.now();

    // Return cached data if still valid
    if (_cachedOffers != null &&
        _cacheTime != null &&
        now.difference(_cacheTime!) < _cacheDuration) {
      return _cachedOffers!;
    }

    // Fetch fresh data
    final offers = await offersDataSource.getOffers();

    // Filter only active offers that are currently running
    _cachedOffers = offers.where((offer) {
      return offer.isActive &&
          offer.startDate.isBefore(now) &&
          offer.endDate.isAfter(now);
    }).toList();

    _cacheTime = now;
    return _cachedOffers!;
  }

  /// Clear cache to force refresh
  void clearCache() {
    _cachedOffers = null;
    _cacheTime = null;
  }

  /// Check if a product has any active offers
  Future<OfferInfo?> getProductOfferInfo(String productId) async {
    try {
      final offers = await _getActiveOffers();

      for (final offer in offers) {
        // Check BOGO offers
        if (offer.type == OfferType.bogo) {
          final details = offer.details as BOGOOfferDetails;
          if (details.buyProductId == productId ||
              details.getProductId == productId) {
            return OfferInfo(
              type: 'BOGO',
              label: details.buyProductId == productId
                  ? 'Buy ${details.buyQuantity} Get ${details.getQuantity} Free'
                  : 'Free Item',
              color: OfferColor.green,
              offer: offer,
            );
          }
        }

        // Check Bundle offers
        if (offer.type == OfferType.bundle) {
          final details = offer.details as BundleOfferDetails;
          if (details.items.any((item) => item.productId == productId)) {
            return OfferInfo(
              type: 'Bundle',
              label: 'In Bundle',
              color: OfferColor.purple,
              offer: offer,
            );
          }
        }

        // Check Discount offers
        if (offer.type == OfferType.discount) {
          final details = offer.details as DiscountOfferDetails;
          if (details.productId == productId) {
            final discount = details.isPercentage
                ? '${details.discountValue.toInt()}% OFF'
                : 'EGP ${details.discountValue} OFF';
            return OfferInfo(
              type: 'Discount',
              label: discount,
              color: OfferColor.red,
              offer: offer,
            );
          }
        }

        // Check Free Item offers
        if (offer.type == OfferType.freeItem) {
          final details = offer.details as FreeItemOfferDetails;
          if (details.freeItems.any((item) => item.productId == productId)) {
            return OfferInfo(
              type: 'Free Gift',
              label: 'Free with Purchase',
              color: OfferColor.orange,
              offer: offer,
            );
          }
        }
      }

      return null;
    } catch (e) {
      print('Error checking product offer: $e');
      return null;
    }
  }

  /// Check if a category has any active offers
  Future<List<OfferInfo>> getCategoryOfferInfo(String categoryId) async {
    try {
      final offers = await _getActiveOffers();
      final List<OfferInfo> categoryOffers = [];

      for (final offer in offers) {
        if (offer.type == OfferType.discount) {
          final details = offer.details as DiscountOfferDetails;
          if (details.categoryId == categoryId) {
            final discount = details.isPercentage
                ? '${details.discountValue.toInt()}% OFF'
                : 'EGP ${details.discountValue} OFF';
            categoryOffers.add(
              OfferInfo(
                type: 'Category Sale',
                label: discount,
                color: OfferColor.red,
                offer: offer,
              ),
            );
          }
        }
      }

      return categoryOffers;
    } catch (e) {
      print('Error checking category offer: $e');
      return [];
    }
  }

  /// Check if a sub-category has any active offers
  Future<List<OfferInfo>> getSubCategoryOfferInfo(String subCategoryId) async {
    try {
      final offers = await _getActiveOffers();
      final List<OfferInfo> subCategoryOffers = [];

      for (final offer in offers) {
        if (offer.type == OfferType.discount) {
          final details = offer.details as DiscountOfferDetails;
          if (details.subCategoryId == subCategoryId) {
            final discount = details.isPercentage
                ? '${details.discountValue.toInt()}% OFF'
                : 'EGP ${details.discountValue} OFF';
            subCategoryOffers.add(
              OfferInfo(
                type: 'Sale',
                label: discount,
                color: OfferColor.red,
                offer: offer,
              ),
            );
          }
        }
      }

      return subCategoryOffers;
    } catch (e) {
      print('Error checking sub-category offer: $e');
      return [];
    }
  }

  /// Get all active offers summary
  Future<OffersSummary> getOffersSummary() async {
    try {
      final offers = await _getActiveOffers();

      return OffersSummary(
        totalOffers: offers.length,
        discountOffers:
            offers.where((o) => o.type == OfferType.discount).length,
        bogoOffers: offers.where((o) => o.type == OfferType.bogo).length,
        bundleOffers: offers.where((o) => o.type == OfferType.bundle).length,
        minPurchaseOffers:
            offers.where((o) => o.type == OfferType.minPurchase).length,
        freeItemOffers:
            offers.where((o) => o.type == OfferType.freeItem).length,
      );
    } catch (e) {
      print('Error getting offers summary: $e');
      return OffersSummary.empty();
    }
  }
}

/// Information about an offer
class OfferInfo {
  final String type;
  final String label;
  final OfferColor color;
  final Offer offer;

  OfferInfo({
    required this.type,
    required this.label,
    required this.color,
    required this.offer,
  });
}

/// Offer badge colors
enum OfferColor {
  red, // Discounts
  green, // BOGO
  purple, // Bundles
  orange, // Free items
  blue, // Min purchase
}

/// Summary of all active offers
class OffersSummary {
  final int totalOffers;
  final int discountOffers;
  final int bogoOffers;
  final int bundleOffers;
  final int minPurchaseOffers;
  final int freeItemOffers;

  OffersSummary({
    required this.totalOffers,
    required this.discountOffers,
    required this.bogoOffers,
    required this.bundleOffers,
    required this.minPurchaseOffers,
    required this.freeItemOffers,
  });

  factory OffersSummary.empty() {
    return OffersSummary(
      totalOffers: 0,
      discountOffers: 0,
      bogoOffers: 0,
      bundleOffers: 0,
      minPurchaseOffers: 0,
      freeItemOffers: 0,
    );
  }
}
