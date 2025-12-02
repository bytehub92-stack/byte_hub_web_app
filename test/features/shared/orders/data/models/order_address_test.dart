// test/features/orders/data/models/order_address_test.dart

import 'package:admin_panel/features/shared/orders/domain/entities/order_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderAddress', () {
    late Map<String, dynamic> validJson;

    setUp(() {
      validJson = {
        'full_name': 'John Doe',
        'phone_number': '+201234567890',
        'address_line1': '123 Main Street',
        'address_line2': 'Apt 4B',
        'city': 'Cairo',
        'landmark': 'Near City Mall',
        'country': 'Egypt',
      };
    });

    group('fromJson', () {
      test('should create OrderAddress from valid JSON with all fields', () {
        // Act
        final result = OrderAddress.fromJson(validJson);

        // Assert
        expect(result.fullName, 'John Doe');
        expect(result.phoneNumber, '+201234567890');
        expect(result.addressLine1, '123 Main Street');
        expect(result.addressLine2, 'Apt 4B');
        expect(result.city, 'Cairo');
        expect(result.landmark, 'Near City Mall');
        expect(result.country, 'Egypt');
      });

      test('should create OrderAddress with null optional fields', () {
        // Arrange
        final jsonWithoutOptionals = {
          'full_name': 'John Doe',
          'phone_number': '+201234567890',
          'address_line1': '123 Main Street',
          'city': 'Cairo',
        };

        // Act
        final result = OrderAddress.fromJson(jsonWithoutOptionals);

        // Assert
        expect(result.fullName, 'John Doe');
        expect(result.phoneNumber, '+201234567890');
        expect(result.addressLine1, '123 Main Street');
        expect(result.addressLine2, null);
        expect(result.city, 'Cairo');
        expect(result.landmark, null);
        expect(result.country, 'Egypt'); // Default value
      });

      test('should use default country when not provided', () {
        // Arrange
        final jsonWithoutCountry = {
          'full_name': 'John Doe',
          'phone_number': '+201234567890',
          'address_line1': '123 Main Street',
          'city': 'Cairo',
        };

        // Act
        final result = OrderAddress.fromJson(jsonWithoutCountry);

        // Assert
        expect(result.country, 'Egypt');
      });

      test('should handle empty string optional fields', () {
        // Arrange
        final jsonWithEmptyStrings = {
          'full_name': 'John Doe',
          'phone_number': '+201234567890',
          'address_line1': '123 Main Street',
          'address_line2': '',
          'city': 'Cairo',
          'landmark': '',
          'country': 'Egypt',
        };

        // Act
        final result = OrderAddress.fromJson(jsonWithEmptyStrings);

        // Assert
        expect(result.addressLine2, '');
        expect(result.landmark, '');
      });
    });

    group('toJson', () {
      test('should convert OrderAddress to JSON with all fields', () {
        // Arrange
        const address = OrderAddress(
          fullName: 'John Doe',
          phoneNumber: '+201234567890',
          addressLine1: '123 Main Street',
          addressLine2: 'Apt 4B',
          city: 'Cairo',
          landmark: 'Near City Mall',
          country: 'Egypt',
        );

        // Act
        final result = address.toJson();

        // Assert
        expect(result['full_name'], 'John Doe');
        expect(result['phone_number'], '+201234567890');
        expect(result['address_line1'], '123 Main Street');
        expect(result['address_line2'], 'Apt 4B');
        expect(result['city'], 'Cairo');
        expect(result['landmark'], 'Near City Mall');
        expect(result['country'], 'Egypt');
      });

      test('should convert OrderAddress to JSON with null optional fields', () {
        // Arrange
        const address = OrderAddress(
          fullName: 'John Doe',
          phoneNumber: '+201234567890',
          addressLine1: '123 Main Street',
          city: 'Cairo',
          country: 'Egypt',
        );

        // Act
        final result = address.toJson();

        // Assert
        expect(result['full_name'], 'John Doe');
        expect(result['phone_number'], '+201234567890');
        expect(result['address_line1'], '123 Main Street');
        expect(result['address_line2'], null);
        expect(result['city'], 'Cairo');
        expect(result['landmark'], null);
        expect(result['country'], 'Egypt');
      });
    });

    group('fullAddress', () {
      test('should format full address with all fields', () {
        // Arrange
        const address = OrderAddress(
          fullName: 'John Doe',
          phoneNumber: '+201234567890',
          addressLine1: '123 Main Street',
          addressLine2: 'Apt 4B',
          city: 'Cairo',
          landmark: 'Near City Mall',
          country: 'Egypt',
        );

        // Act
        final result = address.fullAddress;

        // Assert
        expect(
          result,
          '123 Main Street, Apt 4B, Cairo, Near City Mall, Egypt',
        );
      });

      test('should format full address without optional fields', () {
        // Arrange
        const address = OrderAddress(
          fullName: 'John Doe',
          phoneNumber: '+201234567890',
          addressLine1: '123 Main Street',
          city: 'Cairo',
          country: 'Egypt',
        );

        // Act
        final result = address.fullAddress;

        // Assert
        expect(result, '123 Main Street, Cairo, Egypt');
      });

      test('should format full address skipping empty optional fields', () {
        // Arrange
        const address = OrderAddress(
          fullName: 'John Doe',
          phoneNumber: '+201234567890',
          addressLine1: '123 Main Street',
          addressLine2: '',
          city: 'Cairo',
          landmark: '',
          country: 'Egypt',
        );

        // Act
        final result = address.fullAddress;

        // Assert
        expect(result, '123 Main Street, Cairo, Egypt');
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        // Arrange
        const address1 = OrderAddress(
          fullName: 'John Doe',
          phoneNumber: '+201234567890',
          addressLine1: '123 Main Street',
          addressLine2: 'Apt 4B',
          city: 'Cairo',
          landmark: 'Near City Mall',
          country: 'Egypt',
        );

        const address2 = OrderAddress(
          fullName: 'John Doe',
          phoneNumber: '+201234567890',
          addressLine1: '123 Main Street',
          addressLine2: 'Apt 4B',
          city: 'Cairo',
          landmark: 'Near City Mall',
          country: 'Egypt',
        );

        // Assert
        expect(address1, address2);
        expect(address1.hashCode, address2.hashCode);
      });

      test('should not be equal when fields differ', () {
        // Arrange
        const address1 = OrderAddress(
          fullName: 'John Doe',
          phoneNumber: '+201234567890',
          addressLine1: '123 Main Street',
          city: 'Cairo',
          country: 'Egypt',
        );

        const address2 = OrderAddress(
          fullName: 'Jane Doe',
          phoneNumber: '+201234567890',
          addressLine1: '123 Main Street',
          city: 'Cairo',
          country: 'Egypt',
        );

        // Assert
        expect(address1, isNot(address2));
      });
    });

    group('JSON round trip', () {
      test('should maintain data integrity through JSON serialization', () {
        // Arrange
        const original = OrderAddress(
          fullName: 'John Doe',
          phoneNumber: '+201234567890',
          addressLine1: '123 Main Street',
          addressLine2: 'Apt 4B',
          city: 'Cairo',
          landmark: 'Near City Mall',
          country: 'Egypt',
        );

        // Act
        final json = original.toJson();
        final restored = OrderAddress.fromJson(json);

        // Assert
        expect(restored, original);
      });
    });
  });
}
