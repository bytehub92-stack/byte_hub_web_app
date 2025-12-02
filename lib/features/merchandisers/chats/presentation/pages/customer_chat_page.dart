// lib/features/chat/presentation/pages/customer_chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/colors.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../widgets/chat_room_panel.dart';

class CustomerChatPage extends StatelessWidget {
  final String merchandiserId;
  final String customerProfileId;
  final String customerName;
  final String? customerAvatar;

  const CustomerChatPage({
    super.key,
    required this.merchandiserId,
    required this.customerProfileId,
    required this.customerName,
    this.customerAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => sl<ChatBloc>()
        ..add(
          LoadChatMessages(
            customerProfileId: customerProfileId,
            customerName: customerName,
          ),
        )
        ..add(SubscribeToChatRoom(customerProfileId: customerProfileId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat with $customerName'),
          backgroundColor: isDark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          foregroundColor: isDark
              ? AppColors.onSurfaceDark
              : AppColors.textDark,
          elevation: 0,
        ),
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        body: ChatRoomPanel(
          customerProfileId: customerProfileId,
          customerName: customerName,
          customerAvatar: customerAvatar,
        ),
      ),
    );
  }
}
