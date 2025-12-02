// test/features/shared/domain/usecases/customer_usecases_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/customer_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/customer.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/customer/get_customers_by_merchandiser.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/customer/toggle_customer_status.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/datasources/fake_customer_remote_datasource.dart';

void main() {
  late GetCustomersByMerchandiser getCustomersUseCase;
  late ToggleCustomerStatus toggleStatusUseCase;
  late CustomerRepositoryImpl repository;
  late FakeCustomerRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeCustomerRemoteDataSource();
    repository = CustomerRepositoryImpl(remoteDataSource: fakeDataSource);
    getCustomersUseCase = GetCustomersByMerchandiser(repository);
    toggleStatusUseCase = ToggleCustomerStatus(repository);
  });

  tearDown(() {
    fakeDataSource.clear();
  });

  group('GetCustomersByMerchandiser', () {
    const tMerchandiserId = 'merch-1';

    group('Success Cases', () {
      test('should return list of customers for merchandiser', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await getCustomersUseCase(tMerchandiserId);

        // Assert
        expect(result, isA<Right<Failure, List<Customer>>>());
        result.fold((failure) => fail('Should not return failure'), (
          customers,
        ) {
          expect(customers, isA<List<Customer>>());
          expect(customers.length, 3);
          expect(customers[0].fullName, 'Ahmed Ali');
          expect(customers[1].fullName, 'Jane Smith');
          expect(customers[2].fullName, 'John Doe');
        });
      });

      test('should return customers sorted by created_at descending', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await getCustomersUseCase(tMerchandiserId);

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

      test('should return customers with all required fields', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await getCustomersUseCase(tMerchandiserId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          customers,
        ) {
          final customer = customers.first;
          expect(customer.id, isNotEmpty);
          expect(customer.email, isNotEmpty);
          expect(customer.fullName, isNotEmpty);
          expect(customer.isActive, isA<bool>());
          expect(customer.createdAt, isA<DateTime>());
          expect(customer.preferredLanguage, isNotEmpty);
          expect(customer.totalOrders, isA<int>());
          expect(customer.totalSpent, isA<double>());
        });
      });

      test('should return empty list when no customers exist', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentMerchId = 'merch-999';

        // Act
        final result = await getCustomersUseCase(nonExistentMerchId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          customers,
        ) {
          expect(customers, isEmpty);
          expect(customers, isA<List<Customer>>());
        });
      });

      test('should include active and inactive customers', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await getCustomersUseCase(tMerchandiserId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          customers,
        ) {
          final activeCount = customers.where((c) => c.isActive).length;
          final inactiveCount = customers.where((c) => !c.isActive).length;
          expect(activeCount, 2);
          expect(inactiveCount, 1);
        });
      });

      test('should include customer statistics', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await getCustomersUseCase(tMerchandiserId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          customers,
        ) {
          final customerWithOrders = customers.firstWhere(
            (c) => c.id == 'cust-1',
          );
          expect(customerWithOrders.totalOrders, 5);
          expect(customerWithOrders.totalSpent, 1500.50);
          expect(customerWithOrders.lastOrderDate, isNotNull);
        });
      });

      test('should handle customers with no orders', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await getCustomersUseCase('merch-2');

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

      test('should handle customers with null optional fields', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await getCustomersUseCase(tMerchandiserId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          customers,
        ) {
          final customerWithNulls = customers.firstWhere(
            (c) => c.id == 'cust-3',
          );
          expect(customerWithNulls.avatarUrl, isNull);
        });
      });

      test('should handle multiple calls correctly', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result1 = await getCustomersUseCase(tMerchandiserId);
        final result2 = await getCustomersUseCase(tMerchandiserId);

        // Assert
        expect(result1, isA<Right<Failure, List<Customer>>>());
        expect(result2, isA<Right<Failure, List<Customer>>>());

        late List<Customer> customers1;
        late List<Customer> customers2;

        result1.fold(
          (failure) => fail('Should not return failure'),
          (customers) => customers1 = customers,
        );

        result2.fold(
          (failure) => fail('Should not return failure'),
          (customers) => customers2 = customers,
        );

        expect(customers1.length, customers2.length);
        expect(customers1.first.id, customers2.first.id);
      });
    });

    group('Failure Cases', () {
      test('should return ServerFailure when repository fails', () async {
        // Arrange
        fakeDataSource.throwError('Database connection failed');

        // Act
        final result = await getCustomersUseCase(tMerchandiserId);

        // Assert
        expect(result, isA<Left<Failure, List<Customer>>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Database connection failed'));
        }, (customers) => fail('Should not return customers'));
      });

      test('should return ServerFailure on network error', () async {
        // Arrange
        fakeDataSource.throwError('Network timeout');

        // Act
        final result = await getCustomersUseCase(tMerchandiserId);

        // Assert
        expect(result, isA<Left<Failure, List<Customer>>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Network timeout'));
        }, (customers) => fail('Should not return customers'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty merchandiser ID', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await getCustomersUseCase('');

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (customers) => expect(customers, isEmpty),
        );
      });

      test('should maintain data consistency across calls', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result1 = await getCustomersUseCase(tMerchandiserId);
        final result2 = await getCustomersUseCase(tMerchandiserId);

        // Assert
        late List<Customer> customers1;
        late List<Customer> customers2;

        result1.fold(
          (failure) => fail('Should not return failure'),
          (customers) => customers1 = customers,
        );

        result2.fold(
          (failure) => fail('Should not return failure'),
          (customers) => customers2 = customers,
        );

        expect(customers1.length, customers2.length);
        for (int i = 0; i < customers1.length; i++) {
          expect(customers1[i].id, customers2[i].id);
          expect(customers1[i].email, customers2[i].email);
        }
      });
    });

    group('Integration Tests', () {
      test('should isolate customers by merchandiser', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final merch1Result = await getCustomersUseCase('merch-1');
        final merch2Result = await getCustomersUseCase('merch-2');

        // Assert
        late List<Customer> merch1Customers;
        late List<Customer> merch2Customers;

        merch1Result.fold(
          (failure) => fail('Should not return failure'),
          (customers) => merch1Customers = customers,
        );

        merch2Result.fold(
          (failure) => fail('Should not return failure'),
          (customers) => merch2Customers = customers,
        );

        expect(merch1Customers.length, 3);
        expect(merch2Customers.length, 1);

        // No overlap in customers
        final merch1Ids = merch1Customers.map((c) => c.id).toSet();
        final merch2Ids = merch2Customers.map((c) => c.id).toSet();
        expect(merch1Ids.intersection(merch2Ids).isEmpty, true);
      });
    });
  });

  group('ToggleCustomerStatus', () {
    const tCustomerId = 'cust-1';

    group('Success Cases - Activation', () {
      test('should activate inactive customer', () async {
        // Arrange
        fakeDataSource.seedData();
        const inactiveCustomerId = 'cust-3';
        // Act
        final result = await toggleStatusUseCase(inactiveCustomerId, true);

        // Assert
        expect(result, isA<Right<Failure, void>>());

        // Verify the change
        final customer = await fakeDataSource.getCustomerById(
          inactiveCustomerId,
        );
        expect(customer.isActive, true);
      });

      test('should keep active customer active', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await toggleStatusUseCase(tCustomerId, true);

        // Assert
        expect(result, isA<Right<Failure, void>>());

        // Verify the state
        final customer = await fakeDataSource.getCustomerById(tCustomerId);
        expect(customer.isActive, true);
      });
    });

    group('Success Cases - Deactivation', () {
      test('should deactivate active customer', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await toggleStatusUseCase(tCustomerId, false);

        // Assert
        expect(result, isA<Right<Failure, void>>());

        // Verify the change
        final customer = await fakeDataSource.getCustomerById(tCustomerId);
        expect(customer.isActive, false);
      });

      test('should keep inactive customer inactive', () async {
        // Arrange
        fakeDataSource.seedData();
        const inactiveCustomerId = 'cust-3';

        // Act
        final result = await toggleStatusUseCase(inactiveCustomerId, false);

        // Assert
        expect(result, isA<Right<Failure, void>>());

        // Verify the state
        final customer = await fakeDataSource.getCustomerById(
          inactiveCustomerId,
        );
        expect(customer.isActive, false);
      });
    });

    group('Success Cases - Multiple Toggles', () {
      test('should handle multiple status toggles', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act & Assert - Deactivate
        final result1 = await toggleStatusUseCase(tCustomerId, false);
        expect(result1, isA<Right<Failure, void>>());

        var customer = await fakeDataSource.getCustomerById(tCustomerId);
        expect(customer.isActive, false);

        // Act & Assert - Activate
        final result2 = await toggleStatusUseCase(tCustomerId, true);
        expect(result2, isA<Right<Failure, void>>());

        customer = await fakeDataSource.getCustomerById(tCustomerId);
        expect(customer.isActive, true);

        // Act & Assert - Deactivate again
        final result3 = await toggleStatusUseCase(tCustomerId, false);
        expect(result3, isA<Right<Failure, void>>());

        customer = await fakeDataSource.getCustomerById(tCustomerId);
        expect(customer.isActive, false);
      });
    });

    group('Failure Cases', () {
      test('should return ServerFailure when customer not found', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentId = 'cust-999';

        // Act
        final result = await toggleStatusUseCase(nonExistentId, false);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Customer not found');
        }, (_) => fail('Should not succeed'));
      });

      test('should return ServerFailure when repository fails', () async {
        // Arrange
        fakeDataSource.seedData();
        fakeDataSource.throwError('Update constraint violation');

        // Act
        final result = await toggleStatusUseCase(tCustomerId, false);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Update constraint violation'));
        }, (_) => fail('Should not succeed'));
      });

      test('should return ServerFailure on network error', () async {
        // Arrange
        fakeDataSource.throwError('Network timeout');

        // Act
        final result = await toggleStatusUseCase(tCustomerId, false);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Network timeout'));
        }, (_) => fail('Should not succeed'));
      });
    });

    group('Edge Cases', () {
      test('should not affect other customer data', () async {
        // Arrange
        fakeDataSource.seedData();
        final customerBefore = await fakeDataSource.getCustomerById(
          tCustomerId,
        );

        // Act
        await toggleStatusUseCase(tCustomerId, false);

        // Assert
        final customerAfter = await fakeDataSource.getCustomerById(tCustomerId);
        expect(customerAfter.id, customerBefore.id);
        expect(customerAfter.email, customerBefore.email);
        expect(customerAfter.fullName, customerBefore.fullName);
        expect(customerAfter.totalOrders, customerBefore.totalOrders);
        expect(customerAfter.totalSpent, customerBefore.totalSpent);
        // Only isActive should change
        expect(customerAfter.isActive, isNot(customerBefore.isActive));
      });

      test('should not affect other customers', () async {
        // Arrange
        fakeDataSource.seedData();
        const otherCustomerId = 'cust-2';
        final otherCustomerBefore = await fakeDataSource.getCustomerById(
          otherCustomerId,
        );

        // Act
        await toggleStatusUseCase(tCustomerId, false);

        // Assert
        final otherCustomerAfter = await fakeDataSource.getCustomerById(
          otherCustomerId,
        );
        expect(otherCustomerAfter.id, otherCustomerBefore.id);
        expect(otherCustomerAfter.isActive, otherCustomerBefore.isActive);
      });
    });
  });
}
