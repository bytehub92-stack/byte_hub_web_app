// lib/features/orders/presentation/bloc/orders_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;
  final String? appliedStatusFilter;
  final String? appliedPaymentFilter;

  const OrdersLoaded({
    required this.orders,
    this.appliedStatusFilter,
    this.appliedPaymentFilter,
  });

  @override
  List<Object?> get props => [
    orders,
    appliedStatusFilter,
    appliedPaymentFilter,
  ];
}

class OrdersEmpty extends OrdersState {
  final String? appliedStatusFilter;
  final String? appliedPaymentFilter;

  const OrdersEmpty({this.appliedStatusFilter, this.appliedPaymentFilter});

  @override
  List<Object?> get props => [appliedStatusFilter, appliedPaymentFilter];
}

class OrderDetailsLoaded extends OrdersState {
  final Order order;

  const OrderDetailsLoaded(this.order);

  @override
  List<Object> get props => [order];
}

class OrderStatusUpdated extends OrdersState {
  final String message;

  const OrderStatusUpdated(this.message);

  @override
  List<Object> get props => [message];
}

class OrderCancelled extends OrdersState {
  final String message;

  const OrderCancelled(this.message);

  @override
  List<Object> get props => [message];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object> get props => [message];
}
