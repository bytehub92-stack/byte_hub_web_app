import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/merchandiser.dart';
import '../entities/create_merchandiser_request.dart';

abstract class MerchandiserRepository {
  Future<Either<Failure, List<Merchandiser>>> getMerchandisers();

  Future<Either<Failure, Merchandiser>> getMerchandiserById(
    String merchandiserId,
  );

  Future<Either<Failure, String>> createMerchandiser(
    CreateMerchandiserRequest request,
  );

  Future<Either<Failure, Unit>> updateMerchandiserStatus(
    String merchandiserId,
    bool isActive,
  );

  Future<Either<Failure, Unit>> deleteMerchandiser(String id);
}
