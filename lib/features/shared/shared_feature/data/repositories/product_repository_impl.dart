import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  const ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProductsBySubCategory({
    required String subCategoryId,
    int page = 1,
    int limit = 20,
    String? searchQuery,
    String? sortBy,
  }) async {
    try {
      final products = await remoteDataSource.getProductsBySubCategory(
        subCategoryId: subCategoryId,
        page: page,
        limit: limit,
        searchQuery: searchQuery,
        sortBy: sortBy,
      );
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String productId) async {
    try {
      final product = await remoteDataSource.getProductById(productId);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct({
    required String merchandiserId,
    required String categoryId,
    required String subCategoryId,
    required Map<String, String> name,
    Map<String, String>? description,
    required double price,
    required List<String> images,
    required int stockQuantity,
    required String unitOfMeasurementId, // NEW
    String? sku,
    bool isAvailable = true,
    bool isFeatured = false,
    double? discountPrice,
    DateTime? discountStartDate,
    DateTime? discountEndDate,
    double? costPrice,
    double? weight,
    Map<String, dynamic>? tags,
  }) async {
    try {
      final productData = {
        'merchandiser_id': merchandiserId,
        'category_id': categoryId,
        'sub_category_id': subCategoryId,
        'name': name,
        'description': description ?? {'en': '', 'ar': ''},
        'price': price,
        'images': images,
        'stock_quantity': stockQuantity,
        'unit_of_measurement_id': unitOfMeasurementId, // NEW
        if (sku != null) 'sku': sku,
        'is_available': isAvailable,
        'is_featured': isFeatured,
        if (discountPrice != null) 'discount_price': discountPrice,
        if (discountStartDate != null)
          'discount_start_date': discountStartDate.toIso8601String(),
        if (discountEndDate != null)
          'discount_end_date': discountEndDate.toIso8601String(),
        if (costPrice != null) 'cost_price': costPrice,
        if (weight != null) 'weight': weight,
        if (tags != null) 'tags': tags,
      };

      final product = await remoteDataSource.createProduct(productData);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
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
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;
      if (images != null) updates['images'] = images;
      if (stockQuantity != null) updates['stock_quantity'] = stockQuantity;
      if (unitOfMeasurementId != null) {
        updates['unit_of_measurement_id'] = unitOfMeasurementId; // NEW
      }
      if (sku != null) updates['sku'] = sku;
      if (isAvailable != null) updates['is_available'] = isAvailable;
      if (isFeatured != null) updates['is_featured'] = isFeatured;
      if (discountPrice != null) updates['discount_price'] = discountPrice;
      if (discountStartDate != null) {
        updates['discount_start_date'] = discountStartDate.toIso8601String();
      }
      if (discountEndDate != null) {
        updates['discount_end_date'] = discountEndDate.toIso8601String();
      }
      if (costPrice != null) updates['cost_price'] = costPrice;
      if (weight != null) updates['weight'] = weight;
      if (tags != null) updates['tags'] = tags;

      if (updates.isEmpty) {
        return Left(ServerFailure(message: 'No fields provided for update'));
      }

      final product = await remoteDataSource.updateProduct(productId, updates);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    try {
      await remoteDataSource.deleteProduct(productId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
