// lib/features/shared/domain/usecases/customer/toggle_customer_status.dart

import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../repositories/customer_repository.dart';

class ToggleCustomerStatus {
  final CustomerRepository repository;

  ToggleCustomerStatus(this.repository);

  Future<Either<Failure, void>> call(String customerId, bool isActive) {
    return repository.toggleCustomerStatus(customerId, isActive);
  }
}
