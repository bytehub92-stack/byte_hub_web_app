// lib/features/admin/domain/usecases/get_admin_stats.dart

import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/admin_stats.dart';
import '../repositories/admin_stats_repository.dart';

class GetAdminStats {
  final AdminStatsRepository repository;

  GetAdminStats(this.repository);

  Future<Either<Failure, AdminStats>> call() {
    return repository.getAdminStats();
  }
}
