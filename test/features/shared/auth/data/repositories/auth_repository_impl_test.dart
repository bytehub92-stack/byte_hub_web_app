import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/auth/data/models/user_model.dart';
import 'package:admin_panel/features/shared/auth/data/repositories/auth_repository_impl.dart';
import 'package:admin_panel/features/shared/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../fixtures/auth_fixtures.dart';
import '../../../../../helpers/mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      const UserModel(id: '', email: 'email', userType: UserType.admin),
    );
  });

  group('login', () {
    const tEmail = AuthFixtures.validEmail;
    const tPassword = AuthFixtures.validPassword;

    test('should check if device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.login(any(), any()),
      ).thenAnswer((_) async => AuthFixtures.adminUser);
      when(
        () => mockLocalDataSource.cacheUser(any()),
      ).thenAnswer((_) async => {});

      // Act
      await repository.login(tEmail, tPassword);

      // Assert
      verify(() => mockNetworkInfo.isConnected).called(1);
    });

    test('should return User when login is successful', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.login(tEmail, tPassword),
      ).thenAnswer((_) async => AuthFixtures.adminUser);
      when(
        () => mockLocalDataSource.cacheUser(any()),
      ).thenAnswer((_) async => {});

      // Act
      final result = await repository.login(tEmail, tPassword);

      // Assert
      expect(result, const Right(AuthFixtures.adminUser));
      verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
    });

    test('should cache user data after successful login', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.login(tEmail, tPassword),
      ).thenAnswer((_) async => AuthFixtures.adminUser);
      when(
        () => mockLocalDataSource.cacheUser(any()),
      ).thenAnswer((_) async => {});

      // Act
      await repository.login(tEmail, tPassword);

      // Assert
      verify(
        () => mockLocalDataSource.cacheUser(AuthFixtures.adminUser),
      ).called(1);
    });

    test('should still return user even if caching fails', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.login(tEmail, tPassword),
      ).thenAnswer((_) async => AuthFixtures.adminUser);
      when(
        () => mockLocalDataSource.cacheUser(any()),
      ).thenThrow(Exception('Cache error'));

      // Act
      final result = await repository.login(tEmail, tPassword);

      // Assert
      expect(result, const Right(AuthFixtures.adminUser));
    });

    test(
      'should return ServerFailure when remote source throws ServerException',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.login(any(), any()),
        ).thenThrow(const ServerException(message: 'Invalid credentials'));

        // Act
        final result = await repository.login(tEmail, tPassword);

        // Assert
        expect(
          result,
          const Left(ServerFailure(message: 'Invalid credentials')),
        );
      },
    );

    test('should return NetworkFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.login(tEmail, tPassword);

      // Assert
      expect(result, const Left(NetworkFailure()));
      verifyNever(() => mockRemoteDataSource.login(any(), any()));
    });
  });

  group('logout', () {
    test('should clear cache and remote logout when online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.logout()).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.clearCache()).thenAnswer((_) async => {});

      // Act
      final result = await repository.logout();

      // Assert
      expect(result, const Right(null));
      verify(() => mockRemoteDataSource.logout()).called(1);
      verify(() => mockLocalDataSource.clearCache()).called(1);
    });

    test('should return NetworkFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.logout();

      // Assert
      expect(result, const Left(NetworkFailure()));
    });
  });

  group('getCurrentUser', () {
    test('should return cached user when available', () async {
      // Arrange
      when(
        () => mockLocalDataSource.getCachedUser(),
      ).thenAnswer((_) async => AuthFixtures.adminUser);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, const Right(AuthFixtures.adminUser));
    });

    test('should return null when no cached user', () async {
      // Arrange
      when(
        () => mockLocalDataSource.getCachedUser(),
      ).thenAnswer((_) async => null);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, const Right(null));
    });
  });
}
