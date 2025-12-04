import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories(String merchandiserId);
  Future<Either<Failure, Category>> getCategoryById(String categoryId);
  Future<Either<Failure, Category>> createCategory({
    required String merchandiserId,
    required Map<String, String> name,
    String? imageThumbnail,
    String? image,
    int sortOrder = 0,
  });
  Future<Either<Failure, Category>> updateCategory({
    required String categoryId,
    Map<String, String>? name,
    String? imageThumbnail,
    String? image,
    int? sortOrder,
    bool? isActive,
  });
  Future<Either<Failure, void>> deleteCategory(String categoryId);
}
