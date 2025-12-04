// lib/features/shared/app_settings/domain/usecases/get_app_setting.dart
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/app_setting.dart';
import '../repositories/app_settings_repository.dart';

class GetAppSetting {
  final AppSettingsRepository repository;

  GetAppSetting(this.repository);

  Future<Either<Failure, AppSetting>> call({
    required String settingKey,
    String? merchandiserId,
  }) async {
    return await repository.getAppSetting(
      settingKey: settingKey,
      merchandiserId: merchandiserId,
    );
  }
}
