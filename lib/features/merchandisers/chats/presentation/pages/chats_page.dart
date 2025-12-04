// lib/features/chat/presentation/pages/chats_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/colors.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../../data/models/chat_preview_model.dart';
import '../widgets/chat_list_panel.dart';
import '../widgets/chat_room_panel.dart';
import '../widgets/empty_chat_selection_state.dart';

class ChatsPage extends StatefulWidget {
  final String merchandiserId;
  final String? initialCustomerId;
  final String? initialCustomerName;
  final String? initialCustomerAvatar;

  const ChatsPage({
    super.key,
    required this.merchandiserId,
    this.initialCustomerId,
    this.initialCustomerName,
    this.initialCustomerAvatar,
  });

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  String? _selectedCustomerAvatar;

  // 🔥 NEW: Cache chat previews locally to prevent disappearing
  List<ChatPreviewModel>? _cachedPreviews;

  @override
  void initState() {
    super.initState();
    // If navigated from notification or customer dropdown, select that customer
    if (widget.initialCustomerId != null) {
      _selectedCustomerId = widget.initialCustomerId;
      _selectedCustomerName = widget.initialCustomerName;
      _selectedCustomerAvatar = widget.initialCustomerAvatar;

      // Load messages for this customer
      context.read<ChatBloc>().add(
        LoadChatMessages(
          customerProfileId: widget.initialCustomerId!,
          customerName: widget.initialCustomerName ?? 'Customer',
        ),
      );

      // Subscribe to this chat room
      context.read<ChatBloc>().add(
        SubscribeToChatRoom(customerProfileId: widget.initialCustomerId!),
      );
    }
  }

  void _onChatSelected(ChatPreviewModel preview) {
    setState(() {
      _selectedCustomerId = preview.customerProfileId;
      _selectedCustomerName = preview.customerName;
      _selectedCustomerAvatar = preview.customerAvatar;
    });

    // Unsubscribe from previous chat room
    context.read<ChatBloc>().add(const UnsubscribeFromChat());

    // Load messages
    context.read<ChatBloc>().add(
      LoadChatMessages(
        customerProfileId: preview.customerProfileId,
        customerName: preview.customerName,
      ),
    );

    // Subscribe to this chat room
    context.read<ChatBloc>().add(
      SubscribeToChatRoom(customerProfileId: preview.customerProfileId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Row(
        children: [
          // Left Panel - Chat List
          SizedBox(
            width: 360,
            child: ChatListPanel(
              merchandiserId: widget.merchandiserId,
              selectedCustomerId: _selectedCustomerId,
              onChatSelected: _onChatSelected,
              // 🔥 NEW: Pass cached previews
              cachedPreviews: _cachedPreviews,
              onPreviewsLoaded: (previews) {
                // 🔥 NEW: Cache previews when loaded
                setState(() {
                  _cachedPreviews = previews;
                });
              },
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          // Right Panel - Chat Room
          Expanded(
            child: _selectedCustomerId != null
                ? ChatRoomPanel(
                    customerProfileId: _selectedCustomerId!,
                    customerName: _selectedCustomerName ?? 'Customer',
                    customerAvatar: _selectedCustomerAvatar,
                  )
                : const EmptyChatSelectionState(),
          ),
        ],
      ),
    );
  }
}
