// lib/features/chat/presentation/widgets/empty_chat_state.dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';

class EmptyChatState extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onRefresh;

  const EmptyChatState({super.key, this.searchQuery, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasSearch = searchQuery != null && searchQuery!.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch ? Icons.search_off : Icons.chat_bubble_outline,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? 'No chats found' : 'No conversations yet',
              style: AppTextStyles.getBodyLarge(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'No conversations match "$searchQuery"'
                  : 'When customers message you, their conversations will appear here',
              style: AppTextStyles.getBodySmall(context).copyWith(
                color: isDark ? AppColors.greyDark500 : AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
