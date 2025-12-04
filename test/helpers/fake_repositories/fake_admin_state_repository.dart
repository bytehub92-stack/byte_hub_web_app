import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/entities/admin_stats.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/repositories/admin_stats_repository.dart';
import 'package:dartz/dartz.dart';

class FakeAdminStatsRepository implements AdminStatsRepository {
  bool shouldReturnError = false;

  @override
  Future<Either<Failure, AdminStats>> getAdminStats() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldReturnError) {
      return Left(ServerFailure(message: 'Failed to load stats'));
    }
    return const Right(
      AdminStats(
        totalMerchandisers: 50,
        totalCustomers: 1000,
        totalCategories: 20,
        totalProducts: 500,
        activeMerchandisers: 45,
      ),
    );
  }
}
