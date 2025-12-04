import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/admin_stats_bloc/admin_stats_bloc.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/admin_stats_bloc/admin_stats_event.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/admin_stats_bloc/admin_stats_state.dart';
import '../../../../../helpers/test_helpers.dart';

void main() {
  late AdminStatsBloc bloc;
  late FakeGetAdminStats fakeGetAdminStats;

  setUp(() {
    fakeGetAdminStats = FakeGetAdminStats();
    bloc = AdminStatsBloc(getAdminStats: fakeGetAdminStats);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be AdminStatsInitial', () {
    expect(bloc.state, equals(AdminStatsInitial()));
  });

  blocTest<AdminStatsBloc, AdminStatsState>(
    'emits [AdminStatsLoading, AdminStatsLoaded] when successful',
    build: () {
      fakeGetAdminStats.shouldReturnError = false;
      return AdminStatsBloc(getAdminStats: fakeGetAdminStats);
    },
    act: (bloc) => bloc.add(LoadAdminStats()),
    wait: const Duration(milliseconds: 200),
    expect: () => [
      AdminStatsLoading(),
      isA<AdminStatsLoaded>().having(
        (s) => s.stats.totalMerchandisers,
        'total merchandisers',
        50,
      ),
    ],
  );

  blocTest<AdminStatsBloc, AdminStatsState>(
    'emits [AdminStatsLoading, AdminStatsError] when fails',
    build: () {
      fakeGetAdminStats.shouldReturnError = true;
      return AdminStatsBloc(getAdminStats: fakeGetAdminStats);
    },
    act: (bloc) => bloc.add(LoadAdminStats()),
    wait: const Duration(milliseconds: 200),
    expect: () => [
      AdminStatsLoading(),
      isA<AdminStatsError>().having(
        (s) => s.message,
        'error message',
        'Failed to load stats',
      ),
    ],
  );
}
