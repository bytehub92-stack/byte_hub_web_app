import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/shared/offers/domain/repositories/offers_repository.dart';

import 'package:dartz/dartz.dart';

class CreateOfferUseCase {
  final OffersRepository repository;

  CreateOfferUseCase(this.repository);

  Future<Either<Failure, void>> call(Offer offer) async {
    return await repository.createOffer(offer);
  }
}
