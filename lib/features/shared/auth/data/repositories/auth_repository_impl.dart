import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../../../../core/debug/debug_config.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    DebugConfig.logInfo('auth repository impl: start login');
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.login(email, password);

        // Cache the user for offline access
        try {
          await localDataSource.cacheUser(user);
        } catch (e) {
          DebugConfig.logError('Failed to cache user', error: e);
          // Don't fail login if caching fails
        }

        return Right(user);
      } on ServerException catch (e) {
        DebugConfig.logError('Server error during login', error: e);
        return Left(ServerFailure(message: e.message));
      } catch (e, stackTrace) {
        DebugConfig.logError(
          'Unexpected error during login',
          error: e,
          stackTrace: stackTrace,
        );
        return Left(AuthFailure(message: 'Login failed: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.logout();
        await localDataSource.clearCache();
        return const Right(null);
      } catch (e) {
        DebugConfig.logError('Logout error', error: e);
        return Left(AuthFailure(message: 'Logout failed: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      return Right(cachedUser);
    } catch (e) {
      DebugConfig.logError('Get current user error', error: e);
      return Left(
        AuthFailure(message: 'Failed to get current user: ${e.toString()}'),
      );
    }
  }
}
