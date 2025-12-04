// lib/features/shared/data/repositories/unit_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/unit_of_measurement.dart';
import '../../domain/repositories/unit_repository.dart';
import '../datasources/unit_remote_datasource.dart';

class UnitRepositoryImpl implements UnitRepository {
  final UnitRemoteDataSource remoteDataSource;

  const UnitRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UnitOfMeasurement>>> getUnits() async {
    try {
      final units = await remoteDataSource.getUnits();
      return Right(units);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UnitOfMeasurement>> getUnitById(String unitId) async {
    try {
      final unit = await remoteDataSource.getUnitById(unitId);
      return Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
