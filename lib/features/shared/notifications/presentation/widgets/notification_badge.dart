// lib/features/notifications/presentation/widgets/notification_badge.dart
import 'package:admin_panel/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_state.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;

  const NotificationBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final unreadCount = state is NotificationLoaded ? state.unreadCount : 0;

        if (unreadCount == 0) {
          return child;
        }

        return Badge(
          label: Text(
            unreadCount > 99 ? '99+' : unreadCount.toString(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.error,
          child: child,
        );
      },
    );
  }
}
