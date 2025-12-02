// lib/features/orders/data/repositories/orders_repository_impl.dart

import 'package:dartz/dartz.dart' hide Order;
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Order>>> getAllOrders({
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final orders = await remoteDataSource.getAllOrders(
        status: status,
        paymentStatus: paymentStatus,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrdersByMerchandiser({
    required String merchandiserId,
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final orders = await remoteDataSource.getOrdersByMerchandiser(
        merchandiserId: merchandiserId,
        status: status,
        paymentStatus: paymentStatus,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrdersByCustomer({
    required String customerId,
    String? merchandiserId,
    String? status,
  }) async {
    try {
      print('orders repo impl: orders customers start');
      final orders = await remoteDataSource.getOrdersByCustomer(
        customerId: customerId,
        merchandiserId: merchandiserId,
        status: status,
      );
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderById(String orderId) async {
    try {
      final order = await remoteDataSource.getOrderById(orderId);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await remoteDataSource.updateOrderStatus(
        orderId: orderId,
        status: status,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  }) async {
    try {
      await remoteDataSource.updatePaymentStatus(
        orderId: orderId,
        paymentStatus: paymentStatus,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    try {
      await remoteDataSource.cancelOrder(orderId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getOrderStatistics({
    String? merchandiserId,
  }) async {
    try {
      final stats = await remoteDataSource.getOrderStatistics(
        merchandiserId: merchandiserId,
      );
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
