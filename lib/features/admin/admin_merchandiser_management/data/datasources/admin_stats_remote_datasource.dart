// lib/features/admin/data/datasources/admin_stats_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/error/exceptions.dart';
import '../models/admin_stats_model.dart';

abstract class AdminStatsRemoteDataSource {
  Future<AdminStatsModel> getAdminStats();
}

class AdminStatsRemoteDataSourceImpl implements AdminStatsRemoteDataSource {
  final SupabaseClient supabaseClient;

  const AdminStatsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<AdminStatsModel> getAdminStats() async {
    try {
      // Get total merchandisers count from merchandiser_details_view
      final merchandisersCount = await supabaseClient
          .from('merchandiser_details_view')
          .select('id')
          .count(CountOption.exact);

      // Get active merchandisers count (now checks profiles.is_active through the view)
      final activeMerchandisersCount = await supabaseClient
          .from('merchandiser_details_view')
          .select('id')
          .eq('is_active', true)
          .count(CountOption.exact);

      print(
        'admin stats remote datasource, active merchandisers count: $activeMerchandisersCount',
      );

      // Get customers count
      final customersCount = await supabaseClient
          .from('profiles')
          .select('id')
          .eq('user_type', 'customer')
          .count(CountOption.exact);

      print('admin stats remote datasource, customers count: $customersCount');

      // Get total categories count (across all merchandisers)
      final categoriesCount = await supabaseClient
          .from('categories')
          .select('id')
          .count(CountOption.exact);

      // Get total products count (across all merchandisers)
      final productsCount = await supabaseClient
          .from('products')
          .select('id')
          .count(CountOption.exact);

      return AdminStatsModel(
        totalMerchandisers: merchandisersCount.count,
        totalCustomers: customersCount.count,
        totalCategories: categoriesCount.count,
        totalProducts: productsCount.count,
        activeMerchandisers: activeMerchandisersCount.count,
      );
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to fetch stats: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
}
