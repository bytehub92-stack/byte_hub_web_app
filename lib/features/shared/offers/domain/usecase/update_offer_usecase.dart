import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/shared/offers/domain/repositories/offers_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateOfferUseCase {
  final OffersRepository repository;

  UpdateOfferUseCase(this.repository);

  Future<Either<Failure, void>> call(Offer offer) async {
    return await repository.updateOffer(offer);
  }
}
