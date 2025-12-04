// Update product_repository.dart interface to include unitOfMeasurementId parameter:

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:dartz/dartz.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProductsBySubCategory({
    required String subCategoryId,
    int page = 1,
    int limit = 20,
    String? searchQuery,
    String? sortBy,
  });

  Future<Either<Failure, Product>> getProductById(String productId);

  Future<Either<Failure, Product>> createProduct({
    required String merchandiserId,
    required String categoryId,
    required String subCategoryId,
    required Map<String, String> name,
    Map<String, String>? description,
    required double price,
    required List<String> images,
    required int stockQuantity,
    required String unitOfMeasurementId, // NEW: REQUIRED
    String? sku,
    bool isAvailable = true,
    bool isFeatured = false,
    double? discountPrice,
    DateTime? discountStartDate,
    DateTime? discountEndDate,
    double? costPrice,
    double? weight,
    Map<String, dynamic>? tags,
  });

  Future<Either<Failure, Product>> updateProduct({
    required String productId,
    Map<String, String>? name,
    Map<String, String>? description,
    double? price,
    List<String>? images,
    int? stockQuantity,
    String? unitOfMeasurementId, // NEW
    String? sku,
    bool? isAvailable,
    bool? isFeatured,
    double? discountPrice,
    DateTime? discountStartDate,
    DateTime? discountEndDate,
    double? costPrice,
    double? weight,
    Map<String, dynamic>? tags,
  });

  Future<Either<Failure, void>> deleteProduct(String productId);
}
