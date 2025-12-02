// lib/features/delivery/domain/entities/driver.dart

import 'package:equatable/equatable.dart';

class Driver extends Equatable {
  final String id;
  final String profileId;
  final String merchandiserId;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? licenseNumber;
  final bool isAvailable;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields for display
  final int? activeOrdersCount;
  final int? completedOrdersCount;

  const Driver({
    required this.id,
    required this.profileId,
    required this.merchandiserId,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.vehicleType,
    this.vehicleNumber,
    this.licenseNumber,
    required this.isAvailable,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.activeOrdersCount,
    this.completedOrdersCount,
  });

  String get vehicleInfo {
    if (vehicleType != null && vehicleNumber != null) {
      return '$vehicleType - $vehicleNumber';
    }
    return vehicleType ?? 'No vehicle info';
  }

  String get statusLabel {
    if (!isActive) return 'Inactive';
    return isAvailable ? 'Available' : 'Busy';
  }

  @override
  List<Object?> get props => [
        id,
        profileId,
        merchandiserId,
        fullName,
        email,
        phoneNumber,
        vehicleType,
        vehicleNumber,
        licenseNumber,
        isAvailable,
        isActive,
        createdAt,
        updatedAt,
        activeOrdersCount,
        completedOrdersCount,
      ];
}
