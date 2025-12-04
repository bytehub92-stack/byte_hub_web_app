// lib/features/offers/data/repositories/offers_repository_impl.dart
import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/offers/data/datasource/offers_remote_datasource.dart';
import 'package:admin_panel/features/shared/offers/data/models/offer_model.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/shared/offers/domain/repositories/offers_repository.dart';

import 'package:dartz/dartz.dart';

class OffersRepositoryImpl implements OffersRepository {
  final OffersRemoteDataSource remoteDataSource;

  OffersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Offer>>> getOffers() async {
    try {
      final offers = await remoteDataSource.getOffers();
      return Right(offers);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to load offers: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Offer>> getOfferById(String offerId) async {
    try {
      final offer = await remoteDataSource.getOfferById(offerId);
      return Right(offer);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to load offer: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> createOffer(Offer offer) async {
    try {
      final offerModel = OfferModel(
        id: offer.id,
        merchandiserId: offer.merchandiserId,
        title: offer.title,
        description: offer.description,
        imageUrl: offer.imageUrl,
        type: offer.type,
        startDate: offer.startDate,
        endDate: offer.endDate,
        isActive: offer.isActive,
        sortOrder: offer.sortOrder,
        details: offer.details,
      );
      await remoteDataSource.createOffer(offerModel);
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to create offer: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateOffer(Offer offer) async {
    try {
      final offerModel = OfferModel(
        id: offer.id,
        merchandiserId: offer.merchandiserId,
        title: offer.title,
        description: offer.description,
        imageUrl: offer.imageUrl,
        type: offer.type,
        startDate: offer.startDate,
        endDate: offer.endDate,
        isActive: offer.isActive,
        sortOrder: offer.sortOrder,
        details: offer.details,
      );
      await remoteDataSource.updateOffer(offerModel);
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to update offer: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteOffer(String offerId) async {
    try {
      await remoteDataSource.deleteOffer(offerId);
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to delete offer: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> toggleOfferStatus(
    String offerId,
    bool isActive,
  ) async {
    try {
      await remoteDataSource.toggleOfferStatus(offerId, isActive);
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to toggle offer status: ${e.toString()}',
        ),
      );
    }
  }
}
