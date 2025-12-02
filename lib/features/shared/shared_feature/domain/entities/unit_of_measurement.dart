// lib/features/shared/domain/entities/unit_of_measurement.dart

import 'package:equatable/equatable.dart';

class UnitOfMeasurement extends Equatable {
  final String id;
  final String code;
  final Map<String, String> name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UnitOfMeasurement({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, code, name, isActive, createdAt, updatedAt];
}
