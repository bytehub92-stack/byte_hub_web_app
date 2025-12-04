import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/sub_category_repository.dart';
import 'package:dartz/dartz.dart';

class CreateSubCategoryParams {
  final String merchandiserId;
  final String categoryId;
  final Map<String, String> name;
  final int sortOrder;
  final bool isActive;

  const CreateSubCategoryParams({
    required this.merchandiserId,
    required this.categoryId,
    required this.name,
    this.sortOrder = 0,
    this.isActive = true,
  });
}

class CreateSubCategoryUsecase {
  final SubCategoryRepository repository;

  CreateSubCategoryUsecase(this.repository);

  Future<Either<Failure, SubCategory>> call(CreateSubCategoryParams params) {
    return repository.createSubCategory(
      merchandiserId: params.merchandiserId,
      categoryId: params.categoryId,
      name: params.name,
      sortOrder: params.sortOrder,
      isActive: params.isActive,
    );
  }
}
