// lib/features/merchandiser/domain/usecases/product/create_product_usecase.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/core/usecases/usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';

class CreateProductParams {
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

  CreateProductParams({
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
}

class CreateProductUsecase implements UseCase<Product, CreateProductParams> {
  final ProductRepository repository;

  CreateProductUsecase(this.repository);

  @override
  Future<Either<Failure, Product>> call(CreateProductParams params) async {
    return await repository.createProduct(
      merchandiserId: params.merchandiserId,
      categoryId: params.categoryId,
      subCategoryId: params.subCategoryId,
      name: params.name,
      description: params.description,
      price: params.price,
      images: params.images,
      stockQuantity: params.stockQuantity,
      unitOfMeasurementId: params.unitOfMeasurementId, // NEW
      sku: params.sku,
      isAvailable: params.isAvailable,
      isFeatured: params.isFeatured,
      discountPrice: params.discountPrice,
      discountStartDate: params.discountStartDate,
      discountEndDate: params.discountEndDate,
      costPrice: params.costPrice,
      weight: params.weight,
      tags: params.tags,
    );
  }
}
