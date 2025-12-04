// lib/features/offers/domain/repositories/offers_repository.dart
import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:dartz/dartz.dart';

abstract class OffersRepository {
  Future<Either<Failure, List<Offer>>> getOffers();
  Future<Either<Failure, Offer>> getOfferById(String offerId);
  Future<Either<Failure, void>> createOffer(Offer offer);
  Future<Either<Failure, void>> updateOffer(Offer offer);
  Future<Either<Failure, void>> deleteOffer(String offerId);
  Future<Either<Failure, void>> toggleOfferStatus(
    String offerId,
    bool isActive,
  );
}
