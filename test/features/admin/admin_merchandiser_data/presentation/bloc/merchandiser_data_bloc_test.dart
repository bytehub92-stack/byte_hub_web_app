// test/features/admin/admin_merchandiser_data/bloc/merchandiser_data_bloc_test.dart

import 'package:admin_panel/features/admin/admin_merchandiser_data/bloc/merchandiser_data_bloc.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_data/bloc/merchandiser_data_event.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_data/bloc/merchandiser_data_states.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/category_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/product_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/sub_category_repositoy_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_categories_usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_products_usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_sub_categories_usecase.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../shared/store_management/data/datasources/fake_category_remote_datasource.dart';
import '../../../../shared/store_management/data/datasources/fake_product_remote_datasource.dart';
import '../../../../shared/store_management/data/datasources/fake_sub_category_remote_datasource.dart';

void main() {
  late MerchandiserDataBloc bloc;
  late GetCategoriesByMerchandiserIdUseCase
      getCategoriesByMerchandiserIdUseCase;
  late GetSubCategoriesByCategoryId getSubCategoriesUseCase;
  late GetProductsBySubCategoryUsecase getProductsUseCase;
  late CategoryRepositoryImpl categoryRepository;
  late SubCategoryRepositoryImpl subCategoryRepository;
  late ProductRepositoryImpl productRepository;
  late FakeCategoryRemoteDataSource fakeCategoryDataSource;
  late FakeSubCategoryRemoteDataSource fakeSubCategoryDataSource;
  late FakeProductRemoteDataSource fakeProductDataSource;

  setUp(() {
    fakeCategoryDataSource = FakeCategoryRemoteDataSource();
    fakeSubCategoryDataSource = FakeSubCategoryRemoteDataSource();
    fakeProductDataSource = FakeProductRemoteDataSource();

    categoryRepository = CategoryRepositoryImpl(
      remoteDataSource: fakeCategoryDataSource,
    );
    subCategoryRepository = SubCategoryRepositoryImpl(
      remoteDataSource: fakeSubCategoryDataSource,
    );
    productRepository = ProductRepositoryImpl(
      remoteDataSource: fakeProductDataSource,
    );

    getCategoriesByMerchandiserIdUseCase =
        GetCategoriesByMerchandiserIdUseCase(categoryRepository);
    getSubCategoriesUseCase = GetSubCategoriesByCategoryId(
      subCategoryRepository,
    );
    getProductsUseCase = GetProductsBySubCategoryUsecase(productRepository);

    bloc = MerchandiserDataBloc(
      getCategoriesByMerchandiserIdUseCase:
          getCategoriesByMerchandiserIdUseCase,
      getSubCategoriesByCategoryId: getSubCategoriesUseCase,
      getProductsBySubCategoryUsecase: getProductsUseCase,
    );
  });

  tearDown(() {
    fakeCategoryDataSource.clear();
    fakeSubCategoryDataSource.clear();
    fakeProductDataSource.clear();
    bloc.close();
  });

  group('MerchandiserDataBloc', () {
    const tMerchandiserId = 'merch-1';
    const tCategoryId = 'cat-1';
    const tSubCategoryId = 'sub-1';

    test('initial state should be MerchandiserDataStateInitial', () {
      // Assert
      expect(bloc.state, isA<MerchandiserDataStateInitial>());
    });

    group('AdminLoadCategories', () {
      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should emit [CategoriesLoading, CategoriesLoaded] when successful',
        build: () {
          fakeCategoryDataSource.seedData();
          return bloc;
        },
        act: (bloc) =>
            bloc.add(AdminLoadCategories(merchandiserId: tMerchandiserId)),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          CategoriesLoading(),
          isA<CategoriesLoaded>()
              .having((s) => s.categories.length, 'categories length', 2)
              .having(
                (s) => s.categories.first.merchandiserId,
                'merchandiserId',
                tMerchandiserId,
              ),
        ],
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should emit empty list when no categories exist for merchandiser',
        build: () {
          fakeCategoryDataSource.seedData();
          return bloc;
        },
        act: (bloc) =>
            bloc.add(AdminLoadCategories(merchandiserId: 'merch-999')),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          CategoriesLoading(),
          isA<CategoriesLoaded>()
              .having((s) => s.categories, 'categories', isEmpty),
        ],
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should return categories sorted by sort_order',
        build: () {
          fakeCategoryDataSource.seedData();
          return bloc;
        },
        act: (bloc) =>
            bloc.add(AdminLoadCategories(merchandiserId: tMerchandiserId)),
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final state = bloc.state as CategoriesLoaded;
          for (int i = 0; i < state.categories.length - 1; i++) {
            expect(
              state.categories[i].sortOrder <=
                  state.categories[i + 1].sortOrder,
              true,
            );
          }
        },
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should emit [CategoriesLoading, MerchandiserDataStateError] on failure',
        build: () {
          fakeCategoryDataSource.throwError('Database error');
          return bloc;
        },
        act: (bloc) =>
            bloc.add(AdminLoadCategories(merchandiserId: tMerchandiserId)),
        expect: () => [
          CategoriesLoading(),
          isA<MerchandiserDataStateError>().having(
            (s) => s.message,
            'message',
            contains('Database error'),
          ),
        ],
      );
    });

    group('AdminLoadSubCategories', () {
      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should emit [SubCategoriesLoading, SubCategoriesLoaded] when successful',
        build: () {
          fakeSubCategoryDataSource.seedData();
          return bloc;
        },
        act: (bloc) =>
            bloc.add(AdminLoadSubCategories(categoryId: tCategoryId)),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          SubCategoriesLoading(),
          isA<SubCategoriesLoaded>()
              .having((s) => s.subCategories.length, 'subCategories length', 2)
              .having(
                (s) => s.selectedSubCategoryId,
                'selectedSubCategoryId',
                'sub-1',
              ),
        ],
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should select first sub-category automatically',
        build: () {
          fakeSubCategoryDataSource.seedData();
          return bloc;
        },
        act: (bloc) =>
            bloc.add(AdminLoadSubCategories(categoryId: tCategoryId)),
        wait: const Duration(milliseconds: 600),
        verify: (bloc) {
          final state = bloc.state as SubCategoriesLoaded;
          expect(state.selectedSubCategoryId, state.subCategories.first.id);
        },
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should emit empty list when no sub-categories exist',
        build: () {
          fakeSubCategoryDataSource.seedData();
          return bloc;
        },
        act: (bloc) => bloc.add(AdminLoadSubCategories(categoryId: 'cat-999')),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          SubCategoriesLoading(),
          isA<SubCategoriesLoaded>()
              .having((s) => s.subCategories, 'subCategories', isEmpty)
              .having(
                (s) => s.selectedSubCategoryId,
                'selectedSubCategoryId',
                '',
              ),
        ],
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should emit [SubCategoriesLoading, MerchandiserDataStateError] on failure',
        build: () {
          fakeSubCategoryDataSource.throwError('Database error');
          return bloc;
        },
        act: (bloc) =>
            bloc.add(AdminLoadSubCategories(categoryId: tCategoryId)),
        expect: () => [
          SubCategoriesLoading(),
          isA<MerchandiserDataStateError>().having(
            (s) => s.message,
            'message',
            contains('Database error'),
          ),
        ],
      );
    });

    group('AdminLoadProducts', () {
      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should emit [ProductsLoading, ProductsLoaded] when successful',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          return bloc;
        },
        seed: () => SubCategoriesLoaded(
          subCategories: fakeSubCategoryDataSource
              .getAllSubCategories()
              .where((s) => s.categoryId == tCategoryId)
              .toList(),
          selectedSubCategoryId: tSubCategoryId,
        ),
        act: (bloc) =>
            bloc.add(AdminLoadProducts(subCategoryId: tSubCategoryId)),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          ProductsLoading(),
          isA<ProductsLoaded>()
              .having((s) => s.products.length, 'products length', 2)
              .having(
                (s) => s.selectedSubCategoryId,
                'selectedSubCategoryId',
                tSubCategoryId,
              )
              .having((s) => s.hasMore, 'hasMore', false)
              .having((s) => s.currentPage, 'currentPage', 1),
        ],
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should handle pagination correctly',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          return bloc;
        },
        seed: () => SubCategoriesLoaded(
          subCategories: fakeSubCategoryDataSource
              .getAllSubCategories()
              .where((s) => s.categoryId == tCategoryId)
              .toList(),
          selectedSubCategoryId: tSubCategoryId,
        ),
        act: (bloc) => bloc.add(
          AdminLoadProducts(subCategoryId: tSubCategoryId, page: 1, limit: 1),
        ),
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          final state = bloc.state as ProductsLoaded;
          expect(state.products.length, 1);
          expect(state.hasMore, true);
        },
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should apply search filter',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          return bloc;
        },
        seed: () => SubCategoriesLoaded(
          subCategories: fakeSubCategoryDataSource
              .getAllSubCategories()
              .where((s) => s.categoryId == tCategoryId)
              .toList(),
          selectedSubCategoryId: tSubCategoryId,
        ),
        act: (bloc) => bloc.add(
          AdminLoadProducts(
            subCategoryId: tSubCategoryId,
            searchQuery: 'iPhone',
          ),
        ),
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          final state = bloc.state as ProductsLoaded;
          expect(state.products.length, 1);
          expect(state.products.first.name['en'], contains('iPhone'));
          expect(state.currentSearchQuery, 'iPhone');
        },
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should apply sort by price ascending',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          return bloc;
        },
        seed: () => SubCategoriesLoaded(
          subCategories: fakeSubCategoryDataSource
              .getAllSubCategories()
              .where((s) => s.categoryId == tCategoryId)
              .toList(),
          selectedSubCategoryId: tSubCategoryId,
        ),
        act: (bloc) => bloc.add(
          AdminLoadProducts(subCategoryId: tSubCategoryId, sortBy: 'price_asc'),
        ),
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          final state = bloc.state as ProductsLoaded;
          for (int i = 0; i < state.products.length - 1; i++) {
            expect(
              state.products[i].price <= state.products[i + 1].price,
              true,
            );
          }
          expect(state.currentSortBy, 'price_asc');
        },
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should emit [ProductsLoading, MerchandiserDataStateError] on failure',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.throwError('Network error');
          return bloc;
        },
        seed: () => SubCategoriesLoaded(
          subCategories: fakeSubCategoryDataSource
              .getAllSubCategories()
              .where((s) => s.categoryId == tCategoryId)
              .toList(),
          selectedSubCategoryId: tSubCategoryId,
        ),
        act: (bloc) =>
            bloc.add(AdminLoadProducts(subCategoryId: tSubCategoryId)),
        expect: () => [
          ProductsLoading(),
          isA<MerchandiserDataStateError>().having(
            (s) => s.message,
            'message',
            contains('Network error'),
          ),
        ],
      );
    });

    group('AdminLoadMoreProducts', () {
      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should load next page of products',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          return bloc;
        },
        seed: () => ProductsLoaded(
          subCategories: fakeSubCategoryDataSource
              .getAllSubCategories()
              .where((s) => s.categoryId == tCategoryId)
              .toList(),
          selectedSubCategoryId: tSubCategoryId,
          products: fakeProductDataSource
              .getAllProducts()
              .where((p) => p.subCategoryId == tSubCategoryId)
              .take(1)
              .toList(),
          hasMore: true,
          currentPage: 1,
        ),
        act: (bloc) => bloc.add(AdminLoadMoreProducts()),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          isA<ProductsLoadingMore>().having(
            (s) => s.products.length,
            'products length',
            1,
          ),
          isA<ProductsLoaded>()
              .having((s) => s.products.length, 'products length', 2)
              .having((s) => s.currentPage, 'currentPage', 2),
        ],
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should not load more when hasMore is false',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          return bloc;
        },
        seed: () => ProductsLoaded(
          subCategories: fakeSubCategoryDataSource
              .getAllSubCategories()
              .where((s) => s.categoryId == tCategoryId)
              .toList(),
          selectedSubCategoryId: tSubCategoryId,
          products: fakeProductDataSource
              .getAllProducts()
              .where((p) => p.subCategoryId == tSubCategoryId)
              .toList(),
          hasMore: false,
          currentPage: 1,
        ),
        act: (bloc) => bloc.add(AdminLoadMoreProducts()),
        expect: () => [],
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should emit error on failure while loading more',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          fakeProductDataSource.throwError('Network error');
          return bloc;
        },
        seed: () => ProductsLoaded(
          subCategories: fakeSubCategoryDataSource
              .getAllSubCategories()
              .where((s) => s.categoryId == tCategoryId)
              .toList(),
          selectedSubCategoryId: tSubCategoryId,
          products: fakeProductDataSource
              .getAllProducts()
              .where((p) => p.subCategoryId == tSubCategoryId)
              .take(1)
              .toList(),
          hasMore: true,
          currentPage: 1,
        ),
        act: (bloc) => bloc.add(AdminLoadMoreProducts()),
        expect: () => [
          isA<ProductsLoadingMore>(),
          isA<MerchandiserDataStateError>().having(
            (s) => s.message,
            'message',
            contains('Network error'),
          ),
        ],
      );
    });

    group('AdminSearchProducts', () {
      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should reload products with search query',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          return bloc;
        },
        seed: () => ProductsLoaded(
          subCategories: fakeSubCategoryDataSource
              .getAllSubCategories()
              .where((s) => s.categoryId == tCategoryId)
              .toList(),
          selectedSubCategoryId: tSubCategoryId,
          products: fakeProductDataSource
              .getAllProducts()
              .where((p) => p.subCategoryId == tSubCategoryId)
              .toList(),
          hasMore: false,
          currentPage: 1,
        ),
        act: (bloc) => bloc.add(AdminSearchProducts(query: 'Samsung')),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          ProductsLoading(),
          isA<ProductsLoaded>()
              .having((s) => s.products.length, 'products length', 1)
              .having(
                (s) => s.currentSearchQuery,
                'currentSearchQuery',
                'Samsung',
              ),
        ],
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should clear search when query is empty',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          return bloc;
        },
        seed: () => ProductsLoaded(
          subCategories: fakeSubCategoryDataSource
              .getAllSubCategories()
              .where((s) => s.categoryId == tCategoryId)
              .toList(),
          selectedSubCategoryId: tSubCategoryId,
          products: fakeProductDataSource
              .getAllProducts()
              .where((p) => p.subCategoryId == tSubCategoryId)
              .take(1)
              .toList(),
          hasMore: false,
          currentPage: 1,
          currentSearchQuery: 'iPhone',
        ),
        act: (bloc) => bloc.add(AdminSearchProducts(query: '')),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          ProductsLoading(),
          isA<ProductsLoaded>()
              .having((s) => s.products.length, 'products length', 2)
              .having((s) => s.currentSearchQuery, 'currentSearchQuery', ''),
        ],
      );
    });

    group('AdminSortProducts', () {
      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should reload products with new sort order',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          return bloc;
        },
        seed: () => ProductsLoaded(
          subCategories: fakeSubCategoryDataSource
              .getAllSubCategories()
              .where((s) => s.categoryId == tCategoryId)
              .toList(),
          selectedSubCategoryId: tSubCategoryId,
          products: fakeProductDataSource
              .getAllProducts()
              .where((p) => p.subCategoryId == tSubCategoryId)
              .toList(),
          hasMore: false,
          currentPage: 1,
        ),
        act: (bloc) => bloc.add(AdminSortProducts(sortBy: 'price_desc')),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          ProductsLoading(),
          isA<ProductsLoaded>().having(
            (s) => s.currentSortBy,
            'currentSortBy',
            'price_desc',
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as ProductsLoaded;
          for (int i = 0; i < state.products.length - 1; i++) {
            expect(
              state.products[i].price >= state.products[i + 1].price,
              true,
            );
          }
        },
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should maintain search query when sorting',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          return bloc;
        },
        seed: () => ProductsLoaded(
          subCategories: fakeSubCategoryDataSource
              .getAllSubCategories()
              .where((s) => s.categoryId == tCategoryId)
              .toList(),
          selectedSubCategoryId: tSubCategoryId,
          products: fakeProductDataSource
              .getAllProducts()
              .where((p) => p.subCategoryId == tSubCategoryId)
              .toList(),
          hasMore: false,
          currentPage: 1,
          currentSearchQuery: 'phone',
        ),
        act: (bloc) => bloc.add(AdminSortProducts(sortBy: 'name')),
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          final state = bloc.state as ProductsLoaded;
          expect(state.currentSearchQuery, 'phone');
        },
      );
    });

    group('Edge Cases', () {
      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should handle rapid event firing',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          return bloc;
        },
        act: (bloc) {
          bloc.add(AdminLoadSubCategories(categoryId: tCategoryId));
          bloc.add(AdminLoadProducts(subCategoryId: tSubCategoryId));
          bloc.add(AdminSearchProducts(query: 'iPhone'));
          bloc.add(AdminSortProducts(sortBy: 'price_asc'));
        },
        skip: 3,
        wait: const Duration(milliseconds: 300),
        expect: () => [ProductsLoading(), isA<ProductsLoaded>()],
      );

      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should handle empty products gracefully',
        build: () {
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          return bloc;
        },
        seed: () => SubCategoriesLoaded(
          subCategories: fakeSubCategoryDataSource
              .getAllSubCategories()
              .where((s) => s.categoryId == tCategoryId)
              .toList(),
          selectedSubCategoryId: tSubCategoryId,
        ),
        act: (bloc) => bloc.add(AdminLoadProducts(subCategoryId: 'sub-999')),
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          final state = bloc.state as ProductsLoaded;
          expect(state.products, isEmpty);
          expect(state.hasMore, false);
        },
      );
    });

    group('Integration Tests', () {
      blocTest<MerchandiserDataBloc, MerchandiserDataState>(
        'should handle complete flow: categories -> subcategories -> products',
        build: () {
          fakeCategoryDataSource.seedData();
          fakeSubCategoryDataSource.seedData();
          fakeProductDataSource.seedData();
          return bloc;
        },
        act: (bloc) async {
          bloc.add(AdminLoadCategories(merchandiserId: tMerchandiserId));
          await Future.delayed(const Duration(milliseconds: 200));
          bloc.add(AdminLoadSubCategories(categoryId: tCategoryId));
          await Future.delayed(const Duration(milliseconds: 700));
          bloc.add(AdminLoadProducts(subCategoryId: tSubCategoryId));
        },
        wait: const Duration(milliseconds: 1500),
        expect: () => [
          CategoriesLoading(),
          isA<CategoriesLoaded>(),
          SubCategoriesLoading(),
          isA<SubCategoriesLoaded>(),
          ProductsLoading(),
          isA<ProductsLoaded>(),
        ],
      );
    });
  });
}
