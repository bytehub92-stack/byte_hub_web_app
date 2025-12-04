// lib/features/shared/app_settings/domain/usecases/create_app_setting.dart
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/app_setting.dart';
import '../repositories/app_settings_repository.dart';

class CreateAppSetting {
  final AppSettingsRepository repository;

  CreateAppSetting(this.repository);

  Future<Either<Failure, AppSetting>> call({
    required String settingKey,
    required Map<String, dynamic> settingValue,
    Map<String, String>? description,
    String? merchandiserId,
  }) async {
    return await repository.createAppSetting(
      settingKey: settingKey,
      settingValue: settingValue,
      description: description,
      merchandiserId: merchandiserId,
    );
  }
}
