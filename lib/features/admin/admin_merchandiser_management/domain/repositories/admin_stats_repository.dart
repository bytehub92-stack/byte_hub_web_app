// lib/features/admin/domain/repositories/admin_stats_repository.dart

import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/entities/admin_stats.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';

abstract class AdminStatsRepository {
  Future<Either<Failure, AdminStats>> getAdminStats();
}
