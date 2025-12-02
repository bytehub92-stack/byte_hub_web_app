// lib/features/notifications/data/models/notification_model.dart
import '../../../notifications/domain/entities/notification.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.type,
    super.referenceId,
    required super.isRead,
    required super.sentAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: Map<String, String>.from(json['title'] ?? {'en': 'Notification'}),
      body: Map<String, String>.from(json['body'] ?? {'en': ''}),
      type: json['type'] ?? 'general',
      referenceId: json['reference_id'],
      isRead: json['is_read'] ?? false,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'reference_id': referenceId,
      'is_read': isRead,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}
