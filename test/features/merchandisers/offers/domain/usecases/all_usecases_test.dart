import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/offers/data/models/offer_model.dart';
import 'package:admin_panel/features/shared/offers/data/repositories/offers_repository_impl.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/shared/offers/domain/usecase/get_offers_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../data/datasources/fake_offers_remote_datasource.dart';

void main() {
  late GetOffersUseCase useCase;
  late OffersRepositoryImpl repository;
  late FakeOffersRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeOffersRemoteDataSource();
    repository = OffersRepositoryImpl(remoteDataSource: fakeDataSource);
    useCase = GetOffersUseCase(repository);
  });

  tearDown(() {
    fakeDataSource.clear();
  });

  test('should return list of offers from repository', () async {
    // Arrange
    final testOffers = [
      OfferModel(
        id: 'offer_1',
        merchandiserId: 'merch_1',
        title: const {'en': 'Offer 1', 'ar': 'عرض 1'},
        description: const {'en': 'Description 1'},
        imageUrl: 'https://example.com/1.jpg',
        type: OfferType.bundle,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: true,
        sortOrder: 1,
        details: const BundleOfferDetails(
          items: [],
          bundlePrice: 100.0,
          originalTotalPrice: 150.0,
        ),
      ),
      OfferModel(
        id: 'offer_2',
        merchandiserId: 'merch_1',
        title: const {'en': 'Offer 2'},
        description: const {'en': 'Description 2'},
        imageUrl: 'https://example.com/2.jpg',
        type: OfferType.discount,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: true,
        sortOrder: 2,
        details: const DiscountOfferDetails(
          productId: 'prod_1',
          discountValue: 20.0,
          isPercentage: true,
        ),
      ),
    ];

    for (final offer in testOffers) {
      fakeDataSource.addOffer(offer);
    }

    // Act
    final result = await useCase();

    // Assert
    expect(result, isA<Right<Failure, List<Offer>>>());
    result.fold(
      (failure) => fail('Should not return failure'),
      (offers) {
        expect(offers.length, 2);
        expect(offers[0].id, 'offer_1');
        expect(offers[1].id, 'offer_2');
        expect(offers[0].title['ar'], 'عرض 1');
      },
    );
  });

  test('should return empty list when no offers exist', () async {
    // Act
    final result = await useCase();

    // Assert
    expect(result, isA<Right<Failure, List<Offer>>>());
    result.fold(
      (failure) => fail('Should not return failure'),
      (offers) => expect(offers.isEmpty, true),
    );
  });

  test('should return failure when repository fails', () async {
    // Arrange
    fakeDataSource.setError('Network error');

    // Act
    final result = await useCase();

    // Assert
    expect(result, isA<Left<Failure, List<Offer>>>());
    result.fold(
      (failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('Failed to load offers'));
      },
      (offers) => fail('Should not return success'),
    );
  });

  test('should return offers sorted by sort order', () async {
    // Arrange
    final testOffers = [
      OfferModel(
        id: 'offer_3',
        merchandiserId: 'merch_1',
        title: const {'en': 'Third'},
        description: const {'en': 'Desc'},
        imageUrl: 'url',
        type: OfferType.bundle,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: true,
        sortOrder: 3,
        details: const BundleOfferDetails(
          items: [],
          bundlePrice: 100.0,
          originalTotalPrice: 150.0,
        ),
      ),
      OfferModel(
        id: 'offer_1',
        merchandiserId: 'merch_1',
        title: const {'en': 'First'},
        description: const {'en': 'Desc'},
        imageUrl: 'url',
        type: OfferType.bundle,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: true,
        sortOrder: 1,
        details: const BundleOfferDetails(
          items: [],
          bundlePrice: 100.0,
          originalTotalPrice: 150.0,
        ),
      ),
      OfferModel(
        id: 'offer_2',
        merchandiserId: 'merch_1',
        title: const {'en': 'Second'},
        description: const {'en': 'Desc'},
        imageUrl: 'url',
        type: OfferType.bundle,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: true,
        sortOrder: 2,
        details: const BundleOfferDetails(
          items: [],
          bundlePrice: 100.0,
          originalTotalPrice: 150.0,
        ),
      ),
    ];

    for (final offer in testOffers) {
      fakeDataSource.addOffer(offer);
    }

    // Act
    final result = await useCase();

    // Assert
    result.fold(
      (failure) => fail('Should not fail'),
      (offers) {
        expect(offers[0].sortOrder, 1);
        expect(offers[1].sortOrder, 2);
        expect(offers[2].sortOrder, 3);
        expect(offers[0].title['en'], 'First');
        expect(offers[2].title['en'], 'Third');
      },
    );
  });

  test('should handle multiple offer types correctly', () async {
    // Arrange
    final testOffers = [
      OfferModel(
        id: 'bundle_1',
        merchandiserId: 'merch_1',
        title: const {'en': 'Bundle'},
        description: const {'en': 'Desc'},
        imageUrl: 'url',
        type: OfferType.bundle,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: true,
        sortOrder: 1,
        details: const BundleOfferDetails(
          items: [],
          bundlePrice: 100.0,
          originalTotalPrice: 150.0,
        ),
      ),
      OfferModel(
        id: 'bogo_1',
        merchandiserId: 'merch_1',
        title: const {'en': 'BOGO'},
        description: const {'en': 'Desc'},
        imageUrl: 'url',
        type: OfferType.bogo,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: true,
        sortOrder: 2,
        details: const BOGOOfferDetails(
          buyProductId: 'p1',
          buyQuantity: 1,
          getProductId: 'p2',
          getQuantity: 1,
          buyProductName: 'Buy',
          getProductName: 'Get',
          buyProductImage: 'buy.jpg',
          getProductImage: 'get.jpg',
        ),
      ),
      OfferModel(
        id: 'discount_1',
        merchandiserId: 'merch_1',
        title: const {'en': 'Discount'},
        description: const {'en': 'Desc'},
        imageUrl: 'url',
        type: OfferType.discount,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: true,
        sortOrder: 3,
        details: const DiscountOfferDetails(
          productId: 'p1',
          discountValue: 20.0,
          isPercentage: true,
        ),
      ),
    ];

    for (final offer in testOffers) {
      fakeDataSource.addOffer(offer);
    }

    // Act
    final result = await useCase();

    // Assert
    result.fold(
      (failure) => fail('Should not fail'),
      (offers) {
        expect(offers.length, 3);
        expect(offers[0].type, OfferType.bundle);
        expect(offers[1].type, OfferType.bogo);
        expect(offers[2].type, OfferType.discount);
      },
    );
  });
}
