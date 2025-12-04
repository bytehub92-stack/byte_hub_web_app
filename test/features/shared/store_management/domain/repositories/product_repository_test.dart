// test/features/shared/shared_feature/domain/repositories/product_repository_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/data/models/product_model.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
  });

  final tMerchandiserId = 'merch-1';
  final tCategoryId = 'cat-1';
  final tSubCategoryId = 'sub-1';
  final tProductId = 'prod-1';
  final tName = {'en': 'iPhone 15 Pro', 'ar': 'آيفون 15 برو'};
  final tDescription = {
    'en': 'Latest iPhone with advanced features',
    'ar': 'أحدث آيفون بميزات متقدمة',
  };
  final tPrice = 999.99;
  final tImages = ['https://example.com/iphone1.jpg'];
  final tStockQuantity = 50;
  final tUnitOfMeasurementId = 'unit-1';

  final tProducts = [
    ProductModel(
      id: 'prod-1',
      merchandiserId: tMerchandiserId,
      categoryId: tCategoryId,
      subCategoryId: tSubCategoryId,
      name: {'en': 'iPhone 15 Pro', 'ar': 'آيفون 15 برو'},
      description: {
        'en': 'Latest iPhone with advanced features',
        'ar': 'أحدث آيفون بميزات متقدمة',
      },
      price: 999.99,
      images: ['https://example.com/iphone1.jpg'],
      imagesThumbnails: null,
      rating: 4.5,
      reviewCount: 120,
      isAvailable: true,
      sku: 'IPH15PRO',
      stockQuantity: 50,
      costPrice: 800.0,
      weight: 0.5,
      tags: {'featured': 'true'},
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      discountPrice: 899.99,
      discountStartDate: DateTime(2024, 1, 1),
      discountEndDate: DateTime(2024, 12, 31),
      isFeatured: true,
      unitOfMeasurementId: 'unit-1',
    ),
    ProductModel(
      id: 'prod-2',
      merchandiserId: tMerchandiserId,
      categoryId: tCategoryId,
      subCategoryId: tSubCategoryId,
      name: {'en': 'Samsung Galaxy S24', 'ar': 'سامسونج جالاكسي S24'},
      description: {'en': 'Powerful Android', 'ar': 'أندرويد قوي'},
      price: 849.99,
      images: ['https://example.com/samsung1.jpg'],
      imagesThumbnails: null,
      rating: 4.3,
      reviewCount: 85,
      isAvailable: true,
      sku: 'SAMS24',
      stockQuantity: 30,
      costPrice: 700.0,
      weight: 0.45,
      tags: null,
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
      discountPrice: null,
      discountStartDate: null,
      discountEndDate: null,
      isFeatured: false,
      unitOfMeasurementId: 'unit-1',
    ),
  ];

  final tProduct = tProducts[0];

  group('ProductRepository', () {
    group('getProductsBySubCategory', () {
      test(
        'should return List<Product> when call to repository is successful',
        () async {
          // arrange
          when(
            () => mockRepository.getProductsBySubCategory(
              subCategoryId: any(named: 'subCategoryId'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              searchQuery: any(named: 'searchQuery'),
              sortBy: any(named: 'sortBy'),
            ),
          ).thenAnswer((_) async => Right(tProducts));

          // act
          final result = await mockRepository.getProductsBySubCategory(
            subCategoryId: tSubCategoryId,
          );

          // assert
          expect(result, Right(tProducts));
          verify(
            () => mockRepository.getProductsBySubCategory(
              subCategoryId: tSubCategoryId,
              page: 1,
              limit: 20,
              searchQuery: null,
              sortBy: null,
            ),
          ).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return empty list when no products exist',
        () async {
          // arrange
          when(
            () => mockRepository.getProductsBySubCategory(
              subCategoryId: any(named: 'subCategoryId'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              searchQuery: any(named: 'searchQuery'),
              sortBy: any(named: 'sortBy'),
            ),
          ).thenAnswer((_) async => const Right([]));

          // act
          final result = await mockRepository.getProductsBySubCategory(
            subCategoryId: tSubCategoryId,
          );

          // assert
          expect(result, equals(const Right<Failure, List<Product>>([])));
          verify(
            () => mockRepository.getProductsBySubCategory(
              subCategoryId: tSubCategoryId,
              page: 1,
              limit: 20,
              searchQuery: null,
              sortBy: null,
            ),
          ).called(1);
        },
      );

      test(
        'should return products with pagination',
        () async {
          // arrange
          when(
            () => mockRepository.getProductsBySubCategory(
              subCategoryId: any(named: 'subCategoryId'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              searchQuery: any(named: 'searchQuery'),
              sortBy: any(named: 'sortBy'),
            ),
          ).thenAnswer((_) async => Right([tProducts[0]]));

          // act
          final result = await mockRepository.getProductsBySubCategory(
            subCategoryId: tSubCategoryId,
            page: 2,
            limit: 10,
          );

          // assert
          expect(result.isRight(), true);
          expect(result.getOrElse(() => []), hasLength(1));
          expect(result.getOrElse(() => [])[0].id, tProducts[0].id);
          verify(
            () => mockRepository.getProductsBySubCategory(
              subCategoryId: tSubCategoryId,
              page: 2,
              limit: 10,
              searchQuery: null,
              sortBy: null,
            ),
          ).called(1);
        },
      );

      test(
        'should return products with search query',
        () async {
          // arrange
          when(
            () => mockRepository.getProductsBySubCategory(
              subCategoryId: any(named: 'subCategoryId'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              searchQuery: any(named: 'searchQuery'),
              sortBy: any(named: 'sortBy'),
            ),
          ).thenAnswer((_) async => Right([tProducts[0]]));

          // act
          final result = await mockRepository.getProductsBySubCategory(
            subCategoryId: tSubCategoryId,
            searchQuery: 'iPhone',
          );
          // assert
          expect(result.isRight(), true);
          expect(result.getOrElse(() => []), hasLength(1));
          expect(result.getOrElse(() => [])[0].id, tProducts[0].id);
          verify(
            () => mockRepository.getProductsBySubCategory(
              subCategoryId: tSubCategoryId,
              page: 1,
              limit: 20,
              searchQuery: 'iPhone',
              sortBy: null,
            ),
          ).called(1);
        },
      );

      test(
        'should return ServerFailure when repository call fails',
        () async {
          // arrange
          when(
            () => mockRepository.getProductsBySubCategory(
              subCategoryId: any(named: 'subCategoryId'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              searchQuery: any(named: 'searchQuery'),
              sortBy: any(named: 'sortBy'),
            ),
          ).thenAnswer(
            (_) async =>
                Left(ServerFailure(message: 'Failed to fetch products')),
          );

          // act
          final result = await mockRepository.getProductsBySubCategory(
            subCategoryId: tSubCategoryId,
          );

          // assert
          expect(
            result,
            Left(ServerFailure(message: 'Failed to fetch products')),
          );
          verify(
            () => mockRepository.getProductsBySubCategory(
              subCategoryId: tSubCategoryId,
              page: 1,
              limit: 20,
              searchQuery: null,
              sortBy: null,
            ),
          ).called(1);
        },
      );
    });

    group('getProductById', () {
      test(
        'should return Product when call to repository is successful',
        () async {
          // arrange
          when(() => mockRepository.getProductById(any()))
              .thenAnswer((_) async => Right(tProduct));

          // act
          final result = await mockRepository.getProductById(tProductId);

          // assert
          expect(result, Right(tProduct));
          verify(() => mockRepository.getProductById(tProductId)).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return ServerFailure when product not found',
        () async {
          // arrange
          when(() => mockRepository.getProductById(any())).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Product not found')),
          );

          // act
          final result = await mockRepository.getProductById('invalid-id');

          // assert
          expect(result, Left(ServerFailure(message: 'Product not found')));
          verify(() => mockRepository.getProductById('invalid-id')).called(1);
        },
      );
    });

    group('createProduct', () {
      test(
        'should return Product when creation is successful',
        () async {
          // arrange
          when(
            () => mockRepository.createProduct(
              merchandiserId: any(named: 'merchandiserId'),
              categoryId: any(named: 'categoryId'),
              subCategoryId: any(named: 'subCategoryId'),
              name: any(named: 'name'),
              description: any(named: 'description'),
              price: any(named: 'price'),
              images: any(named: 'images'),
              stockQuantity: any(named: 'stockQuantity'),
              unitOfMeasurementId: any(named: 'unitOfMeasurementId'),
              sku: any(named: 'sku'),
              isAvailable: any(named: 'isAvailable'),
              isFeatured: any(named: 'isFeatured'),
              discountPrice: any(named: 'discountPrice'),
              discountStartDate: any(named: 'discountStartDate'),
              discountEndDate: any(named: 'discountEndDate'),
              costPrice: any(named: 'costPrice'),
              weight: any(named: 'weight'),
              tags: any(named: 'tags'),
            ),
          ).thenAnswer((_) async => Right(tProduct));

          // act
          final result = await mockRepository.createProduct(
            merchandiserId: tMerchandiserId,
            categoryId: tCategoryId,
            subCategoryId: tSubCategoryId,
            name: tName,
            description: tDescription,
            price: tPrice,
            images: tImages,
            stockQuantity: tStockQuantity,
            unitOfMeasurementId: tUnitOfMeasurementId,
          );

          // assert
          expect(result, Right(tProduct));
          verify(
            () => mockRepository.createProduct(
              merchandiserId: tMerchandiserId,
              categoryId: tCategoryId,
              subCategoryId: tSubCategoryId,
              name: tName,
              description: tDescription,
              price: tPrice,
              images: tImages,
              stockQuantity: tStockQuantity,
              unitOfMeasurementId: tUnitOfMeasurementId,
              sku: null,
              isAvailable: true,
              isFeatured: false,
              discountPrice: null,
              discountStartDate: null,
              discountEndDate: null,
              costPrice: null,
              weight: null,
              tags: null,
            ),
          ).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return ServerFailure when creation fails',
        () async {
          // arrange
          when(
            () => mockRepository.createProduct(
              merchandiserId: any(named: 'merchandiserId'),
              categoryId: any(named: 'categoryId'),
              subCategoryId: any(named: 'subCategoryId'),
              name: any(named: 'name'),
              description: any(named: 'description'),
              price: any(named: 'price'),
              images: any(named: 'images'),
              stockQuantity: any(named: 'stockQuantity'),
              unitOfMeasurementId: any(named: 'unitOfMeasurementId'),
              sku: any(named: 'sku'),
              isAvailable: any(named: 'isAvailable'),
              isFeatured: any(named: 'isFeatured'),
              discountPrice: any(named: 'discountPrice'),
              discountStartDate: any(named: 'discountStartDate'),
              discountEndDate: any(named: 'discountEndDate'),
              costPrice: any(named: 'costPrice'),
              weight: any(named: 'weight'),
              tags: any(named: 'tags'),
            ),
          ).thenAnswer(
            (_) async =>
                Left(ServerFailure(message: 'Failed to create product')),
          );

          // act
          final result = await mockRepository.createProduct(
            merchandiserId: tMerchandiserId,
            categoryId: tCategoryId,
            subCategoryId: tSubCategoryId,
            name: tName,
            description: tDescription,
            price: tPrice,
            images: tImages,
            stockQuantity: tStockQuantity,
            unitOfMeasurementId: tUnitOfMeasurementId,
          );

          // assert
          expect(
            result,
            Left(ServerFailure(message: 'Failed to create product')),
          );
        },
      );
    });

    group('updateProduct', () {
      final tUpdatedProduct = ProductModel(
        id: tProductId,
        merchandiserId: tMerchandiserId,
        categoryId: tCategoryId,
        subCategoryId: tSubCategoryId,
        name: {'en': 'Updated iPhone', 'ar': 'آيفون محدث'},
        description: tDescription,
        price: 949.99,
        images: tImages,
        imagesThumbnails: null,
        rating: 4.5,
        reviewCount: 120,
        isAvailable: true,
        sku: 'IPH15PRO',
        stockQuantity: 40,
        costPrice: 800.0,
        weight: 0.5,
        tags: {'featured': 'true'},
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 3),
        discountPrice: null,
        discountStartDate: null,
        discountEndDate: null,
        isFeatured: true,
        unitOfMeasurementId: tUnitOfMeasurementId,
      );

      test(
        'should return updated Product when update is successful',
        () async {
          // arrange
          when(
            () => mockRepository.updateProduct(
              productId: any(named: 'productId'),
              name: any(named: 'name'),
              description: any(named: 'description'),
              price: any(named: 'price'),
              images: any(named: 'images'),
              stockQuantity: any(named: 'stockQuantity'),
              unitOfMeasurementId: any(named: 'unitOfMeasurementId'),
              sku: any(named: 'sku'),
              isAvailable: any(named: 'isAvailable'),
              isFeatured: any(named: 'isFeatured'),
              discountPrice: any(named: 'discountPrice'),
              discountStartDate: any(named: 'discountStartDate'),
              discountEndDate: any(named: 'discountEndDate'),
              costPrice: any(named: 'costPrice'),
              weight: any(named: 'weight'),
              tags: any(named: 'tags'),
            ),
          ).thenAnswer((_) async => Right(tUpdatedProduct));

          // act
          final result = await mockRepository.updateProduct(
            productId: tProductId,
            name: {'en': 'Updated iPhone', 'ar': 'آيفون محدث'},
            price: 949.99,
            stockQuantity: 40,
          );

          // assert
          expect(result, Right(tUpdatedProduct));
          verify(
            () => mockRepository.updateProduct(
              productId: tProductId,
              name: {'en': 'Updated iPhone', 'ar': 'آيفون محدث'},
              description: null,
              price: 949.99,
              images: null,
              stockQuantity: 40,
              unitOfMeasurementId: null,
              sku: null,
              isAvailable: null,
              isFeatured: null,
              discountPrice: null,
              discountStartDate: null,
              discountEndDate: null,
              costPrice: null,
              weight: null,
              tags: null,
            ),
          ).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return updated Product when updating only one field',
        () async {
          // arrange
          when(
            () => mockRepository.updateProduct(
              productId: any(named: 'productId'),
              name: any(named: 'name'),
              description: any(named: 'description'),
              price: any(named: 'price'),
              images: any(named: 'images'),
              stockQuantity: any(named: 'stockQuantity'),
              unitOfMeasurementId: any(named: 'unitOfMeasurementId'),
              sku: any(named: 'sku'),
              isAvailable: any(named: 'isAvailable'),
              isFeatured: any(named: 'isFeatured'),
              discountPrice: any(named: 'discountPrice'),
              discountStartDate: any(named: 'discountStartDate'),
              discountEndDate: any(named: 'discountEndDate'),
              costPrice: any(named: 'costPrice'),
              weight: any(named: 'weight'),
              tags: any(named: 'tags'),
            ),
          ).thenAnswer((_) async => Right(tUpdatedProduct));

          // act
          final result = await mockRepository.updateProduct(
            productId: tProductId,
            price: 949.99,
          );

          // assert
          expect(result, Right(tUpdatedProduct));
          verify(
            () => mockRepository.updateProduct(
              productId: tProductId,
              name: null,
              description: null,
              price: 949.99,
              images: null,
              stockQuantity: null,
              unitOfMeasurementId: null,
              sku: null,
              isAvailable: null,
              isFeatured: null,
              discountPrice: null,
              discountStartDate: null,
              discountEndDate: null,
              costPrice: null,
              weight: null,
              tags: null,
            ),
          ).called(1);
        },
      );

      test(
        'should return ServerFailure when product not found',
        () async {
          // arrange
          when(
            () => mockRepository.updateProduct(
              productId: any(named: 'productId'),
              name: any(named: 'name'),
              description: any(named: 'description'),
              price: any(named: 'price'),
              images: any(named: 'images'),
              stockQuantity: any(named: 'stockQuantity'),
              unitOfMeasurementId: any(named: 'unitOfMeasurementId'),
              sku: any(named: 'sku'),
              isAvailable: any(named: 'isAvailable'),
              isFeatured: any(named: 'isFeatured'),
              discountPrice: any(named: 'discountPrice'),
              discountStartDate: any(named: 'discountStartDate'),
              discountEndDate: any(named: 'discountEndDate'),
              costPrice: any(named: 'costPrice'),
              weight: any(named: 'weight'),
              tags: any(named: 'tags'),
            ),
          ).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Product not found')),
          );

          // act
          final result = await mockRepository.updateProduct(
            productId: 'invalid-id',
            price: 949.99,
          );

          // assert
          expect(result, Left(ServerFailure(message: 'Product not found')));
        },
      );
    });

    group('deleteProduct', () {
      test(
        'should return void when deletion is successful',
        () async {
          // arrange
          when(() => mockRepository.deleteProduct(any()))
              .thenAnswer((_) async => const Right(null));

          // act
          final result = await mockRepository.deleteProduct(tProductId);

          // assert
          expect(result, const Right(null));
          verify(() => mockRepository.deleteProduct(tProductId)).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return ServerFailure when product not found',
        () async {
          // arrange
          when(() => mockRepository.deleteProduct(any())).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Product not found')),
          );

          // act
          final result = await mockRepository.deleteProduct('invalid-id');

          // assert
          expect(result, Left(ServerFailure(message: 'Product not found')));
          verify(() => mockRepository.deleteProduct('invalid-id')).called(1);
        },
      );

      test(
        'should return ServerFailure when deletion fails',
        () async {
          // arrange
          when(() => mockRepository.deleteProduct(any())).thenAnswer(
            (_) async =>
                Left(ServerFailure(message: 'Failed to delete product')),
          );

          // act
          final result = await mockRepository.deleteProduct(tProductId);

          // assert
          expect(
            result,
            Left(ServerFailure(message: 'Failed to delete product')),
          );
          verify(() => mockRepository.deleteProduct(tProductId)).called(1);
        },
      );
    });
  });
}
