import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/shared/offers/domain/repositories/offers_repository.dart';

import 'package:dartz/dartz.dart';

class GetOffersUseCase {
  final OffersRepository repository;

  GetOffersUseCase(this.repository);

  Future<Either<Failure, List<Offer>>> call() async {
    return await repository.getOffers();
  }
}
