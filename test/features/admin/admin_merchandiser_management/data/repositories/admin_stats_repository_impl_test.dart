import 'package:flutter_test/flutter_test.dart';

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/data/repositories/admin_stats_repository_impl.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  late AdminStatsRepositoryImpl repository;
  late FakeAdminStatsRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeAdminStatsRemoteDataSource();
    repository = AdminStatsRepositoryImpl(remoteDataSource: fakeDataSource);
  });

  group('getAdminStats', () {
    test('should return stats when data source succeeds', () async {
      // Arrange
      fakeDataSource.shouldThrowError = false;

      // Act
      final result = await repository.getAdminStats();

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (stats) {
        expect(stats.totalMerchandisers, 50);
        expect(stats.totalCustomers, 1000);
        expect(stats.totalCategories, 20);
        expect(stats.totalProducts, 500);
      });
    });

    test('should return ServerFailure when data source throws error', () async {
      // Arrange
      fakeDataSource.shouldThrowError = true;

      // Act
      final result = await repository.getAdminStats();

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect((failure as ServerFailure).message, 'Stats error');
      }, (_) => fail('Should return failure'));
    });
  });
}
