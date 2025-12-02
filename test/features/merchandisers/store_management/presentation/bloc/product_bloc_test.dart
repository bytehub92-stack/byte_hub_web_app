// test/features/merchandisers/store_management/presentation/bloc/product_bloc/product_bloc_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/product/create_product_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/product/delete_product_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/product/update_product_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/product_bloc/product_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/product_bloc/product_event.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/product_bloc/product_state.dart';
import 'package:admin_panel/features/shared/shared_feature/data/models/product_model.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_products_usecase.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProductsBySubCategoryUsecase extends Mock
    implements GetProductsBySubCategoryUsecase {}

class MockCreateProductUsecase extends Mock implements CreateProductUsecase {}

class MockUpdateProductUsecase extends Mock implements UpdateProductUsecase {}

class MockDeleteProductUsecase extends Mock implements DeleteProductUsecase {}

void main() {
  late MockGetProductsBySubCategoryUsecase mockGetProducts;
  late MockCreateProductUsecase mockCreateProduct;
  late MockUpdateProductUsecase mockUpdateProduct;
  late MockDeleteProductUsecase mockDeleteProduct;
  late ProductBloc productBloc;

  setUp(() {
    mockGetProducts = MockGetProductsBySubCategoryUsecase();
    mockCreateProduct = MockCreateProductUsecase();
    mockUpdateProduct = MockUpdateProductUsecase();
    mockDeleteProduct = MockDeleteProductUsecase();

    productBloc = ProductBloc(
      getProducts: mockGetProducts,
      createProduct: mockCreateProduct,
      updateProduct: mockUpdateProduct,
      deleteProduct: mockDeleteProduct,
    );
  });

  // Register fallback values for Mocktail
  setUpAll(() {
    registerFallbackValue(GetProductsParams(subCategoryId: 'sub-1'));
    registerFallbackValue(
      CreateProductParams(
        merchandiserId: 'merch-1',
        categoryId: 'cat-1',
        subCategoryId: 'sub-1',
        name: {'en': 'Test', 'ar': 'اختبار'},
        description: {'en': 'Test', 'ar': 'اختبار'},
        price: 100.0,
        images: [],
        stockQuantity: 10,
        unitOfMeasurementId: 'unit-1',
      ),
    );
    registerFallbackValue(
      UpdateProductParams(
        productId: 'prod-1',
      ),
    );
  });

  tearDown(() {
    productBloc.close();
  });

  final tSubCategoryId = 'sub-1';
  final tMerchandiserId = 'merch-1';

  final tProducts = [
    ProductModel(
      id: 'prod-1',
      merchandiserId: tMerchandiserId,
      categoryId: 'cat-1',
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
      categoryId: 'cat-1',
      subCategoryId: tSubCategoryId,
      name: {'en': 'Samsung Galaxy S24', 'ar': 'سامسونج جالاكسي S24'},
      description: {
        'en': 'Powerful Android smartphone',
        'ar': 'هاتف أندرويد قوي',
      },
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

  group('LoadProducts', () {
    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductsLoaded] when LoadProducts is successful',
      build: () {
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => Right(tProducts));
        return productBloc;
      },
      act: (bloc) => bloc.add(LoadProducts(subCategoryId: tSubCategoryId)),
      expect: () => [
        ProductLoading(),
        ProductsLoaded(tProducts),
      ],
      verify: (_) {
        verify(() => mockGetProducts(any())).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductsLoaded] with empty list when no products exist',
      build: () {
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => const Right([]));
        return productBloc;
      },
      act: (bloc) => bloc.add(LoadProducts(subCategoryId: tSubCategoryId)),
      expect: () => [
        ProductLoading(),
        const ProductsLoaded([]),
      ],
      verify: (_) {
        verify(() => mockGetProducts(any())).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductsLoaded] with pagination',
      build: () {
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => Right([tProducts[0]]));
        return productBloc;
      },
      act: (bloc) => bloc.add(LoadProducts(
        subCategoryId: tSubCategoryId,
        page: 2,
        limit: 10,
      )),
      expect: () => [
        ProductLoading(),
        ProductsLoaded([tProducts[0]]),
      ],
      verify: (_) {
        verify(() => mockGetProducts(any())).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductsLoaded] with search query',
      build: () {
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => Right([tProducts[0]]));
        return productBloc;
      },
      act: (bloc) => bloc.add(LoadProducts(
        subCategoryId: tSubCategoryId,
        searchQuery: 'iPhone',
      )),
      expect: () => [
        ProductLoading(),
        ProductsLoaded([tProducts[0]]),
      ],
      verify: (_) {
        verify(() => mockGetProducts(any())).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when LoadProducts fails',
      build: () {
        when(() => mockGetProducts(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Failed to fetch products')),
        );
        return productBloc;
      },
      act: (bloc) => bloc.add(LoadProducts(subCategoryId: tSubCategoryId)),
      expect: () => [
        ProductLoading(),
        const ProductError('Failed to fetch products'),
      ],
      verify: (_) {
        verify(() => mockGetProducts(any())).called(1);
      },
    );
  });

  group('CreateProduct', () {
    final tName = {'en': 'New Product', 'ar': 'منتج جديد'};
    final tDescription = {'en': 'Description', 'ar': 'وصف'};
    final tPrice = 499.99;
    final tImages = ['https://example.com/new.jpg'];
    final tStockQuantity = 100;
    final tUnitOfMeasurementId = 'unit-1';

    final tNewProduct = ProductModel(
      id: 'prod-3',
      merchandiserId: tMerchandiserId,
      categoryId: 'cat-1',
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
      createdAt: DateTime(2024, 1, 3),
      updatedAt: DateTime(2024, 1, 3),
      discountPrice: null,
      discountStartDate: null,
      discountEndDate: null,
      isFeatured: false,
      unitOfMeasurementId: tUnitOfMeasurementId,
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductOperationSuccess, ProductLoading, ProductsLoaded] when CreateProduct is successful',
      build: () {
        when(() => mockCreateProduct(any()))
            .thenAnswer((_) async => Right(tNewProduct));
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => Right([...tProducts, tNewProduct]));
        return productBloc;
      },
      act: (bloc) => bloc.add(CreateProduct(
        merchandiserId: tMerchandiserId,
        categoryId: 'cat-1',
        subCategoryId: tSubCategoryId,
        name: tName,
        description: tDescription,
        price: tPrice,
        images: tImages,
        stockQuantity: tStockQuantity,
        unitOfMeasurementId: tUnitOfMeasurementId,
      )),
      expect: () => [
        ProductLoading(),
        const ProductOperationSuccess('Product created successfully'),
        ProductLoading(),
        ProductsLoaded([...tProducts, tNewProduct]),
      ],
      verify: (_) {
        verify(() => mockCreateProduct(any())).called(1);
        verify(() => mockGetProducts(any())).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when CreateProduct fails',
      build: () {
        when(() => mockCreateProduct(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Failed to create product')),
        );
        return productBloc;
      },
      act: (bloc) => bloc.add(CreateProduct(
        merchandiserId: tMerchandiserId,
        categoryId: 'cat-1',
        subCategoryId: tSubCategoryId,
        name: tName,
        description: tDescription,
        price: tPrice,
        images: tImages,
        stockQuantity: tStockQuantity,
        unitOfMeasurementId: tUnitOfMeasurementId,
      )),
      expect: () => [
        ProductLoading(),
        const ProductError('Failed to create product'),
      ],
      verify: (_) {
        verify(() => mockCreateProduct(any())).called(1);
        verifyNever(() => mockGetProducts(any()));
      },
    );
  });

  group('UpdateProduct', () {
    final tProductId = 'prod-1';
    final tUpdatedName = {
      'en': 'Updated iPhone 15 Pro',
      'ar': 'آيفون 15 برو محدث',
    };
    final tUpdatedPrice = 949.99;

    final tUpdatedProduct = ProductModel(
      id: tProductId,
      merchandiserId: tMerchandiserId,
      categoryId: 'cat-1',
      subCategoryId: tSubCategoryId,
      name: tUpdatedName,
      description: {
        'en': 'Latest iPhone with advanced features',
        'ar': 'أحدث آيفون بميزات متقدمة',
      },
      price: tUpdatedPrice,
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
      updatedAt: DateTime(2024, 1, 4),
      discountPrice: null,
      discountStartDate: null,
      discountEndDate: null,
      isFeatured: true,
      unitOfMeasurementId: 'unit-1',
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductOperationSuccess, ProductLoading, ProductsLoaded] when UpdateProduct is successful',
      build: () {
        when(() => mockUpdateProduct(any()))
            .thenAnswer((_) async => Right(tUpdatedProduct));
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => Right(tProducts));
        return productBloc;
      },
      act: (bloc) => bloc.add(UpdateProduct(
        productId: tProductId,
        subCategoryId: tSubCategoryId,
        name: tUpdatedName,
        price: tUpdatedPrice,
      )),
      expect: () => [
        ProductLoading(),
        const ProductOperationSuccess('Product updated successfully'),
        ProductLoading(),
        ProductsLoaded(tProducts),
      ],
      verify: (_) {
        verify(() => mockUpdateProduct(any())).called(1);
        verify(() => mockGetProducts(any())).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when UpdateProduct fails',
      build: () {
        when(() => mockUpdateProduct(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Product not found')),
        );
        return productBloc;
      },
      act: (bloc) => bloc.add(UpdateProduct(
        productId: 'invalid-id',
        subCategoryId: tSubCategoryId,
        name: tUpdatedName,
      )),
      expect: () => [
        ProductLoading(),
        const ProductError('Product not found'),
      ],
      verify: (_) {
        verify(() => mockUpdateProduct(any())).called(1);
        verifyNever(() => mockGetProducts(any()));
      },
    );
  });

  group('DeleteProduct', () {
    final tProductId = 'prod-1';

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductOperationSuccess, ProductLoading, ProductsLoaded] when DeleteProduct is successful',
      build: () {
        when(() => mockDeleteProduct(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => Right([tProducts[1]]));
        return productBloc;
      },
      act: (bloc) => bloc.add(DeleteProduct(tProductId, tSubCategoryId)),
      expect: () => [
        ProductLoading(),
        const ProductOperationSuccess('Product deleted successfully'),
        ProductLoading(),
        ProductsLoaded([tProducts[1]]),
      ],
      verify: (_) {
        verify(() => mockDeleteProduct(tProductId)).called(1);
        verify(() => mockGetProducts(any())).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when product not found',
      build: () {
        when(() => mockDeleteProduct(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Product not found')),
        );
        return productBloc;
      },
      act: (bloc) => bloc.add(DeleteProduct('invalid-id', tSubCategoryId)),
      expect: () => [
        ProductLoading(),
        const ProductError('Product not found'),
      ],
      verify: (_) {
        verify(() => mockDeleteProduct('invalid-id')).called(1);
        verifyNever(() => mockGetProducts(any()));
      },
    );
  });

  test('initial state should be ProductInitial', () {
    expect(productBloc.state, ProductInitial());
  });
}
