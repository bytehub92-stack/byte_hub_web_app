// lib/features/delivery/presentation/bloc/delivery_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/delivery_repository.dart';
import 'delivery_event.dart';
import 'delivery_state.dart';

class DeliveryBloc extends Bloc<DeliveryEvent, DeliveryState> {
  final DeliveryRepository repository;

  DeliveryBloc({required this.repository}) : super(DeliveryInitial()) {
    on<LoadDrivers>(_onLoadDrivers);
    on<LoadDriverById>(_onLoadDriverById);
    on<AssignOrderToDriver>(_onAssignOrderToDriver);
    on<LoadOrderAssignments>(_onLoadOrderAssignments);
    on<UnassignOrder>(_onUnassignOrder);
    on<LoadDeliveryStatistics>(_onLoadDeliveryStatistics);
    on<LoadMerchandiserCode>(_onLoadMerchandiserCode);
  }

  Future<void> _onLoadDrivers(
    LoadDrivers event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());
    final result = await repository.getDrivers(event.merchandiserId);
    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (drivers) => emit(DriversLoaded(drivers)),
    );
  }

  Future<void> _onLoadDriverById(
    LoadDriverById event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());
    final result = await repository.getDriverById(event.driverId);
    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (driver) => emit(DriverLoaded(driver)),
    );
  }

  Future<void> _onAssignOrderToDriver(
    AssignOrderToDriver event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());
    final result = await repository.assignOrderToDriver(
      orderId: event.orderId,
      driverId: event.driverId,
      assignedBy: event.assignedBy,
      notes: event.notes,
    );
    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (assignment) =>
          emit(OrderAssigned(assignment, 'Order assigned successfully')),
    );
  }

  Future<void> _onLoadOrderAssignments(
    LoadOrderAssignments event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());
    final result = await repository.getOrderAssignments(
      merchandiserId: event.merchandiserId,
      driverId: event.driverId,
      onlyActive: event.onlyActive,
    );
    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (assignments) => emit(OrderAssignmentsLoaded(assignments)),
    );
  }

  Future<void> _onUnassignOrder(
    UnassignOrder event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());
    final result = await repository.unassignOrder(event.orderId);
    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (_) => emit(const OrderUnassigned('Order unassigned successfully')),
    );
  }

  Future<void> _onLoadDeliveryStatistics(
    LoadDeliveryStatistics event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());
    final result = await repository.getDeliveryStatistics(event.merchandiserId);
    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (statistics) => emit(DeliveryStatisticsLoaded(statistics)),
    );
  }

  Future<void> _onLoadMerchandiserCode(
    LoadMerchandiserCode event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());
    final result = await repository.getMerchandiserCode(event.merchandiserId);
    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (code) => emit(MerchandiserCodeLoaded(code)),
    );
  }
}
