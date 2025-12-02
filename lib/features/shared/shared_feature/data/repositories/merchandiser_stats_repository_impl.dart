import 'package:admin_panel/features/shared/shared_feature/data/datasources/merchandiser_stats_datasource.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/merchandiser_stats.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/merchandiser_stats_repository.dart';

class MerchandiserStatsRepositoryImpl implements MerchandiserStatsRepository {
  final MerchandiserStatsDataSource dataSource;

  MerchandiserStatsRepositoryImpl({required this.dataSource});

  @override
  Future<MerchandiserStats> getStats(String merchandiserId) async {
    return await dataSource.getStatsByMerchandiserId(merchandiserId);
  }
}
