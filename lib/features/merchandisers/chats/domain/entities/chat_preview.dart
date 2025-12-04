// lib/features/chat/domain/entities/chat_preview.dart
import 'package:equatable/equatable.dart';

class ChatPreview extends Equatable {
  final String customerProfileId;
  final String customerName;
  final String? customerAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isCustomerOnline;

  const ChatPreview({
    required this.customerProfileId,
    required this.customerName,
    this.customerAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isCustomerOnline,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastMessageTime.day}/${lastMessageTime.month}/${lastMessageTime.year}';
    }
  }

  @override
  List<Object?> get props => [
    customerProfileId,
    customerName,
    customerAvatar,
    lastMessage,
    lastMessageTime,
    unreadCount,
    isCustomerOnline,
  ];
}
