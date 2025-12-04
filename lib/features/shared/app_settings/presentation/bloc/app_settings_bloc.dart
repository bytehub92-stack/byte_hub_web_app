// lib/features/shared/app_settings/presentation/bloc/app_settings_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_app_setting.dart';
import '../../domain/usecases/get_about_section_settings.dart';
import '../../domain/usecases/get_app_setting.dart';
import '../../domain/usecases/update_app_setting.dart';
import 'app_settings_event.dart';
import 'app_settings_state.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  final GetAppSetting getAppSetting;
  final GetAboutSectionSettings getAboutSectionSettings;
  final UpdateAppSetting updateAppSetting;
  final CreateAppSetting createAppSetting;

  AppSettingsBloc({
    required this.getAppSetting,
    required this.getAboutSectionSettings,
    required this.updateAppSetting,
    required this.createAppSetting,
  }) : super(const AppSettingsInitial()) {
    on<LoadAppSetting>(_onLoadAppSetting);
    on<LoadAboutSectionSettings>(_onLoadAboutSectionSettings);
    on<UpdateAppSettingEvent>(_onUpdateAppSetting);
    on<CreateAppSettingEvent>(_onCreateAppSetting);
  }

  Future<void> _onLoadAppSetting(
    LoadAppSetting event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(const AppSettingsLoading());

    final result = await getAppSetting(
      settingKey: event.settingKey,
      merchandiserId: event.merchandiserId,
    );

    result.fold(
      (failure) => emit(AppSettingsError(failure.message)),
      (setting) => emit(AppSettingLoaded(setting)),
    );
  }

  Future<void> _onLoadAboutSectionSettings(
    LoadAboutSectionSettings event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(const AppSettingsLoading());

    final result = await getAboutSectionSettings();

    result.fold(
      (failure) => emit(AppSettingsError(failure.message)),
      (settings) => emit(AboutSectionSettingsLoaded(settings)),
    );
  }

  Future<void> _onUpdateAppSetting(
    UpdateAppSettingEvent event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(const AppSettingsLoading());

    final result = await updateAppSetting(
      settingKey: event.settingKey,
      settingValue: event.settingValue,
      description: event.description,
      merchandiserId: event.merchandiserId,
    );

    result.fold(
      (failure) => emit(AppSettingsError(failure.message)),
      (setting) => emit(AppSettingUpdated(setting)),
    );
  }

  Future<void> _onCreateAppSetting(
    CreateAppSettingEvent event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(const AppSettingsLoading());

    final result = await createAppSetting(
      settingKey: event.settingKey,
      settingValue: event.settingValue,
      description: event.description,
      merchandiserId: event.merchandiserId,
    );

    result.fold(
      (failure) => emit(AppSettingsError(failure.message)),
      (setting) => emit(AppSettingCreated(setting)),
    );
  }
}
