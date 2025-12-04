import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/merchandiser_repository.dart';

class ToggleMerchandiserStatusParams {
  final String id;
  final bool isActive;

  ToggleMerchandiserStatusParams({required this.id, required this.isActive});
}

class ToggleMerchandiserStatus
    implements UseCase<Unit, ToggleMerchandiserStatusParams> {
  final MerchandiserRepository repository;

  ToggleMerchandiserStatus(this.repository);

  @override
  Future<Either<Failure, Unit>> call(
    ToggleMerchandiserStatusParams params,
  ) async {
    return await repository.updateMerchandiserStatus(
      params.id,
      params.isActive,
    );
  }
}
