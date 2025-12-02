// lib/features/notifications/presentation/bloc/notification_bloc.dart
import 'dart:async';
import 'package:admin_panel/features/shared/notifications/data/models/notification_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRemoteDataSource _dataSource;
  StreamSubscription<NotificationModel>? _subscription;

  NotificationBloc(this._dataSource) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<SubscribeToNotifications>(_onSubscribeToNotifications);
    on<NotificationReceived>(_onNotificationReceived);
    on<UnsubscribeFromNotifications>(_onUnsubscribeFromNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await _dataSource.getNotifications(
        userId: event.userId,
      );
      final unreadCount = await _dataSource.getUnreadCount(
        userId: event.userId,
      );
      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      try {
        final notifications = await _dataSource.getNotifications(
          userId: event.userId,
        );
        final unreadCount = await _dataSource.getUnreadCount(
          userId: event.userId,
        );
        emit(
          NotificationLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ),
        );
      } catch (e) {
        // Keep current state on error
      }
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      try {
        await _dataSource.markAsRead(notificationId: event.notificationId);

        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.notifications.map((notif) {
          if (notif.id == event.notificationId) {
            return NotificationModel(
              id: notif.id,
              userId: notif.userId,
              title: notif.title,
              body: notif.body,
              type: notif.type,
              referenceId: notif.referenceId,
              isRead: true,
              sentAt: notif.sentAt,
            );
          }
          return notif;
        }).toList();

        final newUnreadCount = updatedNotifications
            .where((notif) => !notif.isRead)
            .length;

        emit(
          NotificationLoaded(
            notifications: updatedNotifications,
            unreadCount: newUnreadCount,
          ),
        );
      } catch (e) {
        // Silent fail
      }
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      try {
        await _dataSource.markAllAsRead(userId: event.userId);

        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.notifications.map((notif) {
          return NotificationModel(
            id: notif.id,
            userId: notif.userId,
            title: notif.title,
            body: notif.body,
            type: notif.type,
            referenceId: notif.referenceId,
            isRead: true,
            sentAt: notif.sentAt,
          );
        }).toList();

        emit(
          NotificationLoaded(
            notifications: updatedNotifications,
            unreadCount: 0,
          ),
        );
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      try {
        await _dataSource.deleteNotification(
          notificationId: event.notificationId,
        );

        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.notifications
            .where((notif) => notif.id != event.notificationId)
            .toList();

        final newUnreadCount = updatedNotifications
            .where((notif) => !notif.isRead)
            .length;

        emit(
          NotificationLoaded(
            notifications: updatedNotifications,
            unreadCount: newUnreadCount,
          ),
        );
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onSubscribeToNotifications(
    SubscribeToNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    print('🔔 Subscribing to notifications for user: ${event.userId}');

    // Cancel existing subscription
    await _subscription?.cancel();

    // Subscribe to notification stream
    _subscription = _dataSource
        .subscribeToNotifications(userId: event.userId)
        .listen(
          (notification) {
            print(
              '📩 New notification received via stream: ${notification.id}',
            );
            add(NotificationReceived(notification: notification));
          },
          onError: (error) {
            print('❌ Error in notification stream: $error');
          },
          onDone: () {
            print('✅ Notification stream closed');
          },
        );

    print('✅ Successfully subscribed to notifications');
  }

  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    print('🔔 Notification received: ${event.notification.title}');

    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      // Check if notification already exists
      final notificationExists = currentState.notifications.any(
        (notif) => notif.id == event.notification.id,
      );

      if (!notificationExists) {
        print(
          '✅ Adding new notification, current unread: ${currentState.unreadCount}',
        );
        emit(
          NotificationLoaded(
            notifications: [event.notification, ...currentState.notifications],
            unreadCount: currentState.unreadCount + 1,
          ),
        );
      } else {
        print('⚠️ Notification already exists, skipping');
      }
    } else {
      print('⚠️ State is not NotificationLoaded, current state: $state');
      // If not loaded yet, initialize with this notification
      emit(
        NotificationLoaded(notifications: [event.notification], unreadCount: 1),
      );
    }
  }

  Future<void> _onUnsubscribeFromNotifications(
    UnsubscribeFromNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
