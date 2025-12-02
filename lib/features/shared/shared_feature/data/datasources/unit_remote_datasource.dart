// lib/features/shared/data/datasources/unit_remote_datasource.dart

import 'package:admin_panel/features/shared/shared_feature/data/models/unit_of_measurement_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/error/exceptions.dart';

abstract class UnitRemoteDataSource {
  Future<List<UnitOfMeasurementModel>> getUnits();
  Future<UnitOfMeasurementModel> getUnitById(String unitId);
}

class UnitRemoteDataSourceImpl implements UnitRemoteDataSource {
  final SupabaseClient supabaseClient;

  const UnitRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<UnitOfMeasurementModel>> getUnits() async {
    try {
      final response = await supabaseClient
          .from('units_of_measurement')
          .select()
          .eq('is_active', true)
          .order('name->>en', ascending: true);

      return (response as List)
          .map((json) => UnitOfMeasurementModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to fetch units: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<UnitOfMeasurementModel> getUnitById(String unitId) async {
    try {
      final response = await supabaseClient
          .from('units_of_measurement')
          .select()
          .eq('id', unitId)
          .single();

      return UnitOfMeasurementModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to fetch unit: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
}
