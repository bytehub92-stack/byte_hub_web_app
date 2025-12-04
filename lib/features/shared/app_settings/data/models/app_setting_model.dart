// lib/features/shared/app_settings/data/models/app_setting_model.dart
import '../../domain/entities/app_setting.dart';

class AppSettingModel extends AppSetting {
  const AppSettingModel({
    required super.id,
    super.merchandiserId,
    required super.settingKey,
    required super.settingValue,
    super.description,
    required super.updatedAt,
  });

  /// Create from JSON
  factory AppSettingModel.fromJson(Map<String, dynamic> json) {
    return AppSettingModel(
      id: json['id'] as String,
      merchandiserId: json['merchandiser_id'] as String?,
      settingKey: json['setting_key'] as String,
      settingValue: Map<String, dynamic>.from(json['setting_value'] as Map),
      description: json['description'] != null
          ? Map<String, String>.from(json['description'] as Map)
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchandiser_id': merchandiserId,
      'setting_key': settingKey,
      'setting_value': settingValue,
      'description': description,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to Entity
  AppSetting toEntity() {
    return AppSetting(
      id: id,
      merchandiserId: merchandiserId,
      settingKey: settingKey,
      settingValue: settingValue,
      description: description,
      updatedAt: updatedAt,
    );
  }

  /// Create from Entity
  factory AppSettingModel.fromEntity(AppSetting entity) {
    return AppSettingModel(
      id: entity.id,
      merchandiserId: entity.merchandiserId,
      settingKey: entity.settingKey,
      settingValue: entity.settingValue,
      description: entity.description,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create a copy with updated fields
  AppSettingModel copyWith({
    String? id,
    String? merchandiserId,
    String? settingKey,
    Map<String, dynamic>? settingValue,
    Map<String, String>? description,
    DateTime? updatedAt,
  }) {
    return AppSettingModel(
      id: id ?? this.id,
      merchandiserId: merchandiserId ?? this.merchandiserId,
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      description: description ?? this.description,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
