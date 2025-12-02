// test/features/orders/presentation/bloc/orders_bloc_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/orders/data/services/order_service.dart';
import 'package:admin_panel/features/shared/orders/domain/entities/order.dart';
import 'package:admin_panel/features/shared/orders/domain/usecases/orders_usecases.dart';
import 'package:admin_panel/features/shared/orders/presentation/bloc/orders_bloc.dart';
import 'package:admin_panel/features/shared/orders/presentation/bloc/orders_event.dart';
import 'package:admin_panel/features/shared/orders/presentation/bloc/orders_state.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockGetAllOrders extends Mock implements GetAllOrdersUseCase {}

class MockGetOrdersByMerchandiser extends Mock
    implements GetOrdersByMerchandiserUseCase {}

class MockGetOrdersByCustomer extends Mock
    implements GetCustomerOrdersUseCase {}

class MockGetOrderById extends Mock implements GetOrderByIdUseCase {}

class MockUpdateOrderStatus extends Mock implements UpdateOrderStatusUseCase {}

class MockUpdatePaymentStatus extends Mock
    implements UpdatePaymentStatusUseCase {}

class MockOrderService extends Mock implements OrderService {}

void main() {
  late MockGetAllOrders mockGetAllOrders;
  late MockGetOrdersByMerchandiser mockGetOrdersByMerchandiser;
  late MockGetOrdersByCustomer mockGetOrdersByCustomer;
  late MockGetOrderById mockGetOrderById;
  late MockUpdateOrderStatus mockUpdateOrderStatus;
  late MockUpdatePaymentStatus mockUpdatePaymentStatus;
  late MockOrderService mockOrderService;

  setUp(() {
    mockGetAllOrders = MockGetAllOrders();
    mockGetOrdersByMerchandiser = MockGetOrdersByMerchandiser();
    mockGetOrdersByCustomer = MockGetOrdersByCustomer();
    mockGetOrderById = MockGetOrderById();
    mockUpdateOrderStatus = MockUpdateOrderStatus();
    mockUpdatePaymentStatus = MockUpdatePaymentStatus();
    mockOrderService = MockOrderService();

    // Register fallback values for mocktail
    registerFallbackValue(DateTime.now());
  });

  Order createTestOrder({
    String id = 'order_1',
    String status = 'pending',
    String merchandiserId = 'merchandiser_1',
    String customerId = 'customer_1',
  }) {
    return Order(
      id: id,
      customerUserId: customerId,
      merchandiserId: merchandiserId,
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

  OrdersBloc createBloc() {
    return OrdersBloc(
      getAllOrders: mockGetAllOrders,
      getOrdersByMerchandiser: mockGetOrdersByMerchandiser,
      getOrdersByCustomer: mockGetOrdersByCustomer,
      getOrderById: mockGetOrderById,
      updateOrderStatus: mockUpdateOrderStatus,
      updatePaymentStatus: mockUpdatePaymentStatus,
      orderService: mockOrderService,
      GetCustomerOrdersUseCase: mockGetOrdersByCustomer,
    );
  }

  group('OrdersBloc - Admin Get All Orders', () {
    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersLoading, OrdersLoaded] when LoadAllOrders succeeds',
      build: () {
        final orders = [
          createTestOrder(),
          createTestOrder(id: 'order_2', merchandiserId: 'merchandiser_2'),
        ];
        when(() => mockGetAllOrders(
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => Right(orders));

        return createBloc();
      },
      act: (bloc) => bloc.add(const LoadAllOrders()),
      expect: () => [
        OrdersLoading(),
        isA<OrdersLoaded>().having(
          (state) => state.orders.length,
          'orders length',
          2,
        ),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersLoading, OrdersEmpty] when no orders found',
      build: () {
        when(() => mockGetAllOrders(
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => const Right([]));

        return createBloc();
      },
      act: (bloc) => bloc.add(const LoadAllOrders()),
      expect: () => [
        OrdersLoading(),
        const OrdersEmpty(),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersLoading, OrdersError] when LoadAllOrders fails',
      build: () {
        when(() => mockGetAllOrders(
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Failed to fetch orders'),
          ),
        );

        return createBloc();
      },
      act: (bloc) => bloc.add(const LoadAllOrders()),
      expect: () => [
        OrdersLoading(),
        const OrdersError('Failed to fetch orders'),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'filters all orders by status',
      build: () {
        final orders = [createTestOrder(status: 'delivered')];
        when(() => mockGetAllOrders(
              status: 'delivered',
              paymentStatus: any(named: 'paymentStatus'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => Right(orders));

        return createBloc();
      },
      act: (bloc) => bloc.add(const LoadAllOrders(status: 'delivered')),
      expect: () => [
        OrdersLoading(),
        isA<OrdersLoaded>().having(
          (state) => state.appliedStatusFilter,
          'applied status filter',
          'delivered',
        ),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'filters all orders by payment status',
      build: () {
        final orders = [createTestOrder()];
        when(() => mockGetAllOrders(
              status: any(named: 'status'),
              paymentStatus: 'paid',
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => Right(orders));

        return createBloc();
      },
      act: (bloc) => bloc.add(const LoadAllOrders(paymentStatus: 'paid')),
      expect: () => [
        OrdersLoading(),
        isA<OrdersLoaded>().having(
          (state) => state.appliedPaymentFilter,
          'applied payment filter',
          'paid',
        ),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'filters all orders by date range',
      build: () {
        final orders = [createTestOrder()];
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);

        when(() => mockGetAllOrders(
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              startDate: startDate,
              endDate: endDate,
            )).thenAnswer((_) async => Right(orders));

        return createBloc();
      },
      act: (bloc) => bloc.add(LoadAllOrders(
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
      )),
      expect: () => [
        OrdersLoading(),
        isA<OrdersLoaded>(),
      ],
    );
  });

  group('OrdersBloc - Merchandiser Orders', () {
    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersLoading, OrdersLoaded] when LoadMerchandiserOrders succeeds',
      build: () {
        final orders = [
          createTestOrder(),
          createTestOrder(id: 'order_2'),
        ];
        when(() => mockGetOrdersByMerchandiser(
              merchandiserId: 'merchandiser_1',
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => Right(orders));

        return createBloc();
      },
      act: (bloc) => bloc.add(
        const LoadMerchandiserOrders(merchandiserId: 'merchandiser_1'),
      ),
      expect: () => [
        OrdersLoading(),
        isA<OrdersLoaded>().having(
          (state) => state.orders.length,
          'orders length',
          2,
        ),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersLoading, OrdersEmpty] when merchandiser has no orders',
      build: () {
        when(() => mockGetOrdersByMerchandiser(
              merchandiserId: 'merchandiser_1',
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => const Right([]));

        return createBloc();
      },
      act: (bloc) => bloc.add(
        const LoadMerchandiserOrders(merchandiserId: 'merchandiser_1'),
      ),
      expect: () => [
        OrdersLoading(),
        const OrdersEmpty(),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'filters merchandiser orders by status',
      build: () {
        final orders = [createTestOrder(status: 'confirmed')];
        when(() => mockGetOrdersByMerchandiser(
              merchandiserId: 'merchandiser_1',
              status: 'confirmed',
              paymentStatus: any(named: 'paymentStatus'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => Right(orders));

        return createBloc();
      },
      act: (bloc) => bloc.add(
        const LoadMerchandiserOrders(
          merchandiserId: 'merchandiser_1',
          status: 'confirmed',
        ),
      ),
      expect: () => [
        OrdersLoading(),
        isA<OrdersLoaded>().having(
          (state) => state.appliedStatusFilter,
          'applied status filter',
          'confirmed',
        ),
      ],
    );
  });

  group('OrdersBloc - Customer Orders', () {
    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersLoading, OrdersLoaded] when LoadCustomerOrders succeeds',
      build: () {
        final orders = [
          createTestOrder(),
          createTestOrder(id: 'order_2'),
        ];
        when(() => mockGetOrdersByCustomer(
              customerId: 'customer_1',
              merchandiserId: any(named: 'merchandiserId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => Right(orders));

        return createBloc();
      },
      act: (bloc) => bloc.add(
        const LoadCustomerOrders(customerId: 'customer_1'),
      ),
      expect: () => [
        OrdersLoading(),
        isA<OrdersLoaded>().having(
          (state) => state.orders.length,
          'orders length',
          2,
        ),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersLoading, OrdersEmpty] when customer has no orders',
      build: () {
        when(() => mockGetOrdersByCustomer(
              customerId: 'customer_1',
              merchandiserId: any(named: 'merchandiserId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => const Right([]));

        return createBloc();
      },
      act: (bloc) => bloc.add(
        const LoadCustomerOrders(customerId: 'customer_1'),
      ),
      expect: () => [
        OrdersLoading(),
        const OrdersEmpty(),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'filters customer orders by status',
      build: () {
        final orders = [createTestOrder(status: 'delivered')];
        when(() => mockGetOrdersByCustomer(
              customerId: 'customer_1',
              merchandiserId: any(named: 'merchandiserId'),
              status: 'delivered',
            )).thenAnswer((_) async => Right(orders));

        return createBloc();
      },
      act: (bloc) => bloc.add(
        const LoadCustomerOrders(
          customerId: 'customer_1',
          status: 'delivered',
        ),
      ),
      expect: () => [
        OrdersLoading(),
        isA<OrdersLoaded>().having(
          (state) => state.appliedStatusFilter,
          'applied status filter',
          'delivered',
        ),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'filters customer orders by merchandiser',
      build: () {
        final orders = [createTestOrder()];
        when(() => mockGetOrdersByCustomer(
              customerId: 'customer_1',
              merchandiserId: 'merchandiser_1',
              status: any(named: 'status'),
            )).thenAnswer((_) async => Right(orders));

        return createBloc();
      },
      act: (bloc) => bloc.add(
        const LoadCustomerOrders(
          customerId: 'customer_1',
          merchandiserId: 'merchandiser_1',
        ),
      ),
      expect: () => [
        OrdersLoading(),
        isA<OrdersLoaded>(),
      ],
    );
  });

  group('OrdersBloc - Order Details', () {
    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersLoading, OrderDetailsLoaded] when LoadOrderDetails succeeds',
      build: () {
        final order = createTestOrder(id: 'order_123');
        when(() => mockGetOrderById('order_123'))
            .thenAnswer((_) async => Right(order));

        return createBloc();
      },
      act: (bloc) => bloc.add(const LoadOrderDetails('order_123')),
      expect: () => [
        OrdersLoading(),
        isA<OrderDetailsLoaded>().having(
          (state) => state.order.id,
          'order id',
          'order_123',
        ),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersLoading, OrdersError] when order not found',
      build: () {
        when(() => mockGetOrderById('order_999')).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Order not found'),
          ),
        );

        return createBloc();
      },
      act: (bloc) => bloc.add(const LoadOrderDetails('order_999')),
      expect: () => [
        OrdersLoading(),
        const OrdersError('Order not found'),
      ],
    );
  });

  group('OrdersBloc - Merchandiser Update Order Status', () {
    blocTest<OrdersBloc, OrdersState>(
      'emits [OrderStatusUpdated] when status update succeeds',
      build: () {
        when(() => mockUpdateOrderStatus(
              orderId: 'order_1',
              status: 'confirmed',
            )).thenAnswer((_) async => const Right(null));

        when(() => mockOrderService.sendOrderStatusNotification(
              orderId: 'order_1',
              status: 'confirmed',
            )).thenAnswer((_) async => {});

        return createBloc();
      },
      act: (bloc) => bloc.add(
        const UpdateOrderStatusEvent(
          orderId: 'order_1',
          status: 'confirmed',
        ),
      ),
      expect: () => [
        const OrderStatusUpdated('Order status updated successfully'),
      ],
      verify: (_) {
        verify(() => mockOrderService.sendOrderStatusNotification(
              orderId: 'order_1',
              status: 'confirmed',
            )).called(1);
      },
    );

    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersError] when status update fails',
      build: () {
        when(() => mockUpdateOrderStatus(
              orderId: 'order_1',
              status: 'confirmed',
            )).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Update failed'),
          ),
        );

        return createBloc();
      },
      act: (bloc) => bloc.add(
        const UpdateOrderStatusEvent(
          orderId: 'order_1',
          status: 'confirmed',
        ),
      ),
      expect: () => [
        const OrdersError('Update failed'),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'updates order through all status stages',
      build: () {
        when(() => mockUpdateOrderStatus(
              orderId: any(named: 'orderId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => const Right(null));

        when(() => mockOrderService.sendOrderStatusNotification(
              orderId: any(named: 'orderId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => {});

        return createBloc();
      },
      act: (bloc) {
        bloc.add(const UpdateOrderStatusEvent(
          orderId: 'order_1',
          status: 'confirmed',
        ));
        bloc.add(const UpdateOrderStatusEvent(
          orderId: 'order_1',
          status: 'preparing',
        ));
        bloc.add(const UpdateOrderStatusEvent(
          orderId: 'order_1',
          status: 'on_the_way',
        ));
        bloc.add(const UpdateOrderStatusEvent(
          orderId: 'order_1',
          status: 'delivered',
        ));
      },
      expect: () => [
        const OrderStatusUpdated('Order status updated successfully'),
      ],
    );
  });

  group('OrdersBloc - Merchandiser Update Payment Status', () {
    blocTest<OrdersBloc, OrdersState>(
      'emits [OrderStatusUpdated] when payment status update succeeds',
      build: () {
        when(() => mockUpdatePaymentStatus(
              orderId: 'order_1',
              paymentStatus: 'paid',
            )).thenAnswer((_) async => const Right(null));

        return createBloc();
      },
      act: (bloc) => bloc.add(
        const UpdatePaymentStatusEvent(
          orderId: 'order_1',
          paymentStatus: 'paid',
        ),
      ),
      expect: () => [
        const OrderStatusUpdated('Payment status updated successfully'),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersError] when payment status update fails',
      build: () {
        when(() => mockUpdatePaymentStatus(
              orderId: 'order_1',
              paymentStatus: 'paid',
            )).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Update failed'),
          ),
        );

        return createBloc();
      },
      act: (bloc) => bloc.add(
        const UpdatePaymentStatusEvent(
          orderId: 'order_1',
          paymentStatus: 'paid',
        ),
      ),
      expect: () => [
        const OrdersError('Update failed'),
      ],
    );
  });

  group('OrdersBloc - Cancel Order', () {
    blocTest<OrdersBloc, OrdersState>(
      'emits [OrderCancelled] when cancellation succeeds',
      build: () {
        when(() => mockUpdateOrderStatus(
              orderId: 'order_1',
              status: 'cancelled',
            )).thenAnswer((_) async => const Right(null));

        when(() => mockOrderService.sendOrderCancellationNotification(
              orderId: 'order_1',
              byCustomer: false,
            )).thenAnswer((_) async => {});

        return createBloc();
      },
      act: (bloc) => bloc.add(const CancelOrderEvent('order_1')),
      expect: () => [
        const OrderCancelled('Order cancelled successfully'),
      ],
      verify: (_) {
        verify(() => mockOrderService.sendOrderCancellationNotification(
              orderId: 'order_1',
              byCustomer: false,
            )).called(1);
      },
    );

    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersError] when cancellation fails',
      build: () {
        when(() => mockUpdateOrderStatus(
              orderId: 'order_1',
              status: 'cancelled',
            )).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Cannot cancel order'),
          ),
        );

        return createBloc();
      },
      act: (bloc) => bloc.add(const CancelOrderEvent('order_1')),
      expect: () => [
        const OrdersError('Cannot cancel order'),
      ],
    );
  });

  group('OrdersBloc - Initial State', () {
    test('initial state should be OrdersInitial', () {
      final bloc = createBloc();
      expect(bloc.state, OrdersInitial());
      bloc.close();
    });
  });

  group('OrdersBloc - Edge Cases', () {
    blocTest<OrdersBloc, OrdersState>(
      'handles large number of orders',
      build: () {
        final orders = List.generate(
          100,
          (index) => createTestOrder(id: 'order_$index'),
        );

        when(() => mockGetAllOrders(
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => Right(orders));

        return createBloc();
      },
      act: (bloc) => bloc.add(const LoadAllOrders()),
      expect: () => [
        OrdersLoading(),
        isA<OrdersLoaded>().having(
          (state) => state.orders.length,
          'orders length',
          100,
        ),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'handles concurrent filter changes',
      build: () {
        final orders = [createTestOrder()];

        when(() => mockGetAllOrders(
              status: any(named: 'status'),
              paymentStatus: any(named: 'paymentStatus'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => Right(orders));

        return createBloc();
      },
      act: (bloc) {
        bloc.add(const LoadAllOrders(status: 'pending'));
        bloc.add(const LoadAllOrders(status: 'confirmed'));
        bloc.add(const LoadAllOrders(paymentStatus: 'paid'));
      },
      expect: () => [
        OrdersLoading(),
        isA<OrdersLoaded>(),
        OrdersLoading(),
        isA<OrdersLoaded>(),
        OrdersLoading(),
        isA<OrdersLoaded>(),
      ],
    );
  });
}
