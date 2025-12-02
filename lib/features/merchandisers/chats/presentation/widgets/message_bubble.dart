// lib/features/chat/presentation/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/colors.dart';
import '../../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;
  final String customerName;
  final String? customerAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.customerName,
    this.customerAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('hh:mm a');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: customerAvatar != null
                  ? NetworkImage(customerAvatar!)
                  : null,
              child: customerAvatar == null
                  ? Text(
                      customerName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ] else if (!isMe) ...[
            const SizedBox(width: 40),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primary
                        : (isDark ? AppColors.grey800 : AppColors.grey100),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.hasImage) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            message.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                width: 200,
                                color: isDark
                                    ? AppColors.grey800
                                    : AppColors.grey200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isMe
                                          ? AppColors.white
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: 200,
                                color: isDark
                                    ? AppColors.grey800
                                    : AppColors.grey200,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: AppColors.grey500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (message.message.isNotEmpty &&
                            message.message != '📷 Image')
                          const SizedBox(height: 8),
                      ],
                      if (message.message.isNotEmpty &&
                          message.message != '📷 Image')
                        Text(
                          message.message,
                          style: TextStyle(
                            color: isMe
                                ? AppColors.white
                                : (isDark
                                      ? AppColors.onSurfaceDark
                                      : AppColors.textDark),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeFormat.format(message.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.greyDark500
                              : AppColors.grey500,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.greyDark500
                                    : AppColors.grey500),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe && showAvatar) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.store, size: 18, color: AppColors.white),
            ),
          ] else if (isMe) ...[
            const SizedBox(width: 40),
          ],
        ],
      ),
    );
  }
}
