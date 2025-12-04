// lib/features/merchandiser/domain/usecases/product/update_product_usecase.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/core/usecases/usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:dartz/dartz.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/product_repository.dart';

class UpdateProductParams {
  final String productId;
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

  UpdateProductParams({
    required this.productId,
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
}

class UpdateProductUsecase implements UseCase<Product, UpdateProductParams> {
  final ProductRepository repository;

  UpdateProductUsecase(this.repository);

  @override
  Future<Either<Failure, Product>> call(UpdateProductParams params) async {
    return await repository.updateProduct(
      productId: params.productId,
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
