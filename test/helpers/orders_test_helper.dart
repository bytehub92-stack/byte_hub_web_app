// test/helpers/test_helpers.dart

import 'package:admin_panel/features/shared/orders/domain/entities/order.dart';
import 'package:admin_panel/features/shared/orders/domain/entities/order_address.dart';
import 'package:admin_panel/features/shared/orders/domain/entities/order_item.dart';

/// Helper class to create test orders with default values
class OrderTestHelper {
  static Order createOrder({
    String id = 'order_1',
    String customerId = 'customer_1',
    String merchandiserId = 'merchandiser_1',
    String orderNumber = 'ORD-2024-001',
    double totalAmount = 500.0,
    String status = 'pending',
    String paymentStatus = 'pending',
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveryDate,
    String? notes,
    double subtotal = 450.0,
    double taxAmount = 30.0,
    double shippingAmount = 20.0,
    double discountAmount = 0.0,
    String? paymentMethod,
    OrderAddress? shippingAddress,
    OrderAddress? billingAddress,
    List<OrderItemEntity> items = const [],
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? merchandiserName,
    String? appliedOfferId,
    String? appliedOfferType,
    Map<String, dynamic>? offerDetails,
  }) {
    return Order(
      id: id,
      customerUserId: customerId,
      merchandiserId: merchandiserId,
      orderNumber: orderNumber,
      totalAmount: totalAmount,
      status: status,
      createdAt: createdAt ?? DateTime(2024, 1, 15, 10, 30),
      updatedAt: updatedAt ?? DateTime(2024, 1, 15, 10, 30),
      deliveryDate: deliveryDate,
      notes: notes,
      subtotal: subtotal,
      taxAmount: taxAmount,
      shippingAmount: shippingAmount,
      discountAmount: discountAmount,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress,
      billingAddress: billingAddress,
      items: items,
      customerName: customerName ?? 'John Doe',
      customerEmail: customerEmail ?? 'john@example.com',
      customerPhone: customerPhone ?? '+201234567890',
      merchandiserName: merchandiserName ?? 'Test Store',
      appliedOfferId: appliedOfferId,
      appliedOfferType: appliedOfferType,
      offerDetails: offerDetails,
    );
  }

  static OrderAddress createAddress({
    String fullName = 'John Doe',
    String phoneNumber = '+201234567890',
    String addressLine1 = '123 Main Street',
    String? addressLine2,
    String city = 'Cairo',
    String? landmark,
    String country = 'Egypt',
  }) {
    return OrderAddress(
      fullName: fullName,
      phoneNumber: phoneNumber,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      landmark: landmark,
      country: country,
    );
  }

  static OrderItemEntity createOrderItem({
    String id = 'item_1',
    String orderId = 'order_1',
    String productId = 'product_1',
    double quantity = 2.0,
    double unitPrice = 50.0,
    double totalPrice = 100.0,
    Map<String, String>? productName,
    String? productImage,
    DateTime? createdAt,
    bool isFreeItem = false,
    String? offerId,
    String? offerType,
  }) {
    return OrderItemEntity(
      id: id,
      orderId: orderId,
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      productName:
          productName ?? const {'en': 'Test Product', 'ar': 'منتج تجريبي'},
      productImage: productImage,
      createdAt: createdAt ?? DateTime(2024, 1, 15, 10, 30),
      isFreeItem: isFreeItem,
      offerId: offerId,
      offerType: offerType,
    );
  }

  static List<Order> createOrderList({
    int count = 3,
    String? status,
    String? paymentStatus,
  }) {
    return List.generate(
      count,
      (index) => createOrder(
        id: 'order_${index + 1}',
        orderNumber: 'ORD-2024-00${index + 1}',
        status: status ?? 'pending',
        paymentStatus: paymentStatus ?? 'pending',
      ),
    );
  }

  static Map<String, dynamic> createOrderStatistics({
    int totalOrders = 100,
    int pendingOrders = 20,
    int confirmedOrders = 30,
    int preparingOrders = 15,
    int onTheWayOrders = 10,
    int deliveredOrders = 20,
    int cancelledOrders = 5,
    double totalRevenue = 50000.0,
  }) {
    return {
      'total_orders': totalOrders,
      'pending_orders': pendingOrders,
      'confirmed_orders': confirmedOrders,
      'preparing_orders': preparingOrders,
      'on_the_way_orders': onTheWayOrders,
      'delivered_orders': deliveredOrders,
      'cancelled_orders': cancelledOrders,
      'total_revenue': totalRevenue,
    };
  }
}

/// Helper to create order JSON for testing data models
class OrderJsonHelper {
  static Map<String, dynamic> createOrderJson({
    String id = 'order_1',
    String customerId = 'customer_1',
    String merchandiserId = 'merchandiser_1',
    String orderNumber = 'ORD-2024-001',
    double totalAmount = 500.0,
    String status = 'pending',
    String paymentStatus = 'pending',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final date = createdAt ?? DateTime(2024, 1, 15, 10, 30);
    return {
      'id': id,
      'customer_user_id': customerId,
      'merchandiser_id': merchandiserId,
      'order_number': orderNumber,
      'total_amount': totalAmount,
      'status': status,
      'created_at': date.toIso8601String(),
      'updated_at': (updatedAt ?? date).toIso8601String(),
      'subtotal': 450.0,
      'tax_amount': 30.0,
      'shipping_amount': 20.0,
      'discount_amount': 0.0,
      'payment_status': paymentStatus,
      'customer_name': 'John Doe',
      'customer_email': 'john@example.com',
      'customer_phone': '+201234567890',
      'merchandiser_name': 'Test Store',
    };
  }

  static Map<String, dynamic> createOrderItemJson({
    String id = 'item_1',
    String orderId = 'order_1',
    String productId = 'product_1',
    DateTime? createdAt,
  }) {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': 2.0,
      'unit_price': 50.0,
      'total_price': 100.0,
      'product_name': {'en': 'Test Product', 'ar': 'منتج تجريبي'},
      'product_image': 'https://example.com/image.jpg',
      'created_at':
          (createdAt ?? DateTime(2024, 1, 15, 10, 30)).toIso8601String(),
      'is_free_item': false,
    };
  }

  static Map<String, dynamic> createAddressJson({
    String fullName = 'John Doe',
    String phoneNumber = '+201234567890',
  }) {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address_line1': '123 Main Street',
      'address_line2': 'Apt 4B',
      'city': 'Cairo',
      'landmark': 'Near City Mall',
      'country': 'Egypt',
    };
  }
}

/// Constants for testing
class OrderTestConstants {
  static const String testCustomerId = 'customer_test_123';
  static const String testMerchandiserId = 'merchandiser_test_456';
  static const String testOrderId = 'order_test_789';
  static const String testOrderNumber = 'ORD-TEST-001';

  static final DateTime testDate = DateTime(2024, 1, 15, 10, 30);

  static const List<String> validStatuses = [
    'pending',
    'confirmed',
    'preparing',
    'on_the_way',
    'delivered',
    'cancelled',
  ];

  static const List<String> validPaymentStatuses = [
    'pending',
    'paid',
    'failed',
    'refunded',
  ];

  static const List<String> validPaymentMethods = [
    'cash_on_delivery',
    'visa',
    'instapay',
    'wallet',
  ];
}
