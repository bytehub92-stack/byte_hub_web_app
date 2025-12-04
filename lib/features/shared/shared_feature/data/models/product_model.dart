// lib/features/shared/data/models/product_model.dart

import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.merchandiserId,
    required super.categoryId,
    required super.subCategoryId,
    required super.name,
    required super.description,
    required super.price,
    required super.images,
    super.imagesThumbnails,
    required super.rating,
    required super.reviewCount,
    required super.isAvailable,
    super.sku,
    required super.stockQuantity,
    super.costPrice,
    super.weight,
    super.tags,
    required super.createdAt,
    required super.updatedAt,
    super.discountPrice,
    super.discountStartDate,
    super.discountEndDate,
    required super.isFeatured,
    super.categoryName,
    super.subCategoryName,
    super.merchandiserBusinessName,
    super.merchandiserIsActive,
    super.currentPrice,
    super.hasActiveDiscount,
    super.isInStock,
    super.unitOfMeasurementId,
    super.unitName,
    super.unitCode,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      merchandiserId: json['merchandiser_id'] as String,
      categoryId: json['category_id'] as String,
      subCategoryId: json['sub_category_id'] as String,
      name: _parseJsonbField(json['name']),
      description: _parseJsonbField(json['description']),
      price: _parseNumeric(json['price']),
      images: _parseStringArray(json['images']),
      imagesThumbnails: json['images_thumbnails'] != null
          ? _parseStringArray(json['images_thumbnails'])
          : null,
      rating: _parseNumeric(json['rating'] ?? 0.0),
      reviewCount: (json['review_count'] as int?) ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      sku: json['sku'] as String?,
      stockQuantity: (json['stock_quantity'] as int?) ?? 0,
      costPrice: json['cost_price'] != null
          ? _parseNumeric(json['cost_price'])
          : null,
      weight: json['weight'] != null ? _parseNumeric(json['weight']) : null,
      tags: json['tags'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      discountPrice: json['discount_price'] != null
          ? _parseNumeric(json['discount_price'])
          : null,
      discountStartDate: json['discount_start_date'] != null
          ? DateTime.parse(json['discount_start_date'] as String)
          : null,
      discountEndDate: json['discount_end_date'] != null
          ? DateTime.parse(json['discount_end_date'] as String)
          : null,
      isFeatured: json['is_featured'] as bool? ?? false,
      categoryName: json['category_name'] != null
          ? _parseJsonbField(json['category_name'])
          : null,
      subCategoryName: json['sub_category_name'] != null
          ? _parseJsonbField(json['sub_category_name'])
          : null,
      merchandiserBusinessName: json['merchandiser_business_name'] != null
          ? _parseJsonbField(json['merchandiser_business_name'])
          : null,
      merchandiserIsActive: json['merchandiser_is_active'] as bool?,
      currentPrice: json['current_price'] != null
          ? _parseNumeric(json['current_price'])
          : null,
      hasActiveDiscount: json['has_active_discount'] as bool?,
      isInStock: json['is_in_stock'] as bool?,
      // NEW: Unit fields
      unitOfMeasurementId: json['unit_of_measurement_id'] as String?,
      unitCode: json['unit_code'] as String?,
      unitName: json['unit_name'] != null
          ? _parseJsonbField(json['unit_name'])
          : null,
    );
  }

  // Also update toJson() method to include unit fields:
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchandiser_id': merchandiserId,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      if (imagesThumbnails != null) 'images_thumbnails': imagesThumbnails,
      'rating': rating,
      'review_count': reviewCount,
      'is_available': isAvailable,
      if (sku != null) 'sku': sku,
      'stock_quantity': stockQuantity,
      if (costPrice != null) 'cost_price': costPrice,
      if (weight != null) 'weight': weight,
      if (tags != null) 'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (discountPrice != null) 'discount_price': discountPrice,
      if (discountStartDate != null)
        'discount_start_date': discountStartDate!.toIso8601String(),
      if (discountEndDate != null)
        'discount_end_date': discountEndDate!.toIso8601String(),
      'is_featured': isFeatured,
      if (categoryName != null) 'category_name': categoryName,
      if (subCategoryName != null) 'sub_category_name': subCategoryName,
      if (merchandiserBusinessName != null)
        'merchandiser_business_name': merchandiserBusinessName,
      if (merchandiserIsActive != null)
        'merchandiser_is_active': merchandiserIsActive,
      if (currentPrice != null) 'current_price': currentPrice,
      if (hasActiveDiscount != null) 'has_active_discount': hasActiveDiscount,
      if (isInStock != null) 'is_in_stock': isInStock,
      // NEW
      if (unitOfMeasurementId != null)
        'unit_of_measurement_id': unitOfMeasurementId,
      if (unitCode != null) 'unit_code': unitCode,
      if (unitName != null) 'unit_name': unitName,
    };
  }

  // Update copyWith method to include unit fields:
  ProductModel copyWith({
    String? id,
    String? merchandiserId,
    String? categoryId,
    String? subCategoryId,
    Map<String, String>? name,
    Map<String, String>? description,
    double? price,
    List<String>? images,
    List<String>? imagesThumbnails,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    String? sku,
    int? stockQuantity,
    double? costPrice,
    double? weight,
    Map<String, dynamic>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? discountPrice,
    DateTime? discountStartDate,
    DateTime? discountEndDate,
    bool? isFeatured,
    Map<String, String>? categoryName,
    Map<String, String>? subCategoryName,
    Map<String, String>? merchandiserBusinessName,
    bool? merchandiserIsActive,
    double? currentPrice,
    bool? hasActiveDiscount,
    bool? isInStock,
    String? unitOfMeasurementId,
    String? unitCode,
    Map<String, String>? unitName,
  }) {
    return ProductModel(
      id: id ?? this.id,
      merchandiserId: merchandiserId ?? this.merchandiserId,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      imagesThumbnails: imagesThumbnails ?? this.imagesThumbnails,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      sku: sku ?? this.sku,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      costPrice: costPrice ?? this.costPrice,
      weight: weight ?? this.weight,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      discountPrice: discountPrice ?? this.discountPrice,
      discountStartDate: discountStartDate ?? this.discountStartDate,
      discountEndDate: discountEndDate ?? this.discountEndDate,
      isFeatured: isFeatured ?? this.isFeatured,
      categoryName: categoryName ?? this.categoryName,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      merchandiserBusinessName:
          merchandiserBusinessName ?? this.merchandiserBusinessName,
      merchandiserIsActive: merchandiserIsActive ?? this.merchandiserIsActive,
      currentPrice: currentPrice ?? this.currentPrice,
      hasActiveDiscount: hasActiveDiscount ?? this.hasActiveDiscount,
      isInStock: isInStock ?? this.isInStock,
      unitOfMeasurementId: unitOfMeasurementId ?? this.unitOfMeasurementId,
      unitCode: unitCode ?? this.unitCode,
      unitName: unitName ?? this.unitName,
    );
  }

  // Helper method to parse JSONB fields (name, description, category_name, etc.)
  static Map<String, String> _parseJsonbField(dynamic field) {
    if (field == null) return {};
    if (field is Map) {
      return field.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    if (field is String) {
      return {'en': field};
    }
    return {};
  }

  // Helper method to parse PostgreSQL arrays
  static List<String> _parseStringArray(dynamic field) {
    if (field == null) return [];
    if (field is List) {
      return field.map((e) => e.toString()).toList();
    }
    return [];
  }

  // Helper method to parse numeric fields (handles int, double, string, numeric type)
  static double _parseNumeric(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
