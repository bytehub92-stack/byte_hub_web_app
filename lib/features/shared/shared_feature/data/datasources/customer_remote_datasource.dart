// lib/features/shared/data/datasources/customer_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/error/exceptions.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomersByMerchandiser(String merchandiserId);
  Future<CustomerModel> getCustomerById(String customerId);
  Future<void> toggleCustomerStatus(String customerId, bool isActive);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final SupabaseClient supabaseClient;

  const CustomerRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<CustomerModel>> getCustomersByMerchandiser(
    String merchandiserId,
  ) async {
    try {
      final response = await supabaseClient
          .from('customers_view')
          .select()
          .eq('merchandiser_id', merchandiserId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CustomerModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to fetch customers: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<CustomerModel> getCustomerById(String customerId) async {
    try {
      final response = await supabaseClient
          .from('customers_view')
          .select()
          .eq('id', customerId)
          .single();

      return CustomerModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to fetch customer: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleCustomerStatus(String customerId, bool isActive) async {
    try {
      await supabaseClient
          .from('profiles')
          .update({'is_active': isActive})
          .eq('id', customerId);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to update status: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
}
