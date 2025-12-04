// test/features/delivery/data/models/driver_model_test.dart

import 'package:admin_panel/features/merchandisers/delivery/data/models/driver_model.dart';
import 'package:admin_panel/features/merchandisers/delivery/domain/entities/driver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('DriverModel', () {
    late TestDriverBuilder driverBuilder;

    setUp(() {
      driverBuilder = TestDriverBuilder();
    });

    group('fromJson', () {
      test('should parse complete JSON correctly', () {
        // Arrange
        final json = driverBuilder.toJson();

        // Act
        final result = DriverModel.fromJson(json);

        // Assert
        expect(result.id, TestConstants.driverId1);
        expect(result.profileId, TestConstants.profileId1);
        expect(result.merchandiserId, TestConstants.merchandiserId);
        expect(result.fullName, 'John Doe');
        expect(result.email, 'john@example.com');
        expect(result.phoneNumber, '+1234567890');
        expect(result.vehicleType, 'Car');
        expect(result.vehicleNumber, 'ABC-123');
        expect(result.licenseNumber, 'LIC-123');
        expect(result.isAvailable, true);
        expect(result.isActive, true);
        expect(result.activeOrdersCount, 0);
        expect(result.completedOrdersCount, 5);
      });

      test('should handle nested profile data', () {
        // Arrange
        final json = {
          'id': 'driver-1',
          'profile_id': 'profile-1',
          'merchandiser_id': 'merch-1',
          'vehicle_type': 'Bike',
          'vehicle_number': 'XYZ-789',
          'is_available': true,
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'profiles': {
            'full_name': 'Jane Smith',
            'email': 'jane@example.com',
            'phone_number': '+9876543210',
          },
        };

        // Act
        final result = DriverModel.fromJson(json);

        // Assert
        expect(result.fullName, 'Jane Smith');
        expect(result.email, 'jane@example.com');
        expect(result.phoneNumber, '+9876543210');
      });

      test('should handle missing optional fields', () {
        // Arrange
        final json = {
          'id': 'driver-1',
          'profile_id': 'profile-1',
          'merchandiser_id': 'merch-1',
          'is_available': true,
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'profiles': {
            'full_name': 'Test Driver',
          },
        };

        // Act
        final result = DriverModel.fromJson(json);

        // Assert
        expect(result.fullName, 'Test Driver');
        expect(result.email, null);
        expect(result.phoneNumber, null);
        expect(result.vehicleType, null);
        expect(result.vehicleNumber, null);
        expect(result.licenseNumber, null);
        expect(result.activeOrdersCount, null);
        expect(result.completedOrdersCount, null);
      });

      test('should default isAvailable and isActive to true if missing', () {
        // Arrange
        final json = {
          'id': 'driver-1',
          'profile_id': 'profile-1',
          'merchandiser_id': 'merch-1',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'profiles': {
            'full_name': 'Test Driver',
          },
        };

        // Act
        final result = DriverModel.fromJson(json);

        // Assert
        expect(result.isAvailable, true);
        expect(result.isActive, true);
      });

      test('should handle missing profile data with default name', () {
        // Arrange
        final json = {
          'id': 'driver-1',
          'profile_id': 'profile-1',
          'merchandiser_id': 'merch-1',
          'is_available': true,
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
        };

        // Act
        final result = DriverModel.fromJson(json);

        // Assert
        expect(result.fullName, 'Unknown');
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final model = driverBuilder.buildModel();

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], TestConstants.driverId1);
        expect(json['profile_id'], TestConstants.profileId1);
        expect(json['merchandiser_id'], TestConstants.merchandiserId);
        expect(json['vehicle_type'], 'Car');
        expect(json['vehicle_number'], 'ABC-123');
        expect(json['license_number'], 'LIC-123');
        expect(json['is_available'], true);
        expect(json['is_active'], true);
        expect(json['created_at'], isA<String>());
        expect(json['updated_at'], isA<String>());
      });

      test('should handle null values in serialization', () {
        // Arrange
        final model =
            driverBuilder.withVehicleInfo(null, null, null).buildModel();

        // Act
        final json = model.toJson();

        // Assert
        expect(json['vehicle_type'], null);
        expect(json['vehicle_number'], null);
        expect(json['license_number'], null);
      });
    });

    group('Entity Conversion', () {
      test('should extend Driver entity', () {
        // Arrange
        final model = driverBuilder.buildModel();

        // Assert
        expect(model, isA<Driver>());
      });

      test('should have same properties as entity', () {
        // Arrange
        final model = driverBuilder.buildModel();
        final entity = driverBuilder.build();

        // Assert
        expect(model.id, entity.id);
        expect(model.fullName, entity.fullName);
        expect(model.isAvailable, entity.isAvailable);
        expect(model.isActive, entity.isActive);
      });
    });

    group('Driver Entity Helpers', () {
      test('vehicleInfo should return formatted string', () {
        // Arrange
        final driver = driverBuilder.build();

        // Act
        final vehicleInfo = driver.vehicleInfo;

        // Assert
        expect(vehicleInfo, 'Car - ABC-123');
      });

      test('vehicleInfo should handle missing vehicle number', () {
        // Arrange
        final driver = driverBuilder.withVehicleInfo('Car', null, null).build();

        // Act
        final vehicleInfo = driver.vehicleInfo;

        // Assert
        expect(vehicleInfo, 'Car');
      });

      test('vehicleInfo should handle missing vehicle type', () {
        // Arrange
        final driver =
            driverBuilder.withVehicleInfo(null, 'ABC-123', null).build();

        // Act
        final vehicleInfo = driver.vehicleInfo;

        // Assert
        expect(vehicleInfo, 'No vehicle info');
      });

      test('statusLabel should return "Inactive" for inactive driver', () {
        // Arrange
        final driver = driverBuilder.withIsActive(false).build();

        // Act
        final status = driver.statusLabel;

        // Assert
        expect(status, 'Inactive');
      });

      test('statusLabel should return "Available" for available active driver',
          () {
        // Arrange
        final driver =
            driverBuilder.withIsActive(true).withIsAvailable(true).build();

        // Act
        final status = driver.statusLabel;

        // Assert
        expect(status, 'Available');
      });

      test('statusLabel should return "Busy" for unavailable active driver',
          () {
        // Arrange
        final driver =
            driverBuilder.withIsActive(true).withIsAvailable(false).build();

        // Act
        final status = driver.statusLabel;

        // Assert
        expect(status, 'Busy');
      });
    });
  });
}
