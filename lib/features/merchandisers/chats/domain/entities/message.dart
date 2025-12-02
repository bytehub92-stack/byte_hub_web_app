// lib/features/shared/domain/entities/message.dart

import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        senderId,
        receiverId,
        message,
        isRead,
        createdAt,
        updatedAt,
        imageUrl
      ];
}
