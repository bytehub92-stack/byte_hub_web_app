import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/usecases/toggle_merchandiser_status.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  late ToggleMerchandiserStatus usecase;
  late FakeMerchandiserRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeMerchandiserRepository();
    usecase = ToggleMerchandiserStatus(fakeRepository);
  });

  test('should toggle merchandiser status', () async {
    // Arrange
    fakeRepository.shouldReturnError = false;
    final params = ToggleMerchandiserStatusParams(id: '1', isActive: false);

    // Act
    final result = await usecase(params);

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not return failure'),
      (unit) => expect(unit, equals(unit)),
    );
  });
}
