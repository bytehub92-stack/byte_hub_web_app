import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/usecases/get_admin_stats.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  late GetAdminStats usecase;
  late FakeAdminStatsRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeAdminStatsRepository();
    usecase = GetAdminStats(fakeRepository);
  });

  test('should get admin stats from repository', () async {
    // Arrange
    fakeRepository.shouldReturnError = false;

    // Act
    final result = await usecase();

    // Assert
    expect(result.isRight(), true);
    result.fold((failure) => fail('Should not return failure'), (stats) {
      expect(stats.totalMerchandisers, 50);
      expect(stats.totalCustomers, 1000);
    });
  });
}
