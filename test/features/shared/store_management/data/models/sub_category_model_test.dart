// test/features/shared/shared_feature/data/models/sub_category_model_test.dart

import 'package:admin_panel/features/shared/shared_feature/data/models/sub_category_model.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tSubCategoryModel = SubCategoryModel(
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

  group('SubCategoryModel', () {
    test('should be a subclass of SubCategory entity', () {
      expect(tSubCategoryModel, isA<SubCategory>());
    });

    group('fromJson', () {
      test('should return a valid SubCategoryModel from JSON with all fields',
          () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'sub-1',
          'category_id': 'cat-1',
          'merchandiser_id': 'merch-1',
          'name': {'en': 'Smartphones', 'ar': 'هواتف ذكية'},
          'sort_order': 1,
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000',
          'updated_at': '2024-01-01T00:00:00.000',
          'category_name': {'en': 'Electronics', 'ar': 'إلكترونيات'},
          'product_count': 10,
        };

        // act
        final result = SubCategoryModel.fromJson(jsonMap);

        // assert
        expect(result, equals(tSubCategoryModel));
      });

      test(
          'should return a valid SubCategoryModel from JSON without optional fields',
          () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'sub-2',
          'category_id': 'cat-1',
          'merchandiser_id': 'merch-1',
          'name': {'en': 'Laptops', 'ar': 'أجهزة كمبيوتر محمولة'},
          'sort_order': 2,
          'is_active': true,
          'created_at': '2024-01-02T00:00:00.000',
          'updated_at': '2024-01-02T00:00:00.000',
          'category_name': {'en': 'Electronics', 'ar': 'إلكترونيات'},
          'product_count': 5,
        };

        // act
        final result = SubCategoryModel.fromJson(jsonMap);

        // assert
        expect(result.id, 'sub-2');
        expect(result.categoryId, 'cat-1');
        expect(result.merchandiserId, 'merch-1');
        expect(result.name, {'en': 'Laptops', 'ar': 'أجهزة كمبيوتر محمولة'});
        expect(result.sortOrder, 2);
        expect(result.isActive, true);
        expect(
            result.subCategoryName, {'en': 'Electronics', 'ar': 'إلكترونيات'});
        expect(result.productCount, 5);
      });

      test('should handle JSONB name field correctly', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'sub-3',
          'category_id': 'cat-2',
          'merchandiser_id': 'merch-1',
          'name': {'en': 'T-Shirts', 'ar': 'قمصان'},
          'sort_order': 1,
          'is_active': true,
          'created_at': '2024-01-03T00:00:00.000',
          'updated_at': '2024-01-03T00:00:00.000',
          'category_name': {'en': 'Clothing', 'ar': 'ملابس'},
          'product_count': 15,
        };

        // act
        final result = SubCategoryModel.fromJson(jsonMap);

        // assert
        expect(result.name, {'en': 'T-Shirts', 'ar': 'قمصان'});
        expect(result.subCategoryName, {'en': 'Clothing', 'ar': 'ملابس'});
      });

      test('should handle name as string and convert to map', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'sub-4',
          'category_id': 'cat-1',
          'merchandiser_id': 'merch-1',
          'name': 'Simple Name',
          'sort_order': 1,
          'is_active': true,
          'created_at': '2024-01-04T00:00:00.000',
          'updated_at': '2024-01-04T00:00:00.000',
          'category_name': 'Simple Category',
          'product_count': 0,
        };

        // act
        final result = SubCategoryModel.fromJson(jsonMap);

        // assert
        expect(result.name, {'en': 'Simple Name'});
        expect(result.subCategoryName, {'en': 'Simple Category'});
      });

      test('should handle null name field', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'sub-5',
          'category_id': 'cat-1',
          'merchandiser_id': 'merch-1',
          'name': null,
          'sort_order': 1,
          'is_active': true,
          'created_at': '2024-01-05T00:00:00.000',
          'updated_at': '2024-01-05T00:00:00.000',
          'category_name': null,
          'product_count': 0,
        };

        // act
        final result = SubCategoryModel.fromJson(jsonMap);

        // assert
        expect(result.name, {});
        expect(result.subCategoryName, {});
      });

      test('should handle Map<String, dynamic> name field', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'sub-6',
          'category_id': 'cat-1',
          'merchandiser_id': 'merch-1',
          'name': <String, dynamic>{'en': 'Tablets', 'ar': 'أجهزة لوحية'},
          'sort_order': 3,
          'is_active': true,
          'created_at': '2024-01-06T00:00:00.000',
          'updated_at': '2024-01-06T00:00:00.000',
          'category_name': {'en': 'Electronics', 'ar': 'إلكترونيات'},
          'product_count': 7,
        };

        // act
        final result = SubCategoryModel.fromJson(jsonMap);

        // assert
        expect(result.name, {'en': 'Tablets', 'ar': 'أجهزة لوحية'});
      });
    });

    group('equality', () {
      test('should have equal SubCategoryModels with same properties', () {
        // arrange
        final subCategory1 = SubCategoryModel(
          id: 'sub-7',
          categoryId: 'cat-1',
          merchandiserId: 'merch-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime(2024, 1, 7),
          updatedAt: DateTime(2024, 1, 7),
          subCategoryName: {'en': 'Category', 'ar': 'فئة'},
          productCount: 0,
        );

        final subCategory2 = SubCategoryModel(
          id: 'sub-7',
          categoryId: 'cat-1',
          merchandiserId: 'merch-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime(2024, 1, 7),
          updatedAt: DateTime(2024, 1, 7),
          subCategoryName: {'en': 'Category', 'ar': 'فئة'},
          productCount: 0,
        );

        // assert
        expect(subCategory1, equals(subCategory2));
      });

      test('should have different SubCategoryModels with different ids', () {
        // arrange
        final subCategory1 = SubCategoryModel(
          id: 'sub-8',
          categoryId: 'cat-1',
          merchandiserId: 'merch-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime(2024, 1, 8),
          updatedAt: DateTime(2024, 1, 8),
          subCategoryName: {'en': 'Category', 'ar': 'فئة'},
          productCount: 0,
        );

        final subCategory2 = SubCategoryModel(
          id: 'sub-9',
          categoryId: 'cat-1',
          merchandiserId: 'merch-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime(2024, 1, 8),
          updatedAt: DateTime(2024, 1, 8),
          subCategoryName: {'en': 'Category', 'ar': 'فئة'},
          productCount: 0,
        );

        // assert
        expect(subCategory1, isNot(equals(subCategory2)));
      });
    });

    group('props', () {
      test('should return correct props for Equatable', () {
        // act
        final props = tSubCategoryModel;

        // assert
        expect(props, props);
      });
    });
  });
}
