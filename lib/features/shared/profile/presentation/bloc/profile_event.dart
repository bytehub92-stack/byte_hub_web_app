// lib/features/profile/presentation/bloc/profile_event.dart
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends ProfileEvent {
  final String? phoneNumber;
  final String? fullName;
  final String? website;
  final Map<String, dynamic>? businessName;
  final Map<String, dynamic>? businessType;
  final Map<String, dynamic>? description;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? city;
  final Map<String, dynamic>? state;
  final Map<String, dynamic>? country;
  final String? postalCode;
  final String? taxId;

  const UpdateProfile({
    this.phoneNumber,
    this.fullName,
    this.website,
    this.businessName,
    this.businessType,
    this.description,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.taxId,
  });

  @override
  List<Object?> get props => [
    phoneNumber,
    fullName,
    website,
    businessName,
    businessType,
    description,
    address,
    city,
    state,
    country,
    postalCode,
    taxId,
  ];
}

class UploadLogo extends ProfileEvent {
  final Uint8List imageBytes;

  const UploadLogo(this.imageBytes);

  @override
  List<Object> get props => [imageBytes];
}

class ChangePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}
