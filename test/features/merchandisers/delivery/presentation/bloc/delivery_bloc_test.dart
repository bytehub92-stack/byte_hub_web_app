// test/features/delivery/presentation/bloc/delivery_bloc_test.dart

import 'package:admin_panel/features/merchandisers/delivery/data/repositories/delivery_repository_impl.dart';
import 'package:admin_panel/features/merchandisers/delivery/presentation/bloc/delivery_bloc.dart';
import 'package:admin_panel/features/merchandisers/delivery/presentation/bloc/delivery_event.dart';
import 'package:admin_panel/features/merchandisers/delivery/presentation/bloc/delivery_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_delivery_remote_datasource.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late DeliveryBloc bloc;
  late DeliveryRepositoryImpl repository;
  late FakeDeliveryRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeDeliveryRemoteDataSource();
    repository = DeliveryRepositoryImpl(remoteDataSource: fakeDataSource);
    bloc = DeliveryBloc(repository: repository);
  });

  tearDown(() {
    bloc.close();
    fakeDataSource.reset();
  });

  test('initial state should be DeliveryInitial', () {
    expect(bloc.state, equals(DeliveryInitial()));
  });

  group('LoadDrivers', () {
    final drivers = TestDataFactory.createDriverList();

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DriversLoaded] when successful',
      build: () {
        fakeDataSource.setupDrivers(
          drivers
              .map((d) => TestDriverBuilder()
                  .withId(d.id)
                  .withFullName(d.fullName)
                  .withIsActive(d.isActive)
                  .withIsAvailable(d.isAvailable)
                  .withActiveOrders(d.activeOrdersCount ?? 0)
                  .withCompletedOrders(d.completedOrdersCount ?? 0)
                  .buildModel())
              .toList(),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(LoadDrivers(TestConstants.merchandiserId)),
      expect: () => [
        DeliveryLoading(),
        DriversLoaded(drivers),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DriversLoaded] with empty list when no drivers',
      build: () {
        fakeDataSource.setupDrivers([]);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadDrivers(TestConstants.merchandiserId)),
      expect: () => [
        DeliveryLoading(),
        const DriversLoaded([]),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DeliveryError] when failure occurs',
      build: () {
        fakeDataSource.throwException('Failed to load drivers');
        return bloc;
      },
      act: (bloc) => bloc.add(LoadDrivers(TestConstants.merchandiserId)),
      expect: () => [
        DeliveryLoading(),
        const DeliveryError('Failed to load drivers'),
      ],
    );
  });

  group('LoadDriverById', () {
    final driver = TestDataFactory.createDriver();

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DriverLoaded] when driver found',
      build: () {
        fakeDataSource.setupDrivers([
          TestDriverBuilder().buildModel(),
        ]);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadDriverById(TestConstants.driverId1)),
      expect: () => [
        DeliveryLoading(),
        DriverLoaded(driver),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DeliveryError] when driver not found',
      build: () {
        fakeDataSource.setupDrivers([]);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadDriverById('non-existent-id')),
      expect: () => [
        DeliveryLoading(),
        isA<DeliveryError>()
            .having((e) => e.message, 'message', contains('not found')),
      ],
    );
  });

  group('AssignOrderToDriver', () {
    setUp(() {
      final driver = TestDriverBuilder()
          .withIsActive(true)
          .withIsAvailable(true)
          .buildModel();
      fakeDataSource.setupDrivers([driver]);
      fakeDataSource.setupOrderStatus(TestConstants.orderId1, 'preparing');
    });

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, OrderAssigned] when assignment successful',
      build: () => bloc,
      act: (bloc) => bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId1,
          driverId: TestConstants.driverId1,
          assignedBy: TestConstants.assignedBy,
          notes: 'Handle with care',
        ),
      ),
      expect: () => [
        DeliveryLoading(),
        isA<OrderAssigned>()
            .having(
                (s) => s.assignment.orderId, 'orderId', TestConstants.orderId1)
            .having((s) => s.assignment.driverId, 'driverId',
                TestConstants.driverId1)
            .having((s) => s.assignment.notes, 'notes', 'Handle with care')
            .having((s) => s.message, 'message', 'Order assigned successfully'),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DeliveryError] when order already assigned',
      build: () => bloc,
      seed: () {
        // First assignment
        fakeDataSource.assignOrderToDriver(
          orderId: TestConstants.orderId1,
          driverId: TestConstants.driverId1,
          assignedBy: TestConstants.assignedBy,
        );
        return DeliveryInitial();
      },
      act: (bloc) => bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId1,
          driverId: TestConstants.driverId2,
          assignedBy: TestConstants.assignedBy,
        ),
      ),
      expect: () => [
        DeliveryLoading(),
        isA<DeliveryError>()
            .having((e) => e.message, 'message', contains('already assigned')),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DeliveryError] when driver is inactive',
      build: () {
        final inactiveDriver = TestDriverBuilder()
            .withIsActive(false)
            .withIsAvailable(true)
            .buildModel();
        fakeDataSource.setupDrivers([inactiveDriver]);
        return bloc;
      },
      act: (bloc) => bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId1,
          driverId: TestConstants.driverId1,
          assignedBy: TestConstants.assignedBy,
        ),
      ),
      expect: () => [
        DeliveryLoading(),
        isA<DeliveryError>()
            .having((e) => e.message, 'message', contains('inactive driver')),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DeliveryError] when driver is unavailable',
      build: () {
        final unavailableDriver = TestDriverBuilder()
            .withIsActive(true)
            .withIsAvailable(false)
            .buildModel();
        fakeDataSource.setupDrivers([unavailableDriver]);
        return bloc;
      },
      act: (bloc) => bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId1,
          driverId: TestConstants.driverId1,
          assignedBy: TestConstants.assignedBy,
        ),
      ),
      expect: () => [
        DeliveryLoading(),
        isA<DeliveryError>().having(
            (e) => e.message, 'message', contains('unavailable driver')),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DeliveryError] when order status is not preparing',
      build: () {
        fakeDataSource.setupOrderStatus(TestConstants.orderId1, 'pending');
        return bloc;
      },
      act: (bloc) => bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId1,
          driverId: TestConstants.driverId1,
          assignedBy: TestConstants.assignedBy,
        ),
      ),
      expect: () => [
        DeliveryLoading(),
        isA<DeliveryError>()
            .having((e) => e.message, 'message', contains('preparing')),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'allows multiple assignments to same driver',
      build: () {
        fakeDataSource.setupOrderStatus(TestConstants.orderId2, 'preparing');
        return bloc;
      },
      act: (bloc) async {
        bloc.add(
          AssignOrderToDriver(
            orderId: TestConstants.orderId1,
            driverId: TestConstants.driverId1,
            assignedBy: TestConstants.assignedBy,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(
          AssignOrderToDriver(
            orderId: TestConstants.orderId2,
            driverId: TestConstants.driverId1,
            assignedBy: TestConstants.assignedBy,
          ),
        );
      },
      expect: () => [
        DeliveryLoading(),
        isA<OrderAssigned>().having(
            (s) => s.assignment.orderId, 'orderId', TestConstants.orderId1),
        DeliveryLoading(),
        isA<OrderAssigned>().having(
            (s) => s.assignment.orderId, 'orderId', TestConstants.orderId2),
      ],
    );
  });

  group('LoadOrderAssignments', () {
    setUp(() {
      final drivers = [
        TestDriverBuilder().withId(TestConstants.driverId1).buildModel(),
        TestDriverBuilder().withId(TestConstants.driverId2).buildModel(),
      ];
      fakeDataSource.setupDrivers(drivers);

      final assignments = [
        TestOrderAssignmentBuilder()
            .withDriverId(TestConstants.driverId1)
            .withDeliveryStatus('assigned')
            .buildModel(),
        TestOrderAssignmentBuilder()
            .withDriverId(TestConstants.driverId1)
            .withDeliveryStatus('picked_up')
            .buildModel(),
        TestOrderAssignmentBuilder()
            .withDriverId(TestConstants.driverId2)
            .withDeliveryStatus('delivered')
            .buildModel(),
      ];
      fakeDataSource.setupAssignments(assignments);
    });

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, OrderAssignmentsLoaded] with all assignments',
      build: () => bloc,
      act: (bloc) => bloc.add(
        LoadOrderAssignments(merchandiserId: TestConstants.merchandiserId),
      ),
      expect: () => [
        DeliveryLoading(),
        isA<OrderAssignmentsLoaded>()
            .having((s) => s.assignments.length, 'length', 3),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, OrderAssignmentsLoaded] filtered by driver',
      build: () => bloc,
      act: (bloc) => bloc.add(
        LoadOrderAssignments(
          merchandiserId: TestConstants.merchandiserId,
          driverId: TestConstants.driverId1,
        ),
      ),
      expect: () => [
        DeliveryLoading(),
        isA<OrderAssignmentsLoaded>()
            .having((s) => s.assignments.length, 'length', 2)
            .having(
              (s) => s.assignments
                  .every((a) => a.driverId == TestConstants.driverId1),
              'all from driver 1',
              true,
            ),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, OrderAssignmentsLoaded] with only active assignments',
      build: () => bloc,
      act: (bloc) => bloc.add(
        LoadOrderAssignments(
          merchandiserId: TestConstants.merchandiserId,
          onlyActive: true,
        ),
      ),
      expect: () => [
        DeliveryLoading(),
        isA<OrderAssignmentsLoaded>()
            .having((s) => s.assignments.length, 'length', 2)
            .having(
              (s) => s.assignments.every((a) => a.isActive),
              'all active',
              true,
            ),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, OrderAssignmentsLoaded] with combined filters',
      build: () => bloc,
      act: (bloc) => bloc.add(
        LoadOrderAssignments(
          merchandiserId: TestConstants.merchandiserId,
          driverId: TestConstants.driverId1,
          onlyActive: true,
        ),
      ),
      expect: () => [
        DeliveryLoading(),
        isA<OrderAssignmentsLoaded>()
            .having((s) => s.assignments.length, 'length', 2),
      ],
    );
  });

  group('UnassignOrder', () {
    setUp(() {
      final driver = TestDriverBuilder().withActiveOrders(1).buildModel();
      fakeDataSource.setupDrivers([driver]);

      final assignment = TestOrderAssignmentBuilder()
          .withOrderId(TestConstants.orderId1)
          .withDriverId(TestConstants.driverId1)
          .withDeliveryStatus('assigned')
          .buildModel();
      fakeDataSource.setupAssignments([assignment]);
      fakeDataSource.setupOrderStatus(TestConstants.orderId1, 'on_the_way');
    });

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, OrderUnassigned] when successful',
      build: () => bloc,
      act: (bloc) => bloc.add(UnassignOrder(TestConstants.orderId1)),
      expect: () => [
        DeliveryLoading(),
        const OrderUnassigned('Order unassigned successfully'),
      ],
      verify: (_) {
        expect(fakeDataSource.isOrderAssigned(TestConstants.orderId1), false);
        expect(
            fakeDataSource.getOrderStatus(TestConstants.orderId1), 'preparing');
      },
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DeliveryError] when trying to unassign delivered order',
      build: () {
        final deliveredAssignment = TestOrderAssignmentBuilder()
            .withOrderId('delivered-order')
            .withDeliveryStatus('delivered')
            .buildModel();
        fakeDataSource.setupAssignments([deliveredAssignment]);
        return bloc;
      },
      act: (bloc) => bloc.add(UnassignOrder('delivered-order')),
      expect: () => [
        DeliveryLoading(),
        isA<DeliveryError>()
            .having((e) => e.message, 'message', contains('Cannot unassign')),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DeliveryError] when assignment not found',
      build: () => bloc,
      act: (bloc) => bloc.add(UnassignOrder('non-existent-order')),
      expect: () => [
        DeliveryLoading(),
        isA<DeliveryError>()
            .having((e) => e.message, 'message', contains('not found')),
      ],
    );
  });

  group('LoadDeliveryStatistics', () {
    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DeliveryStatisticsLoaded] with correct stats',
      build: () {
        final drivers = [
          TestDriverBuilder()
              .withId('driver-1')
              .withIsActive(true)
              .withIsAvailable(true)
              .buildModel(),
          TestDriverBuilder()
              .withId('driver-2')
              .withIsActive(true)
              .withIsAvailable(false)
              .buildModel(),
          TestDriverBuilder()
              .withId('driver-3')
              .withIsActive(false)
              .buildModel(),
        ];
        fakeDataSource.setupDrivers(drivers);

        final assignments = [
          TestOrderAssignmentBuilder()
              .withDriverId('driver-1')
              .withDeliveryStatus('assigned')
              .buildModel(),
          TestOrderAssignmentBuilder()
              .withDriverId('driver-1')
              .withDeliveryStatus('picked_up')
              .buildModel(),
          TestOrderAssignmentBuilder()
              .withDriverId('driver-2')
              .withDeliveryStatus('delivered')
              .buildModel(),
        ];
        fakeDataSource.setupAssignments(assignments);

        return bloc;
      },
      act: (bloc) =>
          bloc.add(LoadDeliveryStatistics(TestConstants.merchandiserId)),
      expect: () => [
        DeliveryLoading(),
        isA<DeliveryStatisticsLoaded>()
            .having((s) => s.statistics['total_drivers'], 'total_drivers', 3)
            .having((s) => s.statistics['active_drivers'], 'active_drivers', 2)
            .having((s) => s.statistics['available_drivers'],
                'available_drivers', 1)
            .having((s) => s.statistics['total_assignments'],
                'total_assignments', 3)
            .having((s) => s.statistics['active_deliveries'],
                'active_deliveries', 2)
            .having((s) => s.statistics['completed_deliveries'],
                'completed_deliveries', 1),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DeliveryStatisticsLoaded] with zero stats',
      build: () {
        fakeDataSource.setupDrivers([]);
        fakeDataSource.setupAssignments([]);
        return bloc;
      },
      act: (bloc) =>
          bloc.add(LoadDeliveryStatistics(TestConstants.merchandiserId)),
      expect: () => [
        DeliveryLoading(),
        isA<DeliveryStatisticsLoaded>()
            .having((s) => s.statistics['total_drivers'], 'total_drivers', 0)
            .having((s) => s.statistics['active_deliveries'],
                'active_deliveries', 0),
      ],
    );
  });

  group('LoadMerchandiserCode', () {
    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, MerchandiserCodeLoaded] when successful',
      build: () {
        fakeDataSource.setupMerchandiserCode(
          TestConstants.merchandiserId,
          TestConstants.merchandiserCode,
        );
        return bloc;
      },
      act: (bloc) =>
          bloc.add(LoadMerchandiserCode(TestConstants.merchandiserId)),
      expect: () => [
        DeliveryLoading(),
        const MerchandiserCodeLoaded(TestConstants.merchandiserCode),
      ],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'emits [DeliveryLoading, DeliveryError] when code not found',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadMerchandiserCode('non-existent-id')),
      expect: () => [
        DeliveryLoading(),
        isA<DeliveryError>()
            .having((e) => e.message, 'message', contains('not found')),
      ],
    );
  });
}
