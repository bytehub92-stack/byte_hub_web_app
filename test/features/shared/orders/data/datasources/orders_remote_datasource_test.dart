// test/features/orders/data/datasources/orders_remote_datasource_test.dart

import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/features/shared/orders/data/datasources/orders_remote_datasource.dart';
import 'package:admin_panel/features/shared/orders/data/models/order_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake implementation for testing
class FakeOrdersRemoteDataSource implements OrdersRemoteDataSource {
  final List<Map<String, dynamic>> _orders = [];
  bool shouldThrowError = false;
  String? errorMessage;

  void addOrder(Map<String, dynamic> order) {
    _orders.add(order);
  }

  void reset() {
    _orders.clear();
    shouldThrowError = false;
    errorMessage = null;
  }

  @override
  Future<List<OrderModel>> getAllOrders({
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (shouldThrowError) {
      throw ServerException(message: errorMessage ?? 'Database error');
    }

    var filteredOrders = List<Map<String, dynamic>>.from(_orders);

    if (status != null) {
      filteredOrders =
          filteredOrders.where((order) => order['status'] == status).toList();
    }

    if (paymentStatus != null) {
      filteredOrders = filteredOrders
          .where((order) => order['payment_status'] == paymentStatus)
          .toList();
    }

    if (startDate != null) {
      filteredOrders = filteredOrders.where((order) {
        final createdAt = DateTime.parse(order['created_at'] as String);
        return createdAt.isAfter(startDate) ||
            createdAt.isAtSameMomentAs(startDate);
      }).toList();
    }

    if (endDate != null) {
      filteredOrders = filteredOrders.where((order) {
        final createdAt = DateTime.parse(order['created_at'] as String);
        return createdAt.isBefore(endDate) ||
            createdAt.isAtSameMomentAs(endDate);
      }).toList();
    }

    return filteredOrders.map((json) => OrderModel.fromJson(json)).toList();
  }

  @override
  Future<List<OrderModel>> getOrdersByMerchandiser({
    required String merchandiserId,
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (shouldThrowError) {
      throw ServerException(message: errorMessage ?? 'Database error');
    }

    var filteredOrders = _orders
        .where((order) => order['merchandiser_id'] == merchandiserId)
        .toList();

    if (status != null) {
      filteredOrders =
          filteredOrders.where((order) => order['status'] == status).toList();
    }

    if (paymentStatus != null) {
      filteredOrders = filteredOrders
          .where((order) => order['payment_status'] == paymentStatus)
          .toList();
    }

    if (startDate != null) {
      filteredOrders = filteredOrders.where((order) {
        final createdAt = DateTime.parse(order['created_at'] as String);
        return createdAt.isAfter(startDate) ||
            createdAt.isAtSameMomentAs(startDate);
      }).toList();
    }

    if (endDate != null) {
      filteredOrders = filteredOrders.where((order) {
        final createdAt = DateTime.parse(order['created_at'] as String);
        return createdAt.isBefore(endDate) ||
            createdAt.isAtSameMomentAs(endDate);
      }).toList();
    }

    return filteredOrders.map((json) => OrderModel.fromJson(json)).toList();
  }

  @override
  Future<List<OrderModel>> getOrdersByCustomer({
    required String customerId,
    String? merchandiserId,
    String? status,
  }) async {
    if (shouldThrowError) {
      throw ServerException(message: errorMessage ?? 'Database error');
    }

    var filteredOrders = _orders
        .where((order) => order['customer_user_id'] == customerId)
        .toList();

    if (merchandiserId != null) {
      filteredOrders = filteredOrders
          .where((order) => order['merchandiser_id'] == merchandiserId)
          .toList();
    }

    if (status != null) {
      filteredOrders =
          filteredOrders.where((order) => order['status'] == status).toList();
    }

    return filteredOrders.map((json) => OrderModel.fromJson(json)).toList();
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    if (shouldThrowError) {
      throw ServerException(message: errorMessage ?? 'Database error');
    }

    final order = _orders.firstWhere(
      (order) => order['id'] == orderId,
      orElse: () => throw ServerException(message: 'Order not found'),
    );

    return OrderModel.fromJson(order);
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    if (shouldThrowError) {
      throw ServerException(message: errorMessage ?? 'Update failed');
    }

    final index = _orders.indexWhere((order) => order['id'] == orderId);
    if (index == -1) {
      throw ServerException(message: 'Order not found');
    }

    _orders[index]['status'] = status;
    _orders[index]['updated_at'] = DateTime.now().toIso8601String();
  }

  @override
  Future<void> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  }) async {
    if (shouldThrowError) {
      throw ServerException(message: errorMessage ?? 'Update failed');
    }

    final index = _orders.indexWhere((order) => order['id'] == orderId);
    if (index == -1) {
      throw ServerException(message: 'Order not found');
    }

    _orders[index]['payment_status'] = paymentStatus;
    _orders[index]['updated_at'] = DateTime.now().toIso8601String();
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    if (shouldThrowError) {
      throw ServerException(message: errorMessage ?? 'Cancellation failed');
    }

    final index = _orders.indexWhere((order) => order['id'] == orderId);
    if (index == -1) {
      throw ServerException(message: 'Order not found');
    }

    _orders[index]['status'] = 'cancelled';
    _orders[index]['updated_at'] = DateTime.now().toIso8601String();
  }

  @override
  Future<Map<String, dynamic>> getOrderStatistics(
      {String? merchandiserId}) async {
    if (shouldThrowError) {
      throw ServerException(message: errorMessage ?? 'Database error');
    }

    var orders = _orders;

    if (merchandiserId != null) {
      orders = orders
          .where((order) => order['merchandiser_id'] == merchandiserId)
          .toList();
    }

    final totalOrders = orders.length;
    final pendingOrders = orders.where((o) => o['status'] == 'pending').length;
    final confirmedOrders =
        orders.where((o) => o['status'] == 'confirmed').length;
    final preparingOrders =
        orders.where((o) => o['status'] == 'preparing').length;
    final onTheWayOrders =
        orders.where((o) => o['status'] == 'on_the_way').length;
    final deliveredOrders =
        orders.where((o) => o['status'] == 'delivered').length;
    final cancelledOrders =
        orders.where((o) => o['status'] == 'cancelled').length;

    final totalRevenue = orders.fold<double>(
      0.0,
      (sum, order) {
        final amount = order['total_amount'];
        if (amount is num) return sum + amount.toDouble();
        return sum;
      },
    );

    return {
      'total_orders': totalOrders,
      'pending_orders': pendingOrders,
      'confirmed_orders': confirmedOrders,
      'preparing_orders': preparingOrders,
      'on_the_way_orders': onTheWayOrders,
      'delivered_orders': deliveredOrders,
      'cancelled_orders': cancelledOrders,
      'total_revenue': totalRevenue,
    };
  }
}

void main() {
  late FakeOrdersRemoteDataSource dataSource;
  late DateTime testDate;

  setUp(() {
    dataSource = FakeOrdersRemoteDataSource();
    testDate = DateTime(2024, 1, 15, 10, 30);
  });

  tearDown(() {
    dataSource.reset();
  });

  Map<String, dynamic> createTestOrder({
    String id = 'order_1',
    String customerId = 'customer_1',
    String merchandiserId = 'merchandiser_1',
    String orderNumber = 'ORD-2024-001',
    double totalAmount = 500.0,
    String status = 'pending',
    String paymentStatus = 'pending',
  }) {
    return {
      'id': id,
      'customer_user_id': customerId,
      'merchandiser_id': merchandiserId,
      'order_number': orderNumber,
      'total_amount': totalAmount,
      'status': status,
      'created_at': testDate.toIso8601String(),
      'updated_at': testDate.toIso8601String(),
      'subtotal': 450.0,
      'tax_amount': 30.0,
      'shipping_amount': 20.0,
      'discount_amount': 0.0,
      'payment_status': paymentStatus,
      'customer_name': 'John Doe',
      'customer_email': 'john@example.com',
      'customer_phone': '+201234567890',
      'merchandiser_name': 'Test Store',
    };
  }

  group('getAllOrders', () {
    test('should return list of orders when call is successful', () async {
      // Arrange
      dataSource.addOrder(createTestOrder());
      dataSource.addOrder(createTestOrder(
        id: 'order_2',
        orderNumber: 'ORD-2024-002',
      ));

      // Act
      final result = await dataSource.getAllOrders();

      // Assert
      expect(result, isA<List<OrderModel>>());
      expect(result.length, 2);
      expect(result.first.id, 'order_1');
      expect(result.last.id, 'order_2');
    });

    test('should return empty list when no orders exist', () async {
      // Act
      final result = await dataSource.getAllOrders();

      // Assert
      expect(result, isEmpty);
    });

    test('should filter by status when status is provided', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(status: 'pending'));
      dataSource.addOrder(createTestOrder(
        id: 'order_2',
        status: 'confirmed',
      ));
      dataSource.addOrder(createTestOrder(
        id: 'order_3',
        status: 'pending',
      ));

      // Act
      final result = await dataSource.getAllOrders(status: 'pending');

      // Assert
      expect(result.length, 2);
      expect(result.every((order) => order.status == 'pending'), isTrue);
    });

    test('should filter by payment status when provided', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(paymentStatus: 'pending'));
      dataSource.addOrder(createTestOrder(
        id: 'order_2',
        paymentStatus: 'paid',
      ));

      // Act
      final result = await dataSource.getAllOrders(paymentStatus: 'paid');

      // Assert
      expect(result.length, 1);
      expect(result.first.paymentStatus, 'paid');
    });

    test('should filter by date range when dates are provided', () async {
      // Arrange
      final oldDate = DateTime(2024, 1, 1);
      final newDate = DateTime(2024, 1, 20);

      final oldOrder = createTestOrder();
      oldOrder['created_at'] = oldDate.toIso8601String();
      dataSource.addOrder(oldOrder);

      final newOrder = createTestOrder(id: 'order_2');
      newOrder['created_at'] = newDate.toIso8601String();
      dataSource.addOrder(newOrder);

      // Act
      final result = await dataSource.getAllOrders(
        startDate: DateTime(2024, 1, 10),
        endDate: DateTime(2024, 1, 25),
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 'order_2');
    });

    test('should filter by multiple criteria', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(
        status: 'confirmed',
        paymentStatus: 'paid',
      ));
      dataSource.addOrder(createTestOrder(
        id: 'order_2',
        status: 'pending',
        paymentStatus: 'pending',
      ));

      // Act
      final result = await dataSource.getAllOrders(
        status: 'confirmed',
        paymentStatus: 'paid',
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.status, 'confirmed');
      expect(result.first.paymentStatus, 'paid');
    });

    test('should throw ServerException when shouldThrowError is true',
        () async {
      // Arrange
      dataSource.shouldThrowError = true;
      dataSource.errorMessage = 'Database connection failed';

      // Act & Assert
      expect(
        () => dataSource.getAllOrders(),
        throwsA(isA<ServerException>().having(
          (e) => e.message,
          'message',
          'Database connection failed',
        )),
      );
    });
  });

  group('getOrdersByMerchandiser', () {
    test('should return orders for specific merchandiser', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(merchandiserId: 'merchandiser_1'));
      dataSource.addOrder(createTestOrder(
        id: 'order_2',
        merchandiserId: 'merchandiser_2',
      ));
      dataSource.addOrder(createTestOrder(
        id: 'order_3',
        merchandiserId: 'merchandiser_1',
      ));

      // Act
      final result = await dataSource.getOrdersByMerchandiser(
        merchandiserId: 'merchandiser_1',
      );

      // Assert
      expect(result.length, 2);
      expect(
        result.every((order) => order.merchandiserId == 'merchandiser_1'),
        isTrue,
      );
    });

    test('should return empty list when merchandiser has no orders', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(merchandiserId: 'merchandiser_1'));

      // Act
      final result = await dataSource.getOrdersByMerchandiser(
        merchandiserId: 'merchandiser_2',
      );

      // Assert
      expect(result, isEmpty);
    });

    test('should filter merchandiser orders by status', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(
        merchandiserId: 'merchandiser_1',
        status: 'pending',
      ));
      dataSource.addOrder(createTestOrder(
        id: 'order_2',
        merchandiserId: 'merchandiser_1',
        status: 'confirmed',
      ));

      // Act
      final result = await dataSource.getOrdersByMerchandiser(
        merchandiserId: 'merchandiser_1',
        status: 'confirmed',
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.status, 'confirmed');
    });

    test('should filter merchandiser orders by payment status', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(
        merchandiserId: 'merchandiser_1',
        paymentStatus: 'pending',
      ));
      dataSource.addOrder(createTestOrder(
        id: 'order_2',
        merchandiserId: 'merchandiser_1',
        paymentStatus: 'paid',
      ));

      // Act
      final result = await dataSource.getOrdersByMerchandiser(
        merchandiserId: 'merchandiser_1',
        paymentStatus: 'paid',
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.paymentStatus, 'paid');
    });

    test('should throw ServerException when shouldThrowError is true',
        () async {
      // Arrange
      dataSource.shouldThrowError = true;

      // Act & Assert
      expect(
        () => dataSource.getOrdersByMerchandiser(
          merchandiserId: 'merchandiser_1',
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getOrdersByCustomer', () {
    test('should return orders for specific customer', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(customerId: 'customer_1'));
      dataSource.addOrder(createTestOrder(
        id: 'order_2',
        customerId: 'customer_2',
      ));
      dataSource.addOrder(createTestOrder(
        id: 'order_3',
        customerId: 'customer_1',
      ));

      // Act
      final result = await dataSource.getOrdersByCustomer(
        customerId: 'customer_1',
      );

      // Assert
      expect(result.length, 2);
      expect(
        result.every((order) => order.customerUserId == 'customer_1'),
        isTrue,
      );
    });

    test('should filter customer orders by merchandiser', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(
        customerId: 'customer_1',
        merchandiserId: 'merchandiser_1',
      ));
      dataSource.addOrder(createTestOrder(
        id: 'order_2',
        customerId: 'customer_1',
        merchandiserId: 'merchandiser_2',
      ));

      // Act
      final result = await dataSource.getOrdersByCustomer(
        customerId: 'customer_1',
        merchandiserId: 'merchandiser_1',
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.merchandiserId, 'merchandiser_1');
    });

    test('should filter customer orders by status', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(
        customerId: 'customer_1',
        status: 'pending',
      ));
      dataSource.addOrder(createTestOrder(
        id: 'order_2',
        customerId: 'customer_1',
        status: 'delivered',
      ));

      // Act
      final result = await dataSource.getOrdersByCustomer(
        customerId: 'customer_1',
        status: 'delivered',
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.status, 'delivered');
    });

    test('should throw ServerException when shouldThrowError is true',
        () async {
      // Arrange
      dataSource.shouldThrowError = true;

      // Act & Assert
      expect(
        () => dataSource.getOrdersByCustomer(customerId: 'customer_1'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getOrderById', () {
    test('should return order when found', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(id: 'order_123'));

      // Act
      final result = await dataSource.getOrderById('order_123');

      // Assert
      expect(result, isA<OrderModel>());
      expect(result.id, 'order_123');
    });

    test('should throw ServerException when order not found', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(id: 'order_1'));

      // Act & Assert
      expect(
        () => dataSource.getOrderById('order_999'),
        throwsA(isA<ServerException>().having(
          (e) => e.message,
          'message',
          'Order not found',
        )),
      );
    });

    test('should throw ServerException when shouldThrowError is true',
        () async {
      // Arrange
      dataSource.shouldThrowError = true;

      // Act & Assert
      expect(
        () => dataSource.getOrderById('order_1'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('updateOrderStatus', () {
    test('should update order status successfully', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(id: 'order_1', status: 'pending'));

      // Act
      await dataSource.updateOrderStatus(
          orderId: 'order_1', status: 'confirmed');

      // Assert
      final order = await dataSource.getOrderById('order_1');
      expect(order.status, 'confirmed');
    });

    test('should throw ServerException when order not found', () async {
      // Act & Assert
      expect(
        () => dataSource.updateOrderStatus(
          orderId: 'order_999',
          status: 'confirmed',
        ),
        throwsA(isA<ServerException>().having(
          (e) => e.message,
          'message',
          'Order not found',
        )),
      );
    });

    test('should throw ServerException when shouldThrowError is true',
        () async {
      // Arrange
      dataSource.shouldThrowError = true;

      // Act & Assert
      expect(
        () => dataSource.updateOrderStatus(
          orderId: 'order_1',
          status: 'confirmed',
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('updatePaymentStatus', () {
    test('should update payment status successfully', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(
        id: 'order_1',
        paymentStatus: 'pending',
      ));

      // Act
      await dataSource.updatePaymentStatus(
        orderId: 'order_1',
        paymentStatus: 'paid',
      );

      // Assert
      final order = await dataSource.getOrderById('order_1');
      expect(order.paymentStatus, 'paid');
    });

    test('should throw ServerException when order not found', () async {
      // Act & Assert
      expect(
        () => dataSource.updatePaymentStatus(
          orderId: 'order_999',
          paymentStatus: 'paid',
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException when shouldThrowError is true',
        () async {
      // Arrange
      dataSource.shouldThrowError = true;

      // Act & Assert
      expect(
        () => dataSource.updatePaymentStatus(
          orderId: 'order_1',
          paymentStatus: 'paid',
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('cancelOrder', () {
    test('should cancel order successfully', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(id: 'order_1', status: 'pending'));

      // Act
      await dataSource.cancelOrder('order_1');

      // Assert
      final order = await dataSource.getOrderById('order_1');
      expect(order.status, 'cancelled');
    });

    test('should throw ServerException when order not found', () async {
      // Act & Assert
      expect(
        () => dataSource.cancelOrder('order_999'),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException when shouldThrowError is true',
        () async {
      // Arrange
      dataSource.shouldThrowError = true;

      // Act & Assert
      expect(
        () => dataSource.cancelOrder('order_1'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getOrderStatistics', () {
    test('should return statistics for all orders', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(
        status: 'pending',
        totalAmount: 100.0,
      ));
      dataSource.addOrder(createTestOrder(
        id: 'order_2',
        status: 'confirmed',
        totalAmount: 200.0,
      ));
      dataSource.addOrder(createTestOrder(
        id: 'order_3',
        status: 'delivered',
        totalAmount: 300.0,
      ));
      dataSource.addOrder(createTestOrder(
        id: 'order_4',
        status: 'cancelled',
        totalAmount: 50.0,
      ));

      // Act
      final result = await dataSource.getOrderStatistics();

      // Assert
      expect(result['total_orders'], 4);
      expect(result['pending_orders'], 1);
      expect(result['confirmed_orders'], 1);
      expect(result['delivered_orders'], 1);
      expect(result['cancelled_orders'], 1);
      expect(result['total_revenue'], 650.0);
    });

    test('should return statistics filtered by merchandiser', () async {
      // Arrange
      dataSource.addOrder(createTestOrder(
        merchandiserId: 'merchandiser_1',
        totalAmount: 100.0,
      ));
      dataSource.addOrder(createTestOrder(
        id: 'order_2',
        merchandiserId: 'merchandiser_2',
        totalAmount: 200.0,
      ));
      dataSource.addOrder(createTestOrder(
        id: 'order_3',
        merchandiserId: 'merchandiser_1',
        totalAmount: 150.0,
      ));

      // Act
      final result = await dataSource.getOrderStatistics(
        merchandiserId: 'merchandiser_1',
      );

      // Assert
      expect(result['total_orders'], 2);
      expect(result['total_revenue'], 250.0);
    });

    test('should return zero statistics when no orders exist', () async {
      // Act
      final result = await dataSource.getOrderStatistics();

      // Assert
      expect(result['total_orders'], 0);
      expect(result['total_revenue'], 0.0);
      expect(result['pending_orders'], 0);
      expect(result['confirmed_orders'], 0);
      expect(result['delivered_orders'], 0);
      expect(result['cancelled_orders'], 0);
    });

    test('should throw ServerException when shouldThrowError is true',
        () async {
      // Arrange
      dataSource.shouldThrowError = true;

      // Act & Assert
      expect(
        () => dataSource.getOrderStatistics(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
