import 'package:admin_panel/features/shared/shared_feature/domain/entities/merchandiser_stats.dart';

abstract class MerchandiserStatsRepository {
  Future<MerchandiserStats> getStats(String merchandiserId);
}
