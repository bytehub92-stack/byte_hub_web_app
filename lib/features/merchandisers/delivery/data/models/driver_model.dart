// lib/features/delivery/data/models/driver_model.dart

import '../../domain/entities/driver.dart';

class DriverModel extends Driver {
  const DriverModel({
    required super.id,
    required super.profileId,
    required super.merchandiserId,
    required super.fullName,
    super.email,
    super.phoneNumber,
    super.vehicleType,
    super.vehicleNumber,
    super.licenseNumber,
    required super.isAvailable,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.activeOrdersCount,
    super.completedOrdersCount,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    // Extract profile data if nested
    final profileData = json['profiles'];

    return DriverModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      merchandiserId: json['merchandiser_id'] as String,
      fullName: profileData != null
          ? profileData['full_name'] as String
          : json['full_name'] as String? ?? 'Unknown',
      email: profileData != null
          ? profileData['email'] as String?
          : json['email'] as String?,
      phoneNumber: profileData != null
          ? profileData['phone_number'] as String?
          : json['phone_number'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      licenseNumber: json['license_number'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      activeOrdersCount: json['active_orders_count'] as int?,
      completedOrdersCount: json['completed_orders_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'merchandiser_id': merchandiserId,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'license_number': licenseNumber,
      'is_available': isAvailable,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
