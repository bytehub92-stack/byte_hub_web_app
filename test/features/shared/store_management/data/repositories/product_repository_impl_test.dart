// test/features/shared/data/repositories/product_repository_impl_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/product_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fake_datasources/fake_product_remote_datasource.dart';

void main() {
  late ProductRepositoryImpl repository;
  late FakeProductRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeProductRemoteDataSource();
    repository = ProductRepositoryImpl(remoteDataSource: fakeDataSource);
  });

  tearDown(() {
    fakeDataSource.clear();
  });

  group('ProductRepositoryImpl - Admin (Read Only)', () {
    const tSubCategoryId = 'sub-1';
    const tProductId = 'prod-1';

    group('getProductsBySubCategory', () {
      test('should return list of products for sub-category', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getProductsBySubCategory(
          subCategoryId: tSubCategoryId,
        );

        // Assert
        expect(result, isA<Right<Failure, List<Product>>>());
        result.fold((failure) => fail('Should not return failure'), (products) {
          expect(products.length, 2);
          expect(products[0].name['en'], 'Samsung Galaxy S24');
          expect(products[1].name['en'], 'iPhone 15 Pro');
        });
      });

      test('should return empty list when no products exist', () async {
        // Arrange
        fakeDataSource.seedData();
        const emptySubCategory = 'sub-999';

        // Act
        final result = await repository.getProductsBySubCategory(
          subCategoryId: emptySubCategory,
        );

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (products) => expect(products, isEmpty),
        );
      });

      test('should apply pagination correctly', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act - Page 1 with limit 1
        final result1 = await repository.getProductsBySubCategory(
          subCategoryId: tSubCategoryId,
          page: 1,
          limit: 1,
        );

        // Assert
        result1.fold(
          (failure) => fail('Should not return failure'),
          (products) => expect(products.length, 1),
        );

        // Act - Page 2 with limit 1
        final result2 = await repository.getProductsBySubCategory(
          subCategoryId: tSubCategoryId,
          page: 2,
          limit: 1,
        );

        // Assert
        result2.fold(
          (failure) => fail('Should not return failure'),
          (products) => expect(products.length, 1),
        );
      });

      test('should filter products by search query', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getProductsBySubCategory(
          subCategoryId: tSubCategoryId,
          searchQuery: 'iPhone',
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          expect(products.length, 1);
          expect(products[0].name['en'], 'iPhone 15 Pro');
        });
      });

      test('should sort products by price ascending', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getProductsBySubCategory(
          subCategoryId: tSubCategoryId,
          sortBy: 'price_asc',
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          for (int i = 0; i < products.length - 1; i++) {
            expect(products[i].price <= products[i + 1].price, true);
          }
        });
      });

      test('should sort products by price descending', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getProductsBySubCategory(
          subCategoryId: tSubCategoryId,
          sortBy: 'price_desc',
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          for (int i = 0; i < products.length - 1; i++) {
            expect(products[i].price >= products[i + 1].price, true);
          }
        });
      });

      test('should sort products by name', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getProductsBySubCategory(
          subCategoryId: tSubCategoryId,
          sortBy: 'name',
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          for (int i = 0; i < products.length - 1; i++) {
            final name1 = products[i].name['en'] ?? '';
            final name2 = products[i + 1].name['en'] ?? '';
            expect(name1.compareTo(name2) <= 0, true);
          }
        });
      });

      test('should sort products by newest (default)', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getProductsBySubCategory(
          subCategoryId: tSubCategoryId,
          sortBy: 'newest',
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          for (int i = 0; i < products.length - 1; i++) {
            expect(
              products[i].createdAt.isAfter(products[i + 1].createdAt) ||
                  products[i].createdAt.isAtSameMomentAs(
                        products[i + 1].createdAt,
                      ),
              true,
            );
          }
        });
      });

      test('should return ServerFailure on data source error', () async {
        // Arrange
        fakeDataSource.throwError('Network error');

        // Act
        final result = await repository.getProductsBySubCategory(
          subCategoryId: tSubCategoryId,
        );

        // Assert
        expect(result, isA<Left<Failure, List<Product>>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Network error'));
        }, (products) => fail('Should not return products'));
      });
    });

    group('getProductById', () {
      test('should return product when found', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getProductById(tProductId);

        // Assert
        expect(result, isA<Right<Failure, Product>>());
        result.fold((failure) => fail('Should not return failure'), (product) {
          expect(product.id, tProductId);
          expect(product.name['en'], 'iPhone 15 Pro');
          expect(product.price, 999.99);
        });
      });

      test('should return ServerFailure when product not found', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentId = 'prod-999';

        // Act
        final result = await repository.getProductById(nonExistentId);

        // Assert
        expect(result, isA<Left<Failure, Product>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Product not found');
        }, (product) => fail('Should not return product'));
      });

      test('should return ServerFailure on data source error', () async {
        // Arrange
        fakeDataSource.throwError('Database error');

        // Act
        final result = await repository.getProductById(tProductId);

        // Assert
        expect(result, isA<Left<Failure, Product>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Database error'));
        }, (product) => fail('Should not return product'));
      });
    });
  });

  group('ProductRepositoryImpl - Merchandiser (Full CRUD)', () {
    const tMerchandiserId = 'merch-1';
    const tCategoryId = 'cat-1';
    const tSubCategoryId = 'sub-1';
    const tUnitId = 'unit-1';

    group('createProduct', () {
      test('should create and return product successfully', () async {
        // Arrange
        final nameMap = {'en': 'New Product', 'ar': 'منتج جديد'};
        final descMap = {'en': 'Description', 'ar': 'وصف'};
        final images = ['https://example.com/image1.jpg'];
        final initialCount = fakeDataSource.getProductCount();

        // Act
        final result = await repository.createProduct(
          merchandiserId: tMerchandiserId,
          categoryId: tCategoryId,
          subCategoryId: tSubCategoryId,
          name: nameMap,
          description: descMap,
          price: 499.99,
          images: images,
          stockQuantity: 100,
          unitOfMeasurementId: tUnitId,
        );

        // Assert
        expect(result, isA<Right<Failure, Product>>());
        result.fold((failure) => fail('Should not return failure'), (product) {
          expect(product.name, nameMap);
          expect(product.description, descMap);
          expect(product.price, 499.99);
          expect(product.stockQuantity, 100);
          expect(product.unitOfMeasurementId, tUnitId);
          expect(fakeDataSource.getProductCount(), initialCount + 1);
        });
      });

      test('should create product with optional fields', () async {
        // Arrange
        final nameMap = {'en': 'Premium Product', 'ar': 'منتج فاخر'};
        final images = ['https://example.com/image1.jpg'];

        // Act
        final result = await repository.createProduct(
          merchandiserId: tMerchandiserId,
          categoryId: tCategoryId,
          subCategoryId: tSubCategoryId,
          name: nameMap,
          price: 1999.99,
          images: images,
          stockQuantity: 50,
          unitOfMeasurementId: tUnitId,
          sku: 'PREM-001',
          isFeatured: true,
          discountPrice: 1799.99,
          costPrice: 1500.0,
          weight: 2.5,
          tags: {'featured': 'true', 'premium': 'true'},
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (product) {
          expect(product.sku, 'PREM-001');
          expect(product.isFeatured, true);
          expect(product.discountPrice, 1799.99);
          expect(product.costPrice, 1500.0);
          expect(product.weight, 2.5);
          expect(product.tags?['featured'], 'true');
        });
      });

      test('should return ServerFailure on creation error', () async {
        // Arrange
        fakeDataSource.throwError('Insert failed');
        final nameMap = {'en': 'New Product', 'ar': 'منتج جديد'};
        final images = ['https://example.com/image1.jpg'];

        // Act
        final result = await repository.createProduct(
          merchandiserId: tMerchandiserId,
          categoryId: tCategoryId,
          subCategoryId: tSubCategoryId,
          name: nameMap,
          price: 499.99,
          images: images,
          stockQuantity: 100,
          unitOfMeasurementId: tUnitId,
        );

        // Assert
        expect(result, isA<Left<Failure, Product>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Insert failed'));
        }, (product) => fail('Should not return product'));
      });
    });

    group('updateProduct', () {
      test('should update product name and price', () async {
        // Arrange
        fakeDataSource.seedData();
        const productId = 'prod-1';
        final newName = {'en': 'iPhone 15 Pro Max', 'ar': 'آيفون 15 برو ماكس'};
        const newPrice = 1099.99;

        // Act
        final result = await repository.updateProduct(
          productId: productId,
          name: newName,
          price: newPrice,
        );

        // Assert
        expect(result, isA<Right<Failure, Product>>());
        result.fold((failure) => fail('Should not return failure'), (product) {
          expect(product.id, productId);
          expect(product.name, newName);
          expect(product.price, newPrice);
        });
      });

      test('should update product stock quantity', () async {
        // Arrange
        fakeDataSource.seedData();
        const productId = 'prod-1';
        const newStock = 75;

        // Act
        final result = await repository.updateProduct(
          productId: productId,
          stockQuantity: newStock,
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (product) {
          expect(product.stockQuantity, newStock);
        });
      });

      test('should update product availability', () async {
        // Arrange
        fakeDataSource.seedData();
        const productId = 'prod-1';

        // Act
        final result = await repository.updateProduct(
          productId: productId,
          isAvailable: false,
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (product) {
          expect(product.isAvailable, false);
        });
      });

      test('should update multiple fields at once', () async {
        // Arrange
        fakeDataSource.seedData();
        const productId = 'prod-1';
        final newName = {'en': 'Updated Product', 'ar': 'منتج محدث'};
        final newDesc = {'en': 'New Description', 'ar': 'وصف جديد'};
        const newPrice = 899.99;
        const newStock = 60;

        // Act
        final result = await repository.updateProduct(
          productId: productId,
          name: newName,
          description: newDesc,
          price: newPrice,
          stockQuantity: newStock,
          isFeatured: true,
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (product) {
          expect(product.name, newName);
          expect(product.description, newDesc);
          expect(product.price, newPrice);
          expect(product.stockQuantity, newStock);
          expect(product.isFeatured, true);
        });
      });

      test('should update unit of measurement', () async {
        // Arrange
        fakeDataSource.seedData();
        const productId = 'prod-1';
        const newUnitId = 'unit-2';

        // Act
        final result = await repository.updateProduct(
          productId: productId,
          unitOfMeasurementId: newUnitId,
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (product) {
          expect(product.unitOfMeasurementId, newUnitId);
        });
      });

      test('should return ServerFailure when no fields provided', () async {
        // Arrange
        fakeDataSource.seedData();
        const productId = 'prod-1';

        // Act
        final result = await repository.updateProduct(productId: productId);

        // Assert
        expect(result, isA<Left<Failure, Product>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('No fields provided for update'));
        }, (product) => fail('Should not return product'));
      });

      test('should return ServerFailure when product not found', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentId = 'prod-999';

        // Act
        final result = await repository.updateProduct(
          productId: nonExistentId,
          price: 599.99,
        );

        // Assert
        expect(result, isA<Left<Failure, Product>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Product not found');
        }, (product) => fail('Should not return product'));
      });

      test('should return ServerFailure on update error', () async {
        // Arrange
        fakeDataSource.seedData();
        fakeDataSource.throwError('Update failed');
        const productId = 'prod-1';

        // Act
        final result = await repository.updateProduct(
          productId: productId,
          price: 599.99,
        );

        // Assert
        expect(result, isA<Left<Failure, Product>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Update failed'));
        }, (product) => fail('Should not return product'));
      });
    });

    group('deleteProduct', () {
      test('should delete product successfully', () async {
        // Arrange
        fakeDataSource.seedData();
        const productId = 'prod-1';
        final initialCount = fakeDataSource.getProductCount();

        // Act
        final result = await repository.deleteProduct(productId);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        result.fold((failure) => fail('Should not return failure'), (_) {
          expect(fakeDataSource.getProductCount(), initialCount - 1);
          expect(fakeDataSource.productExists(productId), false);
        });
      });

      test('should return ServerFailure when product not found', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentId = 'prod-999';

        // Act
        final result = await repository.deleteProduct(nonExistentId);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Product not found');
        }, (_) => fail('Should not succeed'));
      });

      test('should return ServerFailure on deletion error', () async {
        // Arrange
        fakeDataSource.seedData();
        fakeDataSource.throwError('Delete operation failed');
        const productId = 'prod-1';

        // Act
        final result = await repository.deleteProduct(productId);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Delete operation failed'));
        }, (_) => fail('Should not succeed'));
      });
    });
  });
}
