// lib/features/notifications/presentation/widgets/notification_handler.dart

import 'package:admin_panel/core/constants/route_constants.dart';
import 'package:admin_panel/features/shared/orders/presentation/pages/order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';

class NotificationHandler {
  static void handleNotificationTap(
    BuildContext context,
    NotificationEntity notification,
    String merchandiserId,
  ) {
    // Mark as read
    context.read<NotificationBloc>().add(
      MarkNotificationAsRead(notificationId: notification.id),
    );

    // Navigate based on type
    switch (notification.type) {
      case 'chat':
        if (notification.referenceId != null) {
          Navigator.of(context).pushNamed(
            RouteConstants.chats,
            arguments: {
              'merchandiserId': merchandiserId,
              'selectedCustomerId': notification.referenceId,
            },
          );
        }
        break;
      case 'order':
        if (notification.referenceId != null) {
          // Navigate to order details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(
                orderId: notification.referenceId!,
                isAdminView: false,
              ),
            ),
          );
        }
        break;
      default:
        break;
    }
  }
}
