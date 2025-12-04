// lib/features/shared/app_settings/data/datasources/app_settings_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_setting_model.dart';
import '../../domain/entities/app_setting.dart';

abstract class AppSettingsRemoteDataSource {
  Future<AppSettingModel> getAppSetting({
    required String settingKey,
    String? merchandiserId,
  });

  Future<List<AppSettingModel>> getAppSettings({
    required List<String> settingKeys,
    String? merchandiserId,
  });

  Future<AppSettingModel> updateAppSetting({
    required String id,
    required String settingKey,
    required Map<String, dynamic> settingValue,
    required Map<String, String>? description,
    String? merchandiserId,
  });

  Future<AppSettingModel> createAppSetting({
    required String settingKey,
    required Map<String, dynamic> settingValue,
    required Map<String, String>? description,
    String? merchandiserId,
  });

  Future<void> deleteAppSetting({
    required String settingKey,
    String? merchandiserId,
  });

  Future<List<AppSettingModel>> getAboutSectionSettings();
}

class AppSettingsRemoteDataSourceImpl implements AppSettingsRemoteDataSource {
  final SupabaseClient supabaseClient;

  AppSettingsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<AppSettingModel> getAppSetting({
    required String settingKey,
    String? merchandiserId,
  }) async {
    try {
      final query = supabaseClient
          .from('app_settings')
          .select()
          .eq('setting_key', settingKey);

      // Filter by merchandiser_id (null for global settings)
      final response = merchandiserId == null
          ? await query.isFilter('merchandiser_id', null).single()
          : await query.eq('merchandiser_id', merchandiserId).single();

      return AppSettingModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch app setting: $e');
    }
  }

  @override
  Future<List<AppSettingModel>> getAppSettings({
    required List<String> settingKeys,
    String? merchandiserId,
  }) async {
    try {
      final query = supabaseClient
          .from('app_settings')
          .select()
          .inFilter('setting_key', settingKeys);

      // Filter by merchandiser_id (null for global settings)
      final response = merchandiserId == null
          ? await query.isFilter('merchandiser_id', null)
          : await query.eq('merchandiser_id', merchandiserId);

      return (response as List)
          .map((json) => AppSettingModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch app settings: $e');
    }
  }

  @override
  Future<AppSettingModel> updateAppSetting({
    required String id,
    required String settingKey,
    required Map<String, dynamic> settingValue,
    required Map<String, String>? description,
    String? merchandiserId,
  }) async {
    try {
      final response = await supabaseClient
          .from('app_settings')
          .update({
            'setting_value': settingValue,
            'description': description,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return AppSettingModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update app setting: $e');
    }
  }

  @override
  Future<AppSettingModel> createAppSetting({
    required String settingKey,
    required Map<String, dynamic> settingValue,
    required Map<String, String>? description,
    String? merchandiserId,
  }) async {
    try {
      final response = await supabaseClient
          .from('app_settings')
          .insert({
            'merchandiser_id': merchandiserId,
            'setting_key': settingKey,
            'setting_value': settingValue,
            'description': description,
          })
          .select()
          .single();

      return AppSettingModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create app setting: $e');
    }
  }

  @override
  Future<void> deleteAppSetting({
    required String settingKey,
    String? merchandiserId,
  }) async {
    try {
      final query = supabaseClient
          .from('app_settings')
          .delete()
          .eq('setting_key', settingKey);

      if (merchandiserId == null) {
        await query.isFilter('merchandiser_id', null);
      } else {
        await query.eq('merchandiser_id', merchandiserId);
      }
    } catch (e) {
      throw Exception('Failed to delete app setting: $e');
    }
  }

  @override
  Future<List<AppSettingModel>> getAboutSectionSettings() async {
    try {
      final response = await supabaseClient
          .from('app_settings')
          .select()
          .inFilter('setting_key', AppSettingKeys.aboutSectionKeys)
          .isFilter('merchandiser_id', null);

      return (response as List)
          .map((json) => AppSettingModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch about section settings: $e');
    }
  }
}
