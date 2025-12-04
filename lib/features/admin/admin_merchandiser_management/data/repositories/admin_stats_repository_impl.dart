// lib/features/admin/data/repositories/admin_stats_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/repositories/admin_stats_repository.dart';
import '../datasources/admin_stats_remote_datasource.dart';

class AdminStatsRepositoryImpl implements AdminStatsRepository {
  final AdminStatsRemoteDataSource remoteDataSource;

  const AdminStatsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AdminStats>> getAdminStats() async {
    try {
      final stats = await remoteDataSource.getAdminStats();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
