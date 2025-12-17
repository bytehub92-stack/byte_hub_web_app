import 'package:admin_panel/features/merchandisers/offers/data/models/offer_model.dart';
import 'package:admin_panel/features/merchandisers/offers/data/repositories/offers_repository_impl.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/usecase/create_offer_usecase.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/usecase/delete_offer_usecase.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/usecase/get_offer_by_id_usecase.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/usecase/get_offers_usecase.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/usecase/toggle_offer_status_usecase.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/usecase/update_offer_usecase.dart';
import 'package:admin_panel/features/merchandisers/offers/presentation/bloc/offers_bloc.dart';
import 'package:admin_panel/features/merchandisers/offers/presentation/bloc/offers_event.dart';
import 'package:admin_panel/features/merchandisers/offers/presentation/bloc/offers_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../data/datasources/fake_offers_remote_datasource.dart';
import '../services/fake_offer_notification_service.dart';
import 'package:admin_panel/features/merchandisers/offers/data/services/offer_notification_service.dart';

void main() {
  late OffersBloc bloc;
  late FakeOffersRemoteDataSource fakeDataSource;
  late OffersRepositoryImpl repository;
  late FakeOfferNotificationService fakeNotificationService;
  late GetOffersUseCase getOffersUseCase;
  late GetOfferByIdUseCase getOfferByIdUseCase;
  late CreateOfferUseCase createOfferUseCase;
  late UpdateOfferUseCase updateOfferUseCase;
  late DeleteOfferUseCase deleteOfferUseCase;
  late ToggleOfferStatusUseCase toggleOfferStatusUseCase;

  setUp(() {
    fakeDataSource = FakeOffersRemoteDataSource();
    repository = OffersRepositoryImpl(remoteDataSource: fakeDataSource);
    fakeNotificationService = FakeOfferNotificationService();

    getOffersUseCase = GetOffersUseCase(repository);
    getOfferByIdUseCase = GetOfferByIdUseCase(repository);
    createOfferUseCase = CreateOfferUseCase(repository);
    updateOfferUseCase = UpdateOfferUseCase(repository);
    deleteOfferUseCase = DeleteOfferUseCase(repository);
    toggleOfferStatusUseCase = ToggleOfferStatusUseCase(repository);

    bloc = OffersBloc(
      getOffersUseCase: getOffersUseCase,
      getOfferByIdUseCase: getOfferByIdUseCase,
      createOfferUseCase: createOfferUseCase,
      updateOfferUseCase: updateOfferUseCase,
      deleteOfferUseCase: deleteOfferUseCase,
      toggleOfferStatusUseCase: toggleOfferStatusUseCase,
      notificationService: fakeNotificationService as OfferNotificationService,
    );
  });

  tearDown(() {
    fakeDataSource.clear();
    fakeNotificationService.clear();
    bloc.close();
  });

  test('initial state should be OffersInitial', () {
    expect(bloc.state, equals(OffersInitial()));
  });

  group('LoadOffers', () {
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

    blocTest<OffersBloc, OffersState>(
      'emits [OffersLoading, OffersLoaded] when LoadOffers succeeds',
      build: () {
        for (final offer in testOffers) {
          fakeDataSource.addOffer(offer);
        }
        return bloc;
      },
      act: (bloc) => bloc.add(LoadOffers()),
      expect: () => [
        OffersLoading(),
        OffersLoaded(testOffers),
      ],
    );

    blocTest<OffersBloc, OffersState>(
      'emits [OffersLoading, OffersLoaded] with empty list when no offers',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadOffers()),
      expect: () => [
        OffersLoading(),
        const OffersLoaded([]),
      ],
    );

    blocTest<OffersBloc, OffersState>(
      'emits [OffersLoading, OffersError] when LoadOffers fails',
      build: () {
        fakeDataSource.setError('Network error');
        return bloc;
      },
      act: (bloc) => bloc.add(LoadOffers()),
      expect: () => [
        OffersLoading(),
        isA<OffersError>(),
      ],
      verify: (bloc) {
        final state = bloc.state as OffersError;
        expect(state.message, contains('Failed to load offers'));
      },
    );

    blocTest<OffersBloc, OffersState>(
      'returns offers sorted by sortOrder',
      build: () {
        // Add in random order
        fakeDataSource.addOffer(testOffers[1]); // sortOrder: 2
        fakeDataSource.addOffer(testOffers[0]); // sortOrder: 1
        return bloc;
      },
      act: (bloc) => bloc.add(LoadOffers()),
      expect: () => [
        OffersLoading(),
        isA<OffersLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as OffersLoaded;
        expect(state.offers[0].sortOrder, 1);
        expect(state.offers[1].sortOrder, 2);
      },
    );
  });

  group('LoadOfferById', () {
    final testOffer = OfferModel(
      id: 'target_offer',
      merchandiserId: 'merch_1',
      title: const {'en': 'Target Offer'},
      description: const {'en': 'Description'},
      imageUrl: 'https://example.com/target.jpg',
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

    blocTest<OffersBloc, OffersState>(
      'emits [OffersLoading, OfferLoaded] when LoadOfferById succeeds',
      build: () {
        fakeDataSource.addOffer(testOffer);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadOfferById('target_offer')),
      expect: () => [
        OffersLoading(),
        OfferLoaded(testOffer),
      ],
    );

    blocTest<OffersBloc, OffersState>(
      'emits [OffersLoading, OffersError] when offer not found',
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadOfferById('non_existent')),
      expect: () => [
        OffersLoading(),
        isA<OffersError>(),
      ],
      verify: (bloc) {
        final state = bloc.state as OffersError;
        expect(state.message, contains('Failed to load offer'));
      },
    );

    blocTest<OffersBloc, OffersState>(
      'emits [OffersLoading, OffersError] when LoadOfferById fails',
      build: () {
        fakeDataSource.setError('Database error');
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadOfferById('any_id')),
      expect: () => [
        OffersLoading(),
        isA<OffersError>(),
      ],
    );
  });

  group('CreateOffer', () {
    final newOffer = Offer(
      id: 'new_offer',
      merchandiserId: 'merch_1',
      title: const {'en': 'New Offer', 'ar': 'عرض جديد'},
      description: const {'en': 'New Description', 'ar': 'وصف جديد'},
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

    blocTest<OffersBloc, OffersState>(
      'emits [OffersLoading, OfferCreated, OffersLoading, OffersLoaded] when CreateOffer succeeds',
      build: () => bloc,
      act: (bloc) => bloc.add(CreateOffer(newOffer)),
      expect: () => [
        OffersLoading(),
        OfferCreated(),
        isA<OffersLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as OffersLoaded;
        expect(state.offers.length, 1);
        expect(state.offers[0].id, 'new_offer');
      },
    );

    blocTest<OffersBloc, OffersState>(
      'sends notification when offer is created successfully',
      build: () => bloc,
      act: (bloc) => bloc.add(CreateOffer(newOffer)),
      verify: (_) {
        // Wait for notification to be sent
        expect(
          fakeNotificationService.hasNotificationBeenSent(
            type: 'offer_created',
            offerId: 'new_offer',
          ),
          true,
        );

        final lastNotification = fakeNotificationService.getLastNotification();
        expect(lastNotification?['offer_title'], 'New Offer');
        expect(lastNotification?['merchandiser_id'], 'merch_1');
      },
    );

    blocTest<OffersBloc, OffersState>(
      'emits [OffersLoading, OffersError] when CreateOffer fails',
      build: () {
        fakeDataSource.setError('Creation failed');
        return bloc;
      },
      act: (bloc) => bloc.add(CreateOffer(newOffer)),
      expect: () => [
        OffersLoading(),
        isA<OffersError>(),
      ],
      verify: (bloc) {
        final state = bloc.state as OffersError;
        expect(state.message, contains('Failed to create offer'));
      },
    );

    blocTest<OffersBloc, OffersState>(
      'does not fail offer creation if notification fails',
      build: () {
        fakeNotificationService.setError('Notification service down');
        return bloc;
      },
      act: (bloc) => bloc.add(CreateOffer(newOffer)),
      expect: () => [
        OffersLoading(),
        OfferCreated(),
        isA<OffersLoaded>(),
      ],
    );
  });

  group('UpdateOffer', () {
    final originalOffer = OfferModel(
      id: 'offer_1',
      merchandiserId: 'merch_1',
      title: const {'en': 'Original'},
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

    final updatedOffer = Offer(
      id: 'offer_1',
      merchandiserId: 'merch_1',
      title: const {'en': 'Updated'},
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

    blocTest<OffersBloc, OffersState>(
      'emits [OffersLoading, OfferUpdated, OffersLoading, OffersLoaded] when UpdateOffer succeeds',
      build: () {
        fakeDataSource.addOffer(originalOffer);
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateOffer(updatedOffer)),
      expect: () => [
        OffersLoading(),
        OfferUpdated(),
        OffersLoading(),
        isA<OffersLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as OffersLoaded;
        expect(state.offers[0].title['en'], 'Updated');
        expect(state.offers[0].isActive, false);
      },
    );

    blocTest<OffersBloc, OffersState>(
      'emits [OffersLoading, OffersError] when UpdateOffer fails',
      build: () {
        fakeDataSource.setError('Update failed');
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateOffer(updatedOffer)),
      expect: () => [
        OffersLoading(),
        isA<OffersError>(),
      ],
    );

    blocTest<OffersBloc, OffersState>(
      'emits error when trying to update non-existent offer',
      build: () => bloc,
      act: (bloc) => bloc.add(UpdateOffer(updatedOffer)),
      expect: () => [
        OffersLoading(),
        isA<OffersError>(),
      ],
    );
  });

  group('DeleteOffer', () {
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

    blocTest<OffersBloc, OffersState>(
      'emits [OffersLoading, OfferDeleted, OffersLoading, OffersLoaded] when DeleteOffer succeeds',
      build: () {
        fakeDataSource.addOffer(testOffer);
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteOffer('offer_to_delete')),
      expect: () => [
        OffersLoading(),
        OfferDeleted(),
        OffersLoading(),
        const OffersLoaded([]),
      ],
    );

    blocTest<OffersBloc, OffersState>(
      'emits [OffersLoading, OffersError] when DeleteOffer fails',
      build: () {
        fakeDataSource.setError('Deletion failed');
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteOffer('offer_1')),
      expect: () => [
        OffersLoading(),
        isA<OffersError>(),
      ],
    );

    blocTest<OffersBloc, OffersState>(
      'emits error when trying to delete non-existent offer',
      build: () => bloc,
      act: (bloc) => bloc.add(const DeleteOffer('non_existent')),
      expect: () => [
        OffersLoading(),
        isA<OffersError>(),
      ],
    );
  });

  group('ToggleOfferStatus', () {
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

    blocTest<OffersBloc, OffersState>(
      'emits [OfferStatusToggled, OffersLoading, OffersLoaded] when toggling to inactive',
      build: () {
        fakeDataSource.addOffer(testOffer);
        return bloc;
      },
      act: (bloc) => bloc.add(const ToggleOfferStatus('offer_1', false)),
      expect: () => [
        OfferStatusToggled(),
        OffersLoading(),
        isA<OffersLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as OffersLoaded;
        expect(state.offers[0].isActive, false);
      },
    );

    blocTest<OffersBloc, OffersState>(
      'emits [OfferStatusToggled, OffersLoading, OffersLoaded] when toggling to active',
      build: () {
        final inactiveOffer = OfferModel(
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
        fakeDataSource.addOffer(inactiveOffer);
        return bloc;
      },
      act: (bloc) => bloc.add(const ToggleOfferStatus('offer_1', true)),
      expect: () => [
        OfferStatusToggled(),
        OffersLoading(),
        isA<OffersLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as OffersLoaded;
        expect(state.offers[0].isActive, true);
      },
    );

    blocTest<OffersBloc, OffersState>(
      'emits [OffersError] when ToggleOfferStatus fails',
      build: () {
        fakeDataSource.setError('Toggle failed');
        return bloc;
      },
      act: (bloc) => bloc.add(const ToggleOfferStatus('offer_1', false)),
      expect: () => [
        isA<OffersError>(),
      ],
    );

    blocTest<OffersBloc, OffersState>(
      'emits error when trying to toggle non-existent offer',
      build: () => bloc,
      act: (bloc) => bloc.add(const ToggleOfferStatus('non_existent', true)),
      expect: () => [
        isA<OffersError>(),
      ],
    );

    blocTest<OffersBloc, OffersState>(
      'handles multiple toggle operations correctly',
      build: () {
        fakeDataSource.addOffer(testOffer);
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const ToggleOfferStatus('offer_1', false));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleOfferStatus('offer_1', true));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleOfferStatus('offer_1', false));
      },
      skip: 8, // Skip intermediate states
      expect: () => [
        isA<OffersLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as OffersLoaded;
        expect(state.offers[0].isActive, false);
      },
    );
  });

  group('Complex scenarios', () {
    blocTest<OffersBloc, OffersState>(
      'handles create, update, and delete sequence correctly',
      build: () => bloc,
      act: (bloc) async {
        // Create
        final newOffer = Offer(
          id: 'test_offer',
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
        bloc.add(CreateOffer(newOffer));
        await Future.delayed(const Duration(milliseconds: 100));

        // Update
        final updatedOffer = newOffer.copyWith(
          title: const {'en': 'Updated Test'},
        );
        bloc.add(UpdateOffer(updatedOffer));
        await Future.delayed(const Duration(milliseconds: 100));

        // Delete
        bloc.add(const DeleteOffer('test_offer'));
      },
      skip: 9, // Skip intermediate states
      expect: () => [
        OffersLoading(),
        const OffersLoaded([]),
      ],
    );

    blocTest<OffersBloc, OffersState>(
      'maintains correct state after multiple operations',
      build: () => bloc,
      act: (bloc) async {
        // Create multiple offers
        for (int i = 1; i <= 3; i++) {
          final offer = Offer(
            id: 'offer_$i',
            merchandiserId: 'merch_1',
            title: {'en': 'Offer $i'},
            description: const {'en': 'Description'},
            imageUrl: 'url',
            type: OfferType.bundle,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 12, 31),
            isActive: true,
            sortOrder: i,
            details: const BundleOfferDetails(
              items: [],
              bundlePrice: 100.0,
              originalTotalPrice: 150.0,
            ),
          );
          bloc.add(CreateOffer(offer));
          await Future.delayed(const Duration(milliseconds: 50));
        }

        // Delete one
        bloc.add(const DeleteOffer('offer_2'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Load to verify
        bloc.add(LoadOffers());
      },
      skip: 13, // Skip intermediate states
      expect: () => [
        OffersLoading(),
        isA<OffersLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as OffersLoaded;
        expect(state.offers.length, 2);
        expect(state.offers.any((o) => o.id == 'offer_2'), false);
      },
    );
  });
}
