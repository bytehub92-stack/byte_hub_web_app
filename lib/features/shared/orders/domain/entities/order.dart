// lib/features/orders/domain/entities/order.dart

import 'package:admin_panel/features/shared/orders/domain/entities/order_address.dart';
import 'package:admin_panel/features/shared/orders/domain/entities/order_item.dart';
import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final String customerUserId;
  final String merchandiserId;
  final String orderNumber;
  final double totalAmount;
  final String
  status; // pending, confirmed, preparing, on_the_way, delivered, cancelled
  final DateTime createdAt;
  final DateTime? deliveryDate;
  final String? notes;
  final double subtotal;
  final double taxAmount;
  final double shippingAmount;
  final double discountAmount;
  final String paymentStatus; // pending, paid, failed, refunded
  final String? paymentMethod; // cash_on_delivery, visa, instapay, wallet
  final OrderAddress? shippingAddress;
  final OrderAddress? billingAddress;
  final DateTime updatedAt;
  final List<OrderItemEntity> items;

  final String? appliedOfferId; // NEW: Which offer was applied
  final String? appliedOfferType; // NEW: Type of offer
  final Map<String, dynamic>? offerDetails; // NEW: Offer metadata

  // Additional fields for display
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? merchandiserName;

  const Order({
    required this.id,
    required this.customerUserId,
    required this.merchandiserId,
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.deliveryDate,
    this.notes,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingAmount,
    required this.discountAmount,
    required this.paymentStatus,
    this.paymentMethod,
    this.shippingAddress,
    this.billingAddress,
    required this.updatedAt,
    this.items = const [],
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.merchandiserName,
    this.appliedOfferId,
    this.appliedOfferType,
    this.offerDetails,
  });

  bool get canBeCancelled => status == 'pending' || status == 'confirmed';

  bool get canBeConfirmed => status == 'pending';

  bool get canBePrepared => status == 'confirmed';

  bool get canBeShipped => status == 'preparing';

  bool get canBeDelivered => status == 'on_the_way';

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'on_the_way':
        return 'On the Way';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get paymentStatusLabel {
    switch (paymentStatus) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return paymentStatus;
    }
  }

  @override
  List<Object?> get props => [
    id,
    customerUserId,
    merchandiserId,
    orderNumber,
    totalAmount,
    status,
    createdAt,
    deliveryDate,
    notes,
    subtotal,
    taxAmount,
    shippingAmount,
    discountAmount,
    paymentStatus,
    paymentMethod,
    shippingAddress,
    billingAddress,
    updatedAt,
    items,
    customerName,
    customerEmail,
    customerPhone,
    merchandiserName,
  ];
}
