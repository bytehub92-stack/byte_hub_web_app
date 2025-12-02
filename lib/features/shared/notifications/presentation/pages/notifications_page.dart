// lib/features/notifications/presentation/pages/notifications_page.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/notifications/presentation/utils/notification_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationsPage extends StatelessWidget {
  final String userId;

  const NotificationsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NotificationBloc>()
        ..add(LoadNotifications(userId: userId))
        ..add(SubscribeToNotifications(userId: userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded && state.unreadCount > 0) {
                  return TextButton.icon(
                    onPressed: () {
                      context.read<NotificationBloc>().add(
                        MarkAllNotificationsAsRead(userId: userId),
                      );
                    },
                    icon: const Icon(Icons.done_all),
                    label: const Text('Mark all as read'),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NotificationBloc>().add(
                          LoadNotifications(userId: userId),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: AppTextStyles.getH4(
                          context,
                        ).copyWith(color: AppColors.grey600),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NotificationBloc>().add(
                    RefreshNotifications(userId: userId),
                  );
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  itemCount: state.notifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    final language = 'en'; // Get from locale

                    return Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultRadius,
                          ),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        context.read<NotificationBloc>().add(
                          DeleteNotification(notificationId: notification.id),
                        );
                      },
                      child: Card(
                        color: notification.isRead
                            ? AppColors.surfaceLight
                            : AppColors.grey50,
                        child: InkWell(
                          onTap: () async {
                            // Get merchandiser ID
                            final merchandiserResponse =
                                await sl<SupabaseClient>()
                                    .from('merchandisers')
                                    .select('id')
                                    .eq('profile_id', userId)
                                    .maybeSingle();

                            final merchandiserId =
                                merchandiserResponse?['id'] as String? ?? '';

                            if (context.mounted) {
                              NotificationHandler.handleNotificationTap(
                                context,
                                notification,
                                merchandiserId,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultRadius,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _getNotificationIcon(notification.type),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notification.title[language] ??
                                                notification.title['en'] ??
                                                'Notification',
                                            style:
                                                AppTextStyles.getBodyMedium(
                                                  context,
                                                ).copyWith(
                                                  fontWeight:
                                                      notification.isRead
                                                      ? FontWeight.normal
                                                      : FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notification.body[language] ??
                                                notification.body['en'] ??
                                                '',
                                            style:
                                                AppTextStyles.getBodySmall(
                                                  context,
                                                ).copyWith(
                                                  color: AppColors.grey600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!notification.isRead)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatTimestamp(notification.sentAt),
                                  style: AppTextStyles.getBodySmall(context)
                                      .copyWith(
                                        color: AppColors.grey500,
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'order':
        icon = Icons.shopping_bag;
        color = AppColors.primary;
        break;
      case 'chat':
        icon = Icons.chat_bubble;
        color = AppColors.info;
        break;
      case 'promo':
        icon = Icons.local_offer;
        color = AppColors.warning;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.grey600;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }
}
