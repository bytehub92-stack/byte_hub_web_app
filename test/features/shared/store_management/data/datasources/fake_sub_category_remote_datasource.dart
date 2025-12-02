// test/features/shared/data/datasources/fake_sub_category_remote_datasource.dart

import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/features/shared/shared_feature/data/datasources/sub_category_remote_datasource.dart';
import 'package:admin_panel/features/shared/shared_feature/data/models/sub_category_model.dart';

class FakeSubCategoryRemoteDataSource implements SubCategoryRemoteDataSource {
  final Map<String, SubCategoryModel> _subCategories = {};
  bool shouldThrowError = false;
  String? errorMessage;

  void seedData() {
    final subCat1 = SubCategoryModel(
      id: 'sub-1',
      categoryId: 'cat-1',
      merchandiserId: 'merch-1',
      name: {'en': 'Smartphones', 'ar': 'هواتف ذكية'},
      sortOrder: 1,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      subCategoryName: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      productCount: 10,
    );

    final subCat2 = SubCategoryModel(
      id: 'sub-2',
      categoryId: 'cat-1',
      merchandiserId: 'merch-1',
      name: {'en': 'Laptops', 'ar': 'أجهزة كمبيوتر محمولة'},
      sortOrder: 2,
      isActive: true,
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
      subCategoryName: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      productCount: 5,
    );

    final subCat3 = SubCategoryModel(
      id: 'sub-3',
      categoryId: 'cat-2',
      merchandiserId: 'merch-1',
      name: {'en': 'T-Shirts', 'ar': 'قمصان'},
      sortOrder: 1,
      isActive: true,
      createdAt: DateTime(2024, 1, 3),
      updatedAt: DateTime(2024, 1, 3),
      subCategoryName: {'en': 'Clothing', 'ar': 'ملابس'},
      productCount: 15,
    );

    _subCategories[subCat1.id] = subCat1;
    _subCategories[subCat2.id] = subCat2;
    _subCategories[subCat3.id] = subCat3;
  }

  void clear() {
    _subCategories.clear();
    shouldThrowError = false;
    errorMessage = null;
  }

  void throwError(String message) {
    shouldThrowError = true;
    errorMessage = message;
  }

  @override
  Future<List<SubCategoryModel>> getSubCategoriesByCategoryId(
    String categoryId,
  ) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to fetch sub-categories',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    final results =
        _subCategories.values
            .where((subCat) => subCat.categoryId == categoryId)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return results;
  }

  @override
  Future<SubCategoryModel> getSubCategoryById(String subCategoryId) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to fetch sub-category',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    final subCategory = _subCategories[subCategoryId];
    if (subCategory == null) {
      throw ServerException(message: 'Sub-category not found');
    }

    return subCategory;
  }

  @override
  Future<SubCategoryModel> createSubCategory(
    Map<String, dynamic> subCategoryData,
  ) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to create sub-category',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // Extract and cast the name field properly
    final nameData = subCategoryData['name'];
    Map<String, String> name;

    if (nameData is Map<String, String>) {
      name = nameData;
    } else if (nameData is Map) {
      // Convert Map<dynamic, dynamic> or Map<String, dynamic> to Map<String, String>
      name = nameData.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } else {
      throw ServerException(message: 'Invalid name format');
    }

    final subCategory = SubCategoryModel(
      id: id,
      categoryId: subCategoryData['category_id'] as String,
      merchandiserId: subCategoryData['merchandiser_id'] as String,
      name: name,
      sortOrder: subCategoryData['sort_order'] as int? ?? 0,
      isActive: subCategoryData['is_active'] as bool? ?? true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      subCategoryName: {'en': 'Category', 'ar': 'فئة'},
      productCount: 0,
    );

    _subCategories[id] = subCategory;
    return subCategory;
  }

  @override
  Future<SubCategoryModel> updateSubCategory(
    String subCategoryId,
    Map<String, dynamic> updates,
  ) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to update sub-category',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    final existing = _subCategories[subCategoryId];
    if (existing == null) {
      throw ServerException(message: 'Sub-category not found');
    }

    // Handle name field casting
    Map<String, String>? updatedName;
    if (updates.containsKey('name')) {
      final nameData = updates['name'];
      if (nameData is Map<String, String>) {
        updatedName = nameData;
      } else if (nameData is Map) {
        updatedName = nameData.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
    }

    final updated = SubCategoryModel(
      id: existing.id,
      categoryId: existing.categoryId,
      merchandiserId: existing.merchandiserId,
      name: updatedName ?? existing.name,
      sortOrder: updates['sort_order'] as int? ?? existing.sortOrder,
      isActive: existing.isActive,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      subCategoryName: existing.subCategoryName,
      productCount: existing.productCount,
    );

    _subCategories[subCategoryId] = updated;
    return updated;
  }

  @override
  Future<void> deleteSubCategory(String subCategoryId) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to delete sub-category',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    if (!_subCategories.containsKey(subCategoryId)) {
      throw ServerException(message: 'Sub-category not found');
    }

    // Check if sub-category has products (simulate constraint)
    final subCategory = _subCategories[subCategoryId]!;
    if (subCategory.productCount > 0) {
      throw ServerException(
        message: 'Cannot delete sub-category with existing products',
      );
    }

    _subCategories.remove(subCategoryId);
  }

  // Helper methods for testing
  int getSubCategoryCount() => _subCategories.length;

  bool subCategoryExists(String subCategoryId) =>
      _subCategories.containsKey(subCategoryId);

  List<SubCategoryModel> getAllSubCategories() =>
      _subCategories.values.toList();
}
