import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/data/datasources/admin_stats_remote_datasource.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/data/models/admin_stats_model.dart';

class FakeAdminStatsRemoteDataSource implements AdminStatsRemoteDataSource {
  bool shouldThrowError = false;

  @override
  Future<AdminStatsModel> getAdminStats() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldThrowError) {
      throw ServerException(message: 'Stats error');
    }
    return const AdminStatsModel(
      totalMerchandisers: 50,
      totalCustomers: 1000,
      totalCategories: 20,
      totalProducts: 500,
      activeMerchandisers: 45,
      inactiveCustomers: 100,
    );
  }
}
