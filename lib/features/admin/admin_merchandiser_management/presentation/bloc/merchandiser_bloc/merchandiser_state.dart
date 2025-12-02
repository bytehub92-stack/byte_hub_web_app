import 'package:equatable/equatable.dart';
import '../../../domain/entities/merchandiser.dart';

abstract class MerchandiserState extends Equatable {
  const MerchandiserState();

  @override
  List<Object?> get props => [];
}

class MerchandiserInitial extends MerchandiserState {}

class MerchandiserLoading extends MerchandiserState {}

class MerchandiserLoaded extends MerchandiserState {
  final List<Merchandiser> merchandisers;

  const MerchandiserLoaded({required this.merchandisers});

  @override
  List<Object> get props => [merchandisers];
}

class MerchandiserError extends MerchandiserState {
  final String message;

  const MerchandiserError({required this.message});

  @override
  List<Object> get props => [message];
}

class MerchandiserCreating extends MerchandiserState {}

class MerchandiserCreated extends MerchandiserState {
  final String tempPassword;
  final String email;

  const MerchandiserCreated({required this.tempPassword, required this.email});

  @override
  List<Object> get props => [tempPassword, email];
}

class MerchandiserStatusUpdating extends MerchandiserState {}

class MerchandiserStatusUpdated extends MerchandiserState {}
