// test/features/merchandisers/store_management/domain/usecases/product/product_usecases_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/product/create_product_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/product/delete_product_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/product/update_product_usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/data/models/product_model.dart';
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

  group('CreateProductUsecase', () {
    late CreateProductUsecase useCase;

    setUp(() {
      useCase = CreateProductUsecase(mockRepository);
    });

    final tMerchandiserId = 'merch-1';
    final tCategoryId = 'cat-1';
    final tSubCategoryId = 'sub-1';
    final tName = {'en': 'iPhone 15 Pro', 'ar': 'آيفون 15 برو'};
    final tDescription = {
      'en': 'Latest iPhone with advanced features',
      'ar': 'أحدث آيفون بميزات متقدمة',
    };
    final tPrice = 999.99;
    final tImages = [
      'https://example.com/iphone1.jpg',
      'https://example.com/iphone2.jpg',
    ];
    final tStockQuantity = 50;
    final tUnitOfMeasurementId = 'unit-1';
    final tSku = 'IPH15PRO';
    final tCostPrice = 800.0;
    final tWeight = 0.5;
    final tTags = {'featured': 'true', 'new': 'true'};
    final tDiscountPrice = 899.99;
    final tDiscountStartDate = DateTime(2024, 1, 1);
    final tDiscountEndDate = DateTime(2024, 12, 31);

    final tProduct = ProductModel(
      id: 'prod-1',
      merchandiserId: tMerchandiserId,
      categoryId: tCategoryId,
      subCategoryId: tSubCategoryId,
      name: tName,
      description: tDescription,
      price: tPrice,
      images: tImages,
      imagesThumbnails: null,
      rating: 0.0,
      reviewCount: 0,
      isAvailable: true,
      sku: tSku,
      stockQuantity: tStockQuantity,
      costPrice: tCostPrice,
      weight: tWeight,
      tags: tTags,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      discountPrice: tDiscountPrice,
      discountStartDate: tDiscountStartDate,
      discountEndDate: tDiscountEndDate,
      isFeatured: true,
      unitOfMeasurementId: tUnitOfMeasurementId,
    );

    test('should create a product with all fields', () async {
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

      final params = CreateProductParams(
        merchandiserId: tMerchandiserId,
        categoryId: tCategoryId,
        subCategoryId: tSubCategoryId,
        name: tName,
        description: tDescription,
        price: tPrice,
        images: tImages,
        stockQuantity: tStockQuantity,
        unitOfMeasurementId: tUnitOfMeasurementId,
        sku: tSku,
        isAvailable: true,
        isFeatured: true,
        discountPrice: tDiscountPrice,
        discountStartDate: tDiscountStartDate,
        discountEndDate: tDiscountEndDate,
        costPrice: tCostPrice,
        weight: tWeight,
        tags: tTags,
      );

      // act
      final result = await useCase(params);

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
          sku: tSku,
          isAvailable: true,
          isFeatured: true,
          discountPrice: tDiscountPrice,
          discountStartDate: tDiscountStartDate,
          discountEndDate: tDiscountEndDate,
          costPrice: tCostPrice,
          weight: tWeight,
          tags: tTags,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should create a product with only required fields', () async {
      // arrange
      final minimalProduct = ProductModel(
        id: 'prod-2',
        merchandiserId: tMerchandiserId,
        categoryId: tCategoryId,
        subCategoryId: tSubCategoryId,
        name: tName,
        description: tDescription,
        price: tPrice,
        images: tImages,
        imagesThumbnails: null,
        rating: 0.0,
        reviewCount: 0,
        isAvailable: true,
        sku: null,
        stockQuantity: tStockQuantity,
        costPrice: null,
        weight: null,
        tags: null,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        discountPrice: null,
        discountStartDate: null,
        discountEndDate: null,
        isFeatured: false,
        unitOfMeasurementId: tUnitOfMeasurementId,
      );

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
      ).thenAnswer((_) async => Right(minimalProduct));

      final params = CreateProductParams(
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

      // act
      final result = await useCase(params);

      // assert
      expect(result, Right(minimalProduct));
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
    });

    test('should return ServerFailure when repository fails', () async {
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
        (_) async => Left(ServerFailure(message: 'Failed to create product')),
      );

      final params = CreateProductParams(
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

      // act
      final result = await useCase(params);

      // assert
      expect(result, Left(ServerFailure(message: 'Failed to create product')));
    });
  });

  group('UpdateProductUsecase', () {
    late UpdateProductUsecase useCase;

    setUp(() {
      useCase = UpdateProductUsecase(mockRepository);
    });

    final tProductId = 'prod-1';
    final tName = {'en': 'Updated iPhone 15 Pro', 'ar': 'آيفون 15 برو محدث'};
    final tDescription = {
      'en': 'Updated description',
      'ar': 'وصف محدث',
    };
    final tPrice = 949.99;
    final tImages = ['https://example.com/updated.jpg'];
    final tStockQuantity = 40;
    final tUnitOfMeasurementId = 'unit-2';

    final tUpdatedProduct = ProductModel(
      id: tProductId,
      merchandiserId: 'merch-1',
      categoryId: 'cat-1',
      subCategoryId: 'sub-1',
      name: tName,
      description: tDescription,
      price: tPrice,
      images: tImages,
      imagesThumbnails: null,
      rating: 4.5,
      reviewCount: 120,
      isAvailable: true,
      sku: 'IPH15PRO',
      stockQuantity: tStockQuantity,
      costPrice: 800.0,
      weight: 0.5,
      tags: null,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
      discountPrice: null,
      discountStartDate: null,
      discountEndDate: null,
      isFeatured: true,
      unitOfMeasurementId: tUnitOfMeasurementId,
    );

    test('should update a product with all fields', () async {
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

      final params = UpdateProductParams(
        productId: tProductId,
        name: tName,
        description: tDescription,
        price: tPrice,
        images: tImages,
        stockQuantity: tStockQuantity,
        unitOfMeasurementId: tUnitOfMeasurementId,
      );

      // act
      final result = await useCase(params);

      // assert
      expect(result, Right(tUpdatedProduct));
      verify(
        () => mockRepository.updateProduct(
          productId: tProductId,
          name: tName,
          description: tDescription,
          price: tPrice,
          images: tImages,
          stockQuantity: tStockQuantity,
          unitOfMeasurementId: tUnitOfMeasurementId,
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
    });

    test('should update only product name', () async {
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

      final params = UpdateProductParams(
        productId: tProductId,
        name: tName,
      );

      // act
      final result = await useCase(params);

      // assert
      expect(result, Right(tUpdatedProduct));
      verify(
        () => mockRepository.updateProduct(
          productId: tProductId,
          name: tName,
          description: null,
          price: null,
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
    });

    test('should return ServerFailure when product not found', () async {
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

      final params = UpdateProductParams(
        productId: 'invalid-id',
        name: tName,
      );

      // act
      final result = await useCase(params);

      // assert
      expect(result, Left(ServerFailure(message: 'Product not found')));
    });
  });

  group('DeleteProductUsecase', () {
    late DeleteProductUsecase useCase;

    setUp(() {
      useCase = DeleteProductUsecase(mockRepository);
    });

    final tProductId = 'prod-1';

    test('should delete a product successfully', () async {
      // arrange
      when(() => mockRepository.deleteProduct(any()))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(tProductId);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.deleteProduct(tProductId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when product not found', () async {
      // arrange
      when(() => mockRepository.deleteProduct(any())).thenAnswer(
        (_) async => Left(ServerFailure(message: 'Product not found')),
      );

      // act
      final result = await useCase('invalid-id');

      // assert
      expect(result, Left(ServerFailure(message: 'Product not found')));
      verify(() => mockRepository.deleteProduct('invalid-id')).called(1);
    });

    test('should return ServerFailure when deletion fails', () async {
      // arrange
      when(() => mockRepository.deleteProduct(any())).thenAnswer(
        (_) async => Left(ServerFailure(message: 'Failed to delete product')),
      );

      // act
      final result = await useCase(tProductId);

      // assert
      expect(result, Left(ServerFailure(message: 'Failed to delete product')));
      verify(() => mockRepository.deleteProduct(tProductId)).called(1);
    });
  });
}
