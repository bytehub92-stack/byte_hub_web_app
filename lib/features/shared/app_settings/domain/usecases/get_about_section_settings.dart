// lib/features/shared/app_settings/domain/usecases/get_about_section_settings.dart
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/app_setting.dart';
import '../repositories/app_settings_repository.dart';

class GetAboutSectionSettings {
  final AppSettingsRepository repository;

  GetAboutSectionSettings(this.repository);

  Future<Either<Failure, List<AppSetting>>> call() async {
    return await repository.getAboutSectionSettings();
  }
}
