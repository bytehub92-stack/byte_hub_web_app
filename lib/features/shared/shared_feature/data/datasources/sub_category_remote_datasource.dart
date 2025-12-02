// lib/features/shared/data/datasources/sub_category_remote_datasource.dart

import 'package:admin_panel/features/shared/shared_feature/data/models/sub_category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/error/exceptions.dart';

abstract class SubCategoryRemoteDataSource {
  Future<List<SubCategoryModel>> getSubCategoriesByCategoryId(
    String categoryId,
  );
  Future<SubCategoryModel> getSubCategoryById(String subCategoryId);
  Future<SubCategoryModel> createSubCategory(
    Map<String, dynamic> subCategoryData,
  );
  Future<SubCategoryModel> updateSubCategory(
    String subCategoryId,
    Map<String, dynamic> updates,
  );
  Future<void> deleteSubCategory(String subCategoryId);
}

class SubCategoryRemoteDataSourceImpl implements SubCategoryRemoteDataSource {
  final SupabaseClient supabaseClient;

  const SubCategoryRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<SubCategoryModel>> getSubCategoriesByCategoryId(
    String categoryId,
  ) async {
    try {
      final response = await supabaseClient
          .from('admin_sub_categories_view')
          .select()
          .eq('category_id', categoryId)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => SubCategoryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to fetch sub-categories: ${e.message}',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<SubCategoryModel> getSubCategoryById(String subCategoryId) async {
    try {
      final response = await supabaseClient
          .from('admin_sub_categories_view')
          .select()
          .eq('id', subCategoryId)
          .single();

      return SubCategoryModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to fetch sub-category: ${e.message}',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<SubCategoryModel> createSubCategory(
    Map<String, dynamic> subCategoryData,
  ) async {
    try {
      final response = await supabaseClient
          .from('sub_categories')
          .insert(subCategoryData)
          .select()
          .single();

      // Fetch from view to get complete data with category_name and product_count
      final viewResponse = await supabaseClient
          .from('admin_sub_categories_view')
          .select()
          .eq('id', response['id'])
          .single();

      return SubCategoryModel.fromJson(viewResponse);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to create sub-category: ${e.message}',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<SubCategoryModel> updateSubCategory(
    String subCategoryId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await supabaseClient
          .from('sub_categories')
          .update(updates)
          .eq('id', subCategoryId);

      // Fetch from view to get complete data
      final viewResponse = await supabaseClient
          .from('admin_sub_categories_view')
          .select()
          .eq('id', subCategoryId)
          .single();

      return SubCategoryModel.fromJson(viewResponse);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to update sub-category: ${e.message}',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSubCategory(String subCategoryId) async {
    try {
      await supabaseClient
          .from('sub_categories')
          .delete()
          .eq('id', subCategoryId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to delete sub-category: ${e.message}',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
}
