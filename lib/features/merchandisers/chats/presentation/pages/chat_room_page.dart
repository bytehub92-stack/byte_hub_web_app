// lib/features/chat/presentation/pages/chat_room_page.dart
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/core/utils/file_picker_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_field.dart';

class ChatRoomPage extends StatefulWidget {
  final String customerProfileId;
  final String customerName;
  final String? customerAvatar;

  const ChatRoomPage({
    super.key,
    required this.customerProfileId,
    required this.customerName,
    this.customerAvatar,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String get merchandiserProfileId => sl<AuthService>().currentUserId ?? '';

  @override
  void initState() {
    super.initState();
    // Subscribe to this specific chat room
    context.read<ChatBloc>().add(
          SubscribeToChatRoom(customerProfileId: widget.customerProfileId),
        );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    context.read<ChatBloc>().add(const UnsubscribeFromChat());
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<ChatBloc>().add(
          SendMessage(receiverId: widget.customerProfileId, message: message),
        );

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _pickAndSendImage() async {
    try {
      final file = await FilePicker.instance.pickImage();
      if (file != null) {
        context.read<ChatBloc>().add(
              SendImageMessage(
                receiverId: widget.customerProfileId,
                message: '📷 Image',
                fileBytes: file.bytes,
                fileName: 'chat-image',
              ),
            );
        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: widget.customerAvatar != null
                      ? NetworkImage(widget.customerAvatar!)
                      : null,
                  child: widget.customerAvatar == null
                      ? Text(
                          widget.customerName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customerName,
                        style: AppTextStyles.getBodyLarge(
                          context,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, state) {
                          if (state is ChatMessagesLoaded) {
                            return Text(
                              '${state.messages.length} messages',
                              style:
                                  AppTextStyles.getBodySmall(context).copyWith(
                                color: isDark
                                    ? AppColors.greyDark500
                                    : AppColors.grey500,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatMessagesLoaded) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is ChatMessagesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'Failed to load messages',
                          style: AppTextStyles.getH4(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: AppTextStyles.getBodyMedium(context),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<ChatBloc>().add(
                                  LoadChatMessages(
                                    customerProfileId: widget.customerProfileId,
                                    customerName: widget.customerName,
                                  ),
                                );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ChatMessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No messages yet',
                            style: AppTextStyles.getH4(context),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Start the conversation with ${widget.customerName}',
                            style:
                                AppTextStyles.getBodyMedium(context).copyWith(
                              color: isDark
                                  ? AppColors.greyDark500
                                  : AppColors.grey500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          final isMe =
                              message.senderId == merchandiserProfileId;
                          final showAvatar = index == 0 ||
                              state.messages[index - 1].senderId !=
                                  message.senderId;

                          return MessageBubble(
                            message: message,
                            isMe: isMe,
                            showAvatar: showAvatar,
                            customerName: widget.customerName,
                            customerAvatar: widget.customerAvatar,
                          );
                        },
                      ),
                      if (state.isSendingImage)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Sending image...',
                                    style: AppTextStyles.getBodyMedium(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Input Field
          ChatInputField(
            controller: _messageController,
            onSend: _sendMessage,
            onImagePick: _pickAndSendImage,
          ),
        ],
      ),
    );
  }
}
