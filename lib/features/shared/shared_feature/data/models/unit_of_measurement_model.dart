// lib/features/shared/data/models/unit_of_measurement_model.dart

import 'package:admin_panel/features/shared/shared_feature/domain/entities/unit_of_measurement.dart';

class UnitOfMeasurementModel extends UnitOfMeasurement {
  const UnitOfMeasurementModel({
    required super.id,
    required super.code,
    required super.name,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UnitOfMeasurementModel.fromJson(Map<String, dynamic> json) {
    return UnitOfMeasurementModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: _parseJsonbField(json['name']),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static Map<String, String> _parseJsonbField(dynamic field) {
    if (field == null) return {};
    if (field is Map) {
      return field.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    return {};
  }

  UnitOfMeasurementModel copyWith({
    String? id,
    String? code,
    Map<String, String>? name,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UnitOfMeasurementModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
