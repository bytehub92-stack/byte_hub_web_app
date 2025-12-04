// test/features/delivery/data/repositories/delivery_repository_impl_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/merchandisers/delivery/data/repositories/delivery_repository_impl.dart';
import 'package:admin_panel/features/merchandisers/delivery/domain/entities/driver.dart';
import 'package:admin_panel/features/merchandisers/delivery/domain/entities/order_assignment.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_delivery_remote_datasource.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late DeliveryRepositoryImpl repository;
  late FakeDeliveryRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeDeliveryRemoteDataSource();
    repository = DeliveryRepositoryImpl(remoteDataSource: fakeDataSource);
  });

  tearDown(() {
    fakeDataSource.reset();
  });

  group('getDrivers', () {
    test('should return list of drivers for merchandiser', () async {
      // Arrange
      final drivers = [
        TestDriverBuilder().withId('driver-1').buildModel(),
        TestDriverBuilder().withId('driver-2').buildModel(),
      ];
      fakeDataSource.setupDrivers(drivers);

      // Act
      final result = await repository.getDrivers(TestConstants.merchandiserId);

      // Assert
      expect(result, isA<Right<Failure, List<Driver>>>());
      result.fold(
        (failure) => fail('Should return drivers'),
        (driverList) {
          expect(driverList.length, 2);
          expect(driverList[0].id, 'driver-1');
          expect(driverList[1].id, 'driver-2');
        },
      );
    });

    test('should return empty list when no drivers exist', () async {
      // Arrange
      fakeDataSource.setupDrivers([]);

      // Act
      final result = await repository.getDrivers(TestConstants.merchandiserId);

      // Assert
      expect(result, isA<Right<Failure, List<Driver>>>());
      result.fold(
        (failure) => fail('Should return empty list'),
        (driverList) => expect(driverList.isEmpty, true),
      );
    });

    test('should filter drivers by merchandiser ID', () async {
      // Arrange
      final drivers = [
        TestDriverBuilder().withId('driver-1').buildModel(),
        TestDriverBuilder().withId('driver-2').buildModel(),
      ];
      // Manually modify merchandiser_id for second driver
      final driver2Modified =
          TestDriverBuilder().withId('driver-2').buildModel();

      fakeDataSource.setupDrivers([
        drivers[0],
        driver2Modified,
      ]);

      // Act
      final result = await repository.getDrivers(TestConstants.merchandiserId);

      // Assert
      result.fold(
        (failure) => fail('Should return drivers'),
        (driverList) {
          expect(
              driverList.every(
                (d) => d.merchandiserId == TestConstants.merchandiserId,
              ),
              true);
        },
      );
    });

    test('should return ServerFailure when exception occurs', () async {
      // Arrange
      fakeDataSource.throwException('Database connection failed');

      // Act
      final result = await repository.getDrivers(TestConstants.merchandiserId);

      // Assert
      expect(result, isA<Left<Failure, List<Driver>>>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Database connection failed');
        },
        (drivers) => fail('Should return failure'),
      );
    });
  });

  group('getDriverById', () {
    test('should return driver when found', () async {
      // Arrange
      final driver = TestDriverBuilder().buildModel();
      fakeDataSource.setupDrivers([driver]);

      // Act
      final result = await repository.getDriverById(TestConstants.driverId1);

      // Assert
      expect(result, isA<Right<Failure, Driver>>());
      result.fold(
        (failure) => fail('Should return driver'),
        (returnedDriver) {
          expect(returnedDriver.id, TestConstants.driverId1);
          expect(returnedDriver.fullName, 'John Doe');
        },
      );
    });

    test('should return ServerFailure when driver not found', () async {
      // Arrange
      fakeDataSource.setupDrivers([]);

      // Act
      final result = await repository.getDriverById('non-existent-id');

      // Assert
      expect(result, isA<Left<Failure, Driver>>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Driver not found'));
        },
        (driver) => fail('Should return failure'),
      );
    });
  });

  group('assignOrderToDriver', () {
    setUp(() {
      // Setup a valid driver and order status
      final driver = TestDriverBuilder()
          .withIsActive(true)
          .withIsAvailable(true)
          .buildModel();
      fakeDataSource.setupDrivers([driver]);
      fakeDataSource.setupOrderStatus(TestConstants.orderId1, 'preparing');
    });

    test('should successfully assign order to driver', () async {
      // Act
      final result = await repository.assignOrderToDriver(
        orderId: TestConstants.orderId1,
        driverId: TestConstants.driverId1,
        assignedBy: TestConstants.assignedBy,
        notes: 'Deliver before 5 PM',
      );

      // Assert
      expect(result, isA<Right<Failure, OrderAssignment>>());
      result.fold(
        (failure) => fail('Should assign order successfully'),
        (assignment) {
          expect(assignment.orderId, TestConstants.orderId1);
          expect(assignment.driverId, TestConstants.driverId1);
          expect(assignment.deliveryStatus, 'assigned');
          expect(assignment.notes, 'Deliver before 5 PM');
        },
      );

      // Verify order status changed to on_the_way
      expect(
        fakeDataSource.getOrderStatus(TestConstants.orderId1),
        'on_the_way',
      );

      // Verify driver's active orders increased
      expect(
        fakeDataSource.getDriverActiveOrdersCount(TestConstants.driverId1),
        1,
      );
    });

    test('should fail when order already assigned', () async {
      // Arrange - Assign order first time
      await repository.assignOrderToDriver(
        orderId: TestConstants.orderId1,
        driverId: TestConstants.driverId1,
        assignedBy: TestConstants.assignedBy,
      );

      // Act - Try to assign again
      final result = await repository.assignOrderToDriver(
        orderId: TestConstants.orderId1,
        driverId: TestConstants.driverId2,
        assignedBy: TestConstants.assignedBy,
      );

      // Assert
      expect(result, isA<Left<Failure, OrderAssignment>>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('already assigned'));
        },
        (assignment) => fail('Should fail on duplicate assignment'),
      );
    });

    test('should fail when driver is inactive', () async {
      // Arrange
      final inactiveDriver = TestDriverBuilder()
          .withIsActive(false)
          .withIsAvailable(true)
          .buildModel();
      fakeDataSource.setupDrivers([inactiveDriver]);

      // Act
      final result = await repository.assignOrderToDriver(
        orderId: TestConstants.orderId1,
        driverId: TestConstants.driverId1,
        assignedBy: TestConstants.assignedBy,
      );

      // Assert
      expect(result, isA<Left<Failure, OrderAssignment>>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('inactive driver'));
        },
        (assignment) => fail('Should not assign to inactive driver'),
      );
    });

    test('should fail when driver is unavailable', () async {
      // Arrange
      final unavailableDriver = TestDriverBuilder()
          .withIsActive(true)
          .withIsAvailable(false)
          .buildModel();
      fakeDataSource.setupDrivers([unavailableDriver]);

      // Act
      final result = await repository.assignOrderToDriver(
        orderId: TestConstants.orderId1,
        driverId: TestConstants.driverId1,
        assignedBy: TestConstants.assignedBy,
      );

      // Assert
      expect(result, isA<Left<Failure, OrderAssignment>>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('unavailable driver'));
        },
        (assignment) => fail('Should not assign to unavailable driver'),
      );
    });

    test('should fail when order status is not "preparing"', () async {
      // Arrange
      fakeDataSource.setupOrderStatus(TestConstants.orderId1, 'pending');

      // Act
      final result = await repository.assignOrderToDriver(
        orderId: TestConstants.orderId1,
        driverId: TestConstants.driverId1,
        assignedBy: TestConstants.assignedBy,
      );

      // Assert
      expect(result, isA<Left<Failure, OrderAssignment>>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('must be in "preparing" status'));
          expect(failure.message, contains('pending'));
        },
        (assignment) => fail('Should not assign order with wrong status'),
      );
    });

    test('should fail when driver does not exist', () async {
      // Arrange
      fakeDataSource.setupDrivers([]);

      // Act
      final result = await repository.assignOrderToDriver(
        orderId: TestConstants.orderId1,
        driverId: 'non-existent-driver',
        assignedBy: TestConstants.assignedBy,
      );

      // Assert
      expect(result, isA<Left<Failure, OrderAssignment>>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Driver not found'));
        },
        (assignment) => fail('Should fail when driver does not exist'),
      );
    });

    test('should allow assigning multiple orders to same driver', () async {
      // Arrange
      fakeDataSource.setupOrderStatus(TestConstants.orderId2, 'preparing');

      // Act - Assign first order
      final result1 = await repository.assignOrderToDriver(
        orderId: TestConstants.orderId1,
        driverId: TestConstants.driverId1,
        assignedBy: TestConstants.assignedBy,
      );

      // Act - Assign second order to same driver
      final result2 = await repository.assignOrderToDriver(
        orderId: TestConstants.orderId2,
        driverId: TestConstants.driverId1,
        assignedBy: TestConstants.assignedBy,
      );

      // Assert both succeeded
      expect(result1, isA<Right<Failure, OrderAssignment>>());
      expect(result2, isA<Right<Failure, OrderAssignment>>());

      // Verify driver has 2 active orders
      expect(
        fakeDataSource.getDriverActiveOrdersCount(TestConstants.driverId1),
        2,
      );

      // Verify both assignments exist
      final assignments = fakeDataSource.getAssignmentsByDriverId(
        TestConstants.driverId1,
      );
      expect(assignments.length, 2);
    });
  });

  group('getOrderAssignments', () {
    setUp(() {
      final drivers = [
        TestDriverBuilder().withId(TestConstants.driverId1).buildModel(),
        TestDriverBuilder().withId(TestConstants.driverId2).buildModel(),
      ];
      fakeDataSource.setupDrivers(drivers);

      final assignments = [
        TestOrderAssignmentBuilder()
            .withId('assignment-1')
            .withOrderId('order-1')
            .withDriverId(TestConstants.driverId1)
            .withDeliveryStatus('assigned')
            .buildModel(),
        TestOrderAssignmentBuilder()
            .withId('assignment-2')
            .withOrderId('order-2')
            .withDriverId(TestConstants.driverId1)
            .withDeliveryStatus('picked_up')
            .buildModel(),
        TestOrderAssignmentBuilder()
            .withId('assignment-3')
            .withOrderId('order-3')
            .withDriverId(TestConstants.driverId2)
            .withDeliveryStatus('delivered')
            .buildModel(),
      ];
      fakeDataSource.setupAssignments(assignments);
    });

    test('should return all assignments for merchandiser', () async {
      // Act
      final result = await repository.getOrderAssignments(
        merchandiserId: TestConstants.merchandiserId,
      );

      // Assert
      expect(result, isA<Right<Failure, List<OrderAssignment>>>());
      result.fold(
        (failure) => fail('Should return assignments'),
        (assignments) => expect(assignments.length, 3),
      );
    });

    test('should filter assignments by driver ID', () async {
      // Act
      final result = await repository.getOrderAssignments(
        merchandiserId: TestConstants.merchandiserId,
        driverId: TestConstants.driverId1,
      );

      // Assert
      result.fold(
        (failure) => fail('Should return assignments'),
        (assignments) {
          expect(assignments.length, 2);
          expect(
            assignments.every((a) => a.driverId == TestConstants.driverId1),
            true,
          );
        },
      );
    });

    test('should filter only active assignments', () async {
      // Act
      final result = await repository.getOrderAssignments(
        merchandiserId: TestConstants.merchandiserId,
        onlyActive: true,
      );

      // Assert
      result.fold(
        (failure) => fail('Should return active assignments'),
        (assignments) {
          expect(assignments.length, 2);
          expect(
            assignments.every((a) => ['assigned', 'picked_up', 'on_the_way']
                .contains(a.deliveryStatus)),
            true,
          );
        },
      );
    });

    test('should combine driver filter and active filter', () async {
      // Act
      final result = await repository.getOrderAssignments(
        merchandiserId: TestConstants.merchandiserId,
        driverId: TestConstants.driverId1,
        onlyActive: true,
      );

      // Assert
      result.fold(
        (failure) => fail('Should return filtered assignments'),
        (assignments) {
          expect(assignments.length, 2);
          expect(
            assignments.every((a) =>
                a.driverId == TestConstants.driverId1 &&
                ['assigned', 'picked_up'].contains(a.deliveryStatus)),
            true,
          );
        },
      );
    });

    test('should return empty list when no assignments match', () async {
      // Act
      final result = await repository.getOrderAssignments(
        merchandiserId: TestConstants.merchandiserId,
        driverId: 'non-existent-driver',
      );

      // Assert
      result.fold(
        (failure) => fail('Should return empty list'),
        (assignments) => expect(assignments.isEmpty, true),
      );
    });
  });

  group('unassignOrder', () {
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

    test('should successfully unassign order', () async {
      // Act
      final result = await repository.unassignOrder(TestConstants.orderId1);

      // Assert
      expect(result, isA<Right<Failure, void>>());

      // Verify assignment removed
      expect(
        fakeDataSource.isOrderAssigned(TestConstants.orderId1),
        false,
      );

      // Verify order status changed back to preparing
      expect(
        fakeDataSource.getOrderStatus(TestConstants.orderId1),
        'preparing',
      );

      // Verify driver's active orders decreased
      expect(
        fakeDataSource.getDriverActiveOrdersCount(TestConstants.driverId1),
        0,
      );
    });

    test('should fail when trying to unassign delivered order', () async {
      // Arrange
      final deliveredAssignment = TestOrderAssignmentBuilder()
          .withOrderId('delivered-order')
          .withDriverId(TestConstants.driverId1)
          .withDeliveryStatus('delivered')
          .buildModel();
      fakeDataSource.setupAssignments([deliveredAssignment]);

      // Act
      final result = await repository.unassignOrder('delivered-order');

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(
              failure.message, contains('Cannot unassign a delivered order'));
        },
        (_) => fail('Should not unassign delivered order'),
      );
    });

    test('should fail when assignment does not exist', () async {
      // Act
      final result = await repository.unassignOrder('non-existent-order');

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Assignment not found'));
        },
        (_) => fail('Should fail when assignment does not exist'),
      );
    });
  });

  group('getDeliveryStatistics', () {
    test('should return correct statistics', () async {
      // Arrange
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
            .withIsAvailable(true)
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
            .withDeliveryStatus('on_the_way')
            .buildModel(),
        TestOrderAssignmentBuilder()
            .withDriverId('driver-2')
            .withDeliveryStatus('delivered')
            .buildModel(),
        TestOrderAssignmentBuilder()
            .withDriverId('driver-2')
            .withDeliveryStatus('delivered')
            .buildModel(),
      ];
      fakeDataSource.setupAssignments(assignments);

      // Act
      final result = await repository.getDeliveryStatistics(
        TestConstants.merchandiserId,
      );

      // Assert
      expect(result, isA<Right<Failure, Map<String, dynamic>>>());
      result.fold(
        (failure) => fail('Should return statistics'),
        (stats) {
          expect(stats['total_drivers'], 3);
          expect(stats['active_drivers'], 2); // driver-1 and driver-2
          expect(stats['available_drivers'], 1); // only driver-1
          expect(stats['total_assignments'], 5);
          expect(
              stats['active_deliveries'], 3); // assigned, picked_up, on_the_way
          expect(stats['completed_deliveries'], 2); // delivered
        },
      );
    });

    test('should handle zero statistics', () async {
      // Arrange - No drivers or assignments
      fakeDataSource.setupDrivers([]);
      fakeDataSource.setupAssignments([]);

      // Act
      final result = await repository.getDeliveryStatistics(
        TestConstants.merchandiserId,
      );

      // Assert
      result.fold(
        (failure) => fail('Should return empty statistics'),
        (stats) {
          expect(stats['total_drivers'], 0);
          expect(stats['active_drivers'], 0);
          expect(stats['available_drivers'], 0);
          expect(stats['total_assignments'], 0);
          expect(stats['active_deliveries'], 0);
          expect(stats['completed_deliveries'], 0);
        },
      );
    });
  });

  group('getMerchandiserCode', () {
    test('should return merchandiser code', () async {
      // Arrange
      fakeDataSource.setupMerchandiserCode(
        TestConstants.merchandiserId,
        TestConstants.merchandiserCode,
      );

      // Act
      final result = await repository.getMerchandiserCode(
        TestConstants.merchandiserId,
      );

      // Assert
      expect(result, isA<Right<Failure, String>>());
      result.fold(
        (failure) => fail('Should return code'),
        (code) => expect(code, TestConstants.merchandiserCode),
      );
    });

    test('should return failure when code not found', () async {
      // Act
      final result = await repository.getMerchandiserCode('non-existent-id');

      // Assert
      expect(result, isA<Left<Failure, String>>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('not found'));
        },
        (code) => fail('Should return failure'),
      );
    });
  });
}
