// lib/features/offers/domain/entities/offer.dart
import 'package:equatable/equatable.dart';

enum OfferType { bundle, bogo, discount, minPurchase, freeItem }

// Base Offer Entity
class Offer extends Equatable {
  final String id;
  final String merchandiserId;
  final Map<String, String> title;
  final Map<String, String> description;
  final String imageUrl;
  final OfferType type;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int sortOrder;
  final OfferDetails details;

  const Offer({
    required this.id,
    required this.merchandiserId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.sortOrder,
    required this.details,
  });

  String getTitle(String locale) => title[locale] ?? title['en'] ?? '';
  String getDescription(String locale) =>
      description[locale] ?? description['en'] ?? '';

  @override
  List<Object?> get props => [
    id,
    merchandiserId,
    title,
    description,
    imageUrl,
    type,
    startDate,
    endDate,
    isActive,
    sortOrder,
    details,
  ];

  Offer copyWith({
    String? id,
    String? merchandiserId,
    Map<String, String>? title,
    Map<String, String>? description,
    String? imageUrl,
    OfferType? type,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? sortOrder,
    OfferDetails? details,
  }) {
    return Offer(
      id: id ?? this.id,
      merchandiserId: merchandiserId ?? this.merchandiserId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      details: details ?? this.details,
    );
  }
}

// Abstract base for offer details
abstract class OfferDetails extends Equatable {
  const OfferDetails();
}

// Bundle Offer Details
class BundleOfferDetails extends OfferDetails {
  final List<BundleItem> items;
  final double bundlePrice;
  final double originalTotalPrice;

  const BundleOfferDetails({
    required this.items,
    required this.bundlePrice,
    required this.originalTotalPrice,
  });

  double get savingsAmount => originalTotalPrice - bundlePrice;
  double get savingsPercentage => (savingsAmount / originalTotalPrice) * 100;

  @override
  List<Object?> get props => [items, bundlePrice, originalTotalPrice];
}

class BundleItem extends Equatable {
  final String productId;
  final int quantity;
  final String productName;
  final String productImage;
  final double productPrice;

  const BundleItem({
    required this.productId,
    required this.quantity,
    required this.productName,
    required this.productImage,
    required this.productPrice,
  });

  @override
  List<Object?> get props => [
    productId,
    quantity,
    productName,
    productImage,
    productPrice,
  ];
}

// BOGO Offer Details
class BOGOOfferDetails extends OfferDetails {
  final String buyProductId;
  final int buyQuantity;
  final String getProductId;
  final int getQuantity;
  final String buyProductName;
  final String getProductName;
  final String buyProductImage;
  final String getProductImage;

  const BOGOOfferDetails({
    required this.buyProductId,
    required this.buyQuantity,
    required this.getProductId,
    required this.getQuantity,
    required this.buyProductName,
    required this.getProductName,
    required this.buyProductImage,
    required this.getProductImage,
  });

  @override
  List<Object?> get props => [
    buyProductId,
    buyQuantity,
    getProductId,
    getQuantity,
    buyProductName,
    getProductName,
    buyProductImage,
    getProductImage,
  ];
}

// Discount Offer Details
class DiscountOfferDetails extends OfferDetails {
  final String? productId;
  final String? categoryId;
  final String? subCategoryId;
  final double discountValue;
  final bool isPercentage;
  final double? maxDiscountAmount;
  final double? minPurchaseAmount;

  const DiscountOfferDetails({
    this.productId,
    this.categoryId,
    this.subCategoryId,
    required this.discountValue,
    required this.isPercentage,
    this.maxDiscountAmount,
    this.minPurchaseAmount,
  });

  bool get isProductSpecific => productId != null;
  bool get isCategorySpecific => categoryId != null && subCategoryId == null;
  bool get isSubCategorySpecific => subCategoryId != null;

  @override
  List<Object?> get props => [
    productId,
    categoryId,
    subCategoryId,
    discountValue,
    isPercentage,
    maxDiscountAmount,
    minPurchaseAmount,
  ];
}

// Min Purchase Offer Details
class MinPurchaseOfferDetails extends OfferDetails {
  final double minPurchaseAmount;
  final double? discountValue;
  final bool? isPercentage;
  final bool freeShipping;

  const MinPurchaseOfferDetails({
    required this.minPurchaseAmount,
    this.discountValue,
    this.isPercentage,
    this.freeShipping = false,
  });

  double calculateDiscount(double cartTotal) {
    if (cartTotal < minPurchaseAmount || discountValue == null) {
      return 0;
    }

    if (isPercentage == true) {
      return (cartTotal * discountValue!) / 100;
    }
    return discountValue!;
  }

  @override
  List<Object?> get props => [
    minPurchaseAmount,
    discountValue,
    isPercentage,
    freeShipping,
  ];
}

// Free Item Offer Details
class FreeItemOfferDetails extends OfferDetails {
  final double minPurchaseAmount;
  final List<FreeItemOption> freeItems;

  const FreeItemOfferDetails({
    required this.minPurchaseAmount,
    required this.freeItems,
  });

  @override
  List<Object?> get props => [minPurchaseAmount, freeItems];
}

class FreeItemOption extends Equatable {
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;

  const FreeItemOption({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, productName, productImage, quantity];
}
