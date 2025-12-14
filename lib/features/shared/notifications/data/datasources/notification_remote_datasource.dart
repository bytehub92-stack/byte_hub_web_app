// lib/features/notifications/data/datasources/notification_remote_datasource.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final SupabaseClient _supabase;
  final Map<String, StreamController<NotificationModel>> _streamControllers =
      {};

  NotificationRemoteDataSource(this._supabase);

  /// Get all notifications for a user
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('sent_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount({required String userId}) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      print('notification remote datasource: unread count $response');

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead({required String notificationId}) async {
    try {
      print('notification remote datasource: now will mark as read');
      await _supabase
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
      print('notification remote datasource: now marked as read');
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead({required String userId}) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
      print('notification remote datasource: now marked all as read');
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification({required String notificationId}) async {
    try {
      print('notification remote datasource: now will delete notification');
      await _supabase.from('notifications').delete().eq('id', notificationId);
      print('notification remote datasource: now notification deleted');
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Send single notification
  Future<void> sendNotification({
    required String userId,
    required Map<String, String> title,
    required Map<String, String> body,
    required String type,
    String? referenceId,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'reference_id': referenceId,
        'is_read': false,
      });
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  /// Send bulk notifications
  Future<void> sendBulkNotifications({
    required List<String> userIds,
    required Map<String, String> title,
    required Map<String, String> body,
    required String type,
    String? referenceId,
  }) async {
    try {
      final notifications = userIds
          .map(
            (userId) => {
              'user_id': userId,
              'title': title,
              'body': body,
              'type': type,
              'reference_id': referenceId,
              'is_read': false,
            },
          )
          .toList();

      await _supabase.from('notifications').insert(notifications);
    } catch (e) {
      throw Exception('Failed to send bulk notifications: $e');
    }
  }

  /// Subscribe to real-time notifications using Stream
  Stream<NotificationModel> subscribeToNotifications({required String userId}) {
    // Create or reuse stream controller
    if (!_streamControllers.containsKey(userId)) {
      _streamControllers[userId] =
          StreamController<NotificationModel>.broadcast();

      _supabase
          .channel('notifications:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              try {
                final notification =
                    NotificationModel.fromJson(payload.newRecord);
                _streamControllers[userId]?.add(notification);
                print('✅ Notification added to stream: ${notification.id}');
              } catch (e) {
                print('❌ Error parsing notification: $e');
              }
            },
          )
          .subscribe();
    }

    return _streamControllers[userId]!.stream;
  }

  /// Clean up stream controllers
  void dispose() {
    for (var controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
  }
}
