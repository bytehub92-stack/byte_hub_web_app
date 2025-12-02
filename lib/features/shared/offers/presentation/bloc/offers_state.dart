import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:equatable/equatable.dart';

abstract class OffersState extends Equatable {
  const OffersState();

  @override
  List<Object?> get props => [];
}

class OffersInitial extends OffersState {}

class OffersLoading extends OffersState {}

class OffersLoaded extends OffersState {
  final List<Offer> offers;

  const OffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers];
}

class OfferLoaded extends OffersState {
  final Offer offer;

  const OfferLoaded(this.offer);

  @override
  List<Object?> get props => [offer];
}

class OfferCreated extends OffersState {}

class OfferUpdated extends OffersState {}

class OfferDeleted extends OffersState {}

class OfferStatusToggled extends OffersState {}

class OffersError extends OffersState {
  final String message;

  const OffersError(this.message);

  @override
  List<Object?> get props => [message];
}
