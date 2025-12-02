// lib/features/orders/data/models/order_model.dart

import '../../domain/entities/order.dart';
import '../../domain/entities/order_address.dart';
import '../../domain/entities/order_item.dart';
import 'order_item_model.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.customerUserId,
    required super.merchandiserId,
    required super.orderNumber,
    required super.totalAmount,
    required super.status,
    required super.createdAt,
    super.deliveryDate,
    super.notes,
    required super.subtotal,
    required super.taxAmount,
    required super.shippingAmount,
    required super.discountAmount,
    required super.paymentStatus,
    super.paymentMethod,
    super.shippingAddress,
    super.billingAddress,
    required super.updatedAt,
    super.items,
    super.customerName,
    super.customerEmail,
    super.customerPhone,
    super.merchandiserName,
    super.appliedOfferId,
    super.appliedOfferType,
    super.offerDetails,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse offer metadata - this is what comes from the checkout page
    final offerMetadata = json['offer_metadata'];
    String? appliedOfferId;
    String? appliedOfferType;
    Map<String, dynamic>? offerDetails;

    // If offer_metadata exists and is a list with items
    if (offerMetadata != null &&
        offerMetadata is List &&
        offerMetadata.isNotEmpty) {
      // For now, we'll use the first offer for the main fields
      // But we'll keep all offers in offerDetails
      final firstOffer = offerMetadata[0] as Map<String, dynamic>;
      appliedOfferId = firstOffer['offer_id'] as String?;
      appliedOfferType = firstOffer['offer_type'] as String?;

      // Store the complete offer metadata structure
      offerDetails = {
        'offers': offerMetadata,
        'count': offerMetadata.length,
        // If there's a single offer, also store its details at root level for easy access
        if (offerMetadata.length == 1) ...firstOffer,
      };
    }

    return OrderModel(
      id: json['id'] as String,
      customerUserId: json['customer_user_id'] as String,
      merchandiserId: json['merchandiser_id'] as String,
      orderNumber: json['order_number'] as String,
      totalAmount: _parseDouble(json['total_amount']),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'] as String)
          : null,
      notes: json['notes'] as String?,
      subtotal: _parseDouble(json['subtotal'] ?? 0),
      taxAmount: _parseDouble(json['tax_amount'] ?? 0),
      shippingAmount: _parseDouble(json['shipping_amount'] ?? 0),
      discountAmount: _parseDouble(json['discount_amount'] ?? 0),
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String?,
      shippingAddress: json['shipping_address'] != null
          ? OrderAddress.fromJson(
              json['shipping_address'] as Map<String, dynamic>,
            )
          : null,
      billingAddress: json['billing_address'] != null
          ? OrderAddress.fromJson(
              json['billing_address'] as Map<String, dynamic>,
            )
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: json['order_items'] != null
          ? (json['order_items'] as List)
                .map(
                  (item) =>
                      OrderItemModel.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : [],
      customerName: json['customer_name'] as String?,
      customerEmail: json['customer_email'] as String?,
      customerPhone: json['customer_phone'] as String?,
      merchandiserName: json['merchandiser_name'] as String?,
      appliedOfferId: appliedOfferId,
      appliedOfferType: appliedOfferType,
      offerDetails: offerDetails,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_user_id': customerUserId,
      'merchandiser_id': merchandiserId,
      'order_number': orderNumber,
      'total_amount': totalAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'notes': notes,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'shipping_amount': shippingAmount,
      'discount_amount': discountAmount,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'shipping_address': shippingAddress?.toJson(),
      'billing_address': billingAddress?.toJson(),
      'updated_at': updatedAt.toIso8601String(),
      'offer_metadata': offerDetails?['offers'],
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerUserId,
    String? merchandiserId,
    String? orderNumber,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    DateTime? deliveryDate,
    String? notes,
    double? subtotal,
    double? taxAmount,
    double? shippingAmount,
    double? discountAmount,
    String? paymentStatus,
    String? paymentMethod,
    OrderAddress? shippingAddress,
    OrderAddress? billingAddress,
    DateTime? updatedAt,
    List<OrderItemEntity>? items,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? merchandiserName,
    String? appliedOfferId,
    String? appliedOfferType,
    Map<String, dynamic>? offerDetails,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerUserId: customerUserId ?? this.customerUserId,
      merchandiserId: merchandiserId ?? this.merchandiserId,
      orderNumber: orderNumber ?? this.orderNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      notes: notes ?? this.notes,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingAmount: shippingAmount ?? this.shippingAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      merchandiserName: merchandiserName ?? this.merchandiserName,
      appliedOfferId: appliedOfferId ?? this.appliedOfferId,
      appliedOfferType: appliedOfferType ?? this.appliedOfferType,
      offerDetails: offerDetails ?? this.offerDetails,
    );
  }
}
