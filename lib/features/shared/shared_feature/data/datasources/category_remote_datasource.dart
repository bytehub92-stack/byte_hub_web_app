import 'package:admin_panel/features/shared/shared_feature/data/models/category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/error/exceptions.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories(String merchandiserId);
  Future<CategoryModel> getCategoryById(String categoryId);
  Future<CategoryModel> createCategory({
    required String categoryId,
    required String merchandiserId,
    required Map<String, String> name,
    String? imageThumbnail,
    String? image,
    int sortOrder = 0,
  });
  Future<CategoryModel> updateCategory({
    required String categoryId,
    Map<String, String>? name,
    String? imageThumbnail,
    String? image,
    int? sortOrder,
    bool? isActive,
  });
  Future<void> deleteCategory(String categoryId);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final SupabaseClient supabaseClient;

  const CategoryRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<CategoryModel>> getCategories(String merchandiserId) async {
    try {
      final response = await supabaseClient
          .from('admin_categories_view') // Use view instead of table
          .select()
          .eq('merchandiser_id', merchandiserId)
          .order('sort_order', ascending: true);
      print('category remote data source, get merchs: $response');
      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String categoryId) async {
    try {
      final response = await supabaseClient
          .from('categories')
          .select()
          .eq('id', categoryId)
          .single();

      return CategoryModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to fetch category: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> createCategory({
    required String categoryId,
    required String merchandiserId,
    required Map<String, String> name,
    String? imageThumbnail,
    String? image,
    int sortOrder = 0,
  }) async {
    try {
      final data = {
        'id': categoryId,
        'merchandiser_id': merchandiserId,
        'name': name,
        'image_thumbnail': imageThumbnail,
        'image': image,
        'is_active': true,
        'sort_order': sortOrder,
      };

      final response = await supabaseClient
          .from('categories')
          .insert(data)
          .select()
          .single();

      return CategoryModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to create category: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> updateCategory({
    required String categoryId,
    Map<String, String>? name,
    String? imageThumbnail,
    String? image,
    int? sortOrder,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (imageThumbnail != null) data['image_thumbnail'] = imageThumbnail;
      if (image != null) data['image'] = image;
      if (sortOrder != null) data['sort_order'] = sortOrder;
      if (isActive != null) data['is_active'] = isActive;

      final response = await supabaseClient
          .from('categories')
          .update(data)
          .eq('id', categoryId)
          .select()
          .single();

      return CategoryModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to update category: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await supabaseClient.from('categories').delete().eq('id', categoryId);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to delete category: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
}
