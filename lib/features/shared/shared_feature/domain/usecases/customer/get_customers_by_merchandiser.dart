// lib/features/shared/domain/usecases/customer/get_customers_by_merchandiser.dart

import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';

class GetCustomersByMerchandiser {
  final CustomerRepository repository;

  GetCustomersByMerchandiser(this.repository);

  Future<Either<Failure, List<Customer>>> call(String merchandiserId) {
    return repository.getCustomersByMerchandiser(merchandiserId);
  }
}
