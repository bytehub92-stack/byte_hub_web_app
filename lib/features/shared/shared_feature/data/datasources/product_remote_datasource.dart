import 'package:admin_panel/features/shared/shared_feature/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/error/exceptions.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProductsBySubCategory({
    required String subCategoryId,
    int page = 1,
    int limit = 20,
    String? searchQuery,
    String? sortBy,
  });
  Future<ProductModel> getProductById(String productId);
  Future<ProductModel> createProduct(Map<String, dynamic> productData);
  Future<ProductModel> updateProduct(
    String productId,
    Map<String, dynamic> updates,
  );
  Future<void> deleteProduct(String productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient supabaseClient;

  const ProductRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ProductModel>> getProductsBySubCategory({
    required String subCategoryId,
    int page = 1,
    int limit = 20,
    String? searchQuery,
    String? sortBy,
  }) async {
    try {
      var query = supabaseClient
          .from('admin_products_view')
          .select()
          .eq('sub_category_id', subCategoryId);

      // Add search functionality
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'name->>en.ilike.%$searchQuery%,name->>ar.ilike.%$searchQuery%',
        );
      }

      // Add pagination first
      final offset = (page - 1) * limit;
      var finalQuery = query.range(offset, offset + limit - 1);

      // Add sorting after range
      switch (sortBy) {
        case 'price_asc':
          finalQuery = finalQuery.order('price', ascending: true);
          break;
        case 'price_desc':
          finalQuery = finalQuery.order('price', ascending: false);
          break;
        case 'name':
          finalQuery = finalQuery.order('name->>en', ascending: true);
          break;
        case 'newest':
        default:
          finalQuery = finalQuery.order('created_at', ascending: false);
          break;
      }

      final response = await finalQuery;

      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to fetch products: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> getProductById(String productId) async {
    try {
      final response = await supabaseClient
          .from('admin_products_view')
          .select()
          .eq('id', productId)
          .single();

      return ProductModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to fetch product: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await supabaseClient
          .from('products')
          .insert(productData)
          .select()
          .single();

      // Fetch from view to get complete data with relationships
      final viewResponse = await supabaseClient
          .from('admin_products_view')
          .select()
          .eq('id', response['id'])
          .single();

      return ProductModel.fromJson(viewResponse);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to create product: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> updateProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await supabaseClient.from('products').update(updates).eq('id', productId);

      // Fetch from view to get complete data with relationships
      final viewResponse = await supabaseClient
          .from('admin_products_view')
          .select()
          .eq('id', productId)
          .single();

      return ProductModel.fromJson(viewResponse);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to update product: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await supabaseClient.from('products').delete().eq('id', productId);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to delete product: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
}
