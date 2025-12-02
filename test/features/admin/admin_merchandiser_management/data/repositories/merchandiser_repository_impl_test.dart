import 'package:flutter_test/flutter_test.dart';

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/data/repositories/merchandiser_repository_impl.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/entities/create_merchandiser_request.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  late MerchandiserRepositoryImpl repository;
  late FakeMerchandiserRemoteDataSource fakeDataSource;
  late FakeNetworkInfo fakeNetworkInfo;

  setUp(() {
    fakeDataSource = FakeMerchandiserRemoteDataSource();
    fakeNetworkInfo = FakeNetworkInfo();
    repository = MerchandiserRepositoryImpl(
      remoteDataSource: fakeDataSource,
      networkInfo: fakeNetworkInfo,
    );
  });

  group('getMerchandisers', () {
    test('should return merchandisers when network is connected', () async {
      // Arrange
      fakeNetworkInfo.setConnection(true);
      fakeDataSource.shouldThrowError = false;

      // Act
      final result = await repository.getMerchandisers();

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (
        merchandisers,
      ) {
        expect(merchandisers.length, 2);
        expect(merchandisers[0].businessName['en'], 'Business 1');
      });
    });

    test('should return NetworkFailure when no internet', () async {
      // Arrange
      fakeNetworkInfo.setConnection(false);

      // Act
      final result = await repository.getMerchandisers();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      fakeNetworkInfo.setConnection(true);
      fakeDataSource.shouldThrowError = true;

      // Act
      final result = await repository.getMerchandisers();

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect((failure as ServerFailure).message, 'Server error');
      }, (_) => fail('Should return failure'));
    });
  });

  group('getMerchandiserById', () {
    test('should return merchandiser when found', () async {
      // Arrange
      fakeNetworkInfo.setConnection(true);
      fakeDataSource.shouldThrowError = false;

      // Act
      final result = await repository.getMerchandiserById('1');

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (
        merchandiser,
      ) {
        expect(merchandiser.id, '1');
        expect(merchandiser.businessName['en'], 'Business 1');
      });
    });

    test('should return NetworkFailure when no internet', () async {
      // Arrange
      fakeNetworkInfo.setConnection(false);

      // Act
      final result = await repository.getMerchandiserById('1');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('createMerchandiser', () {
    final tRequest = CreateMerchandiserRequest(
      businessName: 'New Business',
      businessType: 'Electronics',
      description: 'Test description',
      fullName: 'John Doe',
      email: 'john@example.com',
      phoneNumber: '+1234567890',
    );

    test('should return temp password when creation succeeds', () async {
      // Arrange
      fakeNetworkInfo.setConnection(true);
      fakeDataSource.shouldThrowError = false;

      // Act
      final result = await repository.createMerchandiser(tRequest);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (
        tempPassword,
      ) {
        expect(tempPassword, 'TempPass123!');
      });
    });

    test('should return ServerFailure when creation fails', () async {
      // Arrange
      fakeNetworkInfo.setConnection(true);
      fakeDataSource.shouldThrowError = true;

      // Act
      final result = await repository.createMerchandiser(tRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('updateMerchandiserStatus', () {
    test('should return unit when status update succeeds', () async {
      // Arrange
      fakeNetworkInfo.setConnection(true);
      fakeDataSource.shouldThrowError = false;

      // Act
      final result = await repository.updateMerchandiserStatus('1', false);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (unit) => expect(unit, equals(unit)),
      );
    });

    test('should return NetworkFailure when no internet', () async {
      // Arrange
      fakeNetworkInfo.setConnection(false);

      // Act
      final result = await repository.updateMerchandiserStatus('1', false);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
