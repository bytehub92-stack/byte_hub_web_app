// lib/features/shared/app_settings/presentation/bloc/app_settings_event.dart
import 'package:equatable/equatable.dart';

abstract class AppSettingsEvent extends Equatable {
  const AppSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppSetting extends AppSettingsEvent {
  final String settingKey;
  final String? merchandiserId;

  const LoadAppSetting({required this.settingKey, this.merchandiserId});

  @override
  List<Object?> get props => [settingKey, merchandiserId];
}

class LoadAboutSectionSettings extends AppSettingsEvent {
  const LoadAboutSectionSettings();
}

class UpdateAppSettingEvent extends AppSettingsEvent {
  final String settingKey;
  final Map<String, dynamic> settingValue;
  final Map<String, String>? description;
  final String? merchandiserId;

  const UpdateAppSettingEvent({
    required this.settingKey,
    required this.settingValue,
    this.description,
    this.merchandiserId,
  });

  @override
  List<Object?> get props => [
    settingKey,
    settingValue,
    description,
    merchandiserId,
  ];
}

class CreateAppSettingEvent extends AppSettingsEvent {
  final String settingKey;
  final Map<String, dynamic> settingValue;
  final Map<String, String>? description;
  final String? merchandiserId;

  const CreateAppSettingEvent({
    required this.settingKey,
    required this.settingValue,
    this.description,
    this.merchandiserId,
  });

  @override
  List<Object?> get props => [
    settingKey,
    settingValue,
    description,
    merchandiserId,
  ];
}
