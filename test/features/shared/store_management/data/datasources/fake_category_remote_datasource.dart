// test/features/shared/data/datasources/fake_category_remote_datasource.dart

import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/features/shared/shared_feature/data/datasources/category_remote_datasource.dart';
import 'package:admin_panel/features/shared/shared_feature/data/models/category_model.dart';

class FakeCategoryRemoteDataSource implements CategoryRemoteDataSource {
  final Map<String, CategoryModel> _categories = {};
  bool shouldThrowError = false;
  String? errorMessage;

  // Seed with some initial data
  void seedData() {
    final category1 = CategoryModel(
      id: 'cat-1',
      merchandiserId: 'merch-1',
      name: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      imageThumbnail: 'https://example.com/electronics-thumb.jpg',
      image: 'https://example.com/electronics.jpg',
      sortOrder: 1,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      productCount: 15,
      subCategoryCount: 3,
    );

    final category2 = CategoryModel(
      id: 'cat-2',
      merchandiserId: 'merch-1',
      name: {'en': 'Clothing', 'ar': 'ملابس'},
      imageThumbnail: 'https://example.com/clothing-thumb.jpg',
      image: 'https://example.com/clothing.jpg',
      sortOrder: 2,
      isActive: true,
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
      productCount: 25,
      subCategoryCount: 5,
    );

    final category3 = CategoryModel(
      id: 'cat-3',
      merchandiserId: 'merch-2',
      name: {'en': 'Food', 'ar': 'طعام'},
      imageThumbnail: 'https://example.com/food-thumb.jpg',
      image: 'https://example.com/food.jpg',
      sortOrder: 1,
      isActive: false,
      createdAt: DateTime(2024, 1, 3),
      updatedAt: DateTime(2024, 1, 3),
      productCount: 10,
      subCategoryCount: 2,
    );

    _categories[category1.id] = category1;
    _categories[category2.id] = category2;
    _categories[category3.id] = category3;
  }

  void clear() {
    _categories.clear();
    shouldThrowError = false;
    errorMessage = null;
  }

  void throwError(String message) {
    shouldThrowError = true;
    errorMessage = message;
  }

  @override
  Future<List<CategoryModel>> getCategories(String merchandiserId) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to fetch categories',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    final results =
        _categories.values
            .where((cat) => cat.merchandiserId == merchandiserId)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return results;
  }

  @override
  Future<CategoryModel> getCategoryById(String categoryId) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to fetch category',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    final category = _categories[categoryId];
    if (category == null) {
      throw ServerException(message: 'Category not found');
    }

    return category;
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
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to create category',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    if (_categories.containsKey(categoryId)) {
      throw ServerException(message: 'Category already exists');
    }

    final category = CategoryModel(
      id: categoryId,
      merchandiserId: merchandiserId,
      name: name,
      imageThumbnail: imageThumbnail,
      image: image,
      sortOrder: sortOrder,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productCount: 0,
      subCategoryCount: 0,
    );

    _categories[categoryId] = category;
    return category;
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
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to update category',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    final existingCategory = _categories[categoryId];
    if (existingCategory == null) {
      throw ServerException(message: 'Category not found');
    }

    final updatedCategory = CategoryModel(
      id: existingCategory.id,
      merchandiserId: existingCategory.merchandiserId,
      name: name ?? existingCategory.name,
      imageThumbnail: imageThumbnail ?? existingCategory.imageThumbnail,
      image: image ?? existingCategory.image,
      sortOrder: sortOrder ?? existingCategory.sortOrder,
      isActive: isActive ?? existingCategory.isActive,
      createdAt: existingCategory.createdAt,
      updatedAt: DateTime.now(),
      productCount: existingCategory.productCount,
      subCategoryCount: existingCategory.subCategoryCount,
    );

    _categories[categoryId] = updatedCategory;
    return updatedCategory;
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to delete category',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    if (!_categories.containsKey(categoryId)) {
      throw ServerException(message: 'Category not found');
    }

    // Check if category has sub-categories (simulate constraint)
    final category = _categories[categoryId]!;
    if (category.subCategoryCount > 0) {
      throw ServerException(
        message: 'Cannot delete category with existing sub-categories',
      );
    }

    _categories.remove(categoryId);
  }

  // Helper methods for testing
  int getCategoryCount() => _categories.length;

  bool categoryExists(String categoryId) => _categories.containsKey(categoryId);

  List<CategoryModel> getAllCategories() => _categories.values.toList();
}
