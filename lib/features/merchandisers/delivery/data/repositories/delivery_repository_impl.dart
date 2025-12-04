// lib/features/delivery/data/repositories/delivery_repository_impl.dart (continued)

import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/driver.dart';
import '../../domain/entities/order_assignment.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/delivery_remote_datasource.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  final DeliveryRemoteDataSource remoteDataSource;

  DeliveryRepositoryImpl({required this.remoteDataSource});

  // ==================== Merchandiser Operations ====================

  @override
  Future<Either<Failure, List<Driver>>> getDrivers(
    String merchandiserId,
  ) async {
    try {
      final drivers = await remoteDataSource.getDrivers(merchandiserId);
      return Right(drivers);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Driver>> getDriverById(String driverId) async {
    try {
      final driver = await remoteDataSource.getDriverById(driverId);
      return Right(driver);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, OrderAssignment>> assignOrderToDriver({
    required String orderId,
    required String driverId,
    required String assignedBy,
    String? notes,
  }) async {
    try {
      final assignment = await remoteDataSource.assignOrderToDriver(
        orderId: orderId,
        driverId: driverId,
        assignedBy: assignedBy,
        notes: notes,
      );
      return Right(assignment);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<OrderAssignment>>> getOrderAssignments({
    required String merchandiserId,
    String? driverId,
    bool? onlyActive,
  }) async {
    try {
      final assignments = await remoteDataSource.getOrderAssignments(
        merchandiserId: merchandiserId,
        driverId: driverId,
        onlyActive: onlyActive,
      );
      return Right(assignments);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> unassignOrder(String orderId) async {
    try {
      await remoteDataSource.unassignOrder(orderId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDeliveryStatistics(
    String merchandiserId,
  ) async {
    try {
      final stats = await remoteDataSource.getDeliveryStatistics(
        merchandiserId,
      );
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> getMerchandiserCode(
    String merchandiserId,
  ) async {
    try {
      final code = await remoteDataSource.getMerchandiserCode(merchandiserId);
      return Right(code);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
