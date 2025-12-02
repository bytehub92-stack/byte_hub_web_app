// lib/features/shared/presentation/bloc/customer/customer_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/customer/get_customers_by_merchandiser.dart';
import '../../../domain/usecases/customer/toggle_customer_status.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersByMerchandiser getCustomersByMerchandiser;
  final ToggleCustomerStatus toggleCustomerStatus;

  CustomerBloc({
    required this.getCustomersByMerchandiser,
    required this.toggleCustomerStatus,
  }) : super(CustomerInitial()) {
    on<LoadCustomersByMerchandiser>(_onLoadCustomersByMerchandiser);
    on<ToggleCustomerStatusEvent>(_onToggleStatus);
  }

  Future<void> _onLoadCustomersByMerchandiser(
    LoadCustomersByMerchandiser event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await getCustomersByMerchandiser(event.merchandiserId);
    result.fold((failure) => emit(CustomerError(failure.message)), (customers) {
      emit(CustomersLoaded(customers));
    });
  }

  Future<void> _onToggleStatus(
    ToggleCustomerStatusEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await toggleCustomerStatus(event.customerId, event.isActive);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) => emit(CustomerStatusUpdated('Status updated successfully')),
    );
  }
}
