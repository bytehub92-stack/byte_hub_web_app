import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/create_merchandiser.dart';
import '../../../domain/usecases/get_merchandisers.dart';
import '../../../domain/usecases/toggle_merchandiser_status.dart';
import 'merchandiser_event.dart';
import 'merchandiser_state.dart';

class MerchandiserBloc extends Bloc<MerchandiserEvent, MerchandiserState> {
  final GetMerchandisers getMerchandisers;
  final CreateMerchandiser createMerchandiser;
  final ToggleMerchandiserStatus toggleMerchandiserStatus;

  MerchandiserBloc({
    required this.getMerchandisers,
    required this.createMerchandiser,
    required this.toggleMerchandiserStatus,
  }) : super(MerchandiserInitial()) {
    on<LoadMerchandisers>(_onLoadMerchandisers);
    on<CreateMerchandiserEvent>(_onCreateMerchandiser);
    on<ToggleMerchandiserStatusEvent>(_onToggleMerchandiserStatus);
    on<RefreshMerchandisers>(_onRefreshMerchandisers);
  }

  Future<void> _onLoadMerchandisers(
    LoadMerchandisers event,
    Emitter<MerchandiserState> emit,
  ) async {
    emit(MerchandiserLoading());

    final failureOrMerchandisers = await getMerchandisers(NoParams());

    failureOrMerchandisers.fold(
      (failure) => emit(MerchandiserError(message: failure.message)),
      (merchandisers) => emit(MerchandiserLoaded(merchandisers: merchandisers)),
    );
  }

  Future<void> _onCreateMerchandiser(
    CreateMerchandiserEvent event,
    Emitter<MerchandiserState> emit,
  ) async {
    emit(MerchandiserCreating());

    final failureOrPassword = await createMerchandiser(event.request);

    failureOrPassword.fold(
      (failure) => emit(MerchandiserError(message: failure.message)),
      (tempPassword) {
        emit(
          MerchandiserCreated(
            tempPassword: tempPassword,
            email: event.request.email,
          ),
        );
        // Automatically refresh the list after creation
        add(LoadMerchandisers());
      },
    );
  }

  Future<void> _onToggleMerchandiserStatus(
    ToggleMerchandiserStatusEvent event,
    Emitter<MerchandiserState> emit,
  ) async {
    emit(MerchandiserStatusUpdating());

    final failureOrSuccess = await toggleMerchandiserStatus(
      ToggleMerchandiserStatusParams(
        id: event.merchandiserId,
        isActive: event.newStatus,
      ),
    );

    failureOrSuccess.fold(
      (failure) => emit(MerchandiserError(message: failure.message)),
      (_) {
        emit(MerchandiserStatusUpdated());
        // Automatically refresh the list after status update
        add(LoadMerchandisers());
      },
    );
  }

  Future<void> _onRefreshMerchandisers(
    RefreshMerchandisers event,
    Emitter<MerchandiserState> emit,
  ) async {
    add(LoadMerchandisers());
  }
}
