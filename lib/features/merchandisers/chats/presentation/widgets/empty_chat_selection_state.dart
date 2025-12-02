// lib/features/chat/presentation/widgets/empty_chat_selection_state.dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';

class EmptyChatSelectionState extends StatelessWidget {
  const EmptyChatSelectionState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 96,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Select a chat to start messaging',
            style: AppTextStyles.getH3(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: Text(
              'Choose a conversation from the list to view messages and respond to your customers',
              style: AppTextStyles.getBodyLarge(context).copyWith(
                color: isDark ? AppColors.greyDark500 : AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
