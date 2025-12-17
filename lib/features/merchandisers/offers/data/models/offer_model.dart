// lib/features/offers/data/models/offer_model.dart

import 'package:admin_panel/features/merchandisers/offers/domain/entities/offer.dart';

class OfferModel extends Offer {
  const OfferModel({
    required super.id,
    required super.merchandiserId,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.type,
    required super.startDate,
    required super.endDate,
    required super.isActive,
    required super.sortOrder,
    required super.details,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = _parseOfferType(typeStr);
    final details = _parseOfferDetails(type, json['details']);

    return OfferModel(
      id: json['id'] as String,
      merchandiserId: json['merchandiser_id'] as String,
      title: Map<String, String>.from(json['title'] as Map),
      description: Map<String, String>.from(json['description'] as Map),
      imageUrl: json['image_url'] as String,
      type: type,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool,
      sortOrder: json['sort_order'] as int,
      details: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchandiser_id': merchandiserId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'type': _offerTypeToString(type),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'sort_order': sortOrder,
      'details': _detailsToJson(details),
    };
  }

  static OfferType _parseOfferType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'bundle':
        return OfferType.bundle;
      case 'bogo':
        return OfferType.bogo;
      case 'discount':
        return OfferType.discount;
      case 'min_purchase':
        return OfferType.minPurchase;
      case 'free_item':
        return OfferType.freeItem;
      default:
        throw Exception('Unknown offer type: $typeStr');
    }
  }

  static String _offerTypeToString(OfferType type) {
    switch (type) {
      case OfferType.bundle:
        return 'bundle';
      case OfferType.bogo:
        return 'bogo';
      case OfferType.discount:
        return 'discount';
      case OfferType.minPurchase:
        return 'min_purchase';
      case OfferType.freeItem:
        return 'free_item';
    }
  }

  static OfferDetails _parseOfferDetails(
    OfferType type,
    Map<String, dynamic> json,
  ) {
    switch (type) {
      case OfferType.bundle:
        return BundleOfferDetailsModel.fromJson(json);
      case OfferType.bogo:
        return BOGOOfferDetailsModel.fromJson(json);
      case OfferType.discount:
        return DiscountOfferDetailsModel.fromJson(json);
      case OfferType.minPurchase:
        return MinPurchaseOfferDetailsModel.fromJson(json);
      case OfferType.freeItem:
        return FreeItemOfferDetailsModel.fromJson(json);
    }
  }

  static Map<String, dynamic> _detailsToJson(OfferDetails details) {
    if (details is BundleOfferDetails) {
      return BundleOfferDetailsModel.toJson(details);
    } else if (details is BOGOOfferDetails) {
      return BOGOOfferDetailsModel.toJson(details);
    } else if (details is DiscountOfferDetails) {
      return DiscountOfferDetailsModel.toJson(details);
    } else if (details is MinPurchaseOfferDetails) {
      return MinPurchaseOfferDetailsModel.toJson(details);
    } else if (details is FreeItemOfferDetails) {
      return FreeItemOfferDetailsModel.toJson(details);
    }
    throw Exception('Unknown offer details type');
  }
}

// Bundle Offer Details Model
class BundleOfferDetailsModel extends BundleOfferDetails {
  const BundleOfferDetailsModel({
    required super.items,
    required super.bundlePrice,
    required super.originalTotalPrice,
  });

  factory BundleOfferDetailsModel.fromJson(Map<String, dynamic> json) {
    return BundleOfferDetailsModel(
      items: (json['items'] as List)
          .map((item) => BundleItemModel.fromJson(item))
          .toList(),
      bundlePrice: (json['bundle_price'] as num).toDouble(),
      originalTotalPrice: (json['original_total_price'] as num).toDouble(),
    );
  }

  static Map<String, dynamic> toJson(BundleOfferDetails details) {
    return {
      'items': details.items
          .map((item) => BundleItemModel.toJson(item))
          .toList(),
      'bundle_price': details.bundlePrice,
      'original_total_price': details.originalTotalPrice,
    };
  }
}

class BundleItemModel extends BundleItem {
  const BundleItemModel({
    required super.productId,
    required super.quantity,
    required super.productName,
    required super.productImage,
    required super.productPrice,
  });

  factory BundleItemModel.fromJson(Map<String, dynamic> json) {
    return BundleItemModel(
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String,
      productPrice: (json['product_price'] as num).toDouble(),
    );
  }

  static Map<String, dynamic> toJson(BundleItem item) {
    return {
      'product_id': item.productId,
      'quantity': item.quantity,
      'product_name': item.productName,
      'product_image': item.productImage,
      'product_price': item.productPrice,
    };
  }
}

// BOGO Offer Details Model
class BOGOOfferDetailsModel extends BOGOOfferDetails {
  const BOGOOfferDetailsModel({
    required super.buyProductId,
    required super.buyQuantity,
    required super.getProductId,
    required super.getQuantity,
    required super.buyProductName,
    required super.getProductName,
    required super.buyProductImage,
    required super.getProductImage,
  });

  factory BOGOOfferDetailsModel.fromJson(Map<String, dynamic> json) {
    return BOGOOfferDetailsModel(
      buyProductId: json['buy_product_id'] as String,
      buyQuantity: json['buy_quantity'] as int,
      getProductId: json['get_product_id'] as String,
      getQuantity: json['get_quantity'] as int,
      buyProductName: json['buy_product_name'] as String,
      getProductName: json['get_product_name'] as String,
      buyProductImage: json['buy_product_image'] as String,
      getProductImage: json['get_product_image'] as String,
    );
  }

  static Map<String, dynamic> toJson(BOGOOfferDetails details) {
    return {
      'buy_product_id': details.buyProductId,
      'buy_quantity': details.buyQuantity,
      'get_product_id': details.getProductId,
      'get_quantity': details.getQuantity,
      'buy_product_name': details.buyProductName,
      'get_product_name': details.getProductName,
      'buy_product_image': details.buyProductImage,
      'get_product_image': details.getProductImage,
    };
  }
}

// Discount Offer Details Model
class DiscountOfferDetailsModel extends DiscountOfferDetails {
  const DiscountOfferDetailsModel({
    super.productId,
    super.categoryId,
    super.subCategoryId,
    required super.discountValue,
    required super.isPercentage,
    super.maxDiscountAmount,
    super.minPurchaseAmount,
  });

  factory DiscountOfferDetailsModel.fromJson(Map<String, dynamic> json) {
    return DiscountOfferDetailsModel(
      productId: json['product_id'] as String?,
      categoryId: json['category_id'] as String?,
      subCategoryId: json['sub_category_id'] as String?,
      discountValue: (json['discount_value'] as num).toDouble(),
      isPercentage: json['is_percentage'] as bool,
      maxDiscountAmount: json['max_discount_amount'] != null
          ? (json['max_discount_amount'] as num).toDouble()
          : null,
      minPurchaseAmount: json['min_purchase_amount'] != null
          ? (json['min_purchase_amount'] as num).toDouble()
          : null,
    );
  }

  static Map<String, dynamic> toJson(DiscountOfferDetails details) {
    return {
      'product_id': details.productId,
      'category_id': details.categoryId,
      'sub_category_id': details.subCategoryId,
      'discount_value': details.discountValue,
      'is_percentage': details.isPercentage,
      'max_discount_amount': details.maxDiscountAmount,
      'min_purchase_amount': details.minPurchaseAmount,
    };
  }
}

// Min Purchase Offer Details Model
class MinPurchaseOfferDetailsModel extends MinPurchaseOfferDetails {
  const MinPurchaseOfferDetailsModel({
    required super.minPurchaseAmount,
    super.discountValue,
    super.isPercentage,
    super.freeShipping,
  });

  factory MinPurchaseOfferDetailsModel.fromJson(Map<String, dynamic> json) {
    return MinPurchaseOfferDetailsModel(
      minPurchaseAmount: (json['min_purchase_amount'] as num).toDouble(),
      discountValue: json['discount_value'] != null
          ? (json['discount_value'] as num).toDouble()
          : null,
      isPercentage: json['is_percentage'] as bool?,
      freeShipping: json['free_shipping'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> toJson(MinPurchaseOfferDetails details) {
    return {
      'min_purchase_amount': details.minPurchaseAmount,
      'discount_value': details.discountValue,
      'is_percentage': details.isPercentage,
      'free_shipping': details.freeShipping,
    };
  }
}

// Free Item Offer Details Model
class FreeItemOfferDetailsModel extends FreeItemOfferDetails {
  const FreeItemOfferDetailsModel({
    required super.minPurchaseAmount,
    required super.freeItems,
  });

  factory FreeItemOfferDetailsModel.fromJson(Map<String, dynamic> json) {
    return FreeItemOfferDetailsModel(
      minPurchaseAmount: (json['min_purchase_amount'] as num).toDouble(),
      freeItems: (json['free_items'] as List)
          .map((item) => FreeItemOptionModel.fromJson(item))
          .toList(),
    );
  }

  static Map<String, dynamic> toJson(FreeItemOfferDetails details) {
    return {
      'min_purchase_amount': details.minPurchaseAmount,
      'free_items': details.freeItems
          .map((item) => FreeItemOptionModel.toJson(item))
          .toList(),
    };
  }
}

class FreeItemOptionModel extends FreeItemOption {
  const FreeItemOptionModel({
    required super.productId,
    required super.productName,
    required super.productImage,
    required super.quantity,
  });

  factory FreeItemOptionModel.fromJson(Map<String, dynamic> json) {
    return FreeItemOptionModel(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String,
      quantity: json['quantity'] as int,
    );
  }

  static Map<String, dynamic> toJson(FreeItemOption item) {
    return {
      'product_id': item.productId,
      'product_name': item.productName,
      'product_image': item.productImage,
      'quantity': item.quantity,
    };
  }
}
