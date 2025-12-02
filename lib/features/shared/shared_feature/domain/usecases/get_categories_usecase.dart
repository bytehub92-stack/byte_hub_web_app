import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoriesByMerchandiserIdUseCase
    implements UseCase<List<Category>, String> {
  final CategoryRepository repository;

  const GetCategoriesByMerchandiserIdUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(String merchandiserId) async {
    return await repository.getCategories(merchandiserId);
  }
}
