// lib/features/orders/domain/use_cases/orders_usecases.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:dartz/dartz.dart' hide Order;
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

/// Get all orders (Admin only)
class GetAllOrdersUseCase {
  final OrdersRepository repository;

  GetAllOrdersUseCase(this.repository);

  Future<Either<Failure, List<Order>>> call({
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getAllOrders(
      status: status,
      paymentStatus: paymentStatus,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Get orders by merchandiser
class GetOrdersByMerchandiserUseCase {
  final OrdersRepository repository;

  GetOrdersByMerchandiserUseCase(this.repository);

  Future<Either<Failure, List<Order>>> call({
    required String merchandiserId,
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getOrdersByMerchandiser(
      merchandiserId: merchandiserId,
      status: status,
      paymentStatus: paymentStatus,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Get orders by customer
class GetCustomerOrdersUseCase {
  final OrdersRepository repository;

  GetCustomerOrdersUseCase(this.repository);

  Future<Either<Failure, List<Order>>> call({
    required String customerId,
    String? merchandiserId,
    String? status,
  }) async {
    return await repository.getOrdersByCustomer(
      customerId: customerId,
      merchandiserId: merchandiserId,
      status: status,
    );
  }
}

/// Get single order by ID
class GetOrderByIdUseCase {
  final OrdersRepository repository;

  GetOrderByIdUseCase(this.repository);

  Future<Either<Failure, Order>> call(String orderId) async {
    return await repository.getOrderById(orderId);
  }
}

/// Update order status (Merchandiser)
class UpdateOrderStatusUseCase {
  final OrdersRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String orderId,
    required String status,
  }) async {
    return await repository.updateOrderStatus(orderId: orderId, status: status);
  }
}

/// Update payment status (Merchandiser)
class UpdatePaymentStatusUseCase {
  final OrdersRepository repository;

  UpdatePaymentStatusUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String orderId,
    required String paymentStatus,
  }) async {
    return await repository.updatePaymentStatus(
      orderId: orderId,
      paymentStatus: paymentStatus,
    );
  }
}

/// Cancel order
class CancelOrderUseCase {
  final OrdersRepository repository;

  CancelOrderUseCase(this.repository);

  Future<Either<Failure, void>> call(String orderId) async {
    return await repository.cancelOrder(orderId);
  }
}

/// Get order statistics
class GetOrderStatisticsUseCase {
  final OrdersRepository repository;

  GetOrderStatisticsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    String? merchandiserId,
  }) async {
    return await repository.getOrderStatistics(merchandiserId: merchandiserId);
  }
}
