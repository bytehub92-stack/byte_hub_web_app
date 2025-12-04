// lib/features/chat/presentation/widgets/chat_input_field.dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onImagePick;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onImagePick,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image Picker Button
          IconButton(
            onPressed: onImagePick,
            icon: const Icon(Icons.image),
            color: AppColors.primary,
            tooltip: 'Send image',
          ),
          const SizedBox(width: 8),

          // Text Field
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: isDark ? AppColors.backgroundDark : AppColors.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),

          // Send Button
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;
              return Container(
                decoration: BoxDecoration(
                  color: hasText ? AppColors.primary : AppColors.grey300,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: hasText ? onSend : null,
                  icon: const Icon(Icons.send),
                  color: AppColors.white,
                  tooltip: 'Send',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
