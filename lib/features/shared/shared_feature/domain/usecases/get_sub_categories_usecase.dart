import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/sub_category_repository.dart';
import 'package:dartz/dartz.dart';

class GetSubCategoriesByCategoryId {
  final SubCategoryRepository repository;

  GetSubCategoriesByCategoryId(this.repository);

  Future<Either<Failure, List<SubCategory>>> call(String categoryId) {
    return repository.getSubCategories(categoryId);
  }
}

class GetSubCategoryById {
  final SubCategoryRepository repository;

  GetSubCategoryById(this.repository);

  Future<Either<Failure, SubCategory>> call(String subCategoryId) {
    return repository.getSubCategoryById(subCategoryId);
  }
}
