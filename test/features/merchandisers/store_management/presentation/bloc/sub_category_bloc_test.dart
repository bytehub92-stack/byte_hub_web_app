// test/features/merchandisers/store_management/presentation/bloc/sub_category_bloc/sub_category_bloc_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/sub_category/create_sub_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/sub_category/delete_sub_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/sub_category/update_sub_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/sub_category_bloc/sub_category_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/sub_category_bloc/sub_category_event.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/sub_category_bloc/sub_category_state.dart';
import 'package:admin_panel/features/shared/shared_feature/data/models/sub_category_model.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_sub_categories_usecase.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetSubCategoriesByCategoryId extends Mock
    implements GetSubCategoriesByCategoryId {}

class MockCreateSubCategoryUsecase extends Mock
    implements CreateSubCategoryUsecase {}

class MockUpdateSubCategoryUsecase extends Mock
    implements UpdateSubCategoryUsecase {}

class MockDeleteSubCategoryUsecase extends Mock
    implements DeleteSubCategoryUsecase {}

void main() {
  late MockGetSubCategoriesByCategoryId mockGetSubCategories;
  late MockCreateSubCategoryUsecase mockCreateSubCategory;
  late MockUpdateSubCategoryUsecase mockUpdateSubCategory;
  late MockDeleteSubCategoryUsecase mockDeleteSubCategory;
  late SubCategoryBloc subCategoryBloc;

  setUp(() {
    mockGetSubCategories = MockGetSubCategoriesByCategoryId();
    mockCreateSubCategory = MockCreateSubCategoryUsecase();
    mockUpdateSubCategory = MockUpdateSubCategoryUsecase();
    mockDeleteSubCategory = MockDeleteSubCategoryUsecase();

    subCategoryBloc = SubCategoryBloc(
      getSubCategoriesByCategoryId: mockGetSubCategories,
      createSubCategory: mockCreateSubCategory,
      updateSubCategory: mockUpdateSubCategory,
      deleteSubCategory: mockDeleteSubCategory,
    );
  });

  // Register fallback values for Mocktail
  setUpAll(() {
    registerFallbackValue(
      CreateSubCategoryParams(
        merchandiserId: 'merch-1',
        categoryId: 'cat-1',
        name: {'en': 'Test', 'ar': 'اختبار'},
      ),
    );
  });

  tearDown(() {
    subCategoryBloc.close();
  });

  final tCategoryId = 'cat-1';
  final tMerchandiserId = 'merch-1';

  final tSubCategories = [
    SubCategoryModel(
      id: 'sub-1',
      categoryId: tCategoryId,
      merchandiserId: tMerchandiserId,
      name: {'en': 'Smartphones', 'ar': 'هواتف ذكية'},
      sortOrder: 1,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      subCategoryName: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      productCount: 10,
    ),
    SubCategoryModel(
      id: 'sub-2',
      categoryId: tCategoryId,
      merchandiserId: tMerchandiserId,
      name: {'en': 'Laptops', 'ar': 'أجهزة كمبيوتر محمولة'},
      sortOrder: 2,
      isActive: true,
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
      subCategoryName: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      productCount: 5,
    ),
  ];

  group('LoadSubCategories', () {
    blocTest<SubCategoryBloc, SubCategoryState>(
      'emits [SubCategoryLoading, SubCategoriesLoaded] when LoadSubCategories is successful',
      build: () {
        when(() => mockGetSubCategories(any()))
            .thenAnswer((_) async => Right(tSubCategories));
        return subCategoryBloc;
      },
      act: (bloc) => bloc.add(LoadSubCategories(tCategoryId)),
      expect: () => [
        SubCategoryLoading(),
        SubCategoriesLoaded(tSubCategories),
      ],
      verify: (_) {
        verify(() => mockGetSubCategories(tCategoryId)).called(1);
      },
    );

    blocTest<SubCategoryBloc, SubCategoryState>(
      'emits [SubCategoryLoading, SubCategoriesLoaded] with empty list when no sub-categories exist',
      build: () {
        when(() => mockGetSubCategories(any()))
            .thenAnswer((_) async => const Right([]));
        return subCategoryBloc;
      },
      act: (bloc) => bloc.add(LoadSubCategories(tCategoryId)),
      expect: () => [
        SubCategoryLoading(),
        const SubCategoriesLoaded([]),
      ],
      verify: (_) {
        verify(() => mockGetSubCategories(tCategoryId)).called(1);
      },
    );

    blocTest<SubCategoryBloc, SubCategoryState>(
      'emits [SubCategoryLoading, SubCategoryError] when LoadSubCategories fails',
      build: () {
        when(() => mockGetSubCategories(any())).thenAnswer(
          (_) async =>
              Left(ServerFailure(message: 'Failed to fetch sub-categories')),
        );
        return subCategoryBloc;
      },
      act: (bloc) => bloc.add(LoadSubCategories(tCategoryId)),
      expect: () => [
        SubCategoryLoading(),
        const SubCategoryError('Failed to fetch sub-categories'),
      ],
      verify: (_) {
        verify(() => mockGetSubCategories(tCategoryId)).called(1);
      },
    );
  });

  group('CreateSubCategory', () {
    final tName = {'en': 'Tablets', 'ar': 'أجهزة لوحية'};

    final tNewSubCategory = SubCategoryModel(
      id: 'sub-3',
      categoryId: tCategoryId,
      merchandiserId: tMerchandiserId,
      name: tName,
      sortOrder: 0,
      isActive: true,
      createdAt: DateTime(2024, 1, 3),
      updatedAt: DateTime(2024, 1, 3),
      subCategoryName: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      productCount: 0,
    );

    blocTest<SubCategoryBloc, SubCategoryState>(
      'emits [SubCategoryLoading, SubCategoryOperationSuccess, SubCategoryLoading, SubCategoriesLoaded] when CreateSubCategory is successful',
      build: () {
        when(() => mockCreateSubCategory(any()))
            .thenAnswer((_) async => Right(tNewSubCategory));
        when(() => mockGetSubCategories(any())).thenAnswer(
            (_) async => Right([...tSubCategories, tNewSubCategory]));
        return subCategoryBloc;
      },
      act: (bloc) => bloc.add(CreateSubCategory(
        merchandiserId: tMerchandiserId,
        categoryId: tCategoryId,
        name: tName,
      )),
      expect: () => [
        SubCategoryLoading(),
        const SubCategoryOperationSuccess('Sub Category created successfully'),
        SubCategoryLoading(),
        SubCategoriesLoaded([...tSubCategories, tNewSubCategory]),
      ],
      verify: (_) {
        verify(() => mockCreateSubCategory(any())).called(1);
        verify(() => mockGetSubCategories(tCategoryId)).called(1);
      },
    );

    blocTest<SubCategoryBloc, SubCategoryState>(
      'emits [SubCategoryLoading, SubCategoryError] when CreateSubCategory fails',
      build: () {
        when(() => mockCreateSubCategory(any())).thenAnswer(
          (_) async =>
              Left(ServerFailure(message: 'Failed to create sub-category')),
        );
        return subCategoryBloc;
      },
      act: (bloc) => bloc.add(CreateSubCategory(
        merchandiserId: tMerchandiserId,
        categoryId: tCategoryId,
        name: tName,
      )),
      expect: () => [
        SubCategoryLoading(),
        const SubCategoryError('Failed to create sub-category'),
      ],
      verify: (_) {
        verify(() => mockCreateSubCategory(any())).called(1);
        verifyNever(() => mockGetSubCategories(any()));
      },
    );
  });

  group('UpdateSubCategory', () {
    final tSubCategoryId = 'sub-1';
    final tUpdatedName = {
      'en': 'Updated Smartphones',
      'ar': 'هواتف ذكية محدثة',
    };

    final tUpdatedSubCategory = SubCategoryModel(
      id: tSubCategoryId,
      categoryId: tCategoryId,
      merchandiserId: tMerchandiserId,
      name: tUpdatedName,
      sortOrder: 1,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 4),
      subCategoryName: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      productCount: 10,
    );

    blocTest<SubCategoryBloc, SubCategoryState>(
      'emits [SubCategoryLoading, SubCategoryOperationSuccess, SubCategoryLoading, SubCategoriesLoaded] when UpdateSubCategory is successful',
      build: () {
        when(
          () => mockUpdateSubCategory(
            subCategoryId: any(named: 'subCategoryId'),
            name: any(named: 'name'),
            sortOrder: any(named: 'sortOrder'),
          ),
        ).thenAnswer((_) async => Right(tUpdatedSubCategory));
        when(() => mockGetSubCategories(any()))
            .thenAnswer((_) async => Right(tSubCategories));
        return subCategoryBloc;
      },
      act: (bloc) => bloc.add(UpdateSubCategory(
        subCategoryId: tSubCategoryId,
        categoryId: tCategoryId,
        name: tUpdatedName,
      )),
      expect: () => [
        SubCategoryLoading(),
        const SubCategoryOperationSuccess('Sub-Category updated successfully'),
        SubCategoryLoading(),
        SubCategoriesLoaded(tSubCategories),
      ],
      verify: (_) {
        verify(
          () => mockUpdateSubCategory(
            subCategoryId: tSubCategoryId,
            name: tUpdatedName,
          ),
        ).called(1);
        verify(() => mockGetSubCategories(tCategoryId)).called(1);
      },
    );

    blocTest<SubCategoryBloc, SubCategoryState>(
      'emits [SubCategoryLoading, SubCategoryError] when UpdateSubCategory fails',
      build: () {
        when(
          () => mockUpdateSubCategory(
            subCategoryId: any(named: 'subCategoryId'),
            name: any(named: 'name'),
            sortOrder: any(named: 'sortOrder'),
          ),
        ).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Sub-category not found')),
        );
        return subCategoryBloc;
      },
      act: (bloc) => bloc.add(UpdateSubCategory(
        subCategoryId: 'invalid-id',
        categoryId: tCategoryId,
        name: tUpdatedName,
      )),
      expect: () => [
        SubCategoryLoading(),
        const SubCategoryError('Sub-category not found'),
      ],
      verify: (_) {
        verify(
          () => mockUpdateSubCategory(
            subCategoryId: 'invalid-id',
            name: tUpdatedName,
          ),
        ).called(1);
        verifyNever(() => mockGetSubCategories(any()));
      },
    );
  });

  group('DeleteSubCategory', () {
    final tSubCategoryId = 'sub-1';

    blocTest<SubCategoryBloc, SubCategoryState>(
      'emits [SubCategoryLoading, SubCategoryOperationSuccess, SubCategoryLoading, SubCategoriesLoaded] when DeleteSubCategory is successful',
      build: () {
        when(() => mockDeleteSubCategory(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetSubCategories(any()))
            .thenAnswer((_) async => Right([tSubCategories[1]]));
        return subCategoryBloc;
      },
      act: (bloc) => bloc.add(DeleteSubCategory(
        subCategoryId: tSubCategoryId,
        categoryId: tCategoryId,
      )),
      expect: () => [
        SubCategoryLoading(),
        const SubCategoryOperationSuccess('Sub-Category deleted successfully'),
        SubCategoryLoading(),
        SubCategoriesLoaded([tSubCategories[1]]),
      ],
      verify: (_) {
        verify(() => mockDeleteSubCategory(tSubCategoryId)).called(1);
        verify(() => mockGetSubCategories(tCategoryId)).called(1);
      },
    );

    blocTest<SubCategoryBloc, SubCategoryState>(
      'emits [SubCategoryLoading, SubCategoryError] when DeleteSubCategory fails due to existing products',
      build: () {
        when(() => mockDeleteSubCategory(any())).thenAnswer(
          (_) async => Left(
            ServerFailure(
              message: 'Cannot delete sub-category with existing products',
            ),
          ),
        );
        return subCategoryBloc;
      },
      act: (bloc) => bloc.add(DeleteSubCategory(
        subCategoryId: tSubCategoryId,
        categoryId: tCategoryId,
      )),
      expect: () => [
        SubCategoryLoading(),
        const SubCategoryError(
          'Cannot delete sub-category with existing products',
        ),
      ],
      verify: (_) {
        verify(() => mockDeleteSubCategory(tSubCategoryId)).called(1);
        verifyNever(() => mockGetSubCategories(any()));
      },
    );

    blocTest<SubCategoryBloc, SubCategoryState>(
      'emits [SubCategoryLoading, SubCategoryError] when sub-category not found',
      build: () {
        when(() => mockDeleteSubCategory(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Sub-category not found')),
        );
        return subCategoryBloc;
      },
      act: (bloc) => bloc.add(DeleteSubCategory(
        subCategoryId: 'invalid-id',
        categoryId: tCategoryId,
      )),
      expect: () => [
        SubCategoryLoading(),
        const SubCategoryError('Sub-category not found'),
      ],
      verify: (_) {
        verify(() => mockDeleteSubCategory('invalid-id')).called(1);
      },
    );
  });

  test('initial state should be SubCategoryInitial', () {
    expect(subCategoryBloc.state, SubCategoryInitial());
  });
}
