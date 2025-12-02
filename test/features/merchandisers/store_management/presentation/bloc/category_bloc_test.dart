// test/features/merchandisers/store_management/presentation/bloc/category_bloc/category_bloc_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/category/create_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/category/delete_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/category/update_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/category_bloc/category_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/category_bloc/category_event.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/category_bloc/category_state.dart';
import 'package:admin_panel/features/shared/shared_feature/data/models/category_model.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_categories_usecase.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCategoriesByMerchandiserIdUseCase extends Mock
    implements GetCategoriesByMerchandiserIdUseCase {}

class MockCreateCategoryUseCase extends Mock implements CreateCategoryUseCase {}

class MockUpdateCategoryUseCase extends Mock implements UpdateCategoryUseCase {}

class MockDeleteCategoryUseCase extends Mock implements DeleteCategoryUseCase {}

void main() {
  late MockGetCategoriesByMerchandiserIdUseCase mockGetCategories;
  late MockCreateCategoryUseCase mockCreateCategory;
  late MockUpdateCategoryUseCase mockUpdateCategory;
  late MockDeleteCategoryUseCase mockDeleteCategory;
  late CategoryBloc categoryBloc;

  setUp(() {
    mockGetCategories = MockGetCategoriesByMerchandiserIdUseCase();
    mockCreateCategory = MockCreateCategoryUseCase();
    mockUpdateCategory = MockUpdateCategoryUseCase();
    mockDeleteCategory = MockDeleteCategoryUseCase();

    categoryBloc = CategoryBloc(
      getCategoriesUseCase: mockGetCategories,
      createCategoryUseCase: mockCreateCategory,
      updateCategoryUseCase: mockUpdateCategory,
      deleteCategoryUseCase: mockDeleteCategory,
    );
  });

  // Register fallback values for Mocktail
  setUpAll(() {
    registerFallbackValue(
      CreateCategoryParams(
        merchandiserId: 'merch-1',
        name: {'en': 'Test', 'ar': 'اختبار'},
      ),
    );
    registerFallbackValue(
      UpdateCategoryParams(
        categoryId: 'cat-1',
      ),
    );
  });

  tearDown(() {
    categoryBloc.close();
  });

  final tMerchandiserId = 'merch-1';

  final tCategories = [
    CategoryModel(
      id: 'cat-1',
      merchandiserId: tMerchandiserId,
      name: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      imageThumbnail: 'https://example.com/electronics-thumb.jpg',
      image: 'https://example.com/electronics.jpg',
      sortOrder: 1,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      productCount: 15,
      subCategoryCount: 3,
    ),
    CategoryModel(
      id: 'cat-2',
      merchandiserId: tMerchandiserId,
      name: {'en': 'Clothing', 'ar': 'ملابس'},
      imageThumbnail: 'https://example.com/clothing-thumb.jpg',
      image: 'https://example.com/clothing.jpg',
      sortOrder: 2,
      isActive: true,
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
      productCount: 25,
      subCategoryCount: 5,
    ),
  ];

  group('LoadCategories', () {
    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoriesLoaded] when LoadCategories is successful',
      build: () {
        when(() => mockGetCategories(any()))
            .thenAnswer((_) async => Right(tCategories));
        return categoryBloc;
      },
      act: (bloc) => bloc.add(LoadCategories(tMerchandiserId)),
      expect: () => [
        CategoryLoading(),
        CategoriesLoaded(tCategories),
      ],
      verify: (_) {
        verify(() => mockGetCategories(tMerchandiserId)).called(1);
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoriesLoaded] with empty list when no categories exist',
      build: () {
        when(() => mockGetCategories(any()))
            .thenAnswer((_) async => const Right([]));
        return categoryBloc;
      },
      act: (bloc) => bloc.add(LoadCategories(tMerchandiserId)),
      expect: () => [
        CategoryLoading(),
        const CategoriesLoaded([]),
      ],
      verify: (_) {
        verify(() => mockGetCategories(tMerchandiserId)).called(1);
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryError] when LoadCategories fails',
      build: () {
        when(() => mockGetCategories(any())).thenAnswer(
          (_) async =>
              Left(ServerFailure(message: 'Failed to fetch categories')),
        );
        return categoryBloc;
      },
      act: (bloc) => bloc.add(LoadCategories(tMerchandiserId)),
      expect: () => [
        CategoryLoading(),
        const CategoryError('Failed to fetch categories'),
      ],
      verify: (_) {
        verify(() => mockGetCategories(tMerchandiserId)).called(1);
      },
    );
  });

  group('CreateCategory', () {
    final tName = {'en': 'New Category', 'ar': 'فئة جديدة'};
    final tImageThumbnail = 'https://example.com/new-thumb.jpg';
    final tImage = 'https://example.com/new.jpg';

    final tNewCategory = CategoryModel(
      id: 'cat-3',
      merchandiserId: tMerchandiserId,
      name: tName,
      imageThumbnail: tImageThumbnail,
      image: tImage,
      sortOrder: 0,
      isActive: true,
      createdAt: DateTime(2024, 1, 3),
      updatedAt: DateTime(2024, 1, 3),
      productCount: 0,
      subCategoryCount: 0,
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryOperationSuccess, CategoryLoading, CategoriesLoaded] when CreateCategory is successful',
      build: () {
        when(() => mockCreateCategory(any()))
            .thenAnswer((_) async => Right(tNewCategory));
        when(() => mockGetCategories(any()))
            .thenAnswer((_) async => Right([...tCategories, tNewCategory]));
        return categoryBloc;
      },
      act: (bloc) => bloc.add(CreateCategory(
        merchandiserId: tMerchandiserId,
        name: tName,
        imageThumbnail: tImageThumbnail,
        image: tImage,
      )),
      expect: () => [
        CategoryLoading(),
        const CategoryOperationSuccess('Category created successfully'),
        CategoryLoading(),
        CategoriesLoaded([...tCategories, tNewCategory]),
      ],
      verify: (_) {
        verify(() => mockCreateCategory(any())).called(1);
        verify(() => mockGetCategories(tMerchandiserId)).called(1);
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryError] when CreateCategory fails',
      build: () {
        when(() => mockCreateCategory(any())).thenAnswer(
          (_) async =>
              Left(ServerFailure(message: 'Failed to create category')),
        );
        return categoryBloc;
      },
      act: (bloc) => bloc.add(CreateCategory(
        merchandiserId: tMerchandiserId,
        name: tName,
      )),
      expect: () => [
        CategoryLoading(),
        const CategoryError('Failed to create category'),
      ],
      verify: (_) {
        verify(() => mockCreateCategory(any())).called(1);
        verifyNever(() => mockGetCategories(any()));
      },
    );
  });

  group('UpdateCategory', () {
    final tCategoryId = 'cat-1';
    final tUpdatedName = {
      'en': 'Updated Electronics',
      'ar': 'إلكترونيات محدثة'
    };

    final tUpdatedCategory = CategoryModel(
      id: tCategoryId,
      merchandiserId: tMerchandiserId,
      name: tUpdatedName,
      imageThumbnail: 'https://example.com/electronics-thumb.jpg',
      image: 'https://example.com/electronics.jpg',
      sortOrder: 1,
      isActive: false,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 4),
      productCount: 15,
      subCategoryCount: 3,
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryOperationSuccess, CategoryLoading, CategoriesLoaded] when UpdateCategory is successful',
      build: () {
        when(() => mockUpdateCategory(any()))
            .thenAnswer((_) async => Right(tUpdatedCategory));
        when(() => mockGetCategories(any()))
            .thenAnswer((_) async => Right(tCategories));
        return categoryBloc;
      },
      act: (bloc) => bloc.add(UpdateCategory(
        merchandiserId: tMerchandiserId,
        categoryId: tCategoryId,
        name: tUpdatedName,
        isActive: false,
      )),
      expect: () => [
        CategoryLoading(),
        const CategoryOperationSuccess('Category updated successfully'),
        CategoryLoading(),
        CategoriesLoaded(tCategories),
      ],
      verify: (_) {
        verify(() => mockUpdateCategory(any())).called(1);
        verify(() => mockGetCategories(tMerchandiserId)).called(1);
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryError] when UpdateCategory fails',
      build: () {
        when(() => mockUpdateCategory(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Category not found')),
        );
        return categoryBloc;
      },
      act: (bloc) => bloc.add(UpdateCategory(
        merchandiserId: tMerchandiserId,
        categoryId: 'invalid-id',
        name: tUpdatedName,
      )),
      expect: () => [
        CategoryLoading(),
        const CategoryError('Category not found'),
      ],
      verify: (_) {
        verify(() => mockUpdateCategory(any())).called(1);
        verifyNever(() => mockGetCategories(any()));
      },
    );
  });

  group('DeleteCategory', () {
    final tCategoryId = 'cat-1';

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryOperationSuccess, CategoryLoading, CategoriesLoaded] when DeleteCategory is successful',
      build: () {
        when(() => mockDeleteCategory(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetCategories(any()))
            .thenAnswer((_) async => Right([tCategories[1]]));
        return categoryBloc;
      },
      act: (bloc) => bloc.add(DeleteCategory(
        merchandiserId: tMerchandiserId,
        categoryId: tCategoryId,
      )),
      expect: () => [
        CategoryLoading(),
        const CategoryOperationSuccess('Category deleted successfully'),
        CategoryLoading(),
        CategoriesLoaded([tCategories[1]]),
      ],
      verify: (_) {
        verify(() => mockDeleteCategory(tCategoryId)).called(1);
        verify(() => mockGetCategories(tMerchandiserId)).called(1);
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryError] when DeleteCategory fails due to existing sub-categories',
      build: () {
        when(() => mockDeleteCategory(any())).thenAnswer(
          (_) async => Left(
            ServerFailure(
              message: 'Cannot delete category with existing sub-categories',
            ),
          ),
        );
        return categoryBloc;
      },
      act: (bloc) => bloc.add(DeleteCategory(
        merchandiserId: tMerchandiserId,
        categoryId: tCategoryId,
      )),
      expect: () => [
        CategoryLoading(),
        const CategoryError(
            'Cannot delete category with existing sub-categories'),
      ],
      verify: (_) {
        verify(() => mockDeleteCategory(tCategoryId)).called(1);
        verifyNever(() => mockGetCategories(any()));
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryError] when category not found',
      build: () {
        when(() => mockDeleteCategory(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Category not found')),
        );
        return categoryBloc;
      },
      act: (bloc) => bloc.add(DeleteCategory(
        merchandiserId: tMerchandiserId,
        categoryId: 'invalid-id',
      )),
      expect: () => [
        CategoryLoading(),
        const CategoryError('Category not found'),
      ],
      verify: (_) {
        verify(() => mockDeleteCategory('invalid-id')).called(1);
      },
    );
  });

  test('initial state should be CategoryInitial', () {
    expect(categoryBloc.state, CategoryInitial());
  });
}
