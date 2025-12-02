import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/offers/data/models/offer_model.dart';
import 'package:admin_panel/features/shared/offers/data/repositories/offers_repository_impl.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:flutter_test/flutter_test.dart';
import '../datasources/fake_offers_remote_datasource.dart';

void main() {
  late OffersRepositoryImpl repository;
  late FakeOffersRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeOffersRemoteDataSource();
    repository = OffersRepositoryImpl(remoteDataSource: fakeDataSource);
  });

  tearDown(() {
    fakeDataSource.clear();
  });

  group('getOffers', () {
    test('should return list of offers when data source succeeds', () async {
      // Arrange
      final testOffers = [
        OfferModel(
          id: 'offer_1',
          merchandiserId: 'merch_1',
          title: const {'en': 'Offer 1'},
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
      final result = await repository.getOffers();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (offers) {
          expect(offers.length, 2);
          expect(offers[0].id, 'offer_1');
          expect(offers[1].id, 'offer_2');
        },
      );
    });

    test('should return empty list when no offers exist', () async {
      // Act
      final result = await repository.getOffers();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (offers) => expect(offers.isEmpty, true),
      );
    });

    test('should return ServerFailure when data source throws exception',
        () async {
      // Arrange
      fakeDataSource.setError('Network error');

      // Act
      final result = await repository.getOffers();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Failed to load offers'));
        },
        (offers) => fail('Should not return success'),
      );
    });

    test('should return offers sorted by sortOrder', () async {
      // Arrange
      final testOffers = [
        OfferModel(
          id: 'offer_3',
          merchandiserId: 'merch_1',
          title: const {'en': 'Third'},
          description: const {'en': 'Desc'},
          imageUrl: 'https://example.com/3.jpg',
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
      ];

      for (final offer in testOffers) {
        fakeDataSource.addOffer(offer);
      }

      // Act
      final result = await repository.getOffers();

      // Assert
      result.fold(
        (failure) => fail('Should not fail'),
        (offers) {
          expect(offers[0].sortOrder, 1);
          expect(offers[1].sortOrder, 3);
        },
      );
    });
  });

  group('getOfferById', () {
    test('should return offer when found', () async {
      // Arrange
      final testOffer = OfferModel(
        id: 'offer_1',
        merchandiserId: 'merch_1',
        title: const {'en': 'Test Offer'},
        description: const {'en': 'Test Description'},
        imageUrl: 'https://example.com/test.jpg',
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
      );

      fakeDataSource.addOffer(testOffer);

      // Act
      final result = await repository.getOfferById('offer_1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (offer) {
          expect(offer.id, 'offer_1');
          expect(offer.title['en'], 'Test Offer');
        },
      );
    });

    test('should return ServerFailure when offer not found', () async {
      // Act
      final result = await repository.getOfferById('non_existent');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Failed to load offer'));
        },
        (offer) => fail('Should not return success'),
      );
    });

    test('should return ServerFailure when data source throws', () async {
      // Arrange
      fakeDataSource.setError('Database error');

      // Act
      final result = await repository.getOfferById('offer_1');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (offer) => fail('Should not return success'),
      );
    });
  });

  group('createOffer', () {
    test('should successfully create offer', () async {
      // Arrange
      final newOffer = Offer(
        id: 'new_offer',
        merchandiserId: 'merch_1',
        title: const {'en': 'New Offer'},
        description: const {'en': 'New Description'},
        imageUrl: 'https://example.com/new.jpg',
        type: OfferType.bogo,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: true,
        sortOrder: 1,
        details: const BOGOOfferDetails(
          buyProductId: 'prod_1',
          buyQuantity: 2,
          getProductId: 'prod_2',
          getQuantity: 1,
          buyProductName: 'Buy Product',
          getProductName: 'Free Product',
          buyProductImage: 'https://example.com/buy.jpg',
          getProductImage: 'https://example.com/get.jpg',
        ),
      );

      // Act
      final result = await repository.createOffer(newOffer);

      // Assert
      expect(result.isRight(), true);

      // Verify offer was actually added
      final getResult = await repository.getOfferById('new_offer');
      getResult.fold(
        (failure) => fail('Offer should be found'),
        (offer) => expect(offer.id, 'new_offer'),
      );
    });

    test('should return ServerFailure when creation fails', () async {
      // Arrange
      fakeDataSource.setError('Creation failed');

      final newOffer = Offer(
        id: 'new_offer',
        merchandiserId: 'merch_1',
        title: const {'en': 'New Offer'},
        description: const {'en': 'Description'},
        imageUrl: 'https://example.com/new.jpg',
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
      );

      // Act
      final result = await repository.createOffer(newOffer);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Failed to create offer'));
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should handle all offer types correctly', () async {
      // Test creating each type of offer
      final offerTypes = [
        Offer(
          id: 'bundle_offer',
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
        Offer(
          id: 'discount_offer',
          merchandiserId: 'merch_1',
          title: const {'en': 'Discount'},
          description: const {'en': 'Desc'},
          imageUrl: 'url',
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

      for (final offer in offerTypes) {
        final result = await repository.createOffer(offer);
        expect(result.isRight(), true);
      }

      // Verify all were created
      final getResult = await repository.getOffers();
      getResult.fold(
        (failure) => fail('Should not fail'),
        (offers) => expect(offers.length, 2),
      );
    });
  });

  group('updateOffer', () {
    test('should successfully update existing offer', () async {
      // Arrange
      final originalOffer = OfferModel(
        id: 'offer_1',
        merchandiserId: 'merch_1',
        title: const {'en': 'Original Title'},
        description: const {'en': 'Original Description'},
        imageUrl: 'https://example.com/original.jpg',
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
      );

      fakeDataSource.addOffer(originalOffer);

      final updatedOffer = Offer(
        id: 'offer_1',
        merchandiserId: 'merch_1',
        title: const {'en': 'Updated Title'},
        description: const {'en': 'Updated Description'},
        imageUrl: 'https://example.com/updated.jpg',
        type: OfferType.bundle,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: false,
        sortOrder: 2,
        details: const BundleOfferDetails(
          items: [],
          bundlePrice: 120.0,
          originalTotalPrice: 180.0,
        ),
      );

      // Act
      final result = await repository.updateOffer(updatedOffer);

      // Assert
      expect(result.isRight(), true);

      // Verify update worked
      final getResult = await repository.getOfferById('offer_1');
      getResult.fold(
        (failure) => fail('Should find updated offer'),
        (offer) {
          expect(offer.title['en'], 'Updated Title');
          expect(offer.isActive, false);
          expect(offer.sortOrder, 2);
        },
      );
    });

    test('should return ServerFailure when offer not found', () async {
      // Arrange
      final nonExistentOffer = Offer(
        id: 'non_existent',
        merchandiserId: 'merch_1',
        title: const {'en': 'Title'},
        description: const {'en': 'Description'},
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
      );

      // Act
      final result = await repository.updateOffer(nonExistentOffer);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Failed to update offer'));
        },
        (_) => fail('Should not succeed'),
      );
    });

    test('should return ServerFailure when update fails', () async {
      // Arrange
      fakeDataSource.setError('Update failed');

      final offer = Offer(
        id: 'offer_1',
        merchandiserId: 'merch_1',
        title: const {'en': 'Title'},
        description: const {'en': 'Description'},
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
      );

      // Act
      final result = await repository.updateOffer(offer);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('deleteOffer', () {
    test('should successfully delete existing offer', () async {
      // Arrange
      final testOffer = OfferModel(
        id: 'offer_to_delete',
        merchandiserId: 'merch_1',
        title: const {'en': 'To Delete'},
        description: const {'en': 'Description'},
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
      );

      fakeDataSource.addOffer(testOffer);

      // Act
      final result = await repository.deleteOffer('offer_to_delete');

      // Assert
      expect(result.isRight(), true);

      // Verify deletion
      final getResult = await repository.getOfferById('offer_to_delete');
      expect(getResult.isLeft(), true);
    });

    test('should return ServerFailure when offer not found', () async {
      // Act
      final result = await repository.deleteOffer('non_existent');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Failed to delete offer'));
        },
        (_) => fail('Should not succeed'),
      );
    });

    test('should return ServerFailure when deletion fails', () async {
      // Arrange
      fakeDataSource.setError('Deletion failed');

      // Act
      final result = await repository.deleteOffer('offer_1');

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('toggleOfferStatus', () {
    test('should toggle offer from active to inactive', () async {
      // Arrange
      final testOffer = OfferModel(
        id: 'offer_1',
        merchandiserId: 'merch_1',
        title: const {'en': 'Test'},
        description: const {'en': 'Description'},
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
      );

      fakeDataSource.addOffer(testOffer);

      // Act
      final result = await repository.toggleOfferStatus('offer_1', false);

      // Assert
      expect(result.isRight(), true);

      // Verify status changed
      final getResult = await repository.getOfferById('offer_1');
      getResult.fold(
        (failure) => fail('Should find offer'),
        (offer) => expect(offer.isActive, false),
      );
    });

    test('should toggle offer from inactive to active', () async {
      // Arrange
      final testOffer = OfferModel(
        id: 'offer_1',
        merchandiserId: 'merch_1',
        title: const {'en': 'Test'},
        description: const {'en': 'Description'},
        imageUrl: 'url',
        type: OfferType.bundle,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: false,
        sortOrder: 1,
        details: const BundleOfferDetails(
          items: [],
          bundlePrice: 100.0,
          originalTotalPrice: 150.0,
        ),
      );

      fakeDataSource.addOffer(testOffer);

      // Act
      final result = await repository.toggleOfferStatus('offer_1', true);

      // Assert
      expect(result.isRight(), true);

      // Verify status changed
      final getResult = await repository.getOfferById('offer_1');
      getResult.fold(
        (failure) => fail('Should find offer'),
        (offer) => expect(offer.isActive, true),
      );
    });

    test('should return ServerFailure when offer not found', () async {
      // Act
      final result = await repository.toggleOfferStatus('non_existent', true);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Failed to toggle offer status'));
        },
        (_) => fail('Should not succeed'),
      );
    });

    test('should return ServerFailure when toggle fails', () async {
      // Arrange
      fakeDataSource.setError('Toggle failed');

      // Act
      final result = await repository.toggleOfferStatus('offer_1', false);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
