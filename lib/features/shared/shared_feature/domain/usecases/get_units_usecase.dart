// lib/features/shared/domain/usecases/get_units_usecase.dart

import 'package:admin_panel/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/unit_of_measurement.dart';
import '../repositories/unit_repository.dart';

class GetUnitsUsecase implements UseCase<List<UnitOfMeasurement>, NoParams> {
  final UnitRepository repository;

  GetUnitsUsecase(this.repository);

  @override
  Future<Either<Failure, List<UnitOfMeasurement>>> call(NoParams params) async {
    return await repository.getUnits();
  }
}
