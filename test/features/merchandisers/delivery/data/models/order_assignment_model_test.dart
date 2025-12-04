// test/features/delivery/data/models/order_assignment_model_test.dart

import 'package:admin_panel/features/merchandisers/delivery/data/models/order_assignment_model.dart';
import 'package:admin_panel/features/merchandisers/delivery/domain/entities/order_assignment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('OrderAssignmentModel', () {
    late TestOrderAssignmentBuilder assignmentBuilder;

    setUp(() {
      assignmentBuilder = TestOrderAssignmentBuilder();
    });

    group('fromJson', () {
      test('should parse complete JSON correctly', () {
        // Arrange
        final json = assignmentBuilder.toJson();

        // Act
        final result = OrderAssignmentModel.fromJson(json);

        // Assert
        expect(result.id, TestConstants.assignmentId1);
        expect(result.orderId, TestConstants.orderId1);
        expect(result.driverId, TestConstants.driverId1);
        expect(result.assignedBy, TestConstants.assignedBy);
        expect(result.deliveryStatus, 'assigned');
        expect(result.orderNumber, 'ORD-001');
        expect(result.customerName, 'Customer One');
        expect(result.customerPhone, '+9876543210');
        expect(result.customerAddress, '123 Main St, City, State');
        expect(result.orderAmount, 150.0);
        expect(result.orderStatus, 'preparing');
        expect(result.paymentStatus, 'pending');
        expect(result.driverName, 'John Doe');
        expect(result.driverPhone, '+1234567890');
      });

      test('should parse nested order data', () {
        // Arrange
        final json = {
          'id': 'assignment-1',
          'order_id': 'order-1',
          'driver_id': 'driver-1',
          'assigned_at': '2024-01-01T10:00:00.000Z',
          'delivery_status': 'picked_up',
          'orders': {
            'order_number': 'ORD-999',
            'total_amount': 250.50,
            'status': 'on_the_way',
            'payment_status': 'paid',
            'shipping_address': {
              'street_address': '456 Oak Ave',
              'city': 'Springfield',
              'state': 'IL',
            },
            'profiles': {
              'full_name': 'John Customer',
              'phone_number': '+1111111111',
            },
          },
          'drivers': {
            'merchandiser_id': TestConstants.merchandiserId,
            'profiles': {
              'full_name': 'Mike Driver',
              'phone_number': '+2222222222',
            },
          },
        };

        // Act
        final result = OrderAssignmentModel.fromJson(json);

        // Assert
        expect(result.orderNumber, 'ORD-999');
        expect(result.orderAmount, 250.50);
        expect(result.orderStatus, 'on_the_way');
        expect(result.paymentStatus, 'paid');
        expect(result.customerName, 'John Customer');
        expect(result.customerPhone, '+1111111111');
        expect(result.customerAddress, '456 Oak Ave, Springfield, IL');
        expect(result.driverName, 'Mike Driver');
        expect(result.driverPhone, '+2222222222');
      });

      test('should handle missing optional fields', () {
        // Arrange
        final json = {
          'id': 'assignment-1',
          'order_id': 'order-1',
          'driver_id': 'driver-1',
          'assigned_at': '2024-01-01T10:00:00.000Z',
        };

        // Act
        final result = OrderAssignmentModel.fromJson(json);

        // Assert
        expect(result.id, 'assignment-1');
        expect(result.orderId, 'order-1');
        expect(result.driverId, 'driver-1');
        expect(result.assignedBy, null);
        expect(result.deliveredAt, null);
        expect(result.notes, null);
        expect(result.deliveryStatus, 'assigned'); // Default value
        expect(result.orderNumber, null);
        expect(result.customerName, null);
        expect(result.orderAmount, null);
      });

      test('should handle different amount types', () {
        // Test double
        final jsonDouble = {
          'id': 'assignment-1',
          'order_id': 'order-1',
          'driver_id': 'driver-1',
          'assigned_at': '2024-01-01T10:00:00.000Z',
          'orders': {'total_amount': 100.50},
          'drivers': {'merchandiser_id': 'merch-1'},
        };

        final resultDouble = OrderAssignmentModel.fromJson(jsonDouble);
        expect(resultDouble.orderAmount, 100.50);

        // Test int
        final jsonInt = {
          'id': 'assignment-2',
          'order_id': 'order-2',
          'driver_id': 'driver-2',
          'assigned_at': '2024-01-01T10:00:00.000Z',
          'orders': {'total_amount': 100},
          'drivers': {'merchandiser_id': 'merch-1'},
        };

        final resultInt = OrderAssignmentModel.fromJson(jsonInt);
        expect(resultInt.orderAmount, 100.0);

        // Test string
        final jsonString = {
          'id': 'assignment-3',
          'order_id': 'order-3',
          'driver_id': 'driver-3',
          'assigned_at': '2024-01-01T10:00:00.000Z',
          'orders': {'total_amount': '75.25'},
          'drivers': {'merchandiser_id': 'merch-1'},
        };

        final resultString = OrderAssignmentModel.fromJson(jsonString);
        expect(resultString.orderAmount, 75.25);

        // Test null
        final jsonNull = {
          'id': 'assignment-4',
          'order_id': 'order-4',
          'driver_id': 'driver-4',
          'assigned_at': '2024-01-01T10:00:00.000Z',
          'orders': {'total_amount': null},
          'drivers': {'merchandiser_id': 'merch-1'},
        };

        final resultNull = OrderAssignmentModel.fromJson(jsonNull);
        expect(resultNull.orderAmount, null);
      });

      test('should format address correctly', () {
        // Arrange
        final json = {
          'id': 'assignment-1',
          'order_id': 'order-1',
          'driver_id': 'driver-1',
          'assigned_at': '2024-01-01T10:00:00.000Z',
          'orders': {
            'shipping_address': {
              'street_address': '789 Pine St',
              'city': 'Boston',
              'state': 'MA',
            },
          },
          'drivers': {'merchandiser_id': 'merch-1'},
        };

        // Act
        final result = OrderAssignmentModel.fromJson(json);

        // Assert
        expect(result.customerAddress, '789 Pine St, Boston, MA');
      });

      test('should handle partial address', () {
        // Arrange
        final json = {
          'id': 'assignment-1',
          'order_id': 'order-1',
          'driver_id': 'driver-1',
          'assigned_at': '2024-01-01T10:00:00.000Z',
          'orders': {
            'shipping_address': {
              'city': 'Boston',
            },
          },
          'drivers': {'merchandiser_id': 'merch-1'},
        };

        // Act
        final result = OrderAssignmentModel.fromJson(json);

        // Assert
        expect(result.customerAddress, 'Boston');
      });

      test('should parse delivered_at when present', () {
        // Arrange
        final deliveredTime = DateTime(2024, 1, 1, 15, 30);
        final json = {
          'id': 'assignment-1',
          'order_id': 'order-1',
          'driver_id': 'driver-1',
          'assigned_at': '2024-01-01T10:00:00.000Z',
          'delivered_at': deliveredTime.toIso8601String(),
          'delivery_status': 'delivered',
        };

        // Act
        final result = OrderAssignmentModel.fromJson(json);

        // Assert
        expect(result.deliveredAt, deliveredTime);
        expect(result.deliveryStatus, 'delivered');
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final model = assignmentBuilder.buildModel();

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], TestConstants.assignmentId1);
        expect(json['order_id'], TestConstants.orderId1);
        expect(json['driver_id'], TestConstants.driverId1);
        expect(json['assigned_by'], TestConstants.assignedBy);
        expect(json['delivery_status'], 'assigned');
        expect(json['assigned_at'], isA<String>());
        expect(json['delivered_at'], null);
      });

      test('should include delivered_at when present', () {
        // Arrange
        final deliveredTime = DateTime(2024, 1, 1, 15, 0);
        final model =
            assignmentBuilder.withDeliveredAt(deliveredTime).buildModel();

        // Act
        final json = model.toJson();

        // Assert
        expect(json['delivered_at'], deliveredTime.toIso8601String());
      });

      test('should include notes when present', () {
        // Arrange
        final model =
            assignmentBuilder.withNotes('Handle with care').buildModel();

        // Act
        final json = model.toJson();

        // Assert
        expect(json['notes'], 'Handle with care');
      });
    });

    group('Entity Conversion', () {
      test('should extend OrderAssignment entity', () {
        // Arrange
        final model = assignmentBuilder.buildModel();

        // Assert
        expect(model, isA<OrderAssignment>());
      });

      test('should have same properties as entity', () {
        // Arrange
        final model = assignmentBuilder.buildModel();
        final entity = assignmentBuilder.build();

        // Assert
        expect(model.id, entity.id);
        expect(model.orderId, entity.orderId);
        expect(model.driverId, entity.driverId);
        expect(model.deliveryStatus, entity.deliveryStatus);
      });
    });

    group('OrderAssignment Entity Helpers', () {
      test('isActive should return true for active statuses', () {
        final assignedAssignment =
            assignmentBuilder.withDeliveryStatus('assigned').build();
        expect(assignedAssignment.isActive, true);

        final pickedUpAssignment =
            assignmentBuilder.withDeliveryStatus('picked_up').build();
        expect(pickedUpAssignment.isActive, true);

        final onTheWayAssignment =
            assignmentBuilder.withDeliveryStatus('on_the_way').build();
        expect(onTheWayAssignment.isActive, true);
      });

      test('isActive should return false for completed statuses', () {
        final deliveredAssignment =
            assignmentBuilder.withDeliveryStatus('delivered').build();
        expect(deliveredAssignment.isActive, false);

        final failedAssignment =
            assignmentBuilder.withDeliveryStatus('failed').build();
        expect(failedAssignment.isActive, false);
      });

      test('isCompleted should return true only for delivered status', () {
        final deliveredAssignment =
            assignmentBuilder.withDeliveryStatus('delivered').build();
        expect(deliveredAssignment.isCompleted, true);

        final assignedAssignment =
            assignmentBuilder.withDeliveryStatus('assigned').build();
        expect(assignedAssignment.isCompleted, false);
      });

      test('isFailed should return true only for failed status', () {
        final failedAssignment =
            assignmentBuilder.withDeliveryStatus('failed').build();
        expect(failedAssignment.isFailed, true);

        final deliveredAssignment =
            assignmentBuilder.withDeliveryStatus('delivered').build();
        expect(deliveredAssignment.isFailed, false);
      });

      test('deliveryStatusLabel should return correct labels', () {
        expect(
          assignmentBuilder
              .withDeliveryStatus('assigned')
              .build()
              .deliveryStatusLabel,
          'Assigned',
        );
        expect(
          assignmentBuilder
              .withDeliveryStatus('picked_up')
              .build()
              .deliveryStatusLabel,
          'Picked Up',
        );
        expect(
          assignmentBuilder
              .withDeliveryStatus('on_the_way')
              .build()
              .deliveryStatusLabel,
          'On the Way',
        );
        expect(
          assignmentBuilder
              .withDeliveryStatus('delivered')
              .build()
              .deliveryStatusLabel,
          'Delivered',
        );
        expect(
          assignmentBuilder
              .withDeliveryStatus('failed')
              .build()
              .deliveryStatusLabel,
          'Failed',
        );
        expect(
          assignmentBuilder
              .withDeliveryStatus('unknown')
              .build()
              .deliveryStatusLabel,
          'Unknown',
        );
      });
    });
  });
}
