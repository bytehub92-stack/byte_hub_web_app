import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/merchandiser.dart';
import '../repositories/merchandiser_repository.dart';

class GetMerchandisers implements UseCase<List<Merchandiser>, NoParams> {
  final MerchandiserRepository repository;

  GetMerchandisers(this.repository);

  @override
  Future<Either<Failure, List<Merchandiser>>> call(NoParams params) async {
    return await repository.getMerchandisers();
  }
}
