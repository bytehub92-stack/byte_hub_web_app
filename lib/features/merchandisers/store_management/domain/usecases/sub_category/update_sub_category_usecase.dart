import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/sub_category_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateSubCategoryUsecase {
  final SubCategoryRepository repository;

  UpdateSubCategoryUsecase(this.repository);

  Future<Either<Failure, SubCategory>> call({
    required String subCategoryId,
    Map<String, String>? name,
    int? sortOrder,
  }) {
    return repository.updateSubCategory(
      subCategoryId: subCategoryId,
      name: name,
      sortOrder: sortOrder,
    );
  }
}
