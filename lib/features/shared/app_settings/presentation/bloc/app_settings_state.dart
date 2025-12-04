// lib/features/shared/app_settings/presentation/bloc/app_settings_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/app_setting.dart';

abstract class AppSettingsState extends Equatable {
  const AppSettingsState();

  @override
  List<Object?> get props => [];
}

class AppSettingsInitial extends AppSettingsState {
  const AppSettingsInitial();
}

class AppSettingsLoading extends AppSettingsState {
  const AppSettingsLoading();
}

class AppSettingLoaded extends AppSettingsState {
  final AppSetting setting;

  const AppSettingLoaded(this.setting);

  @override
  List<Object?> get props => [setting];
}

class AboutSectionSettingsLoaded extends AppSettingsState {
  final List<AppSetting> settings;

  const AboutSectionSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];

  /// Helper to get setting by key
  AppSetting? getSettingByKey(String key) {
    try {
      return settings.firstWhere((s) => s.settingKey == key);
    } catch (e) {
      return null;
    }
  }
}

class AppSettingUpdated extends AppSettingsState {
  final AppSetting setting;

  const AppSettingUpdated(this.setting);

  @override
  List<Object?> get props => [setting];
}

class AppSettingCreated extends AppSettingsState {
  final AppSetting setting;

  const AppSettingCreated(this.setting);

  @override
  List<Object?> get props => [setting];
}

class AppSettingsError extends AppSettingsState {
  final String message;

  const AppSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
