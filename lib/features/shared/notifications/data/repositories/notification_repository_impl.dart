// lib/features/notifications/data/repositories/notification_repository_impl.dart
import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final notifications = await remoteDataSource.getNotifications(
        userId: userId,
        limit: limit,
      );
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load notifications'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({required String userId}) async {
    try {
      final count = await remoteDataSource.getUnreadCount(userId: userId);
      return Right(count);
    } catch (e) {
      return const Right(0);
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead({
    required String notificationId,
  }) async {
    try {
      await remoteDataSource.markAsRead(notificationId: notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to mark as read'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead({required String userId}) async {
    try {
      await remoteDataSource.markAllAsRead(userId: userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to mark all as read'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification({
    required String notificationId,
  }) async {
    try {
      await remoteDataSource.deleteNotification(notificationId: notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete notification'));
    }
  }

  @override
  Future<Either<Failure, void>> sendNotification({
    required String userId,
    required Map<String, String> title,
    required Map<String, String> body,
    required String type,
    String? referenceId,
  }) async {
    try {
      await remoteDataSource.sendNotification(
        userId: userId,
        title: title,
        body: body,
        type: type,
        referenceId: referenceId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to send notification'));
    }
  }

  @override
  Future<Either<Failure, void>> sendBulkNotifications({
    required List<String> userIds,
    required Map<String, String> title,
    required Map<String, String> body,
    required String type,
    String? referenceId,
  }) async {
    try {
      await remoteDataSource.sendBulkNotifications(
        userIds: userIds,
        title: title,
        body: body,
        type: type,
        referenceId: referenceId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to send notifications'));
    }
  }

  @override
  Stream<NotificationEntity> subscribeToNotifications({
    required String userId,
  }) {
    return remoteDataSource.subscribeToNotifications(userId: userId);
  }
}
