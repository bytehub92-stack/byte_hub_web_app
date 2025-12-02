// lib/features/shared/app_settings/domain/repositories/app_settings_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/app_setting.dart';

abstract class AppSettingsRepository {
  /// Get a specific app setting by key
  /// If merchandiserId is null, fetches global (admin) settings
  Future<Either<Failure, AppSetting>> getAppSetting({
    required String settingKey,
    String? merchandiserId,
  });

  /// Get multiple app settings by keys
  Future<Either<Failure, List<AppSetting>>> getAppSettings({
    required List<String> settingKeys,
    String? merchandiserId,
  });

  /// Update an app setting (Admin only)
  Future<Either<Failure, AppSetting>> updateAppSetting({
    required String settingKey,
    required Map<String, dynamic> settingValue,
    required Map<String, String>? description,
    String? merchandiserId,
  });

  /// Create a new app setting (Admin only)
  Future<Either<Failure, AppSetting>> createAppSetting({
    required String settingKey,
    required Map<String, dynamic> settingValue,
    required Map<String, String>? description,
    String? merchandiserId,
  });

  /// Delete an app setting (Admin only)
  Future<Either<Failure, void>> deleteAppSetting({
    required String settingKey,
    String? merchandiserId,
  });

  /// Get all About section settings (Terms, Privacy, Help)
  Future<Either<Failure, List<AppSetting>>> getAboutSectionSettings();
}
