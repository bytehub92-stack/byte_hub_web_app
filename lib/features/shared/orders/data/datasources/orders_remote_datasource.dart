// lib/features/orders/data/datasources/orders_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/error/exceptions.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getAllOrders({
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<OrderModel>> getOrdersByMerchandiser({
    required String merchandiserId,
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<OrderModel>> getOrdersByCustomer({
    required String customerId,
    String? merchandiserId,
    String? status,
  });

  Future<OrderModel> getOrderById(String orderId);

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  });

  Future<void> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  });

  Future<void> cancelOrder(String orderId);

  Future<Map<String, dynamic>> getOrderStatistics({String? merchandiserId});
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final SupabaseClient supabaseClient;

  OrdersRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<OrderModel>> getAllOrders({
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      dynamic query = supabaseClient.from('orders').select('''
          *,
          profiles:customer_user_id(full_name, email, phone_number),
          merchandisers:merchandiser_id(business_name)
        ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      if (paymentStatus != null) {
        query = query.eq('payment_status', paymentStatus);
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      query = query.order('created_at', ascending: false);

      final response = await query;

      return (response as List).map((json) {
        final customerData = json['profiles'];
        final merchandiserData = json['merchandisers'];

        return OrderModel.fromJson({
          ...json,
          'customer_name': customerData?['full_name'],
          'customer_email': customerData?['email'],
          'customer_phone': customerData?['phone_number'],
          'merchandiser_name': merchandiserData?['business_name']?['en'],
        });
      }).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch orders: ${e.toString()}');
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByMerchandiser({
    required String merchandiserId,
    String? status,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      dynamic query = supabaseClient
          .from('orders')
          .select('''
          *,
          profiles:customer_user_id(full_name, email, phone_number)
        ''')
          .eq('merchandiser_id', merchandiserId);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (paymentStatus != null) {
        query = query.eq('payment_status', paymentStatus);
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      query = query.order('created_at', ascending: false);

      final response = await query;

      return (response as List).map((json) {
        final customerData = json['profiles'];
        return OrderModel.fromJson({
          ...json,
          'customer_name': customerData?['full_name'],
          'customer_email': customerData?['email'],
          'customer_phone': customerData?['phone_number'],
        });
      }).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch merchandiser orders: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByCustomer({
    required String customerId,
    String? merchandiserId,
    String? status,
  }) async {
    try {
      dynamic query = supabaseClient
          .from('orders')
          .select('''
          *,
          merchandisers:merchandiser_id(business_name)
        ''')
          .eq('customer_user_id', customerId);

      if (merchandiserId != null) {
        query = query.eq('merchandiser_id', merchandiserId);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      query = query.order('created_at', ascending: false);

      final response = await query;

      return (response as List).map((json) {
        final merchandiserData = json['merchandisers'];
        return OrderModel.fromJson({
          ...json,
          'merchandiser_name': merchandiserData?['business_name']?['en'],
        });
      }).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch customer orders: ${e.toString()}',
      );
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await supabaseClient
          .from('orders')
          .select('''
          *,
          profiles:customer_user_id(full_name, email, phone_number),
          merchandisers:merchandiser_id(business_name),
          order_items(
            *,
            products(
              id,
              name,
              price,
              images
            )
          )
        ''')
          .eq('id', orderId)
          .single();

      final customerData = response['profiles'] as Map<String, dynamic>?;
      final merchandiserData =
          response['merchandisers'] as Map<String, dynamic>?;

      // Debug print to see what's in the response
      print('Order Response: ${response.toString()}');
      print('Applied Offer ID: ${response['applied_offer_id']}');
      print('Offer Details: ${response['offer_details']}');

      return OrderModel.fromJson({
        ...response,
        'customer_name': customerData?['full_name'],
        'customer_email': customerData?['email'],
        'customer_phone': customerData?['phone_number'],
        'merchandiser_name': merchandiserData?['business_name']?['en'],
      });
    } catch (e) {
      print('Error fetching order: $e');
      throw ServerException(
        message: 'Failed to fetch order details: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await supabaseClient
          .from('orders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
    } catch (e) {
      throw ServerException(
        message: 'Failed to update order status: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  }) async {
    try {
      await supabaseClient
          .from('orders')
          .update({
            'payment_status': paymentStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
    } catch (e) {
      throw ServerException(
        message: 'Failed to update payment status: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    try {
      await supabaseClient
          .from('orders')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
    } catch (e) {
      throw ServerException(message: 'Failed to cancel order: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderStatistics({
    String? merchandiserId,
  }) async {
    try {
      var query = supabaseClient.from('orders').select('status, total_amount');

      if (merchandiserId != null) {
        query = query.eq('merchandiser_id', merchandiserId);
      }

      final response = await query;
      final orders = response as List;

      final totalOrders = orders.length;
      final pendingOrders = orders
          .where((o) => o['status'] == 'pending')
          .length;
      final confirmedOrders = orders
          .where((o) => o['status'] == 'confirmed')
          .length;
      final preparingOrders = orders
          .where((o) => o['status'] == 'preparing')
          .length;
      final onTheWayOrders = orders
          .where((o) => o['status'] == 'on_the_way')
          .length;
      final deliveredOrders = orders
          .where((o) => o['status'] == 'delivered')
          .length;
      final cancelledOrders = orders
          .where((o) => o['status'] == 'cancelled')
          .length;

      final totalRevenue = orders.fold<double>(
        0.0,
        (sum, order) => sum + (order['total_amount'] as num).toDouble(),
      );

      return {
        'total_orders': totalOrders,
        'pending_orders': pendingOrders,
        'confirmed_orders': confirmedOrders,
        'preparing_orders': preparingOrders,
        'on_the_way_orders': onTheWayOrders,
        'delivered_orders': deliveredOrders,
        'cancelled_orders': cancelledOrders,
        'total_revenue': totalRevenue,
      };
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch order statistics: ${e.toString()}',
      );
    }
  }
}
