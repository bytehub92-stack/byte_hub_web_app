// lib/features/chat/presentation/bloc/chat_event.dart
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import '../../data/models/message_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

// Chat Previews Events
class LoadChatPreviews extends ChatEvent {
  final String merchandiserId;

  const LoadChatPreviews({required this.merchandiserId});

  @override
  List<Object?> get props => [merchandiserId];
}

class RefreshChatPreviews extends ChatEvent {
  final String merchandiserId;

  const RefreshChatPreviews({required this.merchandiserId});

  @override
  List<Object?> get props => [merchandiserId];
}

// Chat Room Events
class LoadChatMessages extends ChatEvent {
  final String customerProfileId;
  final String customerName;

  const LoadChatMessages({
    required this.customerProfileId,
    required this.customerName,
  });

  @override
  List<Object?> get props => [customerProfileId, customerName];
}

class SendMessage extends ChatEvent {
  final String receiverId;
  final String message;

  const SendMessage({required this.receiverId, required this.message});

  @override
  List<Object?> get props => [receiverId, message];
}

class SendImageMessage extends ChatEvent {
  final String receiverId;
  final String message;
  final Uint8List fileBytes;
  final String fileName;

  const SendImageMessage(
      {required this.receiverId,
      required this.message,
      required this.fileBytes,
      required this.fileName});

  @override
  List<Object?> get props => [receiverId, message, fileBytes, fileName];
}

class MarkMessagesAsRead extends ChatEvent {
  final String senderId;
  final String receiverId;

  const MarkMessagesAsRead({required this.senderId, required this.receiverId});

  @override
  List<Object?> get props => [senderId, receiverId];
}

// Subscription Events
class SubscribeToGlobalMessages extends ChatEvent {
  const SubscribeToGlobalMessages();
}

class SubscribeToChatRoom extends ChatEvent {
  final String customerProfileId;

  const SubscribeToChatRoom({required this.customerProfileId});

  @override
  List<Object?> get props => [customerProfileId];
}

class UnsubscribeFromChat extends ChatEvent {
  const UnsubscribeFromChat();
}

// Message Received Events
class GlobalMessageReceived extends ChatEvent {
  final MessageModel message;

  const GlobalMessageReceived({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChatRoomMessageReceived extends ChatEvent {
  final MessageModel message;

  const ChatRoomMessageReceived({required this.message});

  @override
  List<Object?> get props => [message];
}
