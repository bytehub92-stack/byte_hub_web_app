// lib/features/delivery/presentation/bloc/delivery_event.dart

import 'package:equatable/equatable.dart';

abstract class DeliveryEvent extends Equatable {
  const DeliveryEvent();

  @override
  List<Object?> get props => [];
}

// ==================== Merchandiser Events ====================

class LoadDrivers extends DeliveryEvent {
  final String merchandiserId;

  const LoadDrivers(this.merchandiserId);

  @override
  List<Object?> get props => [merchandiserId];
}

class LoadDriverById extends DeliveryEvent {
  final String driverId;

  const LoadDriverById(this.driverId);

  @override
  List<Object?> get props => [driverId];
}

class AssignOrderToDriver extends DeliveryEvent {
  final String orderId;
  final String driverId;
  final String assignedBy;
  final String? notes;

  const AssignOrderToDriver({
    required this.orderId,
    required this.driverId,
    required this.assignedBy,
    this.notes,
  });

  @override
  List<Object?> get props => [orderId, driverId, assignedBy, notes];
}

class LoadOrderAssignments extends DeliveryEvent {
  final String merchandiserId;
  final String? driverId;
  final bool? onlyActive;

  const LoadOrderAssignments({
    required this.merchandiserId,
    this.driverId,
    this.onlyActive,
  });

  @override
  List<Object?> get props => [merchandiserId, driverId, onlyActive];
}

class UnassignOrder extends DeliveryEvent {
  final String orderId;

  const UnassignOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class LoadDeliveryStatistics extends DeliveryEvent {
  final String merchandiserId;

  const LoadDeliveryStatistics(this.merchandiserId);

  @override
  List<Object?> get props => [merchandiserId];
}

class LoadMerchandiserCode extends DeliveryEvent {
  final String merchandiserId;

  const LoadMerchandiserCode(this.merchandiserId);

  @override
  List<Object?> get props => [merchandiserId];
}

// ==================== Driver Events ====================

class LoadCurrentDriver extends DeliveryEvent {
  const LoadCurrentDriver();
}

class RegisterDriverWithCode extends DeliveryEvent {
  final String merchandiserCode;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? licenseNumber;

  const RegisterDriverWithCode({
    required this.merchandiserCode,
    this.vehicleType,
    this.vehicleNumber,
    this.licenseNumber,
  });

  @override
  List<Object?> get props => [
    merchandiserCode,
    vehicleType,
    vehicleNumber,
    licenseNumber,
  ];
}

class UpdateDriverInfo extends DeliveryEvent {
  final String driverId;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? licenseNumber;

  const UpdateDriverInfo({
    required this.driverId,
    this.vehicleType,
    this.vehicleNumber,
    this.licenseNumber,
  });

  @override
  List<Object?> get props => [
    driverId,
    vehicleType,
    vehicleNumber,
    licenseNumber,
  ];
}

class ToggleDriverAvailability extends DeliveryEvent {
  final String driverId;
  final bool isAvailable;

  const ToggleDriverAvailability({
    required this.driverId,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [driverId, isAvailable];
}

class LoadDriverAssignments extends DeliveryEvent {
  final String driverId;
  final bool? onlyActive;

  const LoadDriverAssignments({required this.driverId, this.onlyActive});

  @override
  List<Object?> get props => [driverId, onlyActive];
}

class UpdateDeliveryStatus extends DeliveryEvent {
  final String assignmentId;
  final String status;

  const UpdateDeliveryStatus({
    required this.assignmentId,
    required this.status,
  });

  @override
  List<Object?> get props => [assignmentId, status];
}

class MarkAsDelivered extends DeliveryEvent {
  final String assignmentId;

  const MarkAsDelivered(this.assignmentId);

  @override
  List<Object?> get props => [assignmentId];
}

class LoadDriverStatistics extends DeliveryEvent {
  final String driverId;

  const LoadDriverStatistics(this.driverId);

  @override
  List<Object?> get props => [driverId];
}
