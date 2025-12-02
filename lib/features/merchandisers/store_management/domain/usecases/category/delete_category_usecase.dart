import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/core/usecases/usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteCategoryUseCase implements UseCase<void, String> {
  final CategoryRepository repository;

  const DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String categoryId) async {
    return await repository.deleteCategory(categoryId);
  }
}
