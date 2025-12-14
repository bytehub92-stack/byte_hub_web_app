// lib/features/notifications/presentation/bloc/notification_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool showOverlay;
  final NotificationModel? latestNotification;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    this.showOverlay = false,
    this.latestNotification,
  });

  // ✅ Add copyWith to properly update state
  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? showOverlay,
    NotificationModel? latestNotification,
    bool clearLatest = false,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      showOverlay: showOverlay ?? false,
      latestNotification:
          clearLatest ? null : (latestNotification ?? this.latestNotification),
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        unreadCount,
        showOverlay,
        latestNotification,
        // ✅ Add timestamp to force updates
        DateTime.now().millisecondsSinceEpoch,
      ];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
