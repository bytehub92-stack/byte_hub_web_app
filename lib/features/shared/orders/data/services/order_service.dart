// lib/features/orders/data/services/order_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final SupabaseClient _supabase;

  OrderService(this._supabase);

  /// Get merchandiser profile_id from order
  Future<String?> getMerchandiserProfileId(String orderId) async {
    try {
      final orderResponse = await _supabase
          .from('orders')
          .select('merchandiser_id')
          .eq('id', orderId)
          .single();

      final merchandiserId = orderResponse['merchandiser_id'] as String;

      final merchandiserResponse = await _supabase
          .from('merchandisers')
          .select('profile_id')
          .eq('id', merchandiserId)
          .single();

      return merchandiserResponse['profile_id'] as String;
    } catch (e) {
      return null;
    }
  }

  /// Get customer profile_id from order
  Future<String?> getCustomerProfileId(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('customer_user_id')
          .eq('id', orderId)
          .single();

      return response['customer_user_id'] as String;
    } catch (e) {
      return null;
    }
  }

  /// Get order details
  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('order_number, customer_user_id, merchandiser_id')
          .eq('id', orderId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Send new order notification to merchandiser
  Future<void> sendNewOrderNotification({
    required String orderId,
    required String orderNumber,
  }) async {
    try {
      final merchandiserProfileId = await getMerchandiserProfileId(orderId);
      if (merchandiserProfileId == null) return;

      await _supabase.from('notifications').insert({
        'user_id': merchandiserProfileId,
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
      print('Error sending new order notification: $e');
    }
  }

  /// Send order status change notification to customer
  Future<void> sendOrderStatusNotification({
    required String orderId,
    required String status,
  }) async {
    try {
      final orderDetails = await getOrderDetails(orderId);
      if (orderDetails == null) return;

      final customerId = orderDetails['customer_user_id'] as String;
      final orderNumber = orderDetails['order_number'] as String;

      final statusTitles = {
        'confirmed': 'Order Confirmed',
        'preparing': 'Order is Being Prepared',
        'on_the_way': 'Order is On the Way',
        'delivered': 'Order Delivered',
        'cancelled': 'Order Cancelled',
      };

      final statusTitlesAr = {
        'confirmed': 'تم تأكيد الطلب',
        'preparing': 'يتم تحضير الطلب',
        'on_the_way': 'الطلب في الطريق',
        'delivered': 'تم توصيل الطلب',
        'cancelled': 'تم إلغاء الطلب',
      };

      await _supabase.from('notifications').insert({
        'user_id': customerId,
        'title': {
          'en': statusTitles[status] ?? 'Order Update',
          'ar': statusTitlesAr[status] ?? 'تحديث الطلب',
        },
        'body': {
          'en': 'Your order #$orderNumber is now $status',
          'ar': 'طلبك #$orderNumber الآن ${statusTitlesAr[status]}',
        },
        'type': 'order',
        'reference_id': orderId,
        'is_read': false,
      });
    } catch (e) {
      print('Error sending order status notification: $e');
    }
  }

  /// Send order cancellation notification
  Future<void> sendOrderCancellationNotification({
    required String orderId,
    required bool byCustomer,
  }) async {
    try {
      final orderDetails = await getOrderDetails(orderId);
      if (orderDetails == null) return;

      final orderNumber = orderDetails['order_number'] as String;

      String recipientId;
      if (byCustomer) {
        // Customer cancelled - notify merchandiser
        final merchandiserProfileId = await getMerchandiserProfileId(orderId);
        if (merchandiserProfileId == null) return;
        recipientId = merchandiserProfileId;

        await _supabase.from('notifications').insert({
          'user_id': recipientId,
          'title': {
            'en': 'Order Cancelled by Customer',
            'ar': 'تم إلغاء الطلب من قبل العميل',
          },
          'body': {
            'en': 'Order #$orderNumber has been cancelled by the customer',
            'ar': 'تم إلغاء الطلب #$orderNumber من قبل العميل',
          },
          'type': 'order',
          'reference_id': orderId,
          'is_read': false,
        });
      } else {
        // Merchandiser cancelled - notify customer
        recipientId = orderDetails['customer_user_id'] as String;

        await _supabase.from('notifications').insert({
          'user_id': recipientId,
          'title': {'en': 'Order Cancelled', 'ar': 'تم إلغاء الطلب'},
          'body': {
            'en': 'Your order #$orderNumber has been cancelled',
            'ar': 'تم إلغاء طلبك #$orderNumber',
          },
          'type': 'order',
          'reference_id': orderId,
          'is_read': false,
        });
      }
    } catch (e) {
      print('Error sending cancellation notification: $e');
    }
  }

  /// Get all customer profile_ids for a merchandiser
  Future<List<String>> getMerchandiserCustomers(String merchandiserId) async {
    try {
      final response = await _supabase
          .from('customer_merchandiser_relations')
          .select('customer_user_id')
          .eq('merchandiser_id', merchandiserId)
          .eq('approval_status', 'approved');

      return (response as List)
          .map((item) => item['customer_user_id'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Send bulk notification to all merchandiser customers
  Future<void> sendBulkNotificationToCustomers({
    required String merchandiserId,
    required Map<String, String> title,
    required Map<String, String> body,
    required String type,
    String? referenceId,
  }) async {
    try {
      final customerIds = await getMerchandiserCustomers(merchandiserId);
      if (customerIds.isEmpty) return;

      final notifications = customerIds
          .map(
            (customerId) => {
              'user_id': customerId,
              'title': title,
              'body': body,
              'type': type,
              'reference_id': referenceId,
              'is_read': false,
            },
          )
          .toList();

      await _supabase.from('notifications').insert(notifications);
    } catch (e) {
      print('Error sending bulk notifications: $e');
    }
  }
}
