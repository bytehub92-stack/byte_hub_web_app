// test/features/shared/data/repositories/customer_repository_impl_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/customer_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/customer.dart';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../datasources/fake_customer_remote_datasource.dart';

void main() {
  late CustomerRepositoryImpl repository;
  late FakeCustomerRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeCustomerRemoteDataSource();
    repository = CustomerRepositoryImpl(remoteDataSource: fakeDataSource);
  });

  tearDown(() {
    fakeDataSource.clear();
  });

  group('CustomerRepositoryImpl', () {
    const tMerchandiserId = 'merch-1';
    const tCustomerId = 'cust-1';

    group('getCustomersByMerchandiser - Read Only', () {
      test('should return list of customers for merchandiser', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getCustomersByMerchandiser(
          tMerchandiserId,
        );

        // Assert
        expect(result, isA<Right<Failure, List<Customer>>>());
        result.fold((failure) => fail('Should not return failure'), (
          customers,
        ) {
          expect(customers.length, 3);
          expect(customers[0].fullName, 'Ahmed Ali');
          expect(customers[1].fullName, 'Jane Smith');
          expect(customers[2].fullName, 'John Doe');
        });
      });

      test('should return empty list when no customers exist', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentMerchId = 'merch-999';

        // Act
        final result = await repository.getCustomersByMerchandiser(
          nonExistentMerchId,
        );

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (customers) => expect(customers, isEmpty),
        );
      });

      test('should return customers sorted by created_at descending', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getCustomersByMerchandiser(
          tMerchandiserId,
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          customers,
        ) {
          for (int i = 0; i < customers.length - 1; i++) {
            expect(
              customers[i].createdAt.isAfter(customers[i + 1].createdAt) ||
                  customers[i].createdAt.isAtSameMomentAs(
                    customers[i + 1].createdAt,
                  ),
              true,
            );
          }
        });
      });

      test('should include customer statistics', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getCustomersByMerchandiser(
          tMerchandiserId,
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          customers,
        ) {
          final customer = customers.firstWhere((c) => c.id == tCustomerId);
          expect(customer.totalOrders, 5);
          expect(customer.totalSpent, 1500.50);
          expect(customer.lastOrderDate, isNotNull);
        });
      });

      test('should handle customers with no orders', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getCustomersByMerchandiser('merch-2');

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          customers,
        ) {
          final customer = customers.first;
          expect(customer.totalOrders, 0);
          expect(customer.totalSpent, 0.0);
          expect(customer.lastOrderDate, isNull);
        });
      });

      test('should return ServerFailure on data source error', () async {
        // Arrange
        fakeDataSource.throwError('Network timeout');

        // Act
        final result = await repository.getCustomersByMerchandiser(
          tMerchandiserId,
        );

        // Assert
        expect(result, isA<Left<Failure, List<Customer>>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Network timeout'));
        }, (customers) => fail('Should not return customers'));
      });
    });

    group('getCustomerById - Read Only', () {
      test('should return customer when found', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getCustomerById(tCustomerId);

        // Assert
        expect(result, isA<Right<Failure, Customer>>());
        result.fold((failure) => fail('Should not return failure'), (customer) {
          expect(customer.id, tCustomerId);
          expect(customer.fullName, 'John Doe');
          expect(customer.email, 'john.doe@example.com');
          expect(customer.isActive, true);
        });
      });

      test('should return customer with all fields populated', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getCustomerById(tCustomerId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (customer) {
          expect(customer.phoneNumber, isNotNull);
          expect(customer.avatarUrl, isNotNull);
          expect(customer.preferredLanguage, 'en');
          expect(customer.lastLogin, isNotNull);
          expect(customer.merchandiserId, tMerchandiserId);
        });
      });

      test('should return ServerFailure when customer not found', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentId = 'cust-999';

        // Act
        final result = await repository.getCustomerById(nonExistentId);

        // Assert
        expect(result, isA<Left<Failure, Customer>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Customer not found');
        }, (customer) => fail('Should not return customer'));
      });

      test('should return ServerFailure on data source error', () async {
        // Arrange
        fakeDataSource.throwError('Database connection failed');

        // Act
        final result = await repository.getCustomerById(tCustomerId);

        // Assert
        expect(result, isA<Left<Failure, Customer>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Database connection failed'));
        }, (customer) => fail('Should not return customer'));
      });
    });

    group('toggleCustomerStatus - Admin/Merchandiser Action', () {
      test('should activate customer successfully', () async {
        // Arrange
        fakeDataSource.seedData();
        const inactiveCustomerId = 'cust-3';

        // Verify initial state
        final beforeResult = await repository.getCustomerById(
          inactiveCustomerId,
        );
        beforeResult.fold(
          (failure) => fail('Should not fail'),
          (customer) => expect(customer.isActive, false),
        );

        // Act
        final result = await repository.toggleCustomerStatus(
          inactiveCustomerId,
          true,
        );

        // Assert
        expect(result, isA<Right<Failure, void>>());

        // Verify state changed
        final afterResult = await repository.getCustomerById(
          inactiveCustomerId,
        );
        afterResult.fold(
          (failure) => fail('Should not fail'),
          (customer) => expect(customer.isActive, true),
        );
      });

      test('should deactivate customer successfully', () async {
        // Arrange
        fakeDataSource.seedData();

        // Verify initial state
        final beforeResult = await repository.getCustomerById(tCustomerId);
        beforeResult.fold(
          (failure) => fail('Should not fail'),
          (customer) => expect(customer.isActive, true),
        );

        // Act
        final result = await repository.toggleCustomerStatus(
          tCustomerId,
          false,
        );

        // Assert
        expect(result, isA<Right<Failure, void>>());

        // Verify state changed
        final afterResult = await repository.getCustomerById(tCustomerId);
        afterResult.fold(
          (failure) => fail('Should not fail'),
          (customer) => expect(customer.isActive, false),
        );
      });

      test('should handle multiple status toggles', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act & Assert - Toggle off
        final result1 = await repository.toggleCustomerStatus(
          tCustomerId,
          false,
        );
        expect(result1, isA<Right<Failure, void>>());

        // Act & Assert - Toggle on
        final result2 = await repository.toggleCustomerStatus(
          tCustomerId,
          true,
        );
        expect(result2, isA<Right<Failure, void>>());

        // Verify final state
        final finalResult = await repository.getCustomerById(tCustomerId);
        finalResult.fold(
          (failure) => fail('Should not fail'),
          (customer) => expect(customer.isActive, true),
        );
      });

      test('should return ServerFailure when customer not found', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentId = 'cust-999';

        // Act
        final result = await repository.toggleCustomerStatus(
          nonExistentId,
          false,
        );

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Customer not found');
        }, (_) => fail('Should not succeed'));
      });

      test('should return ServerFailure on update error', () async {
        // Arrange
        fakeDataSource.seedData();
        fakeDataSource.throwError('Update constraint violation');

        // Act
        final result = await repository.toggleCustomerStatus(
          tCustomerId,
          false,
        );

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Update constraint violation'));
        }, (_) => fail('Should not succeed'));
      });
    });

    group('Edge Cases', () {
      test('should handle customer with null optional fields', () async {
        // Arrange
        fakeDataSource.seedData();
        const customerWithNulls = 'cust-3';

        // Act
        final result = await repository.getCustomerById(customerWithNulls);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (customer) {
          expect(customer.avatarUrl, isNull);
          // Should not throw null pointer exceptions
          expect(customer.fullName, isNotEmpty);
        });
      });

      test('should handle customer with no last login', () async {
        // Arrange
        fakeDataSource.seedData();
        const customerNoLogin = 'cust-4';

        // Act
        final result = await repository.getCustomerById(customerNoLogin);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (customer) {
          expect(customer.lastLogin, isNull);
        });
      });

      test('should handle empty merchandiser customer list', () async {
        // Arrange - No seed data

        // Act
        final result = await repository.getCustomersByMerchandiser(
          'any-merchandiser',
        );

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (customers) => expect(customers, isEmpty),
        );
      });

      test(
        'should maintain data integrity across multiple operations',
        () async {
          // Arrange
          fakeDataSource.seedData();
          final initialCustomerCount = fakeDataSource.getCustomerCount();

          // Act - Multiple read operations
          await repository.getCustomersByMerchandiser(tMerchandiserId);
          await repository.getCustomerById(tCustomerId);
          await repository.toggleCustomerStatus(tCustomerId, false);
          await repository.toggleCustomerStatus(tCustomerId, true);

          // Assert - Count should remain the same (no create/delete)
          expect(fakeDataSource.getCustomerCount(), initialCustomerCount);
        },
      );
    });
  });
}
