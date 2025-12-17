import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/repositories/offers_repository.dart';
import 'package:dartz/dartz.dart';

class GetOfferByIdUseCase {
  final OffersRepository repository;

  GetOfferByIdUseCase(this.repository);

  Future<Either<Failure, Offer>> call(String offerId) async {
    return await repository.getOfferById(offerId);
  }
}
