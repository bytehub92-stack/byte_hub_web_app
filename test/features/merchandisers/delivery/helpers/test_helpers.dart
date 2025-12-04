// test/features/delivery/helpers/test_helpers.dart

// ==================== Test Constants ====================
import 'package:admin_panel/features/merchandisers/delivery/data/models/driver_model.dart';
import 'package:admin_panel/features/merchandisers/delivery/data/models/order_assignment_model.dart';
import 'package:admin_panel/features/merchandisers/delivery/domain/entities/driver.dart';
import 'package:admin_panel/features/merchandisers/delivery/domain/entities/order_assignment.dart';

class TestConstants {
  static const String merchandiserId = 'test-merchandiser-id-123';
  static const String merchandiserCode = 'MERCH001';
  static const String driverId1 = 'driver-id-1';
  static const String driverId2 = 'driver-id-2';
  static const String driverId3 = 'driver-id-3';
  static const String profileId1 = 'profile-id-1';
  static const String profileId2 = 'profile-id-2';
  static const String profileId3 = 'profile-id-3';
  static const String orderId1 = 'order-id-1';
  static const String orderId2 = 'order-id-2';
  static const String orderId3 = 'order-id-3';
  static const String assignmentId1 = 'assignment-id-1';
  static const String assignmentId2 = 'assignment-id-2';
  static const String assignedBy = 'merchandiser-user-id-123';
}

// ==================== Test Data Builders ====================
class TestDriverBuilder {
  String id = TestConstants.driverId1;
  String profileId = TestConstants.profileId1;
  String merchandiserId = TestConstants.merchandiserId;
  String fullName = 'John Doe';
  String? email = 'john@example.com';
  String? phoneNumber = '+1234567890';
  String? vehicleType = 'Car';
  String? vehicleNumber = 'ABC-123';
  String? licenseNumber = 'LIC-123';
  bool isAvailable = true;
  bool isActive = true;
  DateTime createdAt = DateTime(2024, 1, 1);
  DateTime updatedAt = DateTime(2024, 1, 1);
  int? activeOrdersCount = 0;
  int? completedOrdersCount = 5;

  TestDriverBuilder();

  TestDriverBuilder withId(String id) {
    this.id = id;
    return this;
  }

  TestDriverBuilder withProfileId(String profileId) {
    this.profileId = profileId;
    return this;
  }

  TestDriverBuilder withFullName(String name) {
    this.fullName = name;
    return this;
  }

  TestDriverBuilder withIsAvailable(bool available) {
    this.isAvailable = available;
    return this;
  }

  TestDriverBuilder withIsActive(bool active) {
    this.isActive = active;
    return this;
  }

  TestDriverBuilder withActiveOrders(int count) {
    this.activeOrdersCount = count;
    return this;
  }

  TestDriverBuilder withCompletedOrders(int count) {
    this.completedOrdersCount = count;
    return this;
  }

  TestDriverBuilder withVehicleInfo(
      String? type, String? vehicleNumber, String? licenseNumber) {
    this.vehicleType = type;
    this.vehicleNumber = vehicleNumber;
    this.licenseNumber = licenseNumber;
    return this;
  }

  Driver build() {
    return Driver(
      id: id,
      profileId: profileId,
      merchandiserId: merchandiserId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      licenseNumber: licenseNumber,
      isAvailable: isAvailable,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      activeOrdersCount: activeOrdersCount,
      completedOrdersCount: completedOrdersCount,
    );
  }

  DriverModel buildModel() {
    return DriverModel(
      id: id,
      profileId: profileId,
      merchandiserId: merchandiserId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      licenseNumber: licenseNumber,
      isAvailable: isAvailable,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      activeOrdersCount: activeOrdersCount,
      completedOrdersCount: completedOrdersCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'merchandiser_id': merchandiserId,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'license_number': licenseNumber,
      'is_available': isAvailable,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'active_orders_count': activeOrdersCount,
      'completed_orders_count': completedOrdersCount,
      'profiles': {
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
      },
    };
  }
}

class TestOrderAssignmentBuilder {
  String id = TestConstants.assignmentId1;
  String orderId = TestConstants.orderId1;
  String driverId = TestConstants.driverId1;
  DateTime assignedAt = DateTime(2024, 1, 1, 10, 0);
  String? assignedBy = TestConstants.assignedBy;
  DateTime? deliveredAt;
  String? notes;
  String deliveryStatus = 'assigned';
  String? orderNumber = 'ORD-001';
  String? customerName = 'Customer One';
  String? customerPhone = '+9876543210';
  String? customerAddress = '123 Main St, City, State';
  double? orderAmount = 150.0;
  String? orderStatus = 'preparing';
  String? paymentStatus = 'pending';
  String? driverName = 'John Doe';
  String? driverPhone = '+1234567890';

  TestOrderAssignmentBuilder();

  TestOrderAssignmentBuilder withId(String id) {
    this.id = id;
    return this;
  }

  TestOrderAssignmentBuilder withOrderId(String orderId) {
    this.orderId = orderId;
    return this;
  }

  TestOrderAssignmentBuilder withDriverId(String driverId) {
    this.driverId = driverId;
    return this;
  }

  TestOrderAssignmentBuilder withDeliveryStatus(String status) {
    this.deliveryStatus = status;
    return this;
  }

  TestOrderAssignmentBuilder withOrderStatus(String status) {
    this.orderStatus = status;
    return this;
  }

  TestOrderAssignmentBuilder withDeliveredAt(DateTime? time) {
    this.deliveredAt = time;
    return this;
  }

  TestOrderAssignmentBuilder withNotes(String? notes) {
    this.notes = notes;
    return this;
  }

  OrderAssignment build() {
    return OrderAssignment(
      id: id,
      orderId: orderId,
      driverId: driverId,
      assignedAt: assignedAt,
      assignedBy: assignedBy,
      deliveredAt: deliveredAt,
      notes: notes,
      deliveryStatus: deliveryStatus,
      orderNumber: orderNumber,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      orderAmount: orderAmount,
      orderStatus: orderStatus,
      paymentStatus: paymentStatus,
      driverName: driverName,
      driverPhone: driverPhone,
    );
  }

  OrderAssignmentModel buildModel() {
    return OrderAssignmentModel(
      id: id,
      orderId: orderId,
      driverId: driverId,
      assignedAt: assignedAt,
      assignedBy: assignedBy,
      deliveredAt: deliveredAt,
      notes: notes,
      deliveryStatus: deliveryStatus,
      orderNumber: orderNumber,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      orderAmount: orderAmount,
      orderStatus: orderStatus,
      paymentStatus: paymentStatus,
      driverName: driverName,
      driverPhone: driverPhone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'driver_id': driverId,
      'assigned_at': assignedAt.toIso8601String(),
      'assigned_by': assignedBy,
      'delivered_at': deliveredAt?.toIso8601String(),
      'notes': notes,
      'delivery_status': deliveryStatus,
      'orders': {
        'order_number': orderNumber,
        'total_amount': orderAmount,
        'status': orderStatus,
        'payment_status': paymentStatus,
        'shipping_address': {
          'street_address': '123 Main St',
          'city': 'City',
          'state': 'State',
        },
        'profiles': {
          'full_name': customerName,
          'phone_number': customerPhone,
        },
      },
      'drivers': {
        'merchandiser_id': TestConstants.merchandiserId,
        'profiles': {
          'full_name': driverName,
          'phone_number': driverPhone,
        },
      },
    };
  }
}

// ==================== Test Data Factory ====================
class TestDataFactory {
  static Driver createDriver({
    String? id,
    bool isAvailable = true,
    bool isActive = true,
    int activeOrders = 0,
  }) {
    return TestDriverBuilder()
        .withId(id ?? TestConstants.driverId1)
        .withIsAvailable(isAvailable)
        .withIsActive(isActive)
        .withActiveOrders(activeOrders)
        .build();
  }

  static List<Driver> createDriverList() {
    return [
      TestDriverBuilder()
          .withId(TestConstants.driverId1)
          .withProfileId(TestConstants.profileId1)
          .withFullName('John Doe')
          .withIsAvailable(true)
          .withIsActive(true)
          .withActiveOrders(1)
          .withCompletedOrders(10)
          .build(),
      TestDriverBuilder()
          .withId(TestConstants.driverId2)
          .withProfileId(TestConstants.profileId2)
          .withFullName('Jane Smith')
          .withIsAvailable(false)
          .withIsActive(true)
          .withActiveOrders(2)
          .withCompletedOrders(15)
          .build(),
      TestDriverBuilder()
          .withId(TestConstants.driverId3)
          .withProfileId(TestConstants.profileId3)
          .withFullName('Bob Johnson')
          .withIsAvailable(true)
          .withIsActive(false)
          .withActiveOrders(0)
          .withCompletedOrders(5)
          .build(),
    ];
  }

  static OrderAssignment createOrderAssignment({
    String? id,
    String? orderId,
    String? driverId,
    String deliveryStatus = 'assigned',
    String orderStatus = 'preparing',
  }) {
    return TestOrderAssignmentBuilder()
        .withId(id ?? TestConstants.assignmentId1)
        .withOrderId(orderId ?? TestConstants.orderId1)
        .withDriverId(driverId ?? TestConstants.driverId1)
        .withDeliveryStatus(deliveryStatus)
        .withOrderStatus(orderStatus)
        .build();
  }

  static List<OrderAssignment> createOrderAssignmentList() {
    return [
      TestOrderAssignmentBuilder()
          .withId(TestConstants.assignmentId1)
          .withOrderId(TestConstants.orderId1)
          .withDriverId(TestConstants.driverId1)
          .withDeliveryStatus('assigned')
          .withOrderStatus('preparing')
          .build(),
      TestOrderAssignmentBuilder()
          .withId(TestConstants.assignmentId2)
          .withOrderId(TestConstants.orderId2)
          .withDriverId(TestConstants.driverId1)
          .withDeliveryStatus('picked_up')
          .withOrderStatus('on_the_way')
          .build(),
      TestOrderAssignmentBuilder()
          .withId('assignment-id-3')
          .withOrderId(TestConstants.orderId3)
          .withDriverId(TestConstants.driverId2)
          .withDeliveryStatus('delivered')
          .withOrderStatus('delivered')
          .withDeliveredAt(DateTime(2024, 1, 1, 15, 0))
          .build(),
    ];
  }

  static Map<String, dynamic> createDeliveryStatistics() {
    return {
      'total_drivers': 3,
      'active_drivers': 2,
      'available_drivers': 1,
      'total_assignments': 10,
      'active_deliveries': 3,
      'completed_deliveries': 7,
    };
  }
}
