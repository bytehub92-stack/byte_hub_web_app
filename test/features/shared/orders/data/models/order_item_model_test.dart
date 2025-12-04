// test/features/orders/data/models/order_item_model_test.dart

import 'package:admin_panel/features/shared/orders/data/models/order_item_model.dart';
import 'package:admin_panel/features/shared/orders/domain/entities/order_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderItemModel', () {
    late Map<String, dynamic> validJson;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      validJson = {
        'id': 'item_123',
        'order_id': 'order_456',
        'product_id': 'product_789',
        'quantity': 2.0,
        'unit_price': 50.0,
        'total_price': 100.0,
        'product_name': {'en': 'Test Product', 'ar': 'منتج تجريبي'},
        'product_image': 'https://example.com/image.jpg',
        'created_at': testDate.toIso8601String(),
        'is_free_item': false,
        'offer_id': 'offer_123',
        'offer_type': 'discount',
      };
    });

    group('fromJson', () {
      test('should create OrderItemModel from valid JSON with all fields', () {
        // Act
        final result = OrderItemModel.fromJson(validJson);

        // Assert
        expect(result.id, 'item_123');
        expect(result.orderId, 'order_456');
        expect(result.productId, 'product_789');
        expect(result.quantity, 2.0);
        expect(result.unitPrice, 50.0);
        expect(result.totalPrice, 100.0);
        expect(result.productName['en'], 'Test Product');
        expect(result.productName['ar'], 'منتج تجريبي');
        expect(result.productImage, 'https://example.com/image.jpg');
        expect(result.createdAt, testDate);
        expect(result.isFreeItem, false);
        expect(result.offerId, 'offer_123');
        expect(result.offerType, 'discount');
      });

      test('should create OrderItemModel with null optional fields', () {
        // Arrange
        final minimalJson = {
          'id': 'item_123',
          'order_id': 'order_456',
          'product_id': 'product_789',
          'quantity': 2.0,
          'unit_price': 50.0,
          'total_price': 100.0,
          'product_name': {'en': 'Test Product'},
          'created_at': testDate.toIso8601String(),
        };

        // Act
        final result = OrderItemModel.fromJson(minimalJson);

        // Assert
        expect(result.id, 'item_123');
        expect(result.productImage, null);
        expect(result.isFreeItem, false); // Default value
        expect(result.offerId, null);
        expect(result.offerType, null);
      });

      test('should handle free item flag correctly', () {
        // Arrange
        validJson['is_free_item'] = true;

        // Act
        final result = OrderItemModel.fromJson(validJson);

        // Assert
        expect(result.isFreeItem, true);
      });

      group('_parseProductName', () {
        test('should parse product name from Map', () {
          // Arrange
          validJson['product_name'] = {'en': 'Product', 'ar': 'منتج'};

          // Act
          final result = OrderItemModel.fromJson(validJson);

          // Assert
          expect(result.productName['en'], 'Product');
          expect(result.productName['ar'], 'منتج');
        });

        test('should parse product name from String', () {
          // Arrange
          validJson['product_name'] = 'Simple Product Name';

          // Act
          final result = OrderItemModel.fromJson(validJson);

          // Assert
          expect(result.productName['en'], 'Simple Product Name');
        });

        test('should handle null product name', () {
          // Arrange
          validJson['product_name'] = null;

          // Act
          final result = OrderItemModel.fromJson(validJson);

          // Assert
          expect(result.productName['en'], 'Unknown Product');
        });

        test('should handle missing product name key', () {
          // Arrange
          validJson.remove('product_name');

          // Act
          final result = OrderItemModel.fromJson(validJson);

          // Assert
          expect(result.productName['en'], 'Unknown Product');
        });
      });

      group('_parseDouble', () {
        test('should parse double from double value', () {
          // Arrange
          validJson['quantity'] = 2.5;
          validJson['unit_price'] = 50.75;
          validJson['total_price'] = 126.875;

          // Act
          final result = OrderItemModel.fromJson(validJson);

          // Assert
          expect(result.quantity, 2.5);
          expect(result.unitPrice, 50.75);
          expect(result.totalPrice, 126.875);
        });

        test('should parse double from int value', () {
          // Arrange
          validJson['quantity'] = 2;
          validJson['unit_price'] = 50;
          validJson['total_price'] = 100;

          // Act
          final result = OrderItemModel.fromJson(validJson);

          // Assert
          expect(result.quantity, 2.0);
          expect(result.unitPrice, 50.0);
          expect(result.totalPrice, 100.0);
        });

        test('should parse double from String value', () {
          // Arrange
          validJson['quantity'] = '2.5';
          validJson['unit_price'] = '50.75';
          validJson['total_price'] = '126.875';

          // Act
          final result = OrderItemModel.fromJson(validJson);

          // Assert
          expect(result.quantity, 2.5);
          expect(result.unitPrice, 50.75);
          expect(result.totalPrice, 126.875);
        });

        test('should return 0.0 for null numeric values', () {
          // Arrange
          validJson['quantity'] = null;
          validJson['unit_price'] = null;
          validJson['total_price'] = null;

          // Act
          final result = OrderItemModel.fromJson(validJson);

          // Assert
          expect(result.quantity, 0.0);
          expect(result.unitPrice, 0.0);
          expect(result.totalPrice, 0.0);
        });

        test('should return 0.0 for invalid String numeric values', () {
          // Arrange
          validJson['quantity'] = 'invalid';
          validJson['unit_price'] = 'not-a-number';
          validJson['total_price'] = 'xyz';

          // Act
          final result = OrderItemModel.fromJson(validJson);

          // Assert
          expect(result.quantity, 0.0);
          expect(result.unitPrice, 0.0);
          expect(result.totalPrice, 0.0);
        });
      });
    });

    group('toJson', () {
      test('should convert OrderItemModel to JSON with all fields', () {
        // Arrange
        final model = OrderItemModel(
          id: 'item_123',
          orderId: 'order_456',
          productId: 'product_789',
          quantity: 2.0,
          unitPrice: 50.0,
          totalPrice: 100.0,
          productName: const {'en': 'Test Product', 'ar': 'منتج تجريبي'},
          productImage: 'https://example.com/image.jpg',
          createdAt: testDate,
          isFreeItem: false,
          offerId: 'offer_123',
          offerType: 'discount',
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['id'], 'item_123');
        expect(result['order_id'], 'order_456');
        expect(result['product_id'], 'product_789');
        expect(result['quantity'], 2.0);
        expect(result['unit_price'], 50.0);
        expect(result['total_price'], 100.0);
        expect(result['product_name'],
            {'en': 'Test Product', 'ar': 'منتج تجريبي'});
        expect(result['product_image'], 'https://example.com/image.jpg');
        expect(result['created_at'], testDate.toIso8601String());
        expect(result['is_free_item'], false);
        expect(result['offer_id'], 'offer_123');
        expect(result['offer_type'], 'discount');
      });

      test('should convert OrderItemModel to JSON with null optional fields',
          () {
        // Arrange
        final model = OrderItemModel(
          id: 'item_123',
          orderId: 'order_456',
          productId: 'product_789',
          quantity: 2.0,
          unitPrice: 50.0,
          totalPrice: 100.0,
          productName: const {'en': 'Test Product'},
          createdAt: testDate,
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['id'], 'item_123');
        expect(result['product_image'], null);
        expect(result['is_free_item'], false);
        expect(result['offer_id'], null);
        expect(result['offer_type'], null);
      });
    });

    group('extends OrderItemEntity', () {
      test('should be an instance of OrderItemEntity', () {
        // Arrange
        final model = OrderItemModel(
          id: 'item_123',
          orderId: 'order_456',
          productId: 'product_789',
          quantity: 2.0,
          unitPrice: 50.0,
          totalPrice: 100.0,
          productName: const {'en': 'Test Product'},
          createdAt: testDate,
        );

        // Assert
        expect(model, isA<OrderItemEntity>());
      });
    });

    group('JSON round trip', () {
      test('should maintain data integrity through JSON serialization', () {
        // Arrange
        final original = OrderItemModel(
          id: 'item_123',
          orderId: 'order_456',
          productId: 'product_789',
          quantity: 2.5,
          unitPrice: 50.75,
          totalPrice: 126.875,
          productName: const {'en': 'Test Product', 'ar': 'منتج تجريبي'},
          productImage: 'https://example.com/image.jpg',
          createdAt: testDate,
          isFreeItem: true,
          offerId: 'offer_123',
          offerType: 'buy_x_get_y',
        );

        // Act
        final json = original.toJson();
        final restored = OrderItemModel.fromJson(json);

        // Assert
        expect(restored.id, original.id);
        expect(restored.orderId, original.orderId);
        expect(restored.productId, original.productId);
        expect(restored.quantity, original.quantity);
        expect(restored.unitPrice, original.unitPrice);
        expect(restored.totalPrice, original.totalPrice);
        expect(restored.productName, original.productName);
        expect(restored.productImage, original.productImage);
        expect(restored.createdAt, original.createdAt);
        expect(restored.isFreeItem, original.isFreeItem);
        expect(restored.offerId, original.offerId);
        expect(restored.offerType, original.offerType);
      });
    });

    group('edge cases', () {
      test('should handle very large quantities and prices', () {
        // Arrange
        validJson['quantity'] = 999999.99;
        validJson['unit_price'] = 999999.99;
        validJson['total_price'] = 999999990000.01;

        // Act
        final result = OrderItemModel.fromJson(validJson);

        // Assert
        expect(result.quantity, 999999.99);
        expect(result.unitPrice, 999999.99);
        expect(result.totalPrice, 999999990000.01);
      });

      test('should handle zero values', () {
        // Arrange
        validJson['quantity'] = 0.0;
        validJson['unit_price'] = 0.0;
        validJson['total_price'] = 0.0;

        // Act
        final result = OrderItemModel.fromJson(validJson);

        // Assert
        expect(result.quantity, 0.0);
        expect(result.unitPrice, 0.0);
        expect(result.totalPrice, 0.0);
      });

      test('should handle negative values (for refunds)', () {
        // Arrange
        validJson['quantity'] = -1.0;
        validJson['unit_price'] = 50.0;
        validJson['total_price'] = -50.0;

        // Act
        final result = OrderItemModel.fromJson(validJson);

        // Assert
        expect(result.quantity, -1.0);
        expect(result.totalPrice, -50.0);
      });
    });
  });
}
