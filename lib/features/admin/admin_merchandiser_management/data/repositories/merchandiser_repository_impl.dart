import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/create_merchandiser_request.dart';
import '../../domain/entities/merchandiser.dart';
import '../../domain/repositories/merchandiser_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class MerchandiserRepositoryImpl implements MerchandiserRepository {
  final MerchandiserRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MerchandiserRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Merchandiser>>> getMerchandisers() async {
    if (await networkInfo.isConnected) {
      try {
        final merchandisers = await remoteDataSource.getMerchandisers();
        return Right(merchandisers);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Merchandiser>> getMerchandiserById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final merchandiser = await remoteDataSource.getMerchandiserById(id);
        return Right(merchandiser);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> createMerchandiser(
    CreateMerchandiserRequest request,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final tempPassword = await remoteDataSource.createMerchandiser(request);
        return Right(tempPassword);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMerchandiserStatus(
    String id,
    bool isActive,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateMerchandiserStatus(id, isActive);
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMerchandiser(String id) async {
    // Implementation for delete functionality
    throw UnimplementedError();
  }
}
