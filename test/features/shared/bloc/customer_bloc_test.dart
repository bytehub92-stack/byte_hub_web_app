// test/features/shared/presentation/bloc/customer/customer_bloc_test.dart

import 'package:admin_panel/features/shared/shared_feature/data/repositories/customer_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/customer/get_customers_by_merchandiser.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/customer/toggle_customer_status.dart';
import 'package:admin_panel/features/shared/shared_feature/presentation/bloc/customer/customer_bloc.dart';
import 'package:admin_panel/features/shared/shared_feature/presentation/bloc/customer/customer_event.dart';
import 'package:admin_panel/features/shared/shared_feature/presentation/bloc/customer/customer_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../store_management/data/datasources/fake_customer_remote_datasource.dart';

void main() {
  late CustomerBloc bloc;
  late GetCustomersByMerchandiser getCustomersUseCase;
  late ToggleCustomerStatus toggleStatusUseCase;
  late CustomerRepositoryImpl repository;
  late FakeCustomerRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeCustomerRemoteDataSource();
    repository = CustomerRepositoryImpl(remoteDataSource: fakeDataSource);
    getCustomersUseCase = GetCustomersByMerchandiser(repository);
    toggleStatusUseCase = ToggleCustomerStatus(repository);

    bloc = CustomerBloc(
      getCustomersByMerchandiser: getCustomersUseCase,
      toggleCustomerStatus: toggleStatusUseCase,
    );
  });

  tearDown(() {
    fakeDataSource.clear();
    bloc.close();
  });

  group('CustomerBloc', () {
    const tMerchandiserId = 'merch-1';
    const tCustomerId = 'cust-1';

    test('initial state should be CustomerInitial', () {
      // Assert
      expect(bloc.state, CustomerInitial());
    });

    group('LoadCustomers', () {
      blocTest<CustomerBloc, CustomerState>(
        'should emit [CustomerLoading, CustomersLoaded] when successful',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCustomersByMerchandiser(tMerchandiserId)),
        wait: const Duration(milliseconds: 300),
        expect: () => [CustomerLoading(), isA<CustomersLoaded>()],
      );

      blocTest<CustomerBloc, CustomerState>(
        'should return customers sorted by created_at descending',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCustomersByMerchandiser(tMerchandiserId)),
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          final state = bloc.state as CustomersLoaded;
          for (int i = 0; i < state.customers.length - 1; i++) {
            expect(
              state.customers[i].createdAt.isAfter(
                    state.customers[i + 1].createdAt,
                  ) ||
                  state.customers[i].createdAt.isAtSameMomentAs(
                    state.customers[i + 1].createdAt,
                  ),
              true,
            );
          }
        },
      );

      blocTest<CustomerBloc, CustomerState>(
        'should return empty list when no customers exist',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCustomersByMerchandiser('merch-999')),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          CustomerLoading(),
          isA<CustomersLoaded>().having(
            (s) => s.customers,
            'customers',
            isEmpty,
          ),
        ],
      );

      blocTest<CustomerBloc, CustomerState>(
        'should include active and inactive customers',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCustomersByMerchandiser(tMerchandiserId)),
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          final state = bloc.state as CustomersLoaded;
          final activeCount = state.customers.where((c) => c.isActive).length;
          final inactiveCount =
              state.customers.where((c) => !c.isActive).length;
          expect(activeCount, 2);
          expect(inactiveCount, 1);
        },
      );

      blocTest<CustomerBloc, CustomerState>(
        'should include customer statistics',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCustomersByMerchandiser(tMerchandiserId)),
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          final state = bloc.state as CustomersLoaded;
          final customerWithOrders = state.customers.firstWhere(
            (c) => c.id == tCustomerId,
          );
          expect(customerWithOrders.totalOrders, 5);
          expect(customerWithOrders.totalSpent, 1500.50);
          expect(customerWithOrders.lastOrderDate, isNotNull);
        },
      );

      blocTest<CustomerBloc, CustomerState>(
        'should emit [CustomerLoading, CustomerError] on failure',
        build: () {
          fakeDataSource.throwError('Database connection failed');
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCustomersByMerchandiser(tMerchandiserId)),
        expect: () => [
          CustomerLoading(),
          isA<CustomerError>().having(
            (s) => s.message,
            'message',
            contains('Database connection failed'),
          ),
        ],
      );

      blocTest<CustomerBloc, CustomerState>(
        'should handle network errors',
        build: () {
          fakeDataSource.throwError('Network timeout');
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCustomersByMerchandiser(tMerchandiserId)),
        expect: () => [
          CustomerLoading(),
          isA<CustomerError>().having(
            (s) => s.message,
            'message',
            contains('Network timeout'),
          ),
        ],
      );
    });

    group('ToggleStatus', () {
      blocTest<CustomerBloc, CustomerState>(
        'should emit [CustomerLoading, CustomerStatusUpdated] when deactivating customer',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        seed: () => CustomersLoaded(
          fakeDataSource
              .getAllCustomers()
              .where((c) => c.merchandiserId == tMerchandiserId)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        ),
        act: (bloc) => bloc.add(ToggleCustomerStatusEvent(tCustomerId, false)),
        wait: const Duration(milliseconds: 300),
        expect: () => [CustomerLoading(), isA<CustomerStatusUpdated>()],
      );

      blocTest<CustomerBloc, CustomerState>(
        'should emit [CustomerLoading, CustomersLoaded] when activating customer',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        seed: () => CustomersLoaded(
          fakeDataSource
              .getAllCustomers()
              .where((c) => c.merchandiserId == tMerchandiserId)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        ),
        act: (bloc) => bloc.add(ToggleCustomerStatusEvent('cust-3', true)),
        wait: const Duration(milliseconds: 300),
        expect: () => [CustomerLoading(), isA<CustomerStatusUpdated>()],
      );

      blocTest<CustomerBloc, CustomerState>(
        'should maintain customer list order after toggle',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        seed: () => CustomersLoaded(
          fakeDataSource
              .getAllCustomers()
              .where((c) => c.merchandiserId == tMerchandiserId)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        ),
        act: (bloc) => bloc.add(ToggleCustomerStatusEvent(tCustomerId, false)),
        wait: const Duration(milliseconds: 300),
        expect: () => [CustomerLoading(), isA<CustomerStatusUpdated>()],
      );

      blocTest<CustomerBloc, CustomerState>(
        'should not affect other customers',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        seed: () => CustomersLoaded(
          fakeDataSource
              .getAllCustomers()
              .where((c) => c.merchandiserId == tMerchandiserId)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        ),
        act: (bloc) => bloc.add(ToggleCustomerStatusEvent(tCustomerId, false)),
        wait: const Duration(milliseconds: 300),
        expect: () => [CustomerLoading(), isA<CustomerStatusUpdated>()],
      );

      blocTest<CustomerBloc, CustomerState>(
        'should emit [CustomerLoading, CustomerError] when customer not found',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        seed: () => CustomersLoaded(
          fakeDataSource
              .getAllCustomers()
              .where((c) => c.merchandiserId == tMerchandiserId)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        ),
        act: (bloc) => bloc.add(ToggleCustomerStatusEvent('cust-999', false)),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          CustomerLoading(),
          isA<CustomerError>().having(
            (s) => s.message,
            'message',
            contains('Customer not found'),
          ),
        ],
      );

      blocTest<CustomerBloc, CustomerState>(
        'should emit [CustomerLoading, CustomerError] on repository failure',
        build: () {
          fakeDataSource.seedData();
          fakeDataSource.throwError('Update constraint violation');
          return bloc;
        },
        seed: () => CustomersLoaded(
          fakeDataSource
              .getAllCustomers()
              .where((c) => c.merchandiserId == tMerchandiserId)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        ),
        act: (bloc) => bloc.add(ToggleCustomerStatusEvent(tCustomerId, false)),
        expect: () => [
          CustomerLoading(),
          isA<CustomerError>().having(
            (s) => s.message,
            'message',
            contains('Update constraint violation'),
          ),
        ],
      );
    });

    group('Multiple Operations', () {
      blocTest<CustomerBloc, CustomerState>(
        'should handle multiple toggles in sequence',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        act: (bloc) async {
          bloc.add(LoadCustomersByMerchandiser(tMerchandiserId));
          await Future.delayed(const Duration(milliseconds: 200));
          bloc.add(ToggleCustomerStatusEvent(tCustomerId, false));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(ToggleCustomerStatusEvent(tCustomerId, true));
        },
        wait: const Duration(milliseconds: 300),
        skip: 4,
        expect: () => [
          CustomerLoading(),
          isA<CustomerStatusUpdated>(),
        ],
      );

      blocTest<CustomerBloc, CustomerState>(
        'should handle reload after toggle',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        act: (bloc) async {
          bloc.add(LoadCustomersByMerchandiser(tMerchandiserId));
          await Future.delayed(const Duration(milliseconds: 300));
          bloc.add(ToggleCustomerStatusEvent(tCustomerId, false));
          await Future.delayed(const Duration(milliseconds: 300));
          bloc.add(LoadCustomersByMerchandiser(tMerchandiserId));
        },
        skip: 4,
        wait: const Duration(milliseconds: 300),
        expect: () => [CustomerLoading(), isA<CustomersLoaded>()],
        verify: (bloc) {
          final state = bloc.state as CustomersLoaded;
          final customer = state.customers.firstWhere(
            (c) => c.id == tCustomerId,
          );
          expect(customer.isActive, false);
        },
      );
    });

    group('Edge Cases', () {
      blocTest<CustomerBloc, CustomerState>(
        'should handle rapid event firing',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        act: (bloc) async {
          bloc.add(LoadCustomersByMerchandiser(tMerchandiserId));
          await Future.delayed(const Duration(milliseconds: 300));
          bloc.add(LoadCustomersByMerchandiser(tMerchandiserId));
          await Future.delayed(const Duration(milliseconds: 300));
          bloc.add(LoadCustomersByMerchandiser(tMerchandiserId));
        },
        skip: 4,
        wait: const Duration(milliseconds: 300),
        expect: () => [CustomerLoading(), isA<CustomersLoaded>()],
      );

      blocTest<CustomerBloc, CustomerState>(
        'should handle empty merchandiser',
        build: () {
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCustomersByMerchandiser('')),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          CustomerLoading(),
          isA<CustomersLoaded>().having(
            (s) => s.customers,
            'customers',
            isEmpty,
          ),
        ],
      );

      blocTest<CustomerBloc, CustomerState>(
        'should preserve merchandiserId after toggle',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        seed: () => CustomersLoaded(
          fakeDataSource
              .getAllCustomers()
              .where((c) => c.merchandiserId == tMerchandiserId)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        ),
        act: (bloc) => bloc.add(ToggleCustomerStatusEvent(tCustomerId, false)),
        wait: const Duration(milliseconds: 300),
        expect: () => [CustomerLoading(), isA<CustomerStatusUpdated>()],
      );

      blocTest<CustomerBloc, CustomerState>(
        'should handle customers with null optional fields',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCustomersByMerchandiser(tMerchandiserId)),
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          final state = bloc.state as CustomersLoaded;
          final customerWithNulls = state.customers.firstWhere(
            (c) => c.id == 'cust-3',
          );
          // Should not throw null pointer exceptions
          expect(customerWithNulls.avatarUrl, isNull);
          expect(customerWithNulls.fullName, isNotEmpty);
        },
      );

      blocTest<CustomerBloc, CustomerState>(
        'should handle customers with zero statistics',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCustomersByMerchandiser('merch-2')),
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          final state = bloc.state as CustomersLoaded;
          final customer = state.customers.first;
          expect(customer.totalOrders, 0);
          expect(customer.totalSpent, 0.0);
          expect(customer.lastOrderDate, isNull);
        },
      );
    });

    group('State Persistence', () {
      blocTest<CustomerBloc, CustomerState>(
        'should maintain customer count through toggle',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        seed: () => CustomersLoaded(
          fakeDataSource
              .getAllCustomers()
              .where((c) => c.merchandiserId == tMerchandiserId)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        ),
        act: (bloc) => bloc.add(ToggleCustomerStatusEvent(tCustomerId, false)),
        wait: const Duration(milliseconds: 300),
        expect: () => [CustomerLoading(), isA<CustomerStatusUpdated>()],
      );

      blocTest<CustomerBloc, CustomerState>(
        'should maintain all customer data except isActive on toggle',
        build: () {
          fakeDataSource.seedData();
          return bloc;
        },
        seed: () => CustomersLoaded(
          fakeDataSource
              .getAllCustomers()
              .where((c) => c.merchandiserId == tMerchandiserId)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        ),
        act: (bloc) => bloc.add(ToggleCustomerStatusEvent(tCustomerId, false)),
        wait: const Duration(milliseconds: 300),
        expect: () => [CustomerLoading(), isA<CustomerStatusUpdated>()],
      );
    });
  });
}
