// test/features/shared/shared_feature/data/models/product_model_test.dart

import 'package:admin_panel/features/shared/shared_feature/data/models/product_model.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tProductModel = ProductModel(
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

  group('ProductModel', () {
    test('should be a subclass of Product entity', () {
      expect(tProductModel, isA<Product>());
    });

    group('fromJson', () {
      test('should return a valid ProductModel from JSON with all fields', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'prod-1',
          'merchandiser_id': 'merch-1',
          'category_id': 'cat-1',
          'sub_category_id': 'sub-1',
          'name': {'en': 'iPhone 15 Pro', 'ar': 'آيفون 15 برو'},
          'description': {
            'en': 'Latest iPhone with advanced features',
            'ar': 'أحدث آيفون بميزات متقدمة',
          },
          'price': 999.99,
          'images': [
            'https://example.com/iphone1.jpg',
            'https://example.com/iphone2.jpg',
          ],
          'images_thumbnails': ['https://example.com/iphone1-thumb.jpg'],
          'rating': 4.5,
          'review_count': 120,
          'is_available': true,
          'sku': 'IPH15PRO',
          'stock_quantity': 50,
          'cost_price': 800.0,
          'weight': 0.5,
          'tags': {'featured': 'true', 'new': 'true'},
          'created_at': '2024-01-01T00:00:00.000',
          'updated_at': '2024-01-01T00:00:00.000',
          'discount_price': 899.99,
          'discount_start_date': '2024-01-01T00:00:00.000',
          'discount_end_date': '2024-12-31T00:00:00.000',
          'is_featured': true,
          'category_name': {'en': 'Electronics', 'ar': 'إلكترونيات'},
          'sub_category_name': {'en': 'Smartphones', 'ar': 'هواتف ذكية'},
          'merchandiser_business_name': {
            'en': 'Tech Store',
            'ar': 'متجر التقنية'
          },
          'merchandiser_is_active': true,
          'current_price': 899.99,
          'has_active_discount': true,
          'is_in_stock': true,
          'unit_of_measurement_id': 'unit-1',
          'unit_code': 'PCS',
          'unit_name': {'en': 'Piece', 'ar': 'قطعة'},
        };

        // act
        final result = ProductModel.fromJson(jsonMap);

        // assert
        expect(result, equals(tProductModel));
      });

      test(
          'should return a valid ProductModel from JSON without optional fields',
          () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'prod-2',
          'merchandiser_id': 'merch-1',
          'category_id': 'cat-1',
          'sub_category_id': 'sub-1',
          'name': {'en': 'Samsung Galaxy S24', 'ar': 'سامسونج جالاكسي S24'},
          'description': {'en': 'Android smartphone', 'ar': 'هاتف أندرويد'},
          'price': 849.99,
          'images': ['https://example.com/samsung1.jpg'],
          'created_at': '2024-01-02T00:00:00.000',
          'updated_at': '2024-01-02T00:00:00.000',
        };

        // act
        final result = ProductModel.fromJson(jsonMap);

        // assert
        expect(result.id, 'prod-2');
        expect(result.merchandiserId, 'merch-1');
        expect(result.categoryId, 'cat-1');
        expect(result.subCategoryId, 'sub-1');
        expect(result.name,
            {'en': 'Samsung Galaxy S24', 'ar': 'سامسونج جالاكسي S24'});
        expect(result.price, 849.99);
        expect(result.rating, 0.0);
        expect(result.reviewCount, 0);
        expect(result.isAvailable, true);
        expect(result.sku, isNull);
        expect(result.stockQuantity, 0);
        expect(result.isFeatured, false);
      });

      test('should parse numeric fields correctly', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'prod-3',
          'merchandiser_id': 'merch-1',
          'category_id': 'cat-1',
          'sub_category_id': 'sub-1',
          'name': {'en': 'Test Product', 'ar': 'منتج تجريبي'},
          'description': {'en': 'Test', 'ar': 'تجربة'},
          'price': '499.99', // String
          'rating': 4, // Int
          'cost_price': 400.0, // Double
          'weight': '0.3', // String
          'images': ['https://example.com/test.jpg'],
          'created_at': '2024-01-03T00:00:00.000',
          'updated_at': '2024-01-03T00:00:00.000',
        };

        // act
        final result = ProductModel.fromJson(jsonMap);

        // assert
        expect(result.price, 499.99);
        expect(result.rating, 4.0);
        expect(result.costPrice, 400.0);
        expect(result.weight, 0.3);
      });

      test('should handle JSONB fields correctly', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'prod-4',
          'merchandiser_id': 'merch-1',
          'category_id': 'cat-1',
          'sub_category_id': 'sub-1',
          'name': {'en': 'Laptop', 'ar': 'لابتوب'},
          'description': {'en': 'Powerful laptop', 'ar': 'لابتوب قوي'},
          'price': 1200.0,
          'images': ['https://example.com/laptop.jpg'],
          'created_at': '2024-01-04T00:00:00.000',
          'updated_at': '2024-01-04T00:00:00.000',
          'category_name': {'en': 'Electronics', 'ar': 'إلكترونيات'},
          'unit_name': {'en': 'Piece', 'ar': 'قطعة'},
        };

        // act
        final result = ProductModel.fromJson(jsonMap);

        // assert
        expect(result.name, {'en': 'Laptop', 'ar': 'لابتوب'});
        expect(
            result.description, {'en': 'Powerful laptop', 'ar': 'لابتوب قوي'});
        expect(result.categoryName, {'en': 'Electronics', 'ar': 'إلكترونيات'});
        expect(result.unitName, {'en': 'Piece', 'ar': 'قطعة'});
      });

      test('should handle string arrays correctly', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'prod-5',
          'merchandiser_id': 'merch-1',
          'category_id': 'cat-1',
          'sub_category_id': 'sub-1',
          'name': {'en': 'Camera', 'ar': 'كاميرا'},
          'description': {'en': 'Digital camera', 'ar': 'كاميرا رقمية'},
          'price': 799.99,
          'images': [
            'https://example.com/cam1.jpg',
            'https://example.com/cam2.jpg',
            'https://example.com/cam3.jpg',
          ],
          'images_thumbnails': [
            'https://example.com/cam1-thumb.jpg',
            'https://example.com/cam2-thumb.jpg',
          ],
          'created_at': '2024-01-05T00:00:00.000',
          'updated_at': '2024-01-05T00:00:00.000',
        };

        // act
        final result = ProductModel.fromJson(jsonMap);

        // assert
        expect(result.images.length, 3);
        expect(result.imagesThumbnails?.length, 2);
      });

      test('should handle null fields correctly', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'prod-6',
          'merchandiser_id': 'merch-1',
          'category_id': 'cat-1',
          'sub_category_id': 'sub-1',
          'name': null,
          'description': null,
          'price': 100.0,
          'images': null,
          'created_at': '2024-01-06T00:00:00.000',
          'updated_at': '2024-01-06T00:00:00.000',
          'category_name': null,
          'unit_name': null,
        };

        // act
        final result = ProductModel.fromJson(jsonMap);

        // assert
        expect(result.name, {});
        expect(result.description, {});
        expect(result.images, []);
        expect(result.categoryName, isNull);
        expect(result.unitName, isNull);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // act
        final result = tProductModel.toJson();

        // assert
        expect(result['id'], 'prod-1');
        expect(result['merchandiser_id'], 'merch-1');
        expect(result['category_id'], 'cat-1');
        expect(result['sub_category_id'], 'sub-1');
        expect(result['name'], {'en': 'iPhone 15 Pro', 'ar': 'آيفون 15 برو'});
        expect(result['price'], 999.99);
        expect(result['images'], [
          'https://example.com/iphone1.jpg',
          'https://example.com/iphone2.jpg',
        ]);
        expect(result['sku'], 'IPH15PRO');
        expect(result['stock_quantity'], 50);
        expect(result['is_featured'], true);
        expect(result['unit_of_measurement_id'], 'unit-1');
        expect(result['unit_code'], 'PCS');
      });

      test('should exclude null optional fields from JSON', () {
        // arrange
        final productWithNulls = ProductModel(
          id: 'prod-7',
          merchandiserId: 'merch-1',
          categoryId: 'cat-1',
          subCategoryId: 'sub-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          description: {'en': 'Test', 'ar': 'اختبار'},
          price: 100.0,
          images: ['https://example.com/test.jpg'],
          imagesThumbnails: null,
          rating: 0.0,
          reviewCount: 0,
          isAvailable: true,
          sku: null,
          stockQuantity: 0,
          costPrice: null,
          weight: null,
          tags: null,
          createdAt: DateTime(2024, 1, 7),
          updatedAt: DateTime(2024, 1, 7),
          discountPrice: null,
          discountStartDate: null,
          discountEndDate: null,
          isFeatured: false,
          unitOfMeasurementId: 'unit-1',
        );

        // act
        final result = productWithNulls.toJson();

        // assert
        expect(result.containsKey('sku'), false);
        expect(result.containsKey('cost_price'), false);
        expect(result.containsKey('weight'), false);
        expect(result.containsKey('tags'), false);
        expect(result.containsKey('discount_price'), false);
      });
    });

    group('copyWith', () {
      test('should copy ProductModel with updated fields', () {
        // act
        final result = tProductModel.copyWith(
          name: {'en': 'Updated iPhone', 'ar': 'آيفون محدث'},
          price: 949.99,
          stockQuantity: 40,
        );

        // assert
        expect(result.id, tProductModel.id);
        expect(result.name, {'en': 'Updated iPhone', 'ar': 'آيفون محدث'});
        expect(result.price, 949.99);
        expect(result.stockQuantity, 40);
        expect(result.sku, tProductModel.sku);
        expect(result.isFeatured, tProductModel.isFeatured);
      });

      test('should keep original values when no parameters provided', () {
        // act
        final result = tProductModel.copyWith();

        // assert
        expect(result, equals(tProductModel));
      });

      test('should update unit of measurement correctly', () {
        // act
        final result = tProductModel.copyWith(
          unitOfMeasurementId: 'unit-2',
          unitCode: 'KG',
          unitName: {'en': 'Kilogram', 'ar': 'كيلوجرام'},
        );

        // assert
        expect(result.unitOfMeasurementId, 'unit-2');
        expect(result.unitCode, 'KG');
        expect(result.unitName, {'en': 'Kilogram', 'ar': 'كيلوجرام'});
      });
    });

    group('equality', () {
      test('should have equal ProductModels with same properties', () {
        // arrange
        final product1 = ProductModel(
          id: 'prod-8',
          merchandiserId: 'merch-1',
          categoryId: 'cat-1',
          subCategoryId: 'sub-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          description: {'en': 'Test', 'ar': 'اختبار'},
          price: 100.0,
          images: ['https://example.com/test.jpg'],
          imagesThumbnails: null,
          rating: 0.0,
          reviewCount: 0,
          isAvailable: true,
          sku: null,
          stockQuantity: 10,
          costPrice: null,
          weight: null,
          tags: null,
          createdAt: DateTime(2024, 1, 8),
          updatedAt: DateTime(2024, 1, 8),
          discountPrice: null,
          discountStartDate: null,
          discountEndDate: null,
          isFeatured: false,
          unitOfMeasurementId: 'unit-1',
        );

        final product2 = ProductModel(
          id: 'prod-8',
          merchandiserId: 'merch-1',
          categoryId: 'cat-1',
          subCategoryId: 'sub-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          description: {'en': 'Test', 'ar': 'اختبار'},
          price: 100.0,
          images: ['https://example.com/test.jpg'],
          imagesThumbnails: null,
          rating: 0.0,
          reviewCount: 0,
          isAvailable: true,
          sku: null,
          stockQuantity: 10,
          costPrice: null,
          weight: null,
          tags: null,
          createdAt: DateTime(2024, 1, 8),
          updatedAt: DateTime(2024, 1, 8),
          discountPrice: null,
          discountStartDate: null,
          discountEndDate: null,
          isFeatured: false,
          unitOfMeasurementId: 'unit-1',
        );

        // assert
        expect(product1, equals(product2));
      });

      test('should have different ProductModels with different ids', () {
        // arrange
        final product1 = ProductModel(
          id: 'prod-9',
          merchandiserId: 'merch-1',
          categoryId: 'cat-1',
          subCategoryId: 'sub-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          description: {'en': 'Test', 'ar': 'اختبار'},
          price: 100.0,
          images: ['https://example.com/test.jpg'],
          imagesThumbnails: null,
          rating: 0.0,
          reviewCount: 0,
          isAvailable: true,
          sku: null,
          stockQuantity: 10,
          costPrice: null,
          weight: null,
          tags: null,
          createdAt: DateTime(2024, 1, 9),
          updatedAt: DateTime(2024, 1, 9),
          discountPrice: null,
          discountStartDate: null,
          discountEndDate: null,
          isFeatured: false,
          unitOfMeasurementId: 'unit-1',
        );

        final product2 = ProductModel(
          id: 'prod-10',
          merchandiserId: 'merch-1',
          categoryId: 'cat-1',
          subCategoryId: 'sub-1',
          name: {'en': 'Test', 'ar': 'اختبار'},
          description: {'en': 'Test', 'ar': 'اختبار'},
          price: 100.0,
          images: ['https://example.com/test.jpg'],
          imagesThumbnails: null,
          rating: 0.0,
          reviewCount: 0,
          isAvailable: true,
          sku: null,
          stockQuantity: 10,
          costPrice: null,
          weight: null,
          tags: null,
          createdAt: DateTime(2024, 1, 9),
          updatedAt: DateTime(2024, 1, 9),
          discountPrice: null,
          discountStartDate: null,
          discountEndDate: null,
          isFeatured: false,
          unitOfMeasurementId: 'unit-1',
        );

        // assert
        expect(product1, isNot(equals(product2)));
      });
    });
  });
}
