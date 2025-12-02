// lib/features/chat/presentation/bloc/chat_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRemoteDataSource _dataSource;
  final String merchandiserProfileId; // ✅ This is CORRECT - use profile_id

  RealtimeChannel? _globalChannel;
  RealtimeChannel? _chatRoomChannel;
  Timer? _typingTimer;

  ChatBloc({
    required ChatRemoteDataSource dataSource,
    required this.merchandiserProfileId,
  })  : _dataSource = dataSource,
        super(ChatInitial()) {
    on<LoadChatPreviews>(_onLoadChatPreviews);
    on<LoadChatMessages>(_onLoadChatMessages);
    on<SendMessage>(_onSendMessage);
    on<SendImageMessage>(_onSendImageMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<SubscribeToGlobalMessages>(_onSubscribeToGlobalMessages);
    on<SubscribeToChatRoom>(_onSubscribeToChatRoom);
    on<GlobalMessageReceived>(_onGlobalMessageReceived);
    on<ChatRoomMessageReceived>(_onChatRoomMessageReceived);
    on<UnsubscribeFromChat>(_onUnsubscribeFromChat);
    on<RefreshChatPreviews>(_onRefreshChatPreviews);
  }

  // ✅ FIXED: Use profile_id directly (matches mobile app behavior)
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatMessagesLoaded) return;

    try {
      final message = await _dataSource.sendMessage(
        senderId:
            merchandiserProfileId, // ✅ Use profile_id, NOT merchandiser_id
        receiverId: event.receiverId,
        message: event.message,
      );

      final currentState = state as ChatMessagesLoaded;
      emit(
        currentState.copyWith(messages: [...currentState.messages, message]),
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // ✅ FIXED: Use profile_id directly (matches mobile app behavior)
  Future<void> _onSendImageMessage(
    SendImageMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatMessagesLoaded) return;

    final currentState = state as ChatMessagesLoaded;
    emit(currentState.copyWith(isSendingImage: true));

    try {
      final message = await _dataSource.sendImageMessage(
          senderId:
              merchandiserProfileId, // ✅ Use profile_id, NOT merchandiser_id
          receiverId: event.receiverId,
          message: event.message,
          fileBytes: event.fileBytes,
          fileName: event.fileName);

      emit(
        currentState.copyWith(
          messages: [...currentState.messages, message],
          isSendingImage: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isSendingImage: false));
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadChatPreviews(
    LoadChatPreviews event,
    Emitter<ChatState> emit,
  ) async {
    // Don't emit loading if we already have previews
    if (state is! ChatPreviewsLoaded) {
      emit(ChatPreviewsLoading());
    }

    try {
      final previews = await _dataSource.getChatPreviews(
        merchandiserId: event.merchandiserId,
      );
      emit(ChatPreviewsLoaded(previews: previews));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    final previousState = state;

    if (state is! ChatMessagesLoaded) {
      emit(ChatMessagesLoading());
    }

    try {
      final messages = await _dataSource.getMessages(
        merchandiserProfileId: merchandiserProfileId,
        customerProfileId: event.customerProfileId,
      );

      emit(
        ChatMessagesLoaded(
          messages: messages,
          customerProfileId: event.customerProfileId,
          customerName: event.customerName,
        ),
      );

      // Auto mark as read
      add(
        MarkMessagesAsRead(
          senderId: event.customerProfileId,
          receiverId: merchandiserProfileId,
        ),
      );
    } catch (e) {
      if (previousState is ChatPreviewsLoaded) {
        emit(previousState);
      }
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _dataSource.markAllAsRead(
        senderId: event.senderId,
        receiverId: event.receiverId,
      );
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _onSubscribeToGlobalMessages(
    SubscribeToGlobalMessages event,
    Emitter<ChatState> emit,
  ) async {
    await _globalChannel?.unsubscribe();

    _globalChannel = _dataSource.subscribeToNewMessages(
      merchandiserProfileId: merchandiserProfileId,
      onMessageReceived: (message) {
        add(GlobalMessageReceived(message: message));
      },
    );
  }

  void _onGlobalMessageReceived(
    GlobalMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatPreviewsLoaded) {
      add(RefreshChatPreviews(merchandiserId: event.message.receiverId));
    }
  }

  Future<void> _onSubscribeToChatRoom(
    SubscribeToChatRoom event,
    Emitter<ChatState> emit,
  ) async {
    await _chatRoomChannel?.unsubscribe();

    _chatRoomChannel = _dataSource.subscribeToChatRoom(
      merchandiserProfileId: merchandiserProfileId,
      customerProfileId: event.customerProfileId,
      onMessageReceived: (message) {
        add(ChatRoomMessageReceived(message: message));
      },
    );
  }

  void _onChatRoomMessageReceived(
    ChatRoomMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;

      final messageExists = currentState.messages.any(
        (msg) => msg.id == event.message.id,
      );

      if (!messageExists) {
        emit(
          currentState.copyWith(
            messages: [...currentState.messages, event.message],
          ),
        );

        add(
          MarkMessagesAsRead(
            senderId: event.message.senderId,
            receiverId: merchandiserProfileId,
          ),
        );
      }
    }
  }

  Future<void> _onUnsubscribeFromChat(
    UnsubscribeFromChat event,
    Emitter<ChatState> emit,
  ) async {
    await _chatRoomChannel?.unsubscribe();
    _chatRoomChannel = null;
  }

  Future<void> _onRefreshChatPreviews(
    RefreshChatPreviews event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final previews = await _dataSource.getChatPreviews(
        merchandiserId: event.merchandiserId,
      );

      if (state is ChatPreviewsLoaded ||
          state is ChatError ||
          state is ChatInitial) {
        emit(ChatPreviewsLoaded(previews: previews));
      }
    } catch (e) {
      print('Failed to refresh chat previews: $e');
    }
  }

  @override
  Future<void> close() {
    _globalChannel?.unsubscribe();
    _chatRoomChannel?.unsubscribe();
    _typingTimer?.cancel();
    return super.close();
  }
}
