import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/merchandiser_stats.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MerchandiserStatsDataSource {
  final SupabaseClient supabaseClient;

  MerchandiserStatsDataSource({required this.supabaseClient});

  Future<MerchandiserStats> getStatsByMerchandiserId(
    String merchandiserId,
  ) async {
    try {
      final categoriesCount = await supabaseClient
          .from('categories')
          .select('id')
          .eq('merchandiser_id', merchandiserId)
          .count(CountOption.exact);

      final productsCount = await supabaseClient
          .from('products')
          .select('id')
          .eq('merchandiser_id', merchandiserId)
          .count(CountOption.exact);

      final customersCount = await supabaseClient
          .from('customer_merchandiser_relations')
          .select('id')
          .eq('merchandiser_id', merchandiserId)
          .count(CountOption.exact);

      final completedOrdersCount = await supabaseClient
          .from('orders')
          .select('id')
          .eq('merchandiser_id', merchandiserId)
          .eq('status', 'delivered')
          .count(CountOption.exact);

      final pendingOrdersCount = await supabaseClient
          .from('orders')
          .select('id')
          .eq('merchandiser_id', merchandiserId)
          .eq('status', 'pending')
          .count(CountOption.exact);

      return MerchandiserStats(
        categoriesCount: categoriesCount.count,
        productsCount: productsCount.count,
        customersCount: customersCount.count,
        completedOrdersCount: completedOrdersCount.count,
        pendingOrdersCount: pendingOrdersCount.count,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
