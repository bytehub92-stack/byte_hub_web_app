import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/core/usecases/usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';

class CreateCategoryParams {
  final String merchandiserId;
  final Map<String, String> name;
  final String? imageThumbnail;
  final String? image;
  final int sortOrder;

  const CreateCategoryParams({
    required this.merchandiserId,
    required this.name,
    this.imageThumbnail,
    this.image,
    this.sortOrder = 0,
  });
}

class CreateCategoryUseCase implements UseCase<Category, CreateCategoryParams> {
  final CategoryRepository repository;

  const CreateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, Category>> call(CreateCategoryParams params) async {
    return await repository.createCategory(
      merchandiserId: params.merchandiserId,
      name: params.name,
      imageThumbnail: params.imageThumbnail,
      image: params.image,
      sortOrder: params.sortOrder,
    );
  }
}
