// test/features/orders/domain/usecases/orders_usecases_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/orders/domain/entities/order.dart';
import 'package:admin_panel/features/shared/orders/domain/repositories/orders_repository.dart';
import 'package:admin_panel/features/shared/orders/domain/usecases/orders_usecases.dart';
import 'package:dartz/dartz.dart' hide order, Order;
import 'package:flutter_test/flutter_test.dart';

/// Fake repository for testing
class FakeOrdersRepository implements OrdersRepository {
  bool shouldReturnFailure = false;
  String failureMessage = 'Test failure';
  List<Order> mockOrders = [];
  Order? mockOrder;
  Map<String, dynamic> mockStatistics = {};

  @override
  Future<Either<Failure, List<Order>>> getAllOrders({
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (shouldReturnFailure) {
      return Left(ServerFailure(message: failureMessage));
    }
    return Right(mockOrders);
  }

  @override
  Future<Either<Failure, List<Order>>> getOrdersByMerchandiser({
    required String merchandiserId,
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (shouldReturnFailure) {
      return Left(ServerFailure(message: failureMessage));
    }
    return Right(mockOrders);
  }

  @override
  Future<Either<Failure, List<Order>>> getOrdersByCustomer({
    required String customerId,
    String? merchandiserId,
    String? status,
  }) async {
    if (shouldReturnFailure) {
      return Left(ServerFailure(message: failureMessage));
    }
    return Right(mockOrders);
  }

  @override
  Future<Either<Failure, Order>> getOrderById(String orderId) async {
    if (shouldReturnFailure) {
      return Left(ServerFailure(message: failureMessage));
    }
    return Right(mockOrder!);
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    if (shouldReturnFailure) {
      return Left(ServerFailure(message: failureMessage));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  }) async {
    if (shouldReturnFailure) {
      return Left(ServerFailure(message: failureMessage));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    if (shouldReturnFailure) {
      return Left(ServerFailure(message: failureMessage));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getOrderStatistics({
    String? merchandiserId,
  }) async {
    if (shouldReturnFailure) {
      return Left(ServerFailure(message: failureMessage));
    }
    return Right(mockStatistics);
  }
}

void main() {
  late FakeOrdersRepository repository;

  setUp(() {
    repository = FakeOrdersRepository();
  });

  Order createTestOrder({String id = 'order_1', String status = 'pending'}) {
    return Order(
      id: id,
      customerUserId: 'customer_1',
      merchandiserId: 'merchandiser_1',
      orderNumber: 'ORD-2024-001',
      totalAmount: 500.0,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      subtotal: 450.0,
      taxAmount: 30.0,
      shippingAmount: 20.0,
      discountAmount: 0.0,
      paymentStatus: 'pending',
    );
  }

  group('GetCustomerOrdersUseCase', () {
    late GetCustomerOrdersUseCase useCase;

    setUp(() {
      useCase = GetCustomerOrdersUseCase(repository);
    });

    test('should return list of customer orders on success', () async {
      // Arrange
      final orders = [createTestOrder(), createTestOrder(id: 'order_2')];
      repository.mockOrders = orders;

      // Act
      final result = await useCase(customerId: 'customer_1');

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (orders) => expect(orders.length, 2),
      );
    });

    test('should filter customer orders by merchandiser', () async {
      // Arrange
      final orders = [createTestOrder()];
      repository.mockOrders = orders;

      // Act
      final result = await useCase(
        customerId: 'customer_1',
        merchandiserId: 'merchandiser_1',
      );

      // Assert
      expect(result, isA<Right>());
    });

    test('should filter customer orders by status', () async {
      // Arrange
      final orders = [createTestOrder(status: 'delivered')];
      repository.mockOrders = orders;

      // Act
      final result = await useCase(
        customerId: 'customer_1',
        status: 'delivered',
      );

      // Assert
      expect(result, isA<Right>());
    });

    test('should return failure when repository fails', () async {
      // Arrange
      repository.shouldReturnFailure = true;
      repository.failureMessage = 'Database error';

      // Act
      final result = await useCase(customerId: 'customer_1');

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure.message, 'Database error'),
        (orders) => fail('Expected Left but got Right'),
      );
    });
  });

  group('GetOrderByIdUseCase', () {
    late GetOrderByIdUseCase useCase;

    setUp(() {
      useCase = GetOrderByIdUseCase(repository);
    });

    test('should return order details on success', () async {
      // Arrange
      final order = createTestOrder(id: 'order_123');
      repository.mockOrder = order;

      // Act
      final result = await useCase('order_123');

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (order) => expect(order.id, 'order_123'),
      );
    });

    test('should return failure when order not found', () async {
      // Arrange
      repository.shouldReturnFailure = true;
      repository.failureMessage = 'Order not found';

      // Act
      final result = await useCase('order_999');

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure.message, 'Order not found'),
        (order) => fail('Expected Left but got Right'),
      );
    });
  });

  group('CancelOrderUseCase', () {
    late CancelOrderUseCase useCase;

    setUp(() {
      useCase = CancelOrderUseCase(repository);
    });

    test('should cancel order successfully', () async {
      // Act
      final result = await useCase('order_1');

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (_) => {}, // Success
      );
    });

    test('should return failure when cancellation fails', () async {
      // Arrange
      repository.shouldReturnFailure = true;
      repository.failureMessage = 'Cannot cancel delivered order';

      // Act
      final result = await useCase('order_1');

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure.message, 'Cannot cancel delivered order'),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('UpdateOrderStatusUseCase (Merchandiser)', () {
    late UpdateOrderStatusUseCase useCase;

    setUp(() {
      useCase = UpdateOrderStatusUseCase(repository);
    });

    test('should update order status to confirmed', () async {
      // Act
      final result = await useCase(
        orderId: 'order_1',
        status: 'confirmed',
      );

      // Assert
      expect(result, isA<Right>());
    });

    test('should update order status to preparing', () async {
      // Act
      final result = await useCase(
        orderId: 'order_1',
        status: 'preparing',
      );

      // Assert
      expect(result, isA<Right>());
    });

    test('should update order status to on_the_way', () async {
      // Act
      final result = await useCase(
        orderId: 'order_1',
        status: 'on_the_way',
      );

      // Assert
      expect(result, isA<Right>());
    });

    test('should update order status to delivered', () async {
      // Act
      final result = await useCase(
        orderId: 'order_1',
        status: 'delivered',
      );

      // Assert
      expect(result, isA<Right>());
    });

    test('should return failure when update fails', () async {
      // Arrange
      repository.shouldReturnFailure = true;
      repository.failureMessage = 'Invalid status transition';

      // Act
      final result = await useCase(
        orderId: 'order_1',
        status: 'invalid_status',
      );

      // Assert
      expect(result, isA<Left>());
    });
  });

  group('UpdatePaymentStatusUseCase (Merchandiser)', () {
    late UpdatePaymentStatusUseCase useCase;

    setUp(() {
      useCase = UpdatePaymentStatusUseCase(repository);
    });

    test('should update payment status to paid', () async {
      // Act
      final result = await useCase(
        orderId: 'order_1',
        paymentStatus: 'paid',
      );

      // Assert
      expect(result, isA<Right>());
    });

    test('should update payment status to refunded', () async {
      // Act
      final result = await useCase(
        orderId: 'order_1',
        paymentStatus: 'refunded',
      );

      // Assert
      expect(result, isA<Right>());
    });

    test('should return failure when update fails', () async {
      // Arrange
      repository.shouldReturnFailure = true;

      // Act
      final result = await useCase(
        orderId: 'order_1',
        paymentStatus: 'paid',
      );

      // Assert
      expect(result, isA<Left>());
    });
  });

  group('GetOrderStatisticsUseCase', () {
    late GetOrderStatisticsUseCase useCase;

    setUp(() {
      useCase = GetOrderStatisticsUseCase(repository);
    });

    test('should return statistics for all orders', () async {
      // Arrange
      repository.mockStatistics = {
        'total_orders': 100,
        'total_revenue': 50000.0,
        'pending_orders': 10,
      };

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (stats) {
          expect(stats['total_orders'], 100);
          expect(stats['total_revenue'], 50000.0);
        },
      );
    });

    test('should return statistics for specific merchandiser', () async {
      // Arrange
      repository.mockStatistics = {
        'total_orders': 50,
        'total_revenue': 25000.0,
      };

      // Act
      final result = await useCase(merchandiserId: 'merchandiser_1');

      // Assert
      expect(result, isA<Right>());
    });

    test('should return failure when statistics fetch fails', () async {
      // Arrange
      repository.shouldReturnFailure = true;

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Left>());
    });
  });

  group('Admin Use Cases', () {
    group('GetAllOrdersUseCase', () {
      late GetAllOrdersUseCase useCase;

      setUp(() {
        useCase = GetAllOrdersUseCase(repository);
      });

      test('should return all orders for admin', () async {
        // Arrange
        final orders = [
          createTestOrder(),
          createTestOrder(id: 'order_2'),
          createTestOrder(id: 'order_3'),
        ];
        repository.mockOrders = orders;

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (orders) => expect(orders.length, 3),
        );
      });

      test('should filter orders by status', () async {
        // Arrange
        final orders = [createTestOrder(status: 'confirmed')];
        repository.mockOrders = orders;

        // Act
        final result = await useCase(status: 'confirmed');

        // Assert
        expect(result, isA<Right>());
      });

      test('should filter orders by payment status', () async {
        // Arrange
        final orders = [createTestOrder()];
        repository.mockOrders = orders;

        // Act
        final result = await useCase(paymentStatus: 'paid');

        // Assert
        expect(result, isA<Right>());
      });

      test('should filter orders by date range', () async {
        // Arrange
        final orders = [createTestOrder()];
        repository.mockOrders = orders;

        // Act
        final result = await useCase(
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
        );

        // Assert
        expect(result, isA<Right>());
      });

      test('should return failure when fetch fails', () async {
        // Arrange
        repository.shouldReturnFailure = true;

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Left>());
      });
    });

    group('GetOrdersByMerchandiserUseCase', () {
      late GetOrdersByMerchandiserUseCase useCase;

      setUp(() {
        useCase = GetOrdersByMerchandiserUseCase(repository);
      });

      test('should return orders for specific merchandiser', () async {
        // Arrange
        final orders = [createTestOrder()];
        repository.mockOrders = orders;

        // Act
        final result = await useCase(merchandiserId: 'merchandiser_1');

        // Assert
        expect(result, isA<Right>());
      });

      test('should filter by status and payment status', () async {
        // Arrange
        final orders = [createTestOrder()];
        repository.mockOrders = orders;

        // Act
        final result = await useCase(
          merchandiserId: 'merchandiser_1',
          status: 'confirmed',
          paymentStatus: 'paid',
        );

        // Assert
        expect(result, isA<Right>());
      });
    });
  });
}
