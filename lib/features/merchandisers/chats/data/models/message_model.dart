import 'package:admin_panel/features/merchandisers/chats/domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.message,
    super.imageUrl,
    required super.isRead,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      message: json['message'] ?? '',
      imageUrl: json['image_url'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'image_url': imageUrl,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    String? imageUrl,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasImage => imageUrl != null;
}
