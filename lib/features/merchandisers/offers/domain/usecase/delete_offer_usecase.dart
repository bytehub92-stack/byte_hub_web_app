import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/repositories/offers_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteOfferUseCase {
  final OffersRepository repository;

  DeleteOfferUseCase(this.repository);

  Future<Either<Failure, void>> call(String offerId) async {
    return await repository.deleteOffer(offerId);
  }
}
