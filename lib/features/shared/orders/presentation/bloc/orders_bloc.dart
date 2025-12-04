// lib/features/orders/presentation/bloc/orders_bloc.dart
import 'package:admin_panel/features/shared/orders/domain/usecases/orders_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/order_service.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetAllOrdersUseCase getAllOrders;
  final GetOrdersByMerchandiserUseCase getOrdersByMerchandiser;
  final GetCustomerOrdersUseCase getOrdersByCustomer;
  final GetOrderByIdUseCase getOrderById;
  final UpdateOrderStatusUseCase updateOrderStatus;
  final UpdatePaymentStatusUseCase updatePaymentStatus;
  final OrderService orderService;

  OrdersBloc({
    required this.getAllOrders,
    required this.getOrdersByMerchandiser,
    required this.getOrdersByCustomer,
    required this.getOrderById,
    required this.updateOrderStatus,
    required this.updatePaymentStatus,
    required this.orderService,
    required GetCustomerOrdersUseCase GetCustomerOrdersUseCase,
  }) : super(OrdersInitial()) {
    on<LoadAllOrders>(_onLoadAllOrders);
    on<LoadMerchandiserOrders>(_onLoadMerchandiserOrders);
    on<LoadCustomerOrders>(_onLoadCustomerOrders);
    on<LoadOrderDetails>(_onLoadOrderDetails);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<UpdatePaymentStatusEvent>(_onUpdatePaymentStatus);
    on<CancelOrderEvent>(_onCancelOrder);
  }

  Future<void> _onLoadAllOrders(
    LoadAllOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());

    final result = await getAllOrders(
      status: event.status,
      paymentStatus: event.paymentStatus,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold((failure) => emit(OrdersError(failure.message)), (orders) {
      if (orders.isEmpty) {
        emit(
          OrdersEmpty(
            appliedStatusFilter: event.status,
            appliedPaymentFilter: event.paymentStatus,
          ),
        );
      } else {
        emit(
          OrdersLoaded(
            orders: orders,
            appliedStatusFilter: event.status,
            appliedPaymentFilter: event.paymentStatus,
          ),
        );
      }
    });
  }

  Future<void> _onLoadMerchandiserOrders(
    LoadMerchandiserOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());

    final result = await getOrdersByMerchandiser(
      merchandiserId: event.merchandiserId,
      status: event.status,
      paymentStatus: event.paymentStatus,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold((failure) => emit(OrdersError(failure.message)), (orders) {
      if (orders.isEmpty) {
        emit(
          OrdersEmpty(
            appliedStatusFilter: event.status,
            appliedPaymentFilter: event.paymentStatus,
          ),
        );
      } else {
        emit(
          OrdersLoaded(
            orders: orders,
            appliedStatusFilter: event.status,
            appliedPaymentFilter: event.paymentStatus,
          ),
        );
      }
    });
  }

  Future<void> _onLoadCustomerOrders(
    LoadCustomerOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());

    final result = await getOrdersByCustomer(
      customerId: event.customerId,
      merchandiserId: event.merchandiserId,
      status: event.status,
    );

    result.fold((failure) => emit(OrdersError(failure.message)), (orders) {
      if (orders.isEmpty) {
        emit(OrdersEmpty(appliedStatusFilter: event.status));
      } else {
        emit(OrdersLoaded(orders: orders, appliedStatusFilter: event.status));
      }
    });
  }

  Future<void> _onLoadOrderDetails(
    LoadOrderDetails event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());

    final result = await getOrderById(event.orderId);

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (order) => emit(OrderDetailsLoaded(order)),
    );
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrdersState> emit,
  ) async {
    final result = await updateOrderStatus(
      orderId: event.orderId,
      status: event.status,
    );

    await result.fold((failure) async => emit(OrdersError(failure.message)), (
      _,
    ) async {
      // Send notification to customer about status change
      await orderService.sendOrderStatusNotification(
        orderId: event.orderId,
        status: event.status,
      );

      emit(const OrderStatusUpdated('Order status updated successfully'));
    });
  }

  Future<void> _onUpdatePaymentStatus(
    UpdatePaymentStatusEvent event,
    Emitter<OrdersState> emit,
  ) async {
    final result = await updatePaymentStatus(
      orderId: event.orderId,
      paymentStatus: event.paymentStatus,
    );

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (_) =>
          emit(const OrderStatusUpdated('Payment status updated successfully')),
    );
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    final result = await updateOrderStatus(
      orderId: event.orderId,
      status: 'cancelled',
    );

    await result.fold((failure) async => emit(OrdersError(failure.message)), (
      _,
    ) async {
      // Send cancellation notification
      // byCustomer = false means cancelled by merchandiser
      await orderService.sendOrderCancellationNotification(
        orderId: event.orderId,
        byCustomer: false,
      );

      emit(const OrderCancelled('Order cancelled successfully'));
    });
  }
}
