// test/features/orders/domain/entities/order_test.dart

import 'package:admin_panel/features/shared/orders/domain/entities/order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Order Entity', () {
    late Order testOrder;

    setUp(() {
      testOrder = Order(
        id: 'order_1',
        customerUserId: 'customer_1',
        merchandiserId: 'merchandiser_1',
        orderNumber: 'ORD-2024-001',
        totalAmount: 500.0,
        status: 'pending',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
        subtotal: 450.0,
        taxAmount: 30.0,
        shippingAmount: 20.0,
        discountAmount: 0.0,
        paymentStatus: 'pending',
      );
    });

    group('canBeCancelled', () {
      test('should return true when status is pending', () {
        // Arrange
        final order = testOrder.copyWith(status: 'pending');

        // Act & Assert
        expect(order.canBeCancelled, isTrue);
      });

      test('should return true when status is confirmed', () {
        // Arrange
        final order = testOrder.copyWith(status: 'confirmed');

        // Act & Assert
        expect(order.canBeCancelled, isTrue);
      });

      test('should return false when status is preparing', () {
        // Arrange
        final order = testOrder.copyWith(status: 'preparing');

        // Act & Assert
        expect(order.canBeCancelled, isFalse);
      });

      test('should return false when status is on_the_way', () {
        // Arrange
        final order = testOrder.copyWith(status: 'on_the_way');

        // Act & Assert
        expect(order.canBeCancelled, isFalse);
      });

      test('should return false when status is delivered', () {
        // Arrange
        final order = testOrder.copyWith(status: 'delivered');

        // Act & Assert
        expect(order.canBeCancelled, isFalse);
      });

      test('should return false when status is cancelled', () {
        // Arrange
        final order = testOrder.copyWith(status: 'cancelled');

        // Act & Assert
        expect(order.canBeCancelled, isFalse);
      });
    });

    group('canBeConfirmed', () {
      test('should return true when status is pending', () {
        // Arrange
        final order = testOrder.copyWith(status: 'pending');

        // Act & Assert
        expect(order.canBeConfirmed, isTrue);
      });

      test('should return false when status is not pending', () {
        // Arrange
        final order = testOrder.copyWith(status: 'confirmed');

        // Act & Assert
        expect(order.canBeConfirmed, isFalse);
      });
    });

    group('canBePrepared', () {
      test('should return true when status is confirmed', () {
        // Arrange
        final order = testOrder.copyWith(status: 'confirmed');

        // Act & Assert
        expect(order.canBePrepared, isTrue);
      });

      test('should return false when status is not confirmed', () {
        // Arrange
        final order = testOrder.copyWith(status: 'pending');

        // Act & Assert
        expect(order.canBePrepared, isFalse);
      });
    });

    group('canBeShipped', () {
      test('should return true when status is preparing', () {
        // Arrange
        final order = testOrder.copyWith(status: 'preparing');

        // Act & Assert
        expect(order.canBeShipped, isTrue);
      });

      test('should return false when status is not preparing', () {
        // Arrange
        final order = testOrder.copyWith(status: 'confirmed');

        // Act & Assert
        expect(order.canBeShipped, isFalse);
      });
    });

    group('canBeDelivered', () {
      test('should return true when status is on_the_way', () {
        // Arrange
        final order = testOrder.copyWith(status: 'on_the_way');

        // Act & Assert
        expect(order.canBeDelivered, isTrue);
      });

      test('should return false when status is not on_the_way', () {
        // Arrange
        final order = testOrder.copyWith(status: 'preparing');

        // Act & Assert
        expect(order.canBeDelivered, isFalse);
      });
    });

    group('statusLabel', () {
      test('should return correct label for pending status', () {
        // Arrange
        final order = testOrder.copyWith(status: 'pending');

        // Act & Assert
        expect(order.statusLabel, 'Pending');
      });

      test('should return correct label for confirmed status', () {
        // Arrange
        final order = testOrder.copyWith(status: 'confirmed');

        // Act & Assert
        expect(order.statusLabel, 'Confirmed');
      });

      test('should return correct label for preparing status', () {
        // Arrange
        final order = testOrder.copyWith(status: 'preparing');

        // Act & Assert
        expect(order.statusLabel, 'Preparing');
      });

      test('should return correct label for on_the_way status', () {
        // Arrange
        final order = testOrder.copyWith(status: 'on_the_way');

        // Act & Assert
        expect(order.statusLabel, 'On the Way');
      });

      test('should return correct label for delivered status', () {
        // Arrange
        final order = testOrder.copyWith(status: 'delivered');

        // Act & Assert
        expect(order.statusLabel, 'Delivered');
      });

      test('should return correct label for cancelled status', () {
        // Arrange
        final order = testOrder.copyWith(status: 'cancelled');

        // Act & Assert
        expect(order.statusLabel, 'Cancelled');
      });

      test('should return status as-is for unknown status', () {
        // Arrange
        final order = testOrder.copyWith(status: 'unknown_status');

        // Act & Assert
        expect(order.statusLabel, 'unknown_status');
      });
    });

    group('paymentStatusLabel', () {
      test('should return correct label for pending payment', () {
        // Arrange
        final order = testOrder.copyWith(paymentStatus: 'pending');

        // Act & Assert
        expect(order.paymentStatusLabel, 'Pending');
      });

      test('should return correct label for paid payment', () {
        // Arrange
        final order = testOrder.copyWith(paymentStatus: 'paid');

        // Act & Assert
        expect(order.paymentStatusLabel, 'Paid');
      });

      test('should return correct label for failed payment', () {
        // Arrange
        final order = testOrder.copyWith(paymentStatus: 'failed');

        // Act & Assert
        expect(order.paymentStatusLabel, 'Failed');
      });

      test('should return correct label for refunded payment', () {
        // Arrange
        final order = testOrder.copyWith(paymentStatus: 'refunded');

        // Act & Assert
        expect(order.paymentStatusLabel, 'Refunded');
      });

      test('should return payment status as-is for unknown status', () {
        // Arrange
        final order = testOrder.copyWith(paymentStatus: 'unknown_payment');

        // Act & Assert
        expect(order.paymentStatusLabel, 'unknown_payment');
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        final order1 = Order(
          id: 'order_1',
          customerUserId: 'customer_1',
          merchandiserId: 'merchandiser_1',
          orderNumber: 'ORD-2024-001',
          totalAmount: 500.0,
          status: 'pending',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
          subtotal: 450.0,
          taxAmount: 30.0,
          shippingAmount: 20.0,
          discountAmount: 0.0,
          paymentStatus: 'pending',
        );

        final order2 = Order(
          id: 'order_1',
          customerUserId: 'customer_1',
          merchandiserId: 'merchandiser_1',
          orderNumber: 'ORD-2024-001',
          totalAmount: 500.0,
          status: 'pending',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
          subtotal: 450.0,
          taxAmount: 30.0,
          shippingAmount: 20.0,
          discountAmount: 0.0,
          paymentStatus: 'pending',
        );

        // Act & Assert
        expect(order1, equals(order2));
        expect(order1.hashCode, equals(order2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final order1 = testOrder;
        final order2 = testOrder.copyWith(id: 'order_2');

        // Act & Assert
        expect(order1, isNot(equals(order2)));
      });
    });

    group('offer fields', () {
      test('should support offer metadata', () {
        // Arrange
        final orderWithOffer = Order(
          id: 'order_1',
          customerUserId: 'customer_1',
          merchandiserId: 'merchandiser_1',
          orderNumber: 'ORD-2024-001',
          totalAmount: 450.0,
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          subtotal: 450.0,
          taxAmount: 30.0,
          shippingAmount: 20.0,
          discountAmount: 50.0,
          paymentStatus: 'pending',
          appliedOfferId: 'offer_123',
          appliedOfferType: 'discount',
          offerDetails: {
            'discount_percentage': 10,
            'offer_name': 'Summer Sale',
          },
        );

        // Act & Assert
        expect(orderWithOffer.appliedOfferId, 'offer_123');
        expect(orderWithOffer.appliedOfferType, 'discount');
        expect(orderWithOffer.offerDetails, isNotNull);
        expect(orderWithOffer.offerDetails!['discount_percentage'], 10);
      });

      test('should handle null offer fields', () {
        // Arrange
        final orderWithoutOffer = testOrder;

        // Act & Assert
        expect(orderWithoutOffer.appliedOfferId, isNull);
        expect(orderWithoutOffer.appliedOfferType, isNull);
        expect(orderWithoutOffer.offerDetails, isNull);
      });
    });

    group('state transition logic', () {
      test('should follow correct order lifecycle', () {
        // Start with pending order
        var order = testOrder.copyWith(status: 'pending');
        expect(order.canBeConfirmed, isTrue);
        expect(order.canBeCancelled, isTrue);

        // Confirm the order
        order = order.copyWith(status: 'confirmed');
        expect(order.canBeConfirmed, isFalse);
        expect(order.canBePrepared, isTrue);
        expect(order.canBeCancelled, isTrue);

        // Start preparing
        order = order.copyWith(status: 'preparing');
        expect(order.canBePrepared, isFalse);
        expect(order.canBeShipped, isTrue);
        expect(order.canBeCancelled, isFalse);

        // Ship the order
        order = order.copyWith(status: 'on_the_way');
        expect(order.canBeShipped, isFalse);
        expect(order.canBeDelivered, isTrue);
        expect(order.canBeCancelled, isFalse);

        // Deliver the order
        order = order.copyWith(status: 'delivered');
        expect(order.canBeDelivered, isFalse);
        expect(order.canBeCancelled, isFalse);
      });

      test('should allow cancellation only in early stages', () {
        // Test each status for cancellation eligibility
        expect(testOrder.copyWith(status: 'pending').canBeCancelled, isTrue);
        expect(testOrder.copyWith(status: 'confirmed').canBeCancelled, isTrue);
        expect(testOrder.copyWith(status: 'preparing').canBeCancelled, isFalse);
        expect(
            testOrder.copyWith(status: 'on_the_way').canBeCancelled, isFalse);
        expect(testOrder.copyWith(status: 'delivered').canBeCancelled, isFalse);
        expect(testOrder.copyWith(status: 'cancelled').canBeCancelled, isFalse);
      });
    });
  });
}

// Add extension method for copyWith to make tests easier
extension OrderCopyWith on Order {
  Order copyWith({
    String? id,
    String? status,
    String? paymentStatus,
  }) {
    return Order(
      id: id ?? this.id,
      customerUserId: customerUserId,
      merchandiserId: merchandiserId,
      orderNumber: orderNumber,
      totalAmount: totalAmount,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      subtotal: subtotal,
      taxAmount: taxAmount,
      shippingAmount: shippingAmount,
      discountAmount: discountAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryDate: deliveryDate,
      notes: notes,
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress,
      billingAddress: billingAddress,
      items: items,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      merchandiserName: merchandiserName,
      appliedOfferId: appliedOfferId,
      appliedOfferType: appliedOfferType,
      offerDetails: offerDetails,
    );
  }
}
