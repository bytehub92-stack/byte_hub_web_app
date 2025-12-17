import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/repositories/offers_repository.dart';
import 'package:dartz/dartz.dart';

class ToggleOfferStatusUseCase {
  final OffersRepository repository;

  ToggleOfferStatusUseCase(this.repository);

  Future<Either<Failure, void>> call(String offerId, bool isActive) async {
    return await repository.toggleOfferStatus(offerId, isActive);
  }
}
