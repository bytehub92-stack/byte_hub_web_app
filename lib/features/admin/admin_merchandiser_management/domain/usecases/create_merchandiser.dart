import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/create_merchandiser_request.dart';
import '../repositories/merchandiser_repository.dart';

class CreateMerchandiser implements UseCase<String, CreateMerchandiserRequest> {
  final MerchandiserRepository repository;

  CreateMerchandiser(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateMerchandiserRequest params) async {
    return await repository.createMerchandiser(params);
  }
}
