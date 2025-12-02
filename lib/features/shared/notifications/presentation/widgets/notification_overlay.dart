// lib/features/notifications/presentation/widgets/notification_overlay.dart
import 'package:admin_panel/core/constants/route_constants.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/notification.dart';

class NotificationOverlay {
  static OverlayEntry? _currentEntry;

  /// Show notification as overlay banner
  static void show(
    BuildContext context,
    NotificationEntity notification, {
    String? merchandiserId,
  }) {
    // Remove existing overlay if any
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    final language = 'en'; // Get from locale if needed

    _currentEntry = OverlayEntry(
      builder: (context) => _NotificationBanner(
        notification: notification,
        language: language,
        merchandiserId: merchandiserId,
        onDismiss: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    overlay.insert(_currentEntry!);

    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      _currentEntry?.remove();
      _currentEntry = null;
    });
  }

  /// Show notification as dialog
  static void showDialog(
    BuildContext context,
    NotificationEntity notification, {
    String? merchandiserId,
  }) {
    final language = 'en'; // Get from locale if needed

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notification',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
            child: _NotificationCard(
              notification: notification,
              language: language,
              merchandiserId: merchandiserId,
              onDismiss: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }
}

class _NotificationBanner extends StatefulWidget {
  final NotificationEntity notification;
  final String language;
  final String? merchandiserId;
  final VoidCallback onDismiss;

  const _NotificationBanner({
    required this.notification,
    required this.language,
    required this.merchandiserId,
    required this.onDismiss,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onDismiss();
    _navigateToDestination();
  }

  void _navigateToDestination() {
    switch (widget.notification.type) {
      case 'order':
        if (widget.notification.referenceId != null) {
          context.go(
            '${RouteConstants.merchandiserDashboard}?orderId=${widget.notification.referenceId}',
          );
        }
        break;
      case 'chat':
        if (widget.notification.referenceId != null &&
            widget.merchandiserId != null) {
          context.go(
            RouteConstants.chats,
            extra: {
              'merchandiserId': widget.merchandiserId,
              'selectedCustomerId': widget.notification.referenceId,
            },
          );
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: _NotificationCard(
              notification: widget.notification,
              language: widget.language,
              merchandiserId: widget.merchandiserId,
              onDismiss: widget.onDismiss,
              onTap: _handleTap,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final String language;
  final String? merchandiserId;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.notification,
    required this.language,
    required this.merchandiserId,
    required this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _getNotificationIcon(notification.type),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title[language] ??
                          notification.title['en'] ??
                          'Notification',
                      style: AppTextStyles.getBodyMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body[language] ??
                          notification.body['en'] ??
                          '',
                      style: AppTextStyles.getBodySmall(
                        context,
                      ).copyWith(color: AppColors.grey600),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
