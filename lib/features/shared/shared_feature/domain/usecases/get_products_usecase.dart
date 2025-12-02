import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsBySubCategoryUsecase {
  final ProductRepository repository;

  GetProductsBySubCategoryUsecase(this.repository);

  Future<Either<Failure, List<Product>>> call(GetProductsParams params) async {
    return await repository.getProductsBySubCategory(
      subCategoryId: params.subCategoryId,
      page: params.page,
      limit: params.limit,
      searchQuery: params.searchQuery,
      sortBy: params.sortBy,
    );
  }
}

class GetProductsParams {
  final String subCategoryId;
  final int page;
  final int limit;
  final String? searchQuery;
  final String? sortBy;

  GetProductsParams({
    required this.subCategoryId,
    this.page = 1,
    this.limit = 20,
    this.searchQuery,
    this.sortBy,
  });
}

class GetProductByIdUsecase {
  final ProductRepository repository;

  GetProductByIdUsecase(this.repository);

  Future<Either<Failure, Product>> call(String productId) async {
    return await repository.getProductById(productId);
  }
}
