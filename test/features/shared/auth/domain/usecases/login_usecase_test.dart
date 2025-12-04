import 'package:admin_panel/features/shared/auth/domain/usecases/login_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../fixtures/auth_fixtures.dart';
import '../../../../../helpers/mocks.dart';

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  test('should get user from repository', () async {
    // Arrange
    when(
      () => mockRepository.login(any(), any()),
    ).thenAnswer((_) async => const Right(AuthFixtures.adminUser));

    // Act
    final result = await useCase(
      const LoginParams(
        email: AuthFixtures.validEmail,
        password: AuthFixtures.validPassword,
      ),
    );

    // Assert
    expect(result, const Right(AuthFixtures.adminUser));
    verify(
      () => mockRepository.login(
        AuthFixtures.validEmail,
        AuthFixtures.validPassword,
      ),
    ).called(1);
  });
}
