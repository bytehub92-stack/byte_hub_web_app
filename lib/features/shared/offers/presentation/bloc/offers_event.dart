import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:equatable/equatable.dart';

abstract class OffersEvent extends Equatable {
  const OffersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOffers extends OffersEvent {}

class LoadOfferById extends OffersEvent {
  final String offerId;

  const LoadOfferById(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

class CreateOffer extends OffersEvent {
  final Offer offer;

  const CreateOffer(this.offer);

  @override
  List<Object?> get props => [offer];
}

class UpdateOffer extends OffersEvent {
  final Offer offer;

  const UpdateOffer(this.offer);

  @override
  List<Object?> get props => [offer];
}

class DeleteOffer extends OffersEvent {
  final String offerId;

  const DeleteOffer(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

class ToggleOfferStatus extends OffersEvent {
  final String offerId;
  final bool isActive;

  const ToggleOfferStatus(this.offerId, this.isActive);

  @override
  List<Object?> get props => [offerId, isActive];
}
