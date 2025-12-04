// lib/features/delivery/presentation/bloc/delivery_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/driver.dart';
import '../../domain/entities/order_assignment.dart';

abstract class DeliveryState extends Equatable {
  const DeliveryState();

  @override
  List<Object?> get props => [];
}

class DeliveryInitial extends DeliveryState {}

class DeliveryLoading extends DeliveryState {}

class DeliveryError extends DeliveryState {
  final String message;

  const DeliveryError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== Merchandiser States ====================

class DriversLoaded extends DeliveryState {
  final List<Driver> drivers;

  const DriversLoaded(this.drivers);

  @override
  List<Object?> get props => [drivers];
}

class DriverLoaded extends DeliveryState {
  final Driver driver;

  const DriverLoaded(this.driver);

  @override
  List<Object?> get props => [driver];
}

class OrderAssigned extends DeliveryState {
  final OrderAssignment assignment;
  final String message;

  const OrderAssigned(this.assignment, this.message);

  @override
  List<Object?> get props => [assignment, message];
}

class OrderAssignmentsLoaded extends DeliveryState {
  final List<OrderAssignment> assignments;

  const OrderAssignmentsLoaded(this.assignments);

  @override
  List<Object?> get props => [assignments];
}

class OrderUnassigned extends DeliveryState {
  final String message;

  const OrderUnassigned(this.message);

  @override
  List<Object?> get props => [message];
}

class DeliveryStatisticsLoaded extends DeliveryState {
  final Map<String, dynamic> statistics;

  const DeliveryStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class MerchandiserCodeLoaded extends DeliveryState {
  final String code;

  const MerchandiserCodeLoaded(this.code);

  @override
  List<Object?> get props => [code];
}

// ==================== Driver States ====================

class DriverRegistered extends DeliveryState {
  final Driver driver;
  final String message;

  const DriverRegistered(this.driver, this.message);

  @override
  List<Object?> get props => [driver, message];
}

class DriverInfoUpdated extends DeliveryState {
  final String message;

  const DriverInfoUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class DriverAvailabilityUpdated extends DeliveryState {
  final String message;

  const DriverAvailabilityUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class DriverAssignmentsLoaded extends DeliveryState {
  final List<OrderAssignment> assignments;

  const DriverAssignmentsLoaded(this.assignments);

  @override
  List<Object?> get props => [assignments];
}

class DeliveryStatusUpdated extends DeliveryState {
  final String message;

  const DeliveryStatusUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class DeliveryMarkedAsCompleted extends DeliveryState {
  final String message;

  const DeliveryMarkedAsCompleted(this.message);

  @override
  List<Object?> get props => [message];
}

class DriverStatisticsLoaded extends DeliveryState {
  final Map<String, dynamic> statistics;

  const DriverStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}
