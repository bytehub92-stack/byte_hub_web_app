// lib/features/delivery/data/datasources/delivery_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/error/exceptions.dart';
import '../models/driver_model.dart';
import '../models/order_assignment_model.dart';

abstract class DeliveryRemoteDataSource {
  Future<List<DriverModel>> getDrivers(String merchandiserId);
  Future<DriverModel> getDriverById(String driverId);
  Future<OrderAssignmentModel> assignOrderToDriver({
    required String orderId,
    required String driverId,
    required String assignedBy,
    String? notes,
  });
  Future<List<OrderAssignmentModel>> getOrderAssignments({
    required String merchandiserId,
    String? driverId,
    bool? onlyActive,
  });
  Future<void> unassignOrder(String orderId);
  Future<Map<String, dynamic>> getDeliveryStatistics(String merchandiserId);
  Future<String> getMerchandiserCode(String merchandiserId);
}

class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final SupabaseClient supabaseClient;

  DeliveryRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<DriverModel>> getDrivers(String merchandiserId) async {
    try {
      final response = await supabaseClient
          .from('drivers_with_stats') // Use the view instead
          .select('*')
          .eq('merchandiser_id', merchandiserId)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        return DriverModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch drivers: ${e.toString()}',
      );
    }
  }

  @override
  Future<DriverModel> getDriverById(String driverId) async {
    try {
      final response = await supabaseClient
          .from('drivers_with_stats') // Use the view instead
          .select('*')
          .eq('id', driverId)
          .single();

      return DriverModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch driver: ${e.toString()}');
    }
  }

  @override
  Future<OrderAssignmentModel> assignOrderToDriver({
    required String orderId,
    required String driverId,
    required String assignedBy,
    String? notes,
  }) async {
    try {
      // Check if order is already assigned
      final existingAssignment = await supabaseClient
          .from('order_assignments')
          .select('id')
          .eq('order_id', orderId)
          .maybeSingle();

      if (existingAssignment != null) {
        throw ServerException(message: 'Order is already assigned to a driver');
      }

      // Create assignment
      final response = await supabaseClient.from('order_assignments').insert({
        'order_id': orderId,
        'driver_id': driverId,
        'assigned_by': assignedBy,
        'notes': notes,
        'delivery_status': 'assigned',
      }).select('''
          *,
          orders!order_assignments_order_id_fkey(
            order_number,
            total_amount,
            status,
            payment_status,
            shipping_address,
            profiles!orders_customer_user_id_fkey(
              full_name,
              phone_number
            )
          ),
          drivers!order_assignments_driver_id_fkey(
            profiles!drivers_profile_id_fkey(
              full_name,
              phone_number
            )
          )
        ''').single();

      // Update order status to on_the_way
      await supabaseClient
          .from('orders')
          .update({'status': 'on_the_way'}).eq('id', orderId);

      return OrderAssignmentModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to assign order: ${e.toString()}');
    }
  }

  @override
  Future<List<OrderAssignmentModel>> getOrderAssignments({
    required String merchandiserId,
    String? driverId,
    bool? onlyActive,
  }) async {
    try {
      var query = supabaseClient.from('order_assignments').select('''
        *,
        orders!order_assignments_order_id_fkey(
          order_number,
          total_amount,
          status,
          payment_status,
          shipping_address,
          profiles!orders_customer_user_id_fkey(
            full_name,
            phone_number
          )
        ),
        drivers!order_assignments_driver_id_fkey(
          id,
          merchandiser_id,
          profiles!drivers_profile_id_fkey(
            full_name,
            phone_number
          )
        )
      ''').eq('drivers.merchandiser_id', merchandiserId);

      // Filter by driver if provided
      if (driverId != null) {
        query = query.eq('driver_id', driverId);
      }

      // Filter only active assignments if requested
      if (onlyActive == true) {
        query = query.inFilter('delivery_status', [
          'assigned',
          'picked_up',
          'on_the_way',
        ]);
      }

      final response = await query;

      return (response as List).map((json) {
        return OrderAssignmentModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch order assignments: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> unassignOrder(String orderId) async {
    try {
      // Get the assignment first to get driver ID
      final assignment = await supabaseClient
          .from('order_assignments')
          .select('delivery_status, driver_id')
          .eq('order_id', orderId)
          .single();

      if (assignment['delivery_status'] == 'delivered') {
        throw ServerException(message: 'Cannot unassign a delivered order');
      }

      // Delete assignment
      await supabaseClient
          .from('order_assignments')
          .delete()
          .eq('order_id', orderId);

      // Update order status back to confirmed or preparing
      await supabaseClient
          .from('orders')
          .update({'status': 'preparing'}).eq('id', orderId);
    } catch (e) {
      throw ServerException(
        message: 'Failed to unassign order: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getDeliveryStatistics(
    String merchandiserId,
  ) async {
    try {
      // Get all drivers
      final driversResponse = await supabaseClient
          .from('drivers')
          .select('id, is_available, is_active')
          .eq('merchandiser_id', merchandiserId);

      final totalDrivers = (driversResponse as List).length;
      final activeDrivers =
          driversResponse.where((d) => d['is_active'] == true).length;
      final availableDrivers = driversResponse
          .where((d) => d['is_available'] == true && d['is_active'] == true)
          .length;

      // Get order assignments
      final assignmentsResponse =
          await supabaseClient.from('order_assignments').select('''
            id,
            delivery_status,
            delivered_at,
            drivers!order_assignments_driver_id_fkey(merchandiser_id)
          ''').eq('drivers.merchandiser_id', merchandiserId);

      final assignments = assignmentsResponse as List;
      final totalAssignments = assignments.length;
      final activeDeliveries = assignments
          .where(
            (a) => [
              'assigned',
              'picked_up',
              'on_the_way',
            ].contains(a['delivery_status']),
          )
          .length;
      final completedDeliveries =
          assignments.where((a) => a['delivery_status'] == 'delivered').length;

      return {
        'total_drivers': totalDrivers,
        'active_drivers': activeDrivers,
        'available_drivers': availableDrivers,
        'total_assignments': totalAssignments,
        'active_deliveries': activeDeliveries,
        'completed_deliveries': completedDeliveries,
      };
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch delivery statistics: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> getMerchandiserCode(String merchandiserId) async {
    try {
      final response = await supabaseClient
          .from('merchandisers')
          .select('merchandiser_code')
          .eq('id', merchandiserId)
          .single();

      return response['merchandiser_code'] as String;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get merchandiser code: ${e.toString()}',
      );
    }
  }
}
