// lib/features/shared/app_settings/domain/usecases/update_app_setting.dart
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/app_setting.dart';
import '../repositories/app_settings_repository.dart';

class UpdateAppSetting {
  final AppSettingsRepository repository;

  UpdateAppSetting(this.repository);

  Future<Either<Failure, AppSetting>> call({
    required String settingKey,
    required Map<String, dynamic> settingValue,
    Map<String, String>? description,
    String? merchandiserId,
  }) async {
    return await repository.updateAppSetting(
      settingKey: settingKey,
      settingValue: settingValue,
      description: description,
      merchandiserId: merchandiserId,
    );
  }
}
