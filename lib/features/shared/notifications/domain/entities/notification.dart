// lib/features/notifications/domain/entities/notification.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final Map<String, String> title;
  final Map<String, String> body;
  final String type; // 'order', 'chat', 'general'
  final String? referenceId;
  final bool isRead;
  final DateTime sentAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.sentAt,
  });

  String getTitle(String languageCode) {
    return title[languageCode] ?? title['en'] ?? 'Notification';
  }

  String getBody(String languageCode) {
    return body[languageCode] ?? body['en'] ?? '';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(sentAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${sentAt.day}/${sentAt.month}/${sentAt.year}';
    }
  }

  IconData get icon {
    switch (type) {
      case 'order':
        return Icons.shopping_bag;
      case 'chat':
        return Icons.chat_bubble;
      case 'general':
      default:
        return Icons.notifications;
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    body,
    type,
    referenceId,
    isRead,
    sentAt,
  ];
}
