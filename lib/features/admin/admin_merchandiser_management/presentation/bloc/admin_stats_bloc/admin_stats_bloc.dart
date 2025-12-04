// lib/features/admin/presentation/bloc/admin_stats_bloc.dart

import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/usecases/get_admin_stats.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/admin_stats_bloc/admin_stats_event.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/admin_stats_bloc/admin_stats_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminStatsBloc extends Bloc<AdminStatsEvent, AdminStatsState> {
  final GetAdminStats getAdminStats;

  AdminStatsBloc({required this.getAdminStats}) : super(AdminStatsInitial()) {
    on<LoadAdminStats>(_onLoadAdminStats);
  }

  Future<void> _onLoadAdminStats(
    LoadAdminStats event,
    Emitter<AdminStatsState> emit,
  ) async {
    emit(AdminStatsLoading());

    final result = await getAdminStats();

    result.fold(
      (failure) => emit(AdminStatsError(failure.message)),
      (stats) => emit(AdminStatsLoaded(stats)),
    );
  }
}
