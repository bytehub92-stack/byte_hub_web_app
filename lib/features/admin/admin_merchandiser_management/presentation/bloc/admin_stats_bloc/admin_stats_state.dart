// lib/features/admin/presentation/bloc/admin_stats_state.dart

import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/entities/admin_stats.dart';
import 'package:equatable/equatable.dart';

abstract class AdminStatsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminStatsInitial extends AdminStatsState {}

class AdminStatsLoading extends AdminStatsState {}

class AdminStatsLoaded extends AdminStatsState {
  final AdminStats stats;

  AdminStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class AdminStatsError extends AdminStatsState {
  final String message;

  AdminStatsError(this.message);
  @override
  List<Object?> get props => [message];
}
