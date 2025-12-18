// lib/features/shared/offers/presentation/bloc/offers_bloc.dart
import 'package:admin_panel/features/merchandisers/offers/data/services/offer_notification_service.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/usecase/create_offer_usecase.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/usecase/delete_offer_usecase.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/usecase/get_offer_by_id_usecase.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/usecase/get_offers_usecase.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/usecase/toggle_offer_status_usecase.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/usecase/update_offer_usecase.dart';
import 'package:admin_panel/features/merchandisers/offers/presentation/bloc/offers_event.dart';
import 'package:admin_panel/features/merchandisers/offers/presentation/bloc/offers_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  final GetOffersUseCase getOffersUseCase;
  final GetOfferByIdUseCase getOfferByIdUseCase;
  final CreateOfferUseCase createOfferUseCase;
  final UpdateOfferUseCase updateOfferUseCase;
  final DeleteOfferUseCase deleteOfferUseCase;
  final ToggleOfferStatusUseCase toggleOfferStatusUseCase;
  final OfferNotificationService notificationService;

  OffersBloc({
    required this.getOffersUseCase,
    required this.getOfferByIdUseCase,
    required this.createOfferUseCase,
    required this.updateOfferUseCase,
    required this.deleteOfferUseCase,
    required this.toggleOfferStatusUseCase,
    required this.notificationService,
  }) : super(OffersInitial()) {
    on<LoadOffers>(_onLoadOffers);
    on<LoadOfferById>(_onLoadOfferById);
    on<CreateOffer>(_onCreateOffer);
    on<UpdateOffer>(_onUpdateOffer);
    on<DeleteOffer>(_onDeleteOffer);
    on<ToggleOfferStatus>(_onToggleOfferStatus);
  }

  Future<void> _onLoadOffers(
    LoadOffers event,
    Emitter<OffersState> emit,
  ) async {
    emit(OffersLoading());
    final result = await getOffersUseCase();
    result.fold(
      (failure) => emit(OffersError(failure.message)),
      (offers) => emit(OffersLoaded(offers)),
    );
  }

  Future<void> _onLoadOfferById(
    LoadOfferById event,
    Emitter<OffersState> emit,
  ) async {
    emit(OffersLoading());
    final result = await getOfferByIdUseCase(event.offerId);
    result.fold(
      (failure) => emit(OffersError(failure.message)),
      (offer) => emit(OfferLoaded(offer)),
    );
  }

  Future<void> _onCreateOffer(
    CreateOffer event,
    Emitter<OffersState> emit,
  ) async {
    emit(OffersLoading());

    final result = await createOfferUseCase(event.offer);

    await result.fold(
      (failure) async {
        emit(OffersError(failure.message));
      },
      (_) async {
        // send notification
        try {
          await notificationService.sendOfferCreatedNotification(
            merchandiserId: event.offer.merchandiserId,
            offerTitle: event.offer.title['en'] ?? 'New Offer',
            offerDescription: event.offer.description['en'] ?? '',
            offerId: event.offer.id,
          );
        } catch (_) {}

        emit(OfferCreated());

        // 🔥 Instead of add(LoadOffers()), load offers here
        final offersResult = await getOffersUseCase();

        offersResult.fold(
          (failure) => emit(OffersError(failure.message)),
          (offers) => emit(OffersLoaded(offers)),
        );
      },
    );
  }

  Future<void> _onUpdateOffer(
    UpdateOffer event,
    Emitter<OffersState> emit,
  ) async {
    emit(OffersLoading());
    final result = await updateOfferUseCase(event.offer);
    result.fold((failure) => emit(OffersError(failure.message)), (_) {
      emit(OfferUpdated());
      add(LoadOffers()); // Reload offers list
    });
  }

  Future<void> _onDeleteOffer(
    DeleteOffer event,
    Emitter<OffersState> emit,
  ) async {
    emit(OffersLoading());
    final result = await deleteOfferUseCase(event.offerId);
    result.fold((failure) => emit(OffersError(failure.message)), (_) {
      emit(OfferDeleted());
      add(LoadOffers()); // Reload offers list
    });
  }

  Future<void> _onToggleOfferStatus(
    ToggleOfferStatus event,
    Emitter<OffersState> emit,
  ) async {
    final result = await toggleOfferStatusUseCase(
      event.offerId,
      event.isActive,
    );
    result.fold((failure) => emit(OffersError(failure.message)), (_) {
      emit(OfferStatusToggled());
      add(LoadOffers()); // Reload offers list
    });
  }
}
