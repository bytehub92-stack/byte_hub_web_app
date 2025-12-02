// lib/features/notifications/data/services/notification_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient supabaseClient;

  NotificationService({required this.supabaseClient});

  /// Send notification when new order is placed
  Future<void> sendNewOrderNotification({
    required String merchandiserId,
    required String orderNumber,
    required String orderId,
  }) async {
    try {
      // Get merchandiser's profile_id
      final merchandiserResponse = await supabaseClient
          .from('merchandisers')
          .select('profile_id')
          .eq('id', merchandiserId)
          .single();

      final profileId = merchandiserResponse['profile_id'] as String;

      // Create notification
      await supabaseClient.from('notifications').insert({
        'user_id': profileId,
        'title': {'en': 'New Order Received', 'ar': 'تم استلام طلب جديد'},
        'body': {
          'en': 'You have received a new order #$orderNumber',
          'ar': 'لقد استلمت طلبًا جديدًا #$orderNumber',
        },
        'type': 'order',
        'reference_id': orderId,
        'is_read': false,
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Send notification when order status changes
  Future<void> sendOrderStatusNotification({
    required String customerId,
    required String orderNumber,
    required String orderId,
    required String status,
  }) async {
    try {
      final Map<String, String> titles = {
        'confirmed': 'Order Confirmed',
        'preparing': 'Order is Being Prepared',
        'on_the_way': 'Order is On the Way',
        'delivered': 'Order Delivered',
        'cancelled': 'Order Cancelled',
      };

      final Map<String, String> titlesAr = {
        'confirmed': 'تم تأكيد الطلب',
        'preparing': 'يتم تحضير الطلب',
        'on_the_way': 'الطلب في الطريق',
        'delivered': 'تم توصيل الطلب',
        'cancelled': 'تم إلغاء الطلب',
      };

      await supabaseClient.from('notifications').insert({
        'user_id': customerId,
        'title': {
          'en': titles[status] ?? 'Order Update',
          'ar': titlesAr[status] ?? 'تحديث الطلب',
        },
        'body': {
          'en':
              'Your order #$orderNumber status has been updated to ${status.replaceAll('_', ' ')}',
          'ar': 'تم تحديث حالة طلبك #$orderNumber إلى ${titlesAr[status]}',
        },
        'type': 'order',
        'reference_id': orderId,
        'is_read': false,
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await supabaseClient
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await supabaseClient
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}
