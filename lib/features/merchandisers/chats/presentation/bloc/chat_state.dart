// lib/features/chat/presentation/bloc/chat_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/chat_preview_model.dart';
import '../../data/models/message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

// Chat Previews States
class ChatPreviewsLoading extends ChatState {}

class ChatPreviewsLoaded extends ChatState {
  final List<ChatPreviewModel> previews;

  const ChatPreviewsLoaded({required this.previews});

  @override
  List<Object?> get props => [previews];
}

// Chat Messages States
class ChatMessagesLoading extends ChatState {}

class ChatMessagesLoaded extends ChatState {
  final List<MessageModel> messages;
  final String customerProfileId;
  final String customerName;
  final bool isSendingImage;

  const ChatMessagesLoaded({
    required this.messages,
    required this.customerProfileId,
    required this.customerName,
    this.isSendingImage = false,
  });

  ChatMessagesLoaded copyWith({
    List<MessageModel>? messages,
    String? customerProfileId,
    String? customerName,
    bool? isSendingImage,
  }) {
    return ChatMessagesLoaded(
      messages: messages ?? this.messages,
      customerProfileId: customerProfileId ?? this.customerProfileId,
      customerName: customerName ?? this.customerName,
      isSendingImage: isSendingImage ?? this.isSendingImage,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    customerProfileId,
    customerName,
    isSendingImage,
  ];
}

// Error State
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
