import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:dartz/dartz.dart';

abstract class SubCategoryRepository {
  Future<Either<Failure, List<SubCategory>>> getSubCategories(
    String categoryId,
  );

  Future<Either<Failure, SubCategory>> getSubCategoryById(String categoryId);
  Future<Either<Failure, SubCategory>> createSubCategory({
    required String merchandiserId,
    required String categoryId,
    required Map<String, String> name,
    int sortOrder = 0,
    bool isActive = true,
  });
  Future<Either<Failure, SubCategory>> updateSubCategory({
    required String subCategoryId,
    Map<String, String>? name,
    int? sortOrder,
  });
  Future<Either<Failure, void>> deleteSubCategory(String subCategoryId);
}
