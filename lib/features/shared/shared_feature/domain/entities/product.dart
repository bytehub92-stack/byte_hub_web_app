// lib/features/shared/domain/entities/product.dart
// Complete version with all fields and getters:

import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String merchandiserId;
  final String categoryId;
  final String subCategoryId;
  final Map<String, String> name;
  final Map<String, String> description;
  final double price;
  final List<String> images;
  final List<String>? imagesThumbnails;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final String? sku;
  final int stockQuantity;
  final double? costPrice;
  final double? weight;
  final Map<String, dynamic>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? discountPrice;
  final DateTime? discountStartDate;
  final DateTime? discountEndDate;
  final bool isFeatured;

  // View fields
  final Map<String, String>? categoryName;
  final Map<String, String>? subCategoryName;
  final Map<String, String>? merchandiserBusinessName;
  final bool? merchandiserIsActive;
  final double? currentPrice;
  final bool? hasActiveDiscount;
  final bool? isInStock;

  // Unit of Measurement fields
  final String? unitOfMeasurementId;
  final String? unitCode;
  final Map<String, String>? unitName;

  const Product({
    required this.id,
    required this.merchandiserId,
    required this.categoryId,
    required this.subCategoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    this.imagesThumbnails,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    this.sku,
    required this.stockQuantity,
    this.costPrice,
    this.weight,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.discountPrice,
    this.discountStartDate,
    this.discountEndDate,
    required this.isFeatured,
    this.categoryName,
    this.subCategoryName,
    this.merchandiserBusinessName,
    this.merchandiserIsActive,
    this.currentPrice,
    this.hasActiveDiscount,
    this.isInStock,
    this.unitOfMeasurementId,
    this.unitCode,
    this.unitName,
  });

  // Formatted price getters
  String get formattedPrice {
    final priceToDisplay = currentPrice ?? price;
    return 'EGP ${priceToDisplay.toStringAsFixed(2)}';
  }

  String get formattedOriginalPrice {
    return 'EGP ${price.toStringAsFixed(2)}';
  }

  // Unit display helper
  String getUnitDisplay(String languageCode) {
    if (unitName == null) return '';
    return unitName![languageCode] ?? unitName!['en'] ?? '';
  }

  // Stock status helper
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 10;

  @override
  List<Object?> get props => [
        id,
        merchandiserId,
        categoryId,
        subCategoryId,
        name,
        description,
        price,
        images,
        imagesThumbnails,
        rating,
        reviewCount,
        isAvailable,
        sku,
        stockQuantity,
        costPrice,
        weight,
        tags,
        createdAt,
        updatedAt,
        discountPrice,
        discountStartDate,
        discountEndDate,
        isFeatured,
        categoryName,
        subCategoryName,
        merchandiserBusinessName,
        merchandiserIsActive,
        currentPrice,
        hasActiveDiscount,
        isInStock,
        unitOfMeasurementId,
        unitCode,
        unitName
      ];
}
