// test/features/shared/data/datasources/fake_product_remote_datasource.dart

import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/features/shared/shared_feature/data/datasources/product_remote_datasource.dart';
import 'package:admin_panel/features/shared/shared_feature/data/models/product_model.dart';

class FakeProductRemoteDataSource implements ProductRemoteDataSource {
  final Map<String, ProductModel> _products = {};
  bool shouldThrowError = false;
  String? errorMessage;

  void seedData() {
    final product1 = ProductModel(
      id: 'prod-1',
      merchandiserId: 'merch-1',
      categoryId: 'cat-1',
      subCategoryId: 'sub-1',
      name: {'en': 'iPhone 15 Pro', 'ar': 'آيفون 15 برو'},
      description: {
        'en': 'Latest iPhone with advanced features',
        'ar': 'أحدث آيفون بميزات متقدمة',
      },
      price: 999.99,
      images: [
        'https://example.com/iphone1.jpg',
        'https://example.com/iphone2.jpg',
      ],
      imagesThumbnails: ['https://example.com/iphone1-thumb.jpg'],
      rating: 4.5,
      reviewCount: 120,
      isAvailable: true,
      sku: 'IPH15PRO',
      stockQuantity: 50,
      costPrice: 800.0,
      weight: 0.5,
      tags: {'featured': 'true', 'new': 'true'},
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      discountPrice: 899.99,
      discountStartDate: DateTime(2024, 1, 1),
      discountEndDate: DateTime(2024, 12, 31),
      isFeatured: true,
      categoryName: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      subCategoryName: {'en': 'Smartphones', 'ar': 'هواتف ذكية'},
      merchandiserBusinessName: {'en': 'Tech Store', 'ar': 'متجر التقنية'},
      merchandiserIsActive: true,
      currentPrice: 899.99,
      hasActiveDiscount: true,
      isInStock: true,
      unitOfMeasurementId: 'unit-1',
      unitCode: 'PCS',
      unitName: {'en': 'Piece', 'ar': 'قطعة'},
    );

    final product2 = ProductModel(
      id: 'prod-2',
      merchandiserId: 'merch-1',
      categoryId: 'cat-1',
      subCategoryId: 'sub-1',
      name: {'en': 'Samsung Galaxy S24', 'ar': 'سامسونج جالاكسي S24'},
      description: {
        'en': 'Powerful Android smartphone',
        'ar': 'هاتف أندرويد قوي',
      },
      price: 849.99,
      images: ['https://example.com/samsung1.jpg'],
      imagesThumbnails: ['https://example.com/samsung1-thumb.jpg'],
      rating: 4.3,
      reviewCount: 85,
      isAvailable: true,
      sku: 'SAMS24',
      stockQuantity: 30,
      costPrice: 700.0,
      weight: 0.45,
      tags: {'new': 'true'},
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
      isFeatured: false,
      categoryName: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      subCategoryName: {'en': 'Smartphones', 'ar': 'هواتف ذكية'},
      merchandiserBusinessName: {'en': 'Tech Store', 'ar': 'متجر التقنية'},
      merchandiserIsActive: true,
      currentPrice: 849.99,
      hasActiveDiscount: false,
      isInStock: true,
      unitOfMeasurementId: 'unit-1',
      unitCode: 'PCS',
      unitName: {'en': 'Piece', 'ar': 'قطعة'},
    );

    final product3 = ProductModel(
      id: 'prod-3',
      merchandiserId: 'merch-1',
      categoryId: 'cat-1',
      subCategoryId: 'sub-2',
      name: {'en': 'MacBook Pro 16', 'ar': 'ماك بوك برو 16'},
      description: {
        'en': 'Professional laptop for creators',
        'ar': 'لابتوب احترافي للمبدعين',
      },
      price: 2499.99,
      images: ['https://example.com/macbook1.jpg'],
      imagesThumbnails: ['https://example.com/macbook1-thumb.jpg'],
      rating: 4.8,
      reviewCount: 200,
      isAvailable: true,
      sku: 'MBP16',
      stockQuantity: 15,
      costPrice: 2000.0,
      weight: 2.0,
      tags: {'professional': 'true'},
      createdAt: DateTime(2024, 1, 3),
      updatedAt: DateTime(2024, 1, 3),
      isFeatured: true,
      categoryName: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      subCategoryName: {'en': 'Laptops', 'ar': 'أجهزة كمبيوتر محمولة'},
      merchandiserBusinessName: {'en': 'Tech Store', 'ar': 'متجر التقنية'},
      merchandiserIsActive: true,
      currentPrice: 2499.99,
      hasActiveDiscount: false,
      isInStock: true,
      unitOfMeasurementId: 'unit-1',
      unitCode: 'PCS',
      unitName: {'en': 'Piece', 'ar': 'قطعة'},
    );

    _products[product1.id] = product1;
    _products[product2.id] = product2;
    _products[product3.id] = product3;
  }

  void clear() {
    _products.clear();
    shouldThrowError = false;
    errorMessage = null;
  }

  void throwError(String message) {
    shouldThrowError = true;
    errorMessage = message;
  }

  @override
  Future<List<ProductModel>> getProductsBySubCategory({
    required String subCategoryId,
    int page = 1,
    int limit = 20,
    String? searchQuery,
    String? sortBy,
  }) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to fetch products',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    var results = _products.values
        .where((product) => product.subCategoryId == subCategoryId)
        .toList();

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      results = results.where((product) {
        final nameEn = product.name['en']?.toLowerCase() ?? '';
        final nameAr = product.name['ar']?.toLowerCase() ?? '';
        final query = searchQuery.toLowerCase();
        return nameEn.contains(query) || nameAr.contains(query);
      }).toList();
    }

    // Apply sorting
    switch (sortBy) {
      case 'price_asc':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name':
        results.sort(
          (a, b) => (a.name['en'] ?? '').compareTo(b.name['en'] ?? ''),
        );
        break;
      case 'newest':
      default:
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    // Apply pagination
    final offset = (page - 1) * limit;
    final end = (offset + limit).clamp(0, results.length);

    if (offset >= results.length) {
      return [];
    }

    return results.sublist(offset, end);
  }

  @override
  Future<ProductModel> getProductById(String productId) async {
    if (shouldThrowError) {
      throw ServerException(message: errorMessage ?? 'Failed to fetch product');
    }

    await Future.delayed(const Duration(milliseconds: 10));

    final product = _products[productId];
    if (product == null) {
      throw ServerException(message: 'Product not found');
    }

    return product;
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to create product',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final product = ProductModel(
      id: id,
      merchandiserId: productData['merchandiser_id'] as String,
      categoryId: productData['category_id'] as String,
      subCategoryId: productData['sub_category_id'] as String,
      name: productData['name'] as Map<String, String>,
      description: productData['description'] as Map<String, String>,
      price: productData['price'] as double,
      images: List<String>.from(productData['images'] as List),
      imagesThumbnails: productData['images_thumbnails'] != null
          ? List<String>.from(productData['images_thumbnails'] as List)
          : null,
      rating: 0.0,
      reviewCount: 0,
      isAvailable: productData['is_available'] as bool? ?? true,
      sku: productData['sku'] as String?,
      stockQuantity: productData['stock_quantity'] as int,
      costPrice: productData['cost_price'] as double?,
      weight: productData['weight'] as double?,
      tags: productData['tags'] as Map<String, dynamic>?,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      discountPrice: productData['discount_price'] as double?,
      discountStartDate: productData['discount_start_date'] != null
          ? DateTime.parse(productData['discount_start_date'] as String)
          : null,
      discountEndDate: productData['discount_end_date'] != null
          ? DateTime.parse(productData['discount_end_date'] as String)
          : null,
      isFeatured: productData['is_featured'] as bool? ?? false,
      unitOfMeasurementId: productData['unit_of_measurement_id'] as String,
    );

    _products[id] = product;
    return product;
  }

  @override
  Future<ProductModel> updateProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to update product',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    final existing = _products[productId];
    if (existing == null) {
      throw ServerException(message: 'Product not found');
    }

    final updated = ProductModel(
      id: existing.id,
      merchandiserId: existing.merchandiserId,
      categoryId: existing.categoryId,
      subCategoryId: existing.subCategoryId,
      name: updates['name'] as Map<String, String>? ?? existing.name,
      description:
          updates['description'] as Map<String, String>? ??
          existing.description,
      price: updates['price'] as double? ?? existing.price,
      images: updates['images'] != null
          ? List<String>.from(updates['images'] as List)
          : existing.images,
      imagesThumbnails: existing.imagesThumbnails,
      rating: existing.rating,
      reviewCount: existing.reviewCount,
      isAvailable: updates['is_available'] as bool? ?? existing.isAvailable,
      sku: updates['sku'] as String? ?? existing.sku,
      stockQuantity:
          updates['stock_quantity'] as int? ?? existing.stockQuantity,
      costPrice: updates['cost_price'] as double? ?? existing.costPrice,
      weight: updates['weight'] as double? ?? existing.weight,
      tags: updates['tags'] as Map<String, dynamic>? ?? existing.tags,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      discountPrice:
          updates['discount_price'] as double? ?? existing.discountPrice,
      discountStartDate: existing.discountStartDate,
      discountEndDate: existing.discountEndDate,
      isFeatured: updates['is_featured'] as bool? ?? existing.isFeatured,
      categoryName: existing.categoryName,
      subCategoryName: existing.subCategoryName,
      merchandiserBusinessName: existing.merchandiserBusinessName,
      merchandiserIsActive: existing.merchandiserIsActive,
      currentPrice: existing.currentPrice,
      hasActiveDiscount: existing.hasActiveDiscount,
      isInStock: existing.isInStock,
      unitOfMeasurementId:
          updates['unit_of_measurement_id'] as String? ??
          existing.unitOfMeasurementId,
      unitCode: existing.unitCode,
      unitName: existing.unitName,
    );

    _products[productId] = updated;
    return updated;
  }

  @override
  Future<void> deleteProduct(String productId) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to delete product',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    if (!_products.containsKey(productId)) {
      throw ServerException(message: 'Product not found');
    }

    _products.remove(productId);
  }

  // Helper methods for testing
  int getProductCount() => _products.length;

  bool productExists(String productId) => _products.containsKey(productId);

  List<ProductModel> getAllProducts() => _products.values.toList();

  int getProductCountBySubCategory(String subCategoryId) =>
      _products.values.where((p) => p.subCategoryId == subCategoryId).length;
}
