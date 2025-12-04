import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/core/usecases/usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateCategoryParams {
  final String categoryId;
  final Map<String, String>? name;
  final String? imageThumbnail;
  final String? image;
  final int? sortOrder;
  final bool? isActive;

  const UpdateCategoryParams({
    required this.categoryId,
    this.name,
    this.imageThumbnail,
    this.image,
    this.sortOrder,
    this.isActive,
  });
}

class UpdateCategoryUseCase implements UseCase<Category, UpdateCategoryParams> {
  final CategoryRepository repository;

  const UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, Category>> call(UpdateCategoryParams params) async {
    return await repository.updateCategory(
      categoryId: params.categoryId,
      name: params.name,
      imageThumbnail: params.imageThumbnail,
      image: params.image,
      sortOrder: params.sortOrder,
      isActive: params.isActive,
    );
  }
}
