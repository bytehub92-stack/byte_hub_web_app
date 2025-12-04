// lib/features/orders/domain/entities/order_address.dart

import 'package:equatable/equatable.dart';

class OrderAddress extends Equatable {
  final String fullName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? landmark;
  final String country;

  const OrderAddress({
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.landmark,
    required this.country,
  });

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      city,
      if (landmark != null && landmark!.isNotEmpty) landmark,
      country,
    ];
    return parts.join(', ');
  }

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String,
      landmark: json['landmark'] as String?,
      country: json['country'] as String? ?? 'Egypt',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'landmark': landmark,
      'country': country,
    };
  }

  @override
  List<Object?> get props => [
    fullName,
    phoneNumber,
    addressLine1,
    addressLine2,
    city,
    landmark,
    country,
  ];
}
