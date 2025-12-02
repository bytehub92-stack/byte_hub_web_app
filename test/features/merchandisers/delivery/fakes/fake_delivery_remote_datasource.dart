// test/features/delivery/fakes/fake_delivery_remote_datasource.dart

import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/features/merchandisers/delivery/data/datasources/delivery_remote_datasource.dart';
import 'package:admin_panel/features/merchandisers/delivery/data/models/driver_model.dart';
import 'package:admin_panel/features/merchandisers/delivery/data/models/order_assignment_model.dart';

import '../helpers/test_helpers.dart';

class FakeDeliveryRemoteDataSource implements DeliveryRemoteDataSource {
  final List<DriverModel> _drivers = [];
  final List<OrderAssignmentModel> _assignments = [];
  final Map<String, String> _merchandiserCodes = {};

  // Track order statuses for validation
  final Map<String, String> _orderStatuses = {};

  bool shouldThrowException = false;
  String? exceptionMessage;

  // Setup initial data
  void setupDrivers(List<DriverModel> drivers) {
    _drivers.clear();
    _drivers.addAll(drivers);
  }

  void setupAssignments(List<OrderAssignmentModel> assignments) {
    _assignments.clear();
    _assignments.addAll(assignments);
  }

  void setupMerchandiserCode(String merchandiserId, String code) {
    _merchandiserCodes[merchandiserId] = code;
  }

  void setupOrderStatus(String orderId, String status) {
    _orderStatuses[orderId] = status;
  }

  void reset() {
    _drivers.clear();
    _assignments.clear();
    _merchandiserCodes.clear();
    _orderStatuses.clear();
    shouldThrowException = false;
    exceptionMessage = null;
  }

  void throwException(String message) {
    shouldThrowException = true;
    exceptionMessage = message;
  }

  void _checkException() {
    if (shouldThrowException) {
      throw ServerException(message: exceptionMessage ?? 'Test exception');
    }
  }

  @override
  Future<List<DriverModel>> getDrivers(String merchandiserId) async {
    _checkException();

    return _drivers
        .where((driver) => driver.merchandiserId == merchandiserId)
        .toList();
  }

  @override
  Future<DriverModel> getDriverById(String driverId) async {
    _checkException();

    try {
      return _drivers.firstWhere((driver) => driver.id == driverId);
    } catch (e) {
      throw ServerException(message: 'Driver not found with id: $driverId');
    }
  }

  @override
  Future<OrderAssignmentModel> assignOrderToDriver({
    required String orderId,
    required String driverId,
    required String assignedBy,
    String? notes,
  }) async {
    _checkException();

    // Validate: Check if order is already assigned
    final existingAssignment =
        _assignments.where((a) => a.orderId == orderId).firstOrNull;

    if (existingAssignment != null) {
      throw ServerException(message: 'Order is already assigned to a driver');
    }

    // Validate: Check if driver exists
    final driver = _drivers.where((d) => d.id == driverId).firstOrNull;
    if (driver == null) {
      throw ServerException(message: 'Driver not found with id: $driverId');
    }

    // Validate: Check if driver is inactive
    if (!driver.isActive) {
      throw ServerException(
        message: 'Cannot assign order to inactive driver',
      );
    }

    // Validate: Check if driver is unavailable
    if (!driver.isAvailable) {
      throw ServerException(
        message: 'Cannot assign order to unavailable driver',
      );
    }

    // Validate: Check order status
    final orderStatus = _orderStatuses[orderId] ?? 'preparing';
    if (orderStatus != 'preparing') {
      throw ServerException(
        message:
            'Order must be in "preparing" status to be assigned. Current status: $orderStatus',
      );
    }

    // Create assignment
    final assignment = TestOrderAssignmentBuilder()
        .withId('assignment-${DateTime.now().millisecondsSinceEpoch}')
        .withOrderId(orderId)
        .withDriverId(driverId)
        .withNotes(notes)
        .withDeliveryStatus('assigned')
        .withOrderStatus('on_the_way')
        .buildModel();

    _assignments.add(assignment);

    // Update order status to on_the_way
    _orderStatuses[orderId] = 'on_the_way';

    // Update driver's active orders count
    final driverIndex = _drivers.indexWhere((d) => d.id == driverId);
    if (driverIndex != -1) {
      final updatedDriver = DriverModel(
        id: driver.id,
        profileId: driver.profileId,
        merchandiserId: driver.merchandiserId,
        fullName: driver.fullName,
        email: driver.email,
        phoneNumber: driver.phoneNumber,
        vehicleType: driver.vehicleType,
        vehicleNumber: driver.vehicleNumber,
        licenseNumber: driver.licenseNumber,
        isAvailable: driver.isAvailable,
        isActive: driver.isActive,
        createdAt: driver.createdAt,
        updatedAt: DateTime.now(),
        activeOrdersCount: (driver.activeOrdersCount ?? 0) + 1,
        completedOrdersCount: driver.completedOrdersCount,
      );
      _drivers[driverIndex] = updatedDriver;
    }

    return assignment;
  }

  @override
  Future<List<OrderAssignmentModel>> getOrderAssignments({
    required String merchandiserId,
    String? driverId,
    bool? onlyActive,
  }) async {
    _checkException();

    var assignments = _assignments.where((assignment) {
      // Get driver for this assignment
      final driver =
          _drivers.where((d) => d.id == assignment.driverId).firstOrNull;

      return driver?.merchandiserId == merchandiserId;
    }).toList();

    // Filter by driver if provided
    if (driverId != null) {
      assignments = assignments.where((a) => a.driverId == driverId).toList();
    }

    // Filter only active assignments if requested
    if (onlyActive == true) {
      assignments = assignments.where((a) {
        return ['assigned', 'picked_up', 'on_the_way']
            .contains(a.deliveryStatus);
      }).toList();
    }

    return assignments;
  }

  @override
  Future<void> unassignOrder(String orderId) async {
    _checkException();

    // Find the assignment
    final assignmentIndex =
        _assignments.indexWhere((a) => a.orderId == orderId);

    if (assignmentIndex == -1) {
      throw ServerException(
          message: 'Assignment not found for order: $orderId');
    }

    final assignment = _assignments[assignmentIndex];

    // Validate: Cannot unassign a delivered order
    if (assignment.deliveryStatus == 'delivered') {
      throw ServerException(message: 'Cannot unassign a delivered order');
    }

    // Update driver's active orders count
    final driver =
        _drivers.where((d) => d.id == assignment.driverId).firstOrNull;

    if (driver != null) {
      final driverIndex = _drivers.indexWhere((d) => d.id == driver.id);
      final updatedDriver = DriverModel(
        id: driver.id,
        profileId: driver.profileId,
        merchandiserId: driver.merchandiserId,
        fullName: driver.fullName,
        email: driver.email,
        phoneNumber: driver.phoneNumber,
        vehicleType: driver.vehicleType,
        vehicleNumber: driver.vehicleNumber,
        licenseNumber: driver.licenseNumber,
        isAvailable: driver.isAvailable,
        isActive: driver.isActive,
        createdAt: driver.createdAt,
        updatedAt: DateTime.now(),
        activeOrdersCount: (driver.activeOrdersCount ?? 0) - 1,
        completedOrdersCount: driver.completedOrdersCount,
      );
      _drivers[driverIndex] = updatedDriver;
    }

    // Remove assignment
    _assignments.removeAt(assignmentIndex);

    // Update order status back to preparing
    _orderStatuses[orderId] = 'preparing';
  }

  @override
  Future<Map<String, dynamic>> getDeliveryStatistics(
    String merchandiserId,
  ) async {
    _checkException();

    final merchantDrivers =
        _drivers.where((d) => d.merchandiserId == merchandiserId).toList();

    final totalDrivers = merchantDrivers.length;
    final activeDrivers = merchantDrivers.where((d) => d.isActive).length;
    final availableDrivers =
        merchantDrivers.where((d) => d.isAvailable && d.isActive).length;

    // Get assignments for this merchandiser
    final merchantAssignments = _assignments.where((assignment) {
      final driver =
          _drivers.where((d) => d.id == assignment.driverId).firstOrNull;
      return driver?.merchandiserId == merchandiserId;
    }).toList();

    final totalAssignments = merchantAssignments.length;
    final activeDeliveries = merchantAssignments
        .where((a) =>
            ['assigned', 'picked_up', 'on_the_way'].contains(a.deliveryStatus))
        .length;
    final completedDeliveries = merchantAssignments
        .where((a) => a.deliveryStatus == 'delivered')
        .length;

    return {
      'total_drivers': totalDrivers,
      'active_drivers': activeDrivers,
      'available_drivers': availableDrivers,
      'total_assignments': totalAssignments,
      'active_deliveries': activeDeliveries,
      'completed_deliveries': completedDeliveries,
    };
  }

  @override
  Future<String> getMerchandiserCode(String merchandiserId) async {
    _checkException();

    final code = _merchandiserCodes[merchandiserId];
    if (code == null) {
      throw ServerException(
        message: 'Merchandiser code not found for id: $merchandiserId',
      );
    }
    return code;
  }

  // Helper methods for testing
  bool isOrderAssigned(String orderId) {
    return _assignments.any((a) => a.orderId == orderId);
  }

  int getDriverActiveOrdersCount(String driverId) {
    final driver = _drivers.where((d) => d.id == driverId).firstOrNull;
    return driver?.activeOrdersCount ?? 0;
  }

  String? getOrderStatus(String orderId) {
    return _orderStatuses[orderId];
  }

  OrderAssignmentModel? getAssignmentByOrderId(String orderId) {
    return _assignments.where((a) => a.orderId == orderId).firstOrNull;
  }

  List<OrderAssignmentModel> getAssignmentsByDriverId(String driverId) {
    return _assignments.where((a) => a.driverId == driverId).toList();
  }
}
