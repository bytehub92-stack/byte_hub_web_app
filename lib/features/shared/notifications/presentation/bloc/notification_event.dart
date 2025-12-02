// lib/features/notifications/presentation/bloc/notification_event.dart
import 'package:equatable/equatable.dart';
import '../../data/models/notification_model.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final String userId;

  const LoadNotifications({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RefreshNotifications extends NotificationEvent {
  final String userId;

  const RefreshNotifications({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationEvent {
  final String userId;

  const MarkAllNotificationsAsRead({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class SubscribeToNotifications extends NotificationEvent {
  final String userId;

  const SubscribeToNotifications({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class NotificationReceived extends NotificationEvent {
  final NotificationModel notification;

  const NotificationReceived({required this.notification});

  @override
  List<Object?> get props => [notification];
}

class UnsubscribeFromNotifications extends NotificationEvent {
  const UnsubscribeFromNotifications();
}
