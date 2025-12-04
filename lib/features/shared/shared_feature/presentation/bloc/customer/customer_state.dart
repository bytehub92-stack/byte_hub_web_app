// lib/features/shared/presentation/bloc/customer/customer_state.dart

import 'package:equatable/equatable.dart';

import '../../../domain/entities/customer.dart';

abstract class CustomerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomersLoaded extends CustomerState {
  final List<Customer> customers;
  CustomersLoaded(this.customers);
  @override
  List<Object?> get props => [customers];
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
  @override
  List<Object?> get props => [message];
}

class CustomerStatusUpdated extends CustomerState {
  final String message;
  CustomerStatusUpdated(this.message);
  @override
  List<Object?> get props => [message];
}
