// test/features/shared/shared_feature/data/models/category_model_test.dart

import 'package:admin_panel/features/shared/shared_feature/data/models/category_model.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tCategoryModel = CategoryModel(
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

  group('CategoryModel', () {
    test('should be a subclass of Category entity', () {
      expect(tCategoryModel, isA<Category>());
    });

    group('fromJson', () {
      test('should return a valid CategoryModel from JSON with all fields', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'cat-1',
          'merchandiser_id': 'merch-1',
          'name': {'en': 'Electronics', 'ar': 'إلكترونيات'},
          'image_thumbnail': 'https://example.com/electronics-thumb.jpg',
          'image': 'https://example.com/electronics.jpg',
          'sort_order': 1,
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000',
          'updated_at': '2024-01-01T00:00:00.000',
          'product_count': 15,
          'sub_category_count': 3,
        };

        // act
        final result = CategoryModel.fromJson(jsonMap);

        // assert
        expect(result, equals(tCategoryModel));
      });

      test(
          'should return a valid CategoryModel from JSON without optional fields',
          () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'cat-2',
          'merchandiser_id': 'merch-1',
          'name': {'en': 'Clothing', 'ar': 'ملابس'},
          'created_at': '2024-01-02T00:00:00.000',
          'updated_at': '2024-01-02T00:00:00.000',
        };

        // act
        final result = CategoryModel.fromJson(jsonMap);

        // assert
        expect(result.id, 'cat-2');
        expect(result.merchandiserId, 'merch-1');
        expect(result.name, {'en': 'Clothing', 'ar': 'ملابس'});
        expect(result.imageThumbnail, isNull);
        expect(result.image, isNull);
        expect(result.sortOrder, 0);
        expect(result.isActive, true);
        expect(result.productCount, 0);
        expect(result.subCategoryCount, 0);
      });

      test('should handle JSONB name field correctly', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'cat-3',
          'merchandiser_id': 'merch-1',
          'name': {'en': 'Food', 'ar': 'طعام'},
          'sort_order': 1,
          'is_active': true,
          'created_at': '2024-01-03T00:00:00.000',
          'updated_at': '2024-01-03T00:00:00.000',
        };

        // act
        final result = CategoryModel.fromJson(jsonMap);

        // assert
        expect(result.name, {'en': 'Food', 'ar': 'طعام'});
      });

      test('should handle name as string and convert to map', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'cat-4',
          'merchandiser_id': 'merch-1',
          'name': 'Simple Name',
          'sort_order': 1,
          'is_active': true,
          'created_at': '2024-01-04T00:00:00.000',
          'updated_at': '2024-01-04T00:00:00.000',
        };

        // act
        final result = CategoryModel.fromJson(jsonMap);

        // assert
        expect(result.name, {'en': 'Simple Name'});
      });

      test('should handle null name field', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'cat-5',
          'merchandiser_id': 'merch-1',
          'name': null,
          'sort_order': 1,
          'is_active': true,
          'created_at': '2024-01-05T00:00:00.000',
          'updated_at': '2024-01-05T00:00:00.000',
        };

        // act
        final result = CategoryModel.fromJson(jsonMap);

        // assert
        expect(result.name, {});
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // act
        final result = tCategoryModel.toJson();

        // assert
        final expectedMap = {
          'id': 'cat-1',
          'merchandiser_id': 'merch-1',
          'name': {'en': 'Electronics', 'ar': 'إلكترونيات'},
          'image_thumbnail': 'https://example.com/electronics-thumb.jpg',
          'image': 'https://example.com/electronics.jpg',
          'sort_order': 1,
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000',
          'updated_at': '2024-01-01T00:00:00.000',
        };

        expect(result, equals(expectedMap));
      });

      test('should handle null optional fields in toJson', () {
        // arrange
        final categoryWithNulls = CategoryModel(
          id: 'cat-6',
          merchandiserId: 'merch-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          imageThumbnail: null,
          image: null,
          sortOrder: 0,
          isActive: true,
          createdAt: DateTime(2024, 1, 6),
          updatedAt: DateTime(2024, 1, 6),
          productCount: 0,
          subCategoryCount: 0,
        );

        // act
        final result = categoryWithNulls.toJson();

        // assert
        expect(result['image_thumbnail'], isNull);
        expect(result['image'], isNull);
      });
    });

    group('fromEntity', () {
      test('should create a CategoryModel from Category entity', () {
        // arrange
        final category = Category(
          id: 'cat-7',
          merchandiserId: 'merch-1',
          name: {'en': 'Books', 'ar': 'كتب'},
          imageThumbnail: 'https://example.com/books-thumb.jpg',
          image: 'https://example.com/books.jpg',
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime.tryParse('2024-01-06')!,
          updatedAt: DateTime.tryParse('2024-01-07')!,
          productCount: 20,
          subCategoryCount: 4,
        );

        // act
        final result = CategoryModel.fromEntity(category);

        // assert
        expect(result, isA<CategoryModel>());
        expect(result.id, category.id);
        expect(result.merchandiserId, category.merchandiserId);
        expect(result.name, category.name);
        expect(result.imageThumbnail, category.imageThumbnail);
        expect(result.image, category.image);
        expect(result.sortOrder, category.sortOrder);
        expect(result.isActive, category.isActive);
        expect(result.productCount, category.productCount);
        expect(result.subCategoryCount, category.subCategoryCount);
      });
    });

    group('equality', () {
      test('should have equal CategoryModels with same properties', () {
        // arrange
        final category1 = CategoryModel(
          id: 'cat-8',
          merchandiserId: 'merch-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          imageThumbnail: null,
          image: null,
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime(2024, 1, 8),
          updatedAt: DateTime(2024, 1, 8),
          productCount: 0,
          subCategoryCount: 0,
        );

        final category2 = CategoryModel(
          id: 'cat-8',
          merchandiserId: 'merch-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          imageThumbnail: null,
          image: null,
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime(2024, 1, 8),
          updatedAt: DateTime(2024, 1, 8),
          productCount: 0,
          subCategoryCount: 0,
        );

        // assert
        expect(category1, equals(category2));
      });

      test('should have different CategoryModels with different ids', () {
        // arrange
        final category1 = CategoryModel(
          id: 'cat-9',
          merchandiserId: 'merch-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          imageThumbnail: null,
          image: null,
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime(2024, 1, 9),
          updatedAt: DateTime(2024, 1, 9),
          productCount: 0,
          subCategoryCount: 0,
        );

        final category2 = CategoryModel(
          id: 'cat-10',
          merchandiserId: 'merch-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          imageThumbnail: null,
          image: null,
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime(2024, 1, 9),
          updatedAt: DateTime(2024, 1, 9),
          productCount: 0,
          subCategoryCount: 0,
        );

        // assert
        expect(category1, isNot(equals(category2)));
      });
    });
  });
}
