// test/features/delivery/integration/delivery_integration_test.dart

import 'package:admin_panel/features/merchandisers/delivery/data/repositories/delivery_repository_impl.dart';
import 'package:admin_panel/features/merchandisers/delivery/presentation/bloc/delivery_bloc.dart';
import 'package:admin_panel/features/merchandisers/delivery/presentation/bloc/delivery_event.dart';
import 'package:admin_panel/features/merchandisers/delivery/presentation/bloc/delivery_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_delivery_remote_datasource.dart';
import '../helpers/test_helpers.dart';

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

  group('Complete Order Assignment Workflow', () {
    test(
        'should handle full order lifecycle: assign -> update status -> deliver',
        () async {
      // Setup
      final driver = TestDriverBuilder()
          .withIsActive(true)
          .withIsAvailable(true)
          .withActiveOrders(0)
          .buildModel();
      fakeDataSource.setupDrivers([driver]);
      fakeDataSource.setupOrderStatus(TestConstants.orderId1, 'preparing');

      // 1. Get available drivers
      bloc.add(LoadDrivers(TestConstants.merchandiserId));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<DriversLoaded>());

      final driversState = bloc.state as DriversLoaded;
      expect(driversState.drivers.length, 1);
      expect(driversState.drivers.first.isAvailable, true);
      expect(driversState.drivers.first.isActive, true);

      // 2. Assign order to driver
      bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId1,
          driverId: TestConstants.driverId1,
          assignedBy: TestConstants.assignedBy,
          notes: 'Deliver by 5 PM',
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<OrderAssigned>());

      final assignedState = bloc.state as OrderAssigned;
      expect(assignedState.assignment.orderId, TestConstants.orderId1);
      expect(assignedState.assignment.deliveryStatus, 'assigned');
      expect(assignedState.assignment.notes, 'Deliver by 5 PM');

      // 3. Verify order status changed
      expect(
        fakeDataSource.getOrderStatus(TestConstants.orderId1),
        'on_the_way',
      );

      // 4. Verify driver's active orders increased
      expect(
        fakeDataSource.getDriverActiveOrdersCount(TestConstants.driverId1),
        1,
      );

      // 5. Load assignments to verify
      bloc.add(
        LoadOrderAssignments(
          merchandiserId: TestConstants.merchandiserId,
          onlyActive: true,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<OrderAssignmentsLoaded>());

      final assignmentsState = bloc.state as OrderAssignmentsLoaded;
      expect(assignmentsState.assignments.length, 1);
      expect(assignmentsState.assignments.first.isActive, true);
    });

    test('should handle unassigning and reassigning order', () async {
      // Setup
      final drivers = [
        TestDriverBuilder()
            .withId(TestConstants.driverId1)
            .withIsActive(true)
            .withIsAvailable(true)
            .buildModel(),
        TestDriverBuilder()
            .withId(TestConstants.driverId2)
            .withIsActive(true)
            .withIsAvailable(true)
            .buildModel(),
      ];
      fakeDataSource.setupDrivers(drivers);
      fakeDataSource.setupOrderStatus(TestConstants.orderId1, 'preparing');

      // 1. Assign to first driver
      bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId1,
          driverId: TestConstants.driverId1,
          assignedBy: TestConstants.assignedBy,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<OrderAssigned>());
      expect(
        fakeDataSource.getDriverActiveOrdersCount(TestConstants.driverId1),
        1,
      );

      // 2. Unassign the order
      bloc.add(UnassignOrder(TestConstants.orderId1));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<OrderUnassigned>());
      expect(fakeDataSource.isOrderAssigned(TestConstants.orderId1), false);
      expect(
        fakeDataSource.getOrderStatus(TestConstants.orderId1),
        'preparing',
      );
      expect(
        fakeDataSource.getDriverActiveOrdersCount(TestConstants.driverId1),
        0,
      );

      // 3. Assign to second driver
      bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId1,
          driverId: TestConstants.driverId2,
          assignedBy: TestConstants.assignedBy,
          notes: 'Reassigned to different driver',
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<OrderAssigned>());

      final reassignedState = bloc.state as OrderAssigned;
      expect(reassignedState.assignment.driverId, TestConstants.driverId2);
      expect(
        fakeDataSource.getDriverActiveOrdersCount(TestConstants.driverId2),
        1,
      );
    });

    test('should handle multiple orders assigned to single driver', () async {
      // Setup
      final driver = TestDriverBuilder()
          .withIsActive(true)
          .withIsAvailable(true)
          .buildModel();
      fakeDataSource.setupDrivers([driver]);
      fakeDataSource.setupOrderStatus(TestConstants.orderId1, 'preparing');
      fakeDataSource.setupOrderStatus(TestConstants.orderId2, 'preparing');
      fakeDataSource.setupOrderStatus(TestConstants.orderId3, 'preparing');

      // 1. Assign first order
      bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId1,
          driverId: TestConstants.driverId1,
          assignedBy: TestConstants.assignedBy,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<OrderAssigned>());

      // 2. Assign second order
      bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId2,
          driverId: TestConstants.driverId1,
          assignedBy: TestConstants.assignedBy,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<OrderAssigned>());

      // 3. Assign third order
      bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId3,
          driverId: TestConstants.driverId1,
          assignedBy: TestConstants.assignedBy,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<OrderAssigned>());

      // 4. Verify driver has 3 active orders
      expect(
        fakeDataSource.getDriverActiveOrdersCount(TestConstants.driverId1),
        3,
      );

      // 5. Load assignments for this driver
      bloc.add(
        LoadOrderAssignments(
          merchandiserId: TestConstants.merchandiserId,
          driverId: TestConstants.driverId1,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<OrderAssignmentsLoaded>());

      final assignmentsState = bloc.state as OrderAssignmentsLoaded;
      expect(assignmentsState.assignments.length, 3);
      expect(
        assignmentsState.assignments.every(
          (a) => a.driverId == TestConstants.driverId1,
        ),
        true,
      );

      // 6. Unassign one order
      bloc.add(UnassignOrder(TestConstants.orderId2));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<OrderUnassigned>());

      // 7. Verify driver now has 2 active orders
      expect(
        fakeDataSource.getDriverActiveOrdersCount(TestConstants.driverId1),
        2,
      );
    });
  });

  group('Statistics Workflow', () {
    test('should show correct statistics as assignments change', () async {
      // Setup
      final drivers = [
        TestDriverBuilder()
            .withId(TestConstants.driverId1)
            .withIsActive(true)
            .withIsAvailable(true)
            .buildModel(),
        TestDriverBuilder()
            .withId(TestConstants.driverId2)
            .withIsActive(true)
            .withIsAvailable(true)
            .buildModel(),
      ];
      fakeDataSource.setupDrivers(drivers);
      fakeDataSource.setupOrderStatus(TestConstants.orderId1, 'preparing');
      fakeDataSource.setupOrderStatus(TestConstants.orderId2, 'preparing');

      // 1. Check initial statistics
      bloc.add(LoadDeliveryStatistics(TestConstants.merchandiserId));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<DeliveryStatisticsLoaded>());

      var statsState = bloc.state as DeliveryStatisticsLoaded;
      expect(statsState.statistics['total_drivers'], 2);
      expect(statsState.statistics['active_drivers'], 2);
      expect(statsState.statistics['available_drivers'], 2);
      expect(statsState.statistics['total_assignments'], 0);
      expect(statsState.statistics['active_deliveries'], 0);

      // 2. Assign first order
      bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId1,
          driverId: TestConstants.driverId1,
          assignedBy: TestConstants.assignedBy,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // 3. Check statistics after first assignment
      bloc.add(LoadDeliveryStatistics(TestConstants.merchandiserId));
      await Future.delayed(const Duration(milliseconds: 100));

      statsState = bloc.state as DeliveryStatisticsLoaded;
      expect(statsState.statistics['total_assignments'], 1);
      expect(statsState.statistics['active_deliveries'], 1);

      // 4. Assign second order
      bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId2,
          driverId: TestConstants.driverId2,
          assignedBy: TestConstants.assignedBy,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // 5. Check statistics after second assignment
      bloc.add(LoadDeliveryStatistics(TestConstants.merchandiserId));
      await Future.delayed(const Duration(milliseconds: 100));

      statsState = bloc.state as DeliveryStatisticsLoaded;
      expect(statsState.statistics['total_assignments'], 2);
      expect(statsState.statistics['active_deliveries'], 2);

      // 6. Unassign one order
      bloc.add(UnassignOrder(TestConstants.orderId1));
      await Future.delayed(const Duration(milliseconds: 100));

      // 7. Check final statistics
      bloc.add(LoadDeliveryStatistics(TestConstants.merchandiserId));
      await Future.delayed(const Duration(milliseconds: 100));

      statsState = bloc.state as DeliveryStatisticsLoaded;
      expect(statsState.statistics['total_assignments'], 1);
      expect(statsState.statistics['active_deliveries'], 1);
    });
  });

  group('Error Recovery Scenarios', () {
    test('should handle errors gracefully and allow retry', () async {
      // Setup
      fakeDataSource.throwException('Network error');

      // 1. Try to load drivers (fails)
      bloc.add(LoadDrivers(TestConstants.merchandiserId));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<DeliveryError>());

      var errorState = bloc.state as DeliveryError;
      expect(errorState.message, 'Network error');

      // 2. Fix the error
      fakeDataSource.reset();
      final driver = TestDriverBuilder().buildModel();
      fakeDataSource.setupDrivers([driver]);

      // 3. Retry (succeeds)
      bloc.add(LoadDrivers(TestConstants.merchandiserId));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<DriversLoaded>());

      final driversState = bloc.state as DriversLoaded;
      expect(driversState.drivers.length, 1);
    });

    test('should handle assignment validation errors correctly', () async {
      // Setup
      final driver = TestDriverBuilder()
          .withIsActive(true)
          .withIsAvailable(true)
          .buildModel();
      fakeDataSource.setupDrivers([driver]);

      // 1. Try to assign with wrong order status
      fakeDataSource.setupOrderStatus(TestConstants.orderId1, 'pending');
      bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId1,
          driverId: TestConstants.driverId1,
          assignedBy: TestConstants.assignedBy,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<DeliveryError>());

      // 2. Fix order status
      fakeDataSource.setupOrderStatus(TestConstants.orderId1, 'preparing');

      // 3. Retry assignment (succeeds)
      bloc.add(
        AssignOrderToDriver(
          orderId: TestConstants.orderId1,
          driverId: TestConstants.driverId1,
          assignedBy: TestConstants.assignedBy,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<OrderAssigned>());
    });
  });

  group('Filtering and Querying', () {
    test('should filter assignments by multiple criteria', () async {
      // Setup
      final drivers = [
        TestDriverBuilder().withId(TestConstants.driverId1).buildModel(),
        TestDriverBuilder().withId(TestConstants.driverId2).buildModel(),
      ];
      fakeDataSource.setupDrivers(drivers);

      final assignments = [
        // Driver 1 - Active
        TestOrderAssignmentBuilder()
            .withId('assignment-1')
            .withOrderId('order-1')
            .withDriverId(TestConstants.driverId1)
            .withDeliveryStatus('assigned')
            .buildModel(),
        // Driver 1 - Active
        TestOrderAssignmentBuilder()
            .withId('assignment-2')
            .withOrderId('order-2')
            .withDriverId(TestConstants.driverId1)
            .withDeliveryStatus('picked_up')
            .buildModel(),
        // Driver 1 - Completed
        TestOrderAssignmentBuilder()
            .withId('assignment-3')
            .withOrderId('order-3')
            .withDriverId(TestConstants.driverId1)
            .withDeliveryStatus('delivered')
            .buildModel(),
        // Driver 2 - Active
        TestOrderAssignmentBuilder()
            .withId('assignment-4')
            .withOrderId('order-4')
            .withDriverId(TestConstants.driverId2)
            .withDeliveryStatus('on_the_way')
            .buildModel(),
        // Driver 2 - Completed
        TestOrderAssignmentBuilder()
            .withId('assignment-5')
            .withOrderId('order-5')
            .withDriverId(TestConstants.driverId2)
            .withDeliveryStatus('delivered')
            .buildModel(),
      ];
      fakeDataSource.setupAssignments(assignments);

      // Test 1: All assignments
      bloc.add(
        LoadOrderAssignments(merchandiserId: TestConstants.merchandiserId),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, isA<OrderAssignmentsLoaded>());
      var state = bloc.state as OrderAssignmentsLoaded;
      expect(state.assignments.length, 5);

      // Test 2: Only active
      bloc.add(
        LoadOrderAssignments(
          merchandiserId: TestConstants.merchandiserId,
          onlyActive: true,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      state = bloc.state as OrderAssignmentsLoaded;
      expect(state.assignments.length, 3);

      // Test 3: Driver 1 only
      bloc.add(
        LoadOrderAssignments(
          merchandiserId: TestConstants.merchandiserId,
          driverId: TestConstants.driverId1,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      state = bloc.state as OrderAssignmentsLoaded;
      expect(state.assignments.length, 3);

      // Test 4: Driver 1 + active only
      bloc.add(
        LoadOrderAssignments(
          merchandiserId: TestConstants.merchandiserId,
          driverId: TestConstants.driverId1,
          onlyActive: true,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      state = bloc.state as OrderAssignmentsLoaded;
      expect(state.assignments.length, 2);

      // Test 5: Driver 2 + active only
      bloc.add(
        LoadOrderAssignments(
          merchandiserId: TestConstants.merchandiserId,
          driverId: TestConstants.driverId2,
          onlyActive: true,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      state = bloc.state as OrderAssignmentsLoaded;
      expect(state.assignments.length, 1);
      expect(state.assignments.first.deliveryStatus, 'on_the_way');
    });
  });
}
