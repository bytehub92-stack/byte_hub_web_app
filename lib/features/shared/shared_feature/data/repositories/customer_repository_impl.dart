// lib/features/shared/data/repositories/customer_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  const CustomerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Customer>>> getCustomersByMerchandiser(
    String merchandiserId,
  ) async {
    try {
      final customers = await remoteDataSource.getCustomersByMerchandiser(
        merchandiserId,
      );
      return Right(customers);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomerById(String customerId) async {
    try {
      final customer = await remoteDataSource.getCustomerById(customerId);
      return Right(customer);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCustomerStatus(
    String customerId,
    bool isActive,
  ) async {
    try {
      await remoteDataSource.toggleCustomerStatus(customerId, isActive);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
