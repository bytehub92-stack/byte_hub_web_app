// lib/features/chat/presentation/widgets/chat_preview_card.dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../data/models/chat_preview_model.dart';

class ChatPreviewCard extends StatelessWidget {
  final ChatPreviewModel preview;
  final bool isSelected;
  final VoidCallback onTap;

  const ChatPreviewCard({
    super.key,
    required this.preview,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: isSelected
              ? Border(left: BorderSide(color: AppColors.primary, width: 3))
              : null,
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: preview.customerAvatar != null
                      ? NetworkImage(preview.customerAvatar!)
                      : null,
                  child: preview.customerAvatar == null
                      ? Text(
                          preview.customerName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                if (preview.isCustomerOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview.customerName,
                          style: AppTextStyles.getBodyMedium(context).copyWith(
                            fontWeight: preview.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.onSurfaceDark
                                      : AppColors.textDark),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        preview.timeAgo,
                        style: AppTextStyles.getBodySmall(context).copyWith(
                          color: preview.unreadCount > 0
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.greyDark500
                                    : AppColors.grey500),
                          fontWeight: preview.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview.lastMessage,
                          style: AppTextStyles.getBodySmall(context).copyWith(
                            color: preview.unreadCount > 0
                                ? (isDark
                                      ? AppColors.onSurfaceDark
                                      : AppColors.textDark)
                                : (isDark
                                      ? AppColors.greyDark500
                                      : AppColors.grey500),
                            fontWeight: preview.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (preview.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            preview.unreadCount > 99
                                ? '99+'
                                : preview.unreadCount.toString(),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
