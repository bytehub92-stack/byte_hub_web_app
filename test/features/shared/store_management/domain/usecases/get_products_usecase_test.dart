// test/features/shared/domain/usecases/get_products_usecase_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/product_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_products_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/datasources/fake_product_remote_datasource.dart';

void main() {
  late GetProductsBySubCategoryUsecase useCase;
  late ProductRepositoryImpl repository;
  late FakeProductRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeProductRemoteDataSource();
    repository = ProductRepositoryImpl(remoteDataSource: fakeDataSource);
    useCase = GetProductsBySubCategoryUsecase(repository);
  });

  tearDown(() {
    fakeDataSource.clear();
  });

  group('GetProductsBySubCategoryUsecase', () {
    const tSubCategoryId = 'sub-1';

    group('Success Cases - Basic Retrieval', () {
      test('should return list of products for sub-category', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(subCategoryId: tSubCategoryId);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<Right<Failure, List<Product>>>());
        result.fold((failure) => fail('Should not return failure'), (products) {
          expect(products, isA<List<Product>>());
          expect(products.length, 2);
          expect(products[0].name['en'], 'Samsung Galaxy S24');
          expect(products[1].name['en'], 'iPhone 15 Pro');
        });
      });

      test('should return products with all required fields', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(subCategoryId: tSubCategoryId);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          final product = products.first;
          expect(product.id, isNotEmpty);
          expect(product.merchandiserId, isNotEmpty);
          expect(product.categoryId, isNotEmpty);
          expect(product.subCategoryId, tSubCategoryId);
          expect(product.name, isNotEmpty);
          expect(product.name['en'], isNotNull);
          expect(product.name['ar'], isNotNull);
          expect(product.price, greaterThan(0));
          expect(product.images, isNotEmpty);
          expect(product.stockQuantity, greaterThanOrEqualTo(0));
          expect(product.isAvailable, isA<bool>());
          expect(product.createdAt, isA<DateTime>());
          expect(product.updatedAt, isA<DateTime>());
        });
      });

      test('should return empty list when no products exist', () async {
        // Arrange
        fakeDataSource.seedData();
        const emptySubCategory = 'sub-999';
        final params = GetProductsParams(subCategoryId: emptySubCategory);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          expect(products, isEmpty);
          expect(products, isA<List<Product>>());
        });
      });

      test(
        'should return correct products for different sub-categories',
        () async {
          // Arrange
          fakeDataSource.seedData();
          final params1 = GetProductsParams(subCategoryId: 'sub-1');
          final params2 = GetProductsParams(subCategoryId: 'sub-2');

          // Act
          final result1 = await useCase(params1);
          final result2 = await useCase(params2);

          // Assert
          late List<Product> products1;
          late List<Product> products2;

          result1.fold(
            (failure) => fail('Should not return failure'),
            (products) => products1 = products,
          );

          result2.fold(
            (failure) => fail('Should not return failure'),
            (products) => products2 = products,
          );

          expect(products1.length, 2);
          expect(products2.length, 1);
          expect(products1.first.subCategoryId, 'sub-1');
          expect(products2.first.subCategoryId, 'sub-2');
        },
      );
    });

    group('Success Cases - Pagination', () {
      test('should return correct page of products', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          page: 1,
          limit: 1,
        );

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          expect(products.length, 1);
        });
      });

      test('should return second page of products', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          page: 2,
          limit: 1,
        );

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          expect(products.length, 1);
        });
      });

      test('should return empty list for page beyond available data', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          page: 10,
          limit: 20,
        );

        // Act
        final result = await useCase(params);

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (products) => expect(products, isEmpty),
        );
      });

      test('should handle different page sizes', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          page: 1,
          limit: 10,
        );

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          expect(products.length, lessThanOrEqualTo(10));
        });
      });
    });

    group('Success Cases - Search', () {
      test('should filter products by search query (English)', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          searchQuery: 'iPhone',
        );

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          expect(products.length, 1);
          expect(products.first.name['en'], contains('iPhone'));
        });
      });

      test(
        'should filter products by search query (case insensitive)',
        () async {
          // Arrange
          fakeDataSource.seedData();
          final params = GetProductsParams(
            subCategoryId: tSubCategoryId,
            searchQuery: 'iphone',
          );

          // Act
          final result = await useCase(params);

          // Assert
          result.fold((failure) => fail('Should not return failure'), (
            products,
          ) {
            expect(products.length, 1);
            expect(
              products.first.name['en']?.toLowerCase(),
              contains('iphone'),
            );
          });
        },
      );

      test(
        'should return empty list when search query matches nothing',
        () async {
          // Arrange
          fakeDataSource.seedData();
          final params = GetProductsParams(
            subCategoryId: tSubCategoryId,
            searchQuery: 'NonExistentProduct',
          );

          // Act
          final result = await useCase(params);

          // Assert
          result.fold(
            (failure) => fail('Should not return failure'),
            (products) => expect(products, isEmpty),
          );
        },
      );

      test('should handle empty search query', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          searchQuery: '',
        );

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          expect(products.length, 2);
        });
      });
    });

    group('Success Cases - Sorting', () {
      test('should sort products by price ascending', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          sortBy: 'price_asc',
        );

        // Act
        final result = await useCase(params);

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
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          sortBy: 'price_desc',
        );

        // Act
        final result = await useCase(params);

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
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          sortBy: 'name',
        );

        // Act
        final result = await useCase(params);

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
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          sortBy: 'newest',
        );

        // Act
        final result = await useCase(params);

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

      test('should handle null sort parameter (use default)', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          sortBy: null,
        );

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          expect(products, isNotEmpty);
        });
      });
    });

    group('Success Cases - Combined Filters', () {
      test('should combine search and sorting', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          searchQuery: 'phone',
          sortBy: 'price_asc',
        );

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          expect(products, isNotEmpty);
          // Verify sorting
          for (int i = 0; i < products.length - 1; i++) {
            expect(products[i].price <= products[i + 1].price, true);
          }
        });
      });

      test('should combine pagination and search', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          searchQuery: 'Samsung',
          page: 1,
          limit: 10,
        );

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          expect(products.length, lessThanOrEqualTo(10));
        });
      });

      test('should combine all filters', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(
          subCategoryId: tSubCategoryId,
          searchQuery: 'phone',
          sortBy: 'price_desc',
          page: 1,
          limit: 5,
        );

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          expect(products.length, lessThanOrEqualTo(5));
        });
      });
    });

    group('Failure Cases', () {
      test('should return ServerFailure when repository fails', () async {
        // Arrange
        fakeDataSource.throwError('Database connection failed');
        final params = GetProductsParams(subCategoryId: tSubCategoryId);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<Left<Failure, List<Product>>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Database connection failed'));
        }, (products) => fail('Should not return products'));
      });

      test('should return ServerFailure on network error', () async {
        // Arrange
        fakeDataSource.throwError('Network timeout');
        final params = GetProductsParams(subCategoryId: tSubCategoryId);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<Left<Failure, List<Product>>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Network timeout'));
        }, (products) => fail('Should not return products'));
      });
    });

    group('Edge Cases', () {
      test('should handle products with discount', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(subCategoryId: tSubCategoryId);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          final productWithDiscount = products.firstWhere(
            (p) => p.discountPrice != null,
          );
          if (productWithDiscount.discountPrice != null) {
            expect(productWithDiscount.currentPrice, isNotNull);
            expect(productWithDiscount.hasActiveDiscount, isNotNull);
          }
        });
      });

      test('should handle products with unit of measurement', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(subCategoryId: tSubCategoryId);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (products) {
          for (final product in products) {
            expect(product.unitOfMeasurementId, isNotNull);
            expect(product.unitCode, isNotNull);
          }
        });
      });

      test('should maintain data consistency across calls', () async {
        // Arrange
        fakeDataSource.seedData();
        final params = GetProductsParams(subCategoryId: tSubCategoryId);

        // Act
        final result1 = await useCase(params);
        final result2 = await useCase(params);

        // Assert - Data should be consistent
        late List<Product> products1;
        late List<Product> products2;

        result1.fold(
          (failure) => fail('Should not return failure'),
          (products) => products1 = products,
        );

        result2.fold(
          (failure) => fail('Should not return failure'),
          (products) => products2 = products,
        );

        expect(products1.length, products2.length);
        for (int i = 0; i < products1.length; i++) {
          expect(products1[i].id, products2[i].id);
          expect(products1[i].name, products2[i].name);
        }
      });
    });
  });

  group('GetProductByIdUsecase', () {
    const tProductId = 'prod-1';
    late GetProductByIdUsecase getByIdUseCase;

    setUp(() {
      getByIdUseCase = GetProductByIdUsecase(repository);
    });

    test('should return product when found', () async {
      // Arrange
      fakeDataSource.seedData();

      // Act
      final result = await getByIdUseCase(tProductId);

      // Assert
      expect(result, isA<Right<Failure, Product>>());
      result.fold((failure) => fail('Should not return failure'), (product) {
        expect(product.id, tProductId);
        expect(product.name['en'], 'iPhone 15 Pro');
      });
    });

    test('should return ServerFailure when product not found', () async {
      // Arrange
      fakeDataSource.seedData();
      const nonExistentId = 'prod-999';

      // Act
      final result = await getByIdUseCase(nonExistentId);

      // Assert
      expect(result, isA<Left<Failure, Product>>());
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Product not found');
      }, (product) => fail('Should not return product'));
    });

    test('should return ServerFailure on error', () async {
      // Arrange
      fakeDataSource.throwError('Database error');

      // Act
      final result = await getByIdUseCase(tProductId);

      // Assert
      expect(result, isA<Left<Failure, Product>>());
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('Database error'));
      }, (product) => fail('Should not return product'));
    });
  });
}
