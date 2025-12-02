// Delete Sub-Category
import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/sub_category_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteSubCategoryUsecase {
  final SubCategoryRepository repository;

  DeleteSubCategoryUsecase(this.repository);

  Future<Either<Failure, void>> call(String subCategoryId) {
    return repository.deleteSubCategory(subCategoryId);
  }
}
