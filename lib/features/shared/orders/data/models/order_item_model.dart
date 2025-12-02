// lib/features/orders/data/models/order_item_model.dart

import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.quantity,
    required super.unitPrice,
    required super.totalPrice,
    required super.productName,
    super.productImage,
    required super.createdAt,
    super.isFreeItem,
    super.offerId,
    super.offerType,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      quantity: _parseDouble(json['quantity']),
      unitPrice: _parseDouble(json['unit_price']),
      totalPrice: _parseDouble(json['total_price']),
      productName: _parseProductName(json['product_name']),
      productImage: json['product_image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isFreeItem: json['is_free_item'] as bool? ?? false,
      offerId: json['offer_id'] as String?,
      offerType: json['offer_type'] as String?,
    );
  }

  static Map<String, String> _parseProductName(dynamic value) {
    if (value == null) return {'en': 'Unknown Product'};
    if (value is Map) {
      return Map<String, String>.from(value);
    }
    if (value is String) {
      return {'en': value};
    }
    return {'en': 'Unknown Product'};
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
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'product_name': productName,
      'product_image': productImage,
      'created_at': createdAt.toIso8601String(),
      'is_free_item': isFreeItem,
      'offer_id': offerId,
      'offer_type': offerType,
    };
  }
}
