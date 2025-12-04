// lib/features/shared/domain/repositories/customer_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getCustomersByMerchandiser(
    String merchandiserId,
  );
  Future<Either<Failure, Customer>> getCustomerById(String customerId);
  Future<Either<Failure, void>> toggleCustomerStatus(
    String customerId,
    bool isActive,
  );
}
