// lib/features/orders/presentation/bloc/orders_event.dart

import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllOrders extends OrdersEvent {
  final String? status;
  final String? paymentStatus;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadAllOrders({
    this.status,
    this.paymentStatus,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, paymentStatus, startDate, endDate];
}

class LoadMerchandiserOrders extends OrdersEvent {
  final String merchandiserId;
  final String? status;
  final String? paymentStatus;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadMerchandiserOrders({
    required this.merchandiserId,
    this.status,
    this.paymentStatus,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
    merchandiserId,
    status,
    paymentStatus,
    startDate,
    endDate,
  ];
}

class LoadCustomerOrders extends OrdersEvent {
  final String customerId;
  final String? merchandiserId;
  final String? status;

  const LoadCustomerOrders({
    required this.customerId,
    this.merchandiserId,
    this.status,
  });

  @override
  List<Object?> get props => [customerId, merchandiserId, status];
}

class LoadOrderDetails extends OrdersEvent {
  final String orderId;

  const LoadOrderDetails(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class UpdateOrderStatusEvent extends OrdersEvent {
  final String orderId;
  final String status;

  const UpdateOrderStatusEvent({required this.orderId, required this.status});

  @override
  List<Object> get props => [orderId, status];
}

class UpdatePaymentStatusEvent extends OrdersEvent {
  final String orderId;
  final String paymentStatus;

  const UpdatePaymentStatusEvent({
    required this.orderId,
    required this.paymentStatus,
  });

  @override
  List<Object> get props => [orderId, paymentStatus];
}

class CancelOrderEvent extends OrdersEvent {
  final String orderId;

  const CancelOrderEvent(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class FilterOrders extends OrdersEvent {
  final String? status;
  final String? paymentStatus;

  const FilterOrders({this.status, this.paymentStatus});

  @override
  List<Object?> get props => [status, paymentStatus];
}
