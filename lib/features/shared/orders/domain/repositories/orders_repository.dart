// lib/features/orders/domain/repositories/orders_repository.dart

import 'package:dartz/dartz.dart' hide Order;
import '../../../../../core/error/failures.dart';
import '../entities/order.dart';

abstract class OrdersRepository {
  /// Get all orders (admin only)
  Future<Either<Failure, List<Order>>> getAllOrders({
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get orders by merchandiser
  Future<Either<Failure, List<Order>>> getOrdersByMerchandiser({
    required String merchandiserId,
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get orders by customer
  Future<Either<Failure, List<Order>>> getOrdersByCustomer({
    required String customerId,
    String? merchandiserId,
    String? status,
  });

  /// Get single order by ID with items
  Future<Either<Failure, Order>> getOrderById(String orderId);

  /// Update order status
  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String status,
  });

  /// Update payment status
  Future<Either<Failure, void>> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  });

  /// Cancel order
  Future<Either<Failure, void>> cancelOrder(String orderId);

  /// Get order statistics
  Future<Either<Failure, Map<String, dynamic>>> getOrderStatistics({
    String? merchandiserId,
  });
}
