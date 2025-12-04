// lib/features/shared/presentation/bloc/customer/customer_event.dart

import 'package:equatable/equatable.dart';

abstract class CustomerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCustomersByMerchandiser extends CustomerEvent {
  final String merchandiserId;
  LoadCustomersByMerchandiser(this.merchandiserId);
  @override
  List<Object?> get props => [merchandiserId];
}

class ToggleCustomerStatusEvent extends CustomerEvent {
  final String customerId;
  final bool isActive;
  ToggleCustomerStatusEvent(this.customerId, this.isActive);
  @override
  List<Object?> get props => [customerId, isActive];
}
