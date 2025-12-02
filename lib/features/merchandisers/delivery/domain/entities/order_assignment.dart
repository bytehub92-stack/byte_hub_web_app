// lib/features/delivery/domain/entities/order_assignment.dart

import 'package:equatable/equatable.dart';

class OrderAssignment extends Equatable {
  final String id;
  final String orderId;
  final String driverId;
  final DateTime assignedAt;
  final String? assignedBy;
  final DateTime? deliveredAt;
  final String? notes;
  final String
  deliveryStatus; // assigned, picked_up, on_the_way, delivered, failed

  // Order details
  final String? orderNumber;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final double? orderAmount;
  final String? orderStatus;
  final String? paymentStatus;

  // Driver details
  final String? driverName;
  final String? driverPhone;

  const OrderAssignment({
    required this.id,
    required this.orderId,
    required this.driverId,
    required this.assignedAt,
    this.assignedBy,
    this.deliveredAt,
    this.notes,
    this.deliveryStatus = 'assigned',
    this.orderNumber,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.orderAmount,
    this.orderStatus,
    this.paymentStatus,
    this.driverName,
    this.driverPhone,
  });

  bool get isActive =>
      ['assigned', 'picked_up', 'on_the_way'].contains(deliveryStatus);
  bool get isCompleted => deliveryStatus == 'delivered';
  bool get isFailed => deliveryStatus == 'failed';

  String get deliveryStatusLabel {
    switch (deliveryStatus) {
      case 'assigned':
        return 'Assigned';
      case 'picked_up':
        return 'Picked Up';
      case 'on_the_way':
        return 'On the Way';
      case 'delivered':
        return 'Delivered';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    driverId,
    assignedAt,
    assignedBy,
    deliveredAt,
    notes,
    deliveryStatus,
    orderNumber,
    customerName,
    customerPhone,
    customerAddress,
    orderAmount,
    orderStatus,
    paymentStatus,
    driverName,
    driverPhone,
  ];
}
