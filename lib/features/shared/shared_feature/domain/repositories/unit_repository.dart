// lib/features/shared/domain/repositories/unit_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/unit_of_measurement.dart';

abstract class UnitRepository {
  Future<Either<Failure, List<UnitOfMeasurement>>> getUnits();
  Future<Either<Failure, UnitOfMeasurement>> getUnitById(String unitId);
}
