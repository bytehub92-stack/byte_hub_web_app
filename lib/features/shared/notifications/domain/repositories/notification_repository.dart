// lib/features/notifications/domain/repositories/notification_repository.dart
import 'package:admin_panel/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required String userId,
    int limit = 50,
  });

  Future<Either<Failure, int>> getUnreadCount({required String userId});

  Future<Either<Failure, void>> markAsRead({required String notificationId});

  Future<Either<Failure, void>> markAllAsRead({required String userId});

  Future<Either<Failure, void>> deleteNotification({
    required String notificationId,
  });

  Future<Either<Failure, void>> sendNotification({
    required String userId,
    required Map<String, String> title,
    required Map<String, String> body,
    required String type,
    String? referenceId,
  });

  Future<Either<Failure, void>> sendBulkNotifications({
    required List<String> userIds,
    required Map<String, String> title,
    required Map<String, String> body,
    required String type,
    String? referenceId,
  });

  Stream<NotificationEntity> subscribeToNotifications({required String userId});
}
