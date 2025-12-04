// lib/features/chat/presentation/widgets/chat_list_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../data/models/chat_preview_model.dart';
import 'chat_preview_card.dart';
import 'empty_chat_state.dart';

class ChatListPanel extends StatefulWidget {
  final String merchandiserId;
  final String? selectedCustomerId;
  final Function(ChatPreviewModel) onChatSelected;
  final List<ChatPreviewModel>? cachedPreviews; // 🔥 NEW
  final Function(List<ChatPreviewModel>)? onPreviewsLoaded; // 🔥 NEW

  const ChatListPanel({
    super.key,
    required this.merchandiserId,
    this.selectedCustomerId,
    required this.onChatSelected,
    this.cachedPreviews,
    this.onPreviewsLoaded,
  });

  @override
  State<ChatListPanel> createState() => _ChatListPanelState();
}

class _ChatListPanelState extends State<ChatListPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.chat_bubble,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Chats', style: AppTextStyles.getH4(context)),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<ChatBloc>().add(
                          RefreshChatPreviews(
                            merchandiserId: widget.merchandiserId,
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search customers...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? AppColors.greyDark500 : AppColors.grey500,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chat List
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              // 🔥 FIXED: Only listen to preview-related states
              listenWhen: (previous, current) {
                return current is ChatPreviewsLoaded ||
                    current is ChatPreviewsLoading ||
                    current is ChatError;
              },
              listener: (context, state) {
                // 🔥 NEW: Cache previews when loaded
                if (state is ChatPreviewsLoaded &&
                    widget.onPreviewsLoaded != null) {
                  widget.onPreviewsLoaded!(state.previews);
                }
              },
              // 🔥 FIXED: Only build when preview states change
              buildWhen: (previous, current) {
                return current is ChatPreviewsLoaded ||
                    current is ChatPreviewsLoading ||
                    current is ChatError;
              },
              builder: (context, state) {
                // 🔥 NEW: Use cached previews if available and state is not preview-related
                final previewsToShow = state is ChatPreviewsLoaded
                    ? state.previews
                    : widget.cachedPreviews;

                if (state is ChatPreviewsLoading &&
                    widget.cachedPreviews == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatError && widget.cachedPreviews == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load chats',
                            style: AppTextStyles.getBodyLarge(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: AppTextStyles.getBodySmall(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<ChatBloc>().add(
                                LoadChatPreviews(
                                  merchandiserId: widget.merchandiserId,
                                ),
                              );
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 🔥 NEW: Use cached or loaded previews
                if (previewsToShow != null) {
                  // Filter chats based on search query
                  final filteredPreviews = previewsToShow.where((preview) {
                    return preview.customerName.toLowerCase().contains(
                          _searchQuery,
                        ) ||
                        preview.lastMessage.toLowerCase().contains(
                          _searchQuery,
                        );
                  }).toList();

                  if (filteredPreviews.isEmpty) {
                    return EmptyChatState(
                      searchQuery: _searchQuery,
                      onRefresh: () {
                        context.read<ChatBloc>().add(
                          LoadChatPreviews(
                            merchandiserId: widget.merchandiserId,
                          ),
                        );
                      },
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredPreviews.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      indent: 68,
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                    itemBuilder: (context, index) {
                      final preview = filteredPreviews[index];
                      final isSelected =
                          preview.customerProfileId ==
                          widget.selectedCustomerId;

                      return ChatPreviewCard(
                        preview: preview,
                        isSelected: isSelected,
                        onTap: () => widget.onChatSelected(preview),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
