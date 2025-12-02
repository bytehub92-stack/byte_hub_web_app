// test/features/orders/data/models/order_model_test.dart

import 'package:admin_panel/features/shared/orders/data/models/order_model.dart';
import 'package:admin_panel/features/shared/orders/domain/entities/order.dart';
import 'package:admin_panel/features/shared/orders/domain/entities/order_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderModel', () {
    late Map<String, dynamic> validJson;
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late DateTime testDeliveryDate;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 15, 10, 30);
      testUpdatedAt = DateTime(2024, 1, 15, 11, 30);
      testDeliveryDate = DateTime(2024, 1, 16, 14, 0);

      validJson = {
        'id': 'order_123',
        'customer_user_id': 'customer_456',
        'merchandiser_id': 'merchandiser_789',
        'order_number': 'ORD-2024-001',
        'total_amount': 500.0,
        'status': 'pending',
        'created_at': testCreatedAt.toIso8601String(),
        'updated_at': testUpdatedAt.toIso8601String(),
        'delivery_date': testDeliveryDate.toIso8601String(),
        'notes': 'Please deliver before 2 PM',
        'subtotal': 450.0,
        'tax_amount': 30.0,
        'shipping_amount': 20.0,
        'discount_amount': 0.0,
        'payment_status': 'pending',
        'payment_method': 'cash_on_delivery',
        'shipping_address': {
          'full_name': 'John Doe',
          'phone_number': '+201234567890',
          'address_line1': '123 Main Street',
          'city': 'Cairo',
          'country': 'Egypt',
        },
        'billing_address': {
          'full_name': 'John Doe',
          'phone_number': '+201234567890',
          'address_line1': '123 Main Street',
          'city': 'Cairo',
          'country': 'Egypt',
        },
        'customer_name': 'John Doe',
        'customer_email': 'john@example.com',
        'customer_phone': '+201234567890',
        'merchandiser_name': 'Test Store',
      };
    });

    group('fromJson', () {
      test('should create OrderModel from valid JSON with all fields', () {
        // Act
        final result = OrderModel.fromJson(validJson);

        // Assert
        expect(result.id, 'order_123');
        expect(result.customerUserId, 'customer_456');
        expect(result.merchandiserId, 'merchandiser_789');
        expect(result.orderNumber, 'ORD-2024-001');
        expect(result.totalAmount, 500.0);
        expect(result.status, 'pending');
        expect(result.createdAt, testCreatedAt);
        expect(result.updatedAt, testUpdatedAt);
        expect(result.deliveryDate, testDeliveryDate);
        expect(result.notes, 'Please deliver before 2 PM');
        expect(result.subtotal, 450.0);
        expect(result.taxAmount, 30.0);
        expect(result.shippingAmount, 20.0);
        expect(result.discountAmount, 0.0);
        expect(result.paymentStatus, 'pending');
        expect(result.paymentMethod, 'cash_on_delivery');
        expect(result.customerName, 'John Doe');
        expect(result.customerEmail, 'john@example.com');
        expect(result.customerPhone, '+201234567890');
        expect(result.merchandiserName, 'Test Store');
      });

      test('should create OrderModel with minimal required fields', () {
        // Arrange
        final minimalJson = {
          'id': 'order_123',
          'customer_user_id': 'customer_456',
          'merchandiser_id': 'merchandiser_789',
          'order_number': 'ORD-2024-001',
          'total_amount': 500.0,
          'created_at': testCreatedAt.toIso8601String(),
          'updated_at': testUpdatedAt.toIso8601String(),
        };

        // Act
        final result = OrderModel.fromJson(minimalJson);

        // Assert
        expect(result.id, 'order_123');
        expect(result.status, 'pending'); // Default value
        expect(result.subtotal, 0.0); // Default value
        expect(result.taxAmount, 0.0); // Default value
        expect(result.shippingAmount, 0.0); // Default value
        expect(result.discountAmount, 0.0); // Default value
        expect(result.paymentStatus, 'pending'); // Default value
        expect(result.deliveryDate, null);
        expect(result.notes, null);
        expect(result.paymentMethod, null);
        expect(result.shippingAddress, null);
        expect(result.billingAddress, null);
      });

      test('should parse offer metadata with single offer', () {
        // Arrange
        validJson['offer_metadata'] = [
          {
            'offer_id': 'offer_123',
            'offer_type': 'discount',
            'discount_percentage': 10,
          }
        ];

        // Act
        final result = OrderModel.fromJson(validJson);

        // Assert
        expect(result.appliedOfferId, 'offer_123');
        expect(result.appliedOfferType, 'discount');
        expect(result.offerDetails, isNotNull);
        expect(result.offerDetails!['offers'], isA<List>());
        expect(result.offerDetails!['count'], 1);
        expect(result.offerDetails!['discount_percentage'], 10);
      });

      test('should parse offer metadata with multiple offers', () {
        // Arrange
        validJson['offer_metadata'] = [
          {
            'offer_id': 'offer_123',
            'offer_type': 'discount',
          },
          {
            'offer_id': 'offer_456',
            'offer_type': 'buy_x_get_y',
          },
        ];

        // Act
        final result = OrderModel.fromJson(validJson);

        // Assert
        expect(result.appliedOfferId, 'offer_123'); // First offer
        expect(result.appliedOfferType, 'discount');
        expect(result.offerDetails!['offers'], isA<List>());
        expect(result.offerDetails!['count'], 2);
      });

      test('should handle null offer metadata', () {
        // Arrange
        validJson['offer_metadata'] = null;

        // Act
        final result = OrderModel.fromJson(validJson);

        // Assert
        expect(result.appliedOfferId, null);
        expect(result.appliedOfferType, null);
        expect(result.offerDetails, null);
      });

      test('should handle empty offer metadata list', () {
        // Arrange
        validJson['offer_metadata'] = [];

        // Act
        final result = OrderModel.fromJson(validJson);

        // Assert
        expect(result.appliedOfferId, null);
        expect(result.appliedOfferType, null);
        expect(result.offerDetails, null);
      });

      test('should parse addresses correctly', () {
        // Act
        final result = OrderModel.fromJson(validJson);

        // Assert
        expect(result.shippingAddress, isNotNull);
        expect(result.shippingAddress!.fullName, 'John Doe');
        expect(result.billingAddress, isNotNull);
        expect(result.billingAddress!.fullName, 'John Doe');
      });

      group('_parseDouble', () {
        test('should parse double from various numeric types', () {
          // Arrange
          validJson['total_amount'] = 500;
          validJson['subtotal'] = '450.50';
          validJson['tax_amount'] = 30.75;

          // Act
          final result = OrderModel.fromJson(validJson);

          // Assert
          expect(result.totalAmount, 500.0);
          expect(result.subtotal, 450.50);
          expect(result.taxAmount, 30.75);
        });

        test('should return 0.0 for null numeric values', () {
          // Arrange
          validJson.remove('subtotal');
          validJson.remove('tax_amount');
          validJson.remove('shipping_amount');
          validJson.remove('discount_amount');

          // Act
          final result = OrderModel.fromJson(validJson);

          // Assert
          expect(result.subtotal, 0.0);
          expect(result.taxAmount, 0.0);
          expect(result.shippingAmount, 0.0);
          expect(result.discountAmount, 0.0);
        });

        test('should return 0.0 for invalid string values', () {
          // Arrange
          validJson['subtotal'] = 'invalid';
          validJson['tax_amount'] = 'not-a-number';

          // Act
          final result = OrderModel.fromJson(validJson);

          // Assert
          expect(result.subtotal, 0.0);
          expect(result.taxAmount, 0.0);
        });
      });

      test('should handle order items when provided', () {
        // Arrange
        validJson['order_items'] = [
          {
            'id': 'item_1',
            'order_id': 'order_123',
            'product_id': 'product_1',
            'quantity': 2.0,
            'unit_price': 50.0,
            'total_price': 100.0,
            'product_name': {'en': 'Product 1'},
            'created_at': testCreatedAt.toIso8601String(),
          }
        ];

        // Act
        final result = OrderModel.fromJson(validJson);

        // Assert
        expect(result.items, isNotEmpty);
        expect(result.items.length, 1);
        expect(result.items.first.productId, 'product_1');
      });
    });

    group('toJson', () {
      test('should convert OrderModel to JSON with all fields', () {
        // Arrange
        final model = OrderModel(
          id: 'order_123',
          customerUserId: 'customer_456',
          merchandiserId: 'merchandiser_789',
          orderNumber: 'ORD-2024-001',
          totalAmount: 500.0,
          status: 'pending',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          deliveryDate: testDeliveryDate,
          notes: 'Test notes',
          subtotal: 450.0,
          taxAmount: 30.0,
          shippingAmount: 20.0,
          discountAmount: 0.0,
          paymentStatus: 'pending',
          paymentMethod: 'cash_on_delivery',
          shippingAddress: const OrderAddress(
            fullName: 'John Doe',
            phoneNumber: '+201234567890',
            addressLine1: '123 Main Street',
            city: 'Cairo',
            country: 'Egypt',
          ),
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['id'], 'order_123');
        expect(result['customer_user_id'], 'customer_456');
        expect(result['merchandiser_id'], 'merchandiser_789');
        expect(result['order_number'], 'ORD-2024-001');
        expect(result['total_amount'], 500.0);
        expect(result['status'], 'pending');
        expect(result['created_at'], testCreatedAt.toIso8601String());
        expect(result['updated_at'], testUpdatedAt.toIso8601String());
        expect(result['delivery_date'], testDeliveryDate.toIso8601String());
        expect(result['notes'], 'Test notes');
        expect(result['subtotal'], 450.0);
        expect(result['tax_amount'], 30.0);
        expect(result['shipping_amount'], 20.0);
        expect(result['discount_amount'], 0.0);
        expect(result['payment_status'], 'pending');
        expect(result['payment_method'], 'cash_on_delivery');
        expect(result['shipping_address'], isNotNull);
      });

      test('should include offer_metadata in JSON', () {
        // Arrange
        final offerDetails = {
          'offers': [
            {'offer_id': 'offer_123', 'offer_type': 'discount'}
          ],
          'count': 1,
        };

        final model = OrderModel(
          id: 'order_123',
          customerUserId: 'customer_456',
          merchandiserId: 'merchandiser_789',
          orderNumber: 'ORD-2024-001',
          totalAmount: 500.0,
          status: 'pending',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          subtotal: 450.0,
          taxAmount: 30.0,
          shippingAmount: 20.0,
          discountAmount: 0.0,
          paymentStatus: 'pending',
          offerDetails: offerDetails,
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['offer_metadata'], isNotNull);
        expect(result['offer_metadata'], isA<List>());
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // Arrange
        final original = OrderModel(
          id: 'order_123',
          customerUserId: 'customer_456',
          merchandiserId: 'merchandiser_789',
          orderNumber: 'ORD-2024-001',
          totalAmount: 500.0,
          status: 'pending',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          subtotal: 450.0,
          taxAmount: 30.0,
          shippingAmount: 20.0,
          discountAmount: 0.0,
          paymentStatus: 'pending',
        );

        // Act
        final updated = original.copyWith(
          status: 'confirmed',
          paymentStatus: 'paid',
        );

        // Assert
        expect(updated.status, 'confirmed');
        expect(updated.paymentStatus, 'paid');
        expect(updated.id, original.id);
        expect(updated.orderNumber, original.orderNumber);
        expect(updated.totalAmount, original.totalAmount);
      });

      test('should not change original when copying', () {
        // Arrange
        final original = OrderModel(
          id: 'order_123',
          customerUserId: 'customer_456',
          merchandiserId: 'merchandiser_789',
          orderNumber: 'ORD-2024-001',
          totalAmount: 500.0,
          status: 'pending',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          subtotal: 450.0,
          taxAmount: 30.0,
          shippingAmount: 20.0,
          discountAmount: 0.0,
          paymentStatus: 'pending',
        );

        // Act
        original.copyWith(status: 'confirmed');

        // Assert
        expect(original.status, 'pending');
      });
    });

    group('extends Order', () {
      test('should be an instance of Order', () {
        // Arrange
        final model = OrderModel(
          id: 'order_123',
          customerUserId: 'customer_456',
          merchandiserId: 'merchandiser_789',
          orderNumber: 'ORD-2024-001',
          totalAmount: 500.0,
          status: 'pending',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          subtotal: 450.0,
          taxAmount: 30.0,
          shippingAmount: 20.0,
          discountAmount: 0.0,
          paymentStatus: 'pending',
        );

        // Assert
        expect(model, isA<Order>());
      });
    });

    group('JSON round trip', () {
      test('should maintain data integrity through JSON serialization', () {
        // Arrange
        final original = OrderModel(
          id: 'order_123',
          customerUserId: 'customer_456',
          merchandiserId: 'merchandiser_789',
          orderNumber: 'ORD-2024-001',
          totalAmount: 500.0,
          status: 'confirmed',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          deliveryDate: testDeliveryDate,
          notes: 'Test notes',
          subtotal: 450.0,
          taxAmount: 30.0,
          shippingAmount: 20.0,
          discountAmount: 50.0,
          paymentStatus: 'paid',
          paymentMethod: 'visa',
          customerName: 'John Doe',
          customerEmail: 'john@example.com',
          customerPhone: '+201234567890',
          merchandiserName: 'Test Store',
        );

        // Act
        final json = original.toJson();
        final restored = OrderModel.fromJson(json);

        // Assert
        expect(restored.id, original.id);
        expect(restored.customerUserId, original.customerUserId);
        expect(restored.merchandiserId, original.merchandiserId);
        expect(restored.orderNumber, original.orderNumber);
        expect(restored.totalAmount, original.totalAmount);
        expect(restored.status, original.status);
        expect(restored.paymentStatus, original.paymentStatus);
        expect(restored.subtotal, original.subtotal);
      });
    });

    group('edge cases', () {
      test('should handle all order statuses', () {
        final statuses = [
          'pending',
          'confirmed',
          'preparing',
          'on_the_way',
          'delivered',
          'cancelled'
        ];

        for (final status in statuses) {
          validJson['status'] = status;
          final result = OrderModel.fromJson(validJson);
          expect(result.status, status);
        }
      });

      test('should handle all payment statuses', () {
        final paymentStatuses = ['pending', 'paid', 'failed', 'refunded'];

        for (final paymentStatus in paymentStatuses) {
          validJson['payment_status'] = paymentStatus;
          final result = OrderModel.fromJson(validJson);
          expect(result.paymentStatus, paymentStatus);
        }
      });

      test('should handle all payment methods', () {
        final paymentMethods = [
          'cash_on_delivery',
          'visa',
          'instapay',
          'wallet'
        ];

        for (final method in paymentMethods) {
          validJson['payment_method'] = method;
          final result = OrderModel.fromJson(validJson);
          expect(result.paymentMethod, method);
        }
      });

      test('should handle very large amounts', () {
        // Arrange
        validJson['total_amount'] = 999999999.99;
        validJson['subtotal'] = 999999999.99;

        // Act
        final result = OrderModel.fromJson(validJson);

        // Assert
        expect(result.totalAmount, 999999999.99);
        expect(result.subtotal, 999999999.99);
      });

      test('should handle zero amounts', () {
        // Arrange
        validJson['total_amount'] = 0.0;
        validJson['subtotal'] = 0.0;
        validJson['tax_amount'] = 0.0;
        validJson['shipping_amount'] = 0.0;
        validJson['discount_amount'] = 0.0;

        // Act
        final result = OrderModel.fromJson(validJson);

        // Assert
        expect(result.totalAmount, 0.0);
        expect(result.subtotal, 0.0);
        expect(result.taxAmount, 0.0);
        expect(result.shippingAmount, 0.0);
        expect(result.discountAmount, 0.0);
      });
    });
  });
}
