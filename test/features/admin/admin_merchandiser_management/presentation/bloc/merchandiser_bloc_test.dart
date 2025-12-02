import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/merchandiser_bloc/merchandiser_bloc.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/merchandiser_bloc/merchandiser_event.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/merchandiser_bloc/merchandiser_state.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/entities/create_merchandiser_request.dart';
import '../../../../../helpers/test_helpers.dart';

void main() {
  late MerchandiserBloc bloc;
  late FakeGetMerchandisers fakeGetMerchandisers;
  late FakeCreateMerchandiser fakeCreateMerchandiser;
  late FakeToggleMerchandiserStatus fakeToggleStatus;

  setUp(() {
    fakeGetMerchandisers = FakeGetMerchandisers();
    fakeCreateMerchandiser = FakeCreateMerchandiser();
    fakeToggleStatus = FakeToggleMerchandiserStatus();

    bloc = MerchandiserBloc(
      getMerchandisers: fakeGetMerchandisers,
      createMerchandiser: fakeCreateMerchandiser,
      toggleMerchandiserStatus: fakeToggleStatus,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be MerchandiserInitial', () {
    expect(bloc.state, equals(MerchandiserInitial()));
  });

  group('LoadMerchandisers', () {
    blocTest<MerchandiserBloc, MerchandiserState>(
      'emits [MerchandiserLoading, MerchandiserLoaded] when successful',
      build: () {
        fakeGetMerchandisers.shouldReturnError = false;
        return MerchandiserBloc(
          getMerchandisers: fakeGetMerchandisers,
          createMerchandiser: fakeCreateMerchandiser,
          toggleMerchandiserStatus: fakeToggleStatus,
        );
      },
      act: (bloc) => bloc.add(LoadMerchandisers()),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        MerchandiserLoading(),
        isA<MerchandiserLoaded>().having(
          (s) => s.merchandisers.length,
          'merchandisers length',
          2,
        ),
      ],
    );

    blocTest<MerchandiserBloc, MerchandiserState>(
      'emits [MerchandiserLoading, MerchandiserError] when fails',
      build: () {
        fakeGetMerchandisers.shouldReturnError = true;
        return MerchandiserBloc(
          getMerchandisers: fakeGetMerchandisers,
          createMerchandiser: fakeCreateMerchandiser,
          toggleMerchandiserStatus: fakeToggleStatus,
        );
      },
      act: (bloc) => bloc.add(LoadMerchandisers()),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        MerchandiserLoading(),
        isA<MerchandiserError>().having(
          (s) => s.message,
          'error message',
          'Failed to load',
        ),
      ],
    );
  });

  group('CreateMerchandiserEvent', () {
    final tRequest = CreateMerchandiserRequest(
      businessName: 'New Business',
      businessType: 'Electronics',
      description: 'Test',
      fullName: 'John Doe',
      email: 'john@example.com',
      phoneNumber: '+1234567890',
    );

    blocTest<MerchandiserBloc, MerchandiserState>(
      'emits [MerchandiserCreating, MerchandiserCreated, MerchandiserLoading, MerchandiserLoaded]',
      build: () {
        fakeCreateMerchandiser.shouldReturnError = false;
        fakeGetMerchandisers.shouldReturnError = false;
        return MerchandiserBloc(
          getMerchandisers: fakeGetMerchandisers,
          createMerchandiser: fakeCreateMerchandiser,
          toggleMerchandiserStatus: fakeToggleStatus,
        );
      },
      act: (bloc) => bloc.add(CreateMerchandiserEvent(request: tRequest)),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        MerchandiserCreating(),
        isA<MerchandiserCreated>(),
        MerchandiserLoading(),
        isA<MerchandiserLoaded>(),
      ],
    );

    blocTest<MerchandiserBloc, MerchandiserState>(
      'emits [MerchandiserCreating, MerchandiserError] when creation fails',
      build: () {
        fakeCreateMerchandiser.shouldReturnError = true;
        return MerchandiserBloc(
          getMerchandisers: fakeGetMerchandisers,
          createMerchandiser: fakeCreateMerchandiser,
          toggleMerchandiserStatus: fakeToggleStatus,
        );
      },
      act: (bloc) => bloc.add(CreateMerchandiserEvent(request: tRequest)),
      wait: const Duration(milliseconds: 200),
      expect: () => [MerchandiserCreating(), isA<MerchandiserError>()],
    );
  });

  group('ToggleMerchandiserStatusEvent', () {
    blocTest<MerchandiserBloc, MerchandiserState>(
      'emits [StatusUpdating, StatusUpdated, Loading, Loaded] when successful',
      build: () {
        fakeToggleStatus.shouldReturnError = false;
        fakeGetMerchandisers.shouldReturnError = false;
        return MerchandiserBloc(
          getMerchandisers: fakeGetMerchandisers,
          createMerchandiser: fakeCreateMerchandiser,
          toggleMerchandiserStatus: fakeToggleStatus,
        );
      },
      act: (bloc) => bloc.add(
        ToggleMerchandiserStatusEvent(merchandiserId: '1', newStatus: false),
      ),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        MerchandiserStatusUpdating(),
        MerchandiserStatusUpdated(),
        MerchandiserLoading(),
        isA<MerchandiserLoaded>(),
      ],
    );
  });
}
