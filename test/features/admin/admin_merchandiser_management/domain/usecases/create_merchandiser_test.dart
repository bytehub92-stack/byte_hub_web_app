import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/entities/create_merchandiser_request.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/usecases/create_merchandiser.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  late CreateMerchandiser usecase;
  late FakeMerchandiserRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeMerchandiserRepository();
    usecase = CreateMerchandiser(fakeRepository);
  });

  final tRequest = CreateMerchandiserRequest(
    businessName: 'New Business',
    businessType: 'Electronics',
    description: 'Test description',
    fullName: 'John Doe',
    email: 'john@example.com',
    phoneNumber: '+1234567890',
  );

  test('should create merchandiser and return temp password', () async {
    // Arrange
    fakeRepository.shouldReturnError = false;

    // Act
    final result = await usecase(tRequest);

    // Assert
    expect(result.isRight(), true);
    result.fold((failure) => fail('Should not return failure'), (tempPassword) {
      expect(tempPassword, 'TempPass123!');
    });
  });
}
