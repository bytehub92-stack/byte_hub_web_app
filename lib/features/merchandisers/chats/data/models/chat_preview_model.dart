// lib/features/chat/data/models/chat_preview_model.dart
import '../../domain/entities/chat_preview.dart';

class ChatPreviewModel extends ChatPreview {
  const ChatPreviewModel({
    required super.customerProfileId,
    required super.customerName,
    super.customerAvatar,
    required super.lastMessage,
    required super.lastMessageTime,
    required super.unreadCount,
    required super.isCustomerOnline,
  });

  factory ChatPreviewModel.fromJson(Map<String, dynamic> json) {
    return ChatPreviewModel(
      customerProfileId: json['customer_profile_id'] ?? '',
      customerName: json['customer_name'] ?? 'Unknown Customer',
      customerAvatar: json['customer_avatar'],
      lastMessage: json['last_message'] ?? 'No messages yet',
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : DateTime.now(),
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      isCustomerOnline: json['is_online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_profile_id': customerProfileId,
      'customer_name': customerName,
      'customer_avatar': customerAvatar,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime.toIso8601String(),
      'unread_count': unreadCount,
      'is_online': isCustomerOnline,
    };
  }
}
