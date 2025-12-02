// lib/features/merchandiser/presentation/bloc/product_bloc/product_event.dart

import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final String subCategoryId;
  final int page;
  final int limit;
  final String? searchQuery;
  final String? sortBy;

  const LoadProducts({
    required this.subCategoryId,
    this.page = 1,
    this.limit = 20,
    this.searchQuery,
    this.sortBy,
  });

  @override
  List<Object?> get props => [subCategoryId, page, limit, searchQuery, sortBy];
}

class CreateProduct extends ProductEvent {
  final String merchandiserId;
  final String categoryId;
  final String subCategoryId;
  final Map<String, String> name;
  final Map<String, String> description;
  final double price;
  final List<String> images;
  final int stockQuantity;
  final String unitOfMeasurementId; // NEW
  final String? sku;
  final bool isAvailable;
  final bool isFeatured;
  final double? discountPrice;
  final DateTime? discountStartDate;
  final DateTime? discountEndDate;
  final double? costPrice;
  final double? weight;
  final Map<String, dynamic>? tags;

  const CreateProduct({
    required this.merchandiserId,
    required this.categoryId,
    required this.subCategoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.stockQuantity,
    required this.unitOfMeasurementId, // NEW
    this.sku,
    this.isAvailable = true,
    this.isFeatured = false,
    this.discountPrice,
    this.discountStartDate,
    this.discountEndDate,
    this.costPrice,
    this.weight,
    this.tags,
  });

  @override
  List<Object?> get props => [
    merchandiserId,
    categoryId,
    subCategoryId,
    name,
    description,
    price,
    images,
    stockQuantity,
    unitOfMeasurementId, // NEW
    sku,
    isAvailable,
    isFeatured,
    discountPrice,
    discountStartDate,
    discountEndDate,
    costPrice,
    weight,
    tags,
  ];
}

class UpdateProduct extends ProductEvent {
  final String productId;
  final String subCategoryId;
  final Map<String, String>? name;
  final Map<String, String>? description;
  final double? price;
  final List<String>? images;
  final int? stockQuantity;
  final String? unitOfMeasurementId; // NEW
  final String? sku;
  final bool? isAvailable;
  final bool? isFeatured;
  final double? discountPrice;
  final DateTime? discountStartDate;
  final DateTime? discountEndDate;
  final double? costPrice;
  final double? weight;
  final Map<String, dynamic>? tags;

  const UpdateProduct({
    required this.productId,
    required this.subCategoryId,
    this.name,
    this.description,
    this.price,
    this.images,
    this.stockQuantity,
    this.unitOfMeasurementId, // NEW
    this.sku,
    this.isAvailable,
    this.isFeatured,
    this.discountPrice,
    this.discountStartDate,
    this.discountEndDate,
    this.costPrice,
    this.weight,
    this.tags,
  });

  @override
  List<Object?> get props => [
    productId,
    subCategoryId,
    name,
    description,
    price,
    images,
    stockQuantity,
    unitOfMeasurementId, // NEW
    sku,
    isAvailable,
    isFeatured,
    discountPrice,
    discountStartDate,
    discountEndDate,
    costPrice,
    weight,
    tags,
  ];
}

class DeleteProduct extends ProductEvent {
  final String productId;
  final String subCategoryId;

  const DeleteProduct(this.productId, this.subCategoryId);

  @override
  List<Object?> get props => [productId, subCategoryId];
}
