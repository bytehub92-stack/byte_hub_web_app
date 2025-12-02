// lib/features/chat/domain/entities/message.dart
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.imageUrl,
    required this.isRead,
    required this.createdAt,
  });

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    senderId,
    receiverId,
    message,
    imageUrl,
    isRead,
    createdAt,
  ];
}
