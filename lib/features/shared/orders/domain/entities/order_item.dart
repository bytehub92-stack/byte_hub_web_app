// lib/features/orders/domain/entities/order_item.dart

import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final Map<String, String> productName;
  final String? productImage;
  final DateTime createdAt;
  final bool isFreeItem; // NEW: Is this a free promotional item?
  final String? offerId; // NEW: Associated offer ID
  final String? offerType; // NEW: Type of offer

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.productName,
    this.productImage,
    required this.createdAt,
    this.isFreeItem = false,
    this.offerId,
    this.offerType,
  });

  String getName(String languageCode) {
    return productName[languageCode] ?? productName['en'] ?? 'Unknown Product';
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    productId,
    quantity,
    unitPrice,
    totalPrice,
    productName,
    productImage,
    createdAt,
  ];
}
