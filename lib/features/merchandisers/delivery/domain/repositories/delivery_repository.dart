// lib/features/delivery/domain/repositories/delivery_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/driver.dart';
import '../entities/order_assignment.dart';

abstract class DeliveryRepository {
  // Merchandiser operations
  Future<Either<Failure, List<Driver>>> getDrivers(String merchandiserId);
  Future<Either<Failure, Driver>> getDriverById(String driverId);
  Future<Either<Failure, OrderAssignment>> assignOrderToDriver({
    required String orderId,
    required String driverId,
    required String assignedBy,
    String? notes,
  });
  Future<Either<Failure, List<OrderAssignment>>> getOrderAssignments({
    required String merchandiserId,
    String? driverId,
    bool? onlyActive,
  });
  Future<Either<Failure, void>> unassignOrder(String orderId);
  Future<Either<Failure, Map<String, dynamic>>> getDeliveryStatistics(
    String merchandiserId,
  );
  Future<Either<Failure, String>> getMerchandiserCode(String merchandiserId);
}
