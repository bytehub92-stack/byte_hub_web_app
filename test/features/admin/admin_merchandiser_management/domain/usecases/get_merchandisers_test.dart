import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/core/usecases/usecase.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/usecases/get_merchandisers.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  late GetMerchandisers usecase;
  late FakeMerchandiserRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeMerchandiserRepository();
    usecase = GetMerchandisers(fakeRepository);
  });

  test('should get merchandisers from repository', () async {
    // Arrange
    fakeRepository.shouldReturnError = false;

    // Act
    final result = await usecase(NoParams());

    // Assert
    expect(result.isRight(), true);
    result.fold((failure) => fail('Should not return failure'), (
      merchandisers,
    ) {
      expect(merchandisers.length, 2);
      expect(merchandisers[0].businessName['en'], 'Business 1');
    });
  });
}
