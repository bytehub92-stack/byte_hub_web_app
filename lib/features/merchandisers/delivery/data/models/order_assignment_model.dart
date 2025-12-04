// lib/features/delivery/data/models/order_assignment_model.dart

import '../../domain/entities/order_assignment.dart';

class OrderAssignmentModel extends OrderAssignment {
  const OrderAssignmentModel({
    required super.id,
    required super.orderId,
    required super.driverId,
    required super.assignedAt,
    super.assignedBy,
    super.deliveredAt,
    super.notes,
    super.deliveryStatus,
    super.orderNumber,
    super.customerName,
    super.customerPhone,
    super.customerAddress,
    super.orderAmount,
    super.orderStatus,
    super.paymentStatus,
    super.driverName,
    super.driverPhone,
  });

  factory OrderAssignmentModel.fromJson(Map<String, dynamic> json) {
    final orderData = json['orders'];
    final driverData = json['drivers'];
    final profileData = orderData?['profiles'];
    final driverProfileData = driverData?['profiles'];
    final shippingAddress = orderData?['shipping_address'];

    return OrderAssignmentModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      driverId: json['driver_id'] as String,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      assignedBy: json['assigned_by'] as String?,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      notes: json['notes'] as String?,
      deliveryStatus: json['delivery_status'] as String? ?? 'assigned',
      orderNumber: orderData?['order_number'] as String?,
      customerName: profileData?['full_name'] as String?,
      customerPhone: profileData?['phone_number'] as String?,
      customerAddress: shippingAddress != null
          ? _formatAddress(shippingAddress)
          : null,
      orderAmount: orderData?['total_amount'] != null
          ? _parseDouble(orderData['total_amount'])
          : null,
      orderStatus: orderData?['status'] as String?,
      paymentStatus: orderData?['payment_status'] as String?,
      driverName: driverProfileData?['full_name'] as String?,
      driverPhone: driverProfileData?['phone_number'] as String?,
    );
  }

  static String _formatAddress(Map<String, dynamic> address) {
    final parts = <String>[];
    if (address['street_address'] != null) {
      parts.add(address['street_address']);
    }
    if (address['city'] != null) parts.add(address['city']);
    if (address['state'] != null) parts.add(address['state']);
    return parts.join(', ');
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
      'driver_id': driverId,
      'assigned_at': assignedAt.toIso8601String(),
      'assigned_by': assignedBy,
      'delivered_at': deliveredAt?.toIso8601String(),
      'notes': notes,
      'delivery_status': deliveryStatus,
    };
  }
}
