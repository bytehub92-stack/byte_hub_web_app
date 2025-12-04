// lib/features/shared/app_settings/data/repositories/app_settings_repository_impl.dart
import 'package:admin_panel/features/shared/app_settings/data/datasource/app_settings_remote_datasource.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/app_setting.dart';
import '../../domain/repositories/app_settings_repository.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  final AppSettingsRemoteDataSource remoteDataSource;

  AppSettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AppSetting>> getAppSetting({
    required String settingKey,
    String? merchandiserId,
  }) async {
    try {
      final result = await remoteDataSource.getAppSetting(
        settingKey: settingKey,
        merchandiserId: merchandiserId,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppSetting>>> getAppSettings({
    required List<String> settingKeys,
    String? merchandiserId,
  }) async {
    try {
      final results = await remoteDataSource.getAppSettings(
        settingKeys: settingKeys,
        merchandiserId: merchandiserId,
      );
      return Right(results.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppSetting>> updateAppSetting({
    required String settingKey,
    required Map<String, dynamic> settingValue,
    required Map<String, String>? description,
    String? merchandiserId,
  }) async {
    try {
      // First, get the existing setting to get its ID
      final existingSetting = await remoteDataSource.getAppSetting(
        settingKey: settingKey,
        merchandiserId: merchandiserId,
      );

      final result = await remoteDataSource.updateAppSetting(
        id: existingSetting.id,
        settingKey: settingKey,
        settingValue: settingValue,
        description: description,
        merchandiserId: merchandiserId,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppSetting>> createAppSetting({
    required String settingKey,
    required Map<String, dynamic> settingValue,
    required Map<String, String>? description,
    String? merchandiserId,
  }) async {
    try {
      final result = await remoteDataSource.createAppSetting(
        settingKey: settingKey,
        settingValue: settingValue,
        description: description,
        merchandiserId: merchandiserId,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAppSetting({
    required String settingKey,
    String? merchandiserId,
  }) async {
    try {
      await remoteDataSource.deleteAppSetting(
        settingKey: settingKey,
        merchandiserId: merchandiserId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppSetting>>> getAboutSectionSettings() async {
    try {
      final results = await remoteDataSource.getAboutSectionSettings();
      return Right(results.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
