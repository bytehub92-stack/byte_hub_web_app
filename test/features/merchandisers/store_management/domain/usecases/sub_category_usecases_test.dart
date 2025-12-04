// test/features/merchandisers/store_management/domain/usecases/sub_category/sub_category_usecases_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/sub_category/create_sub_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/sub_category/delete_sub_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/sub_category/update_sub_category_usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/data/models/sub_category_model.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/sub_category_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSubCategoryRepository extends Mock implements SubCategoryRepository {}

void main() {
  late MockSubCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockSubCategoryRepository();
  });

  group('CreateSubCategoryUsecase', () {
    late CreateSubCategoryUsecase useCase;

    setUp(() {
      useCase = CreateSubCategoryUsecase(mockRepository);
    });

    final tMerchandiserId = 'merch-1';
    final tCategoryId = 'cat-1';
    final tName = {'en': 'Smartphones', 'ar': 'هواتف ذكية'};
    final tSortOrder = 1;

    final tSubCategory = SubCategoryModel(
      id: 'sub-1',
      categoryId: tCategoryId,
      merchandiserId: tMerchandiserId,
      name: tName,
      sortOrder: tSortOrder,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      subCategoryName: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      productCount: 0,
    );

    test('should create a sub-category successfully', () async {
      // arrange
      when(
        () => mockRepository.createSubCategory(
          merchandiserId: any(named: 'merchandiserId'),
          categoryId: any(named: 'categoryId'),
          name: any(named: 'name'),
          sortOrder: any(named: 'sortOrder'),
          isActive: any(named: 'isActive'),
        ),
      ).thenAnswer((_) async => Right(tSubCategory));

      final params = CreateSubCategoryParams(
        merchandiserId: tMerchandiserId,
        categoryId: tCategoryId,
        name: tName,
        sortOrder: tSortOrder,
      );

      // act
      final result = await useCase(params);

      // assert
      expect(result, Right(tSubCategory));
      verify(
        () => mockRepository.createSubCategory(
          merchandiserId: tMerchandiserId,
          categoryId: tCategoryId,
          name: tName,
          sortOrder: tSortOrder,
          isActive: true,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should create a sub-category with default values', () async {
      // arrange
      when(
        () => mockRepository.createSubCategory(
          merchandiserId: any(named: 'merchandiserId'),
          categoryId: any(named: 'categoryId'),
          name: any(named: 'name'),
          sortOrder: any(named: 'sortOrder'),
          isActive: any(named: 'isActive'),
        ),
      ).thenAnswer((_) async => Right(tSubCategory));

      final params = CreateSubCategoryParams(
        merchandiserId: tMerchandiserId,
        categoryId: tCategoryId,
        name: tName,
      );

      // act
      final result = await useCase(params);

      // assert
      expect(result, Right(tSubCategory));
      verify(
        () => mockRepository.createSubCategory(
          merchandiserId: tMerchandiserId,
          categoryId: tCategoryId,
          name: tName,
          sortOrder: 0,
          isActive: true,
        ),
      ).called(1);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      when(
        () => mockRepository.createSubCategory(
          merchandiserId: any(named: 'merchandiserId'),
          categoryId: any(named: 'categoryId'),
          name: any(named: 'name'),
          sortOrder: any(named: 'sortOrder'),
          isActive: any(named: 'isActive'),
        ),
      ).thenAnswer(
        (_) async =>
            Left(ServerFailure(message: 'Failed to create sub-category')),
      );

      final params = CreateSubCategoryParams(
        merchandiserId: tMerchandiserId,
        categoryId: tCategoryId,
        name: tName,
      );

      // act
      final result = await useCase(params);

      // assert
      expect(
        result,
        Left(ServerFailure(message: 'Failed to create sub-category')),
      );
      verify(
        () => mockRepository.createSubCategory(
          merchandiserId: tMerchandiserId,
          categoryId: tCategoryId,
          name: tName,
          sortOrder: 0,
          isActive: true,
        ),
      ).called(1);
    });

    test('should return ServerFailure when category does not exist', () async {
      // arrange
      when(
        () => mockRepository.createSubCategory(
          merchandiserId: any(named: 'merchandiserId'),
          categoryId: any(named: 'categoryId'),
          name: any(named: 'name'),
          sortOrder: any(named: 'sortOrder'),
          isActive: any(named: 'isActive'),
        ),
      ).thenAnswer(
        (_) async => Left(ServerFailure(message: 'Category not found')),
      );

      final params = CreateSubCategoryParams(
        merchandiserId: tMerchandiserId,
        categoryId: 'invalid-cat-id',
        name: tName,
      );

      // act
      final result = await useCase(params);

      // assert
      expect(result, Left(ServerFailure(message: 'Category not found')));
      verify(
        () => mockRepository.createSubCategory(
          merchandiserId: tMerchandiserId,
          categoryId: 'invalid-cat-id',
          name: tName,
          sortOrder: 0,
          isActive: true,
        ),
      ).called(1);
    });
  });

  group('UpdateSubCategoryUsecase', () {
    late UpdateSubCategoryUsecase useCase;

    setUp(() {
      useCase = UpdateSubCategoryUsecase(mockRepository);
    });

    final tSubCategoryId = 'sub-1';
    final tName = {'en': 'Updated Smartphones', 'ar': 'هواتف ذكية محدثة'};
    final tSortOrder = 2;

    final tUpdatedSubCategory = SubCategoryModel(
      id: tSubCategoryId,
      categoryId: 'cat-1',
      merchandiserId: 'merch-1',
      name: tName,
      sortOrder: tSortOrder,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
      subCategoryName: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      productCount: 10,
    );

    test('should update a sub-category with all fields', () async {
      // arrange
      when(
        () => mockRepository.updateSubCategory(
          subCategoryId: any(named: 'subCategoryId'),
          name: any(named: 'name'),
          sortOrder: any(named: 'sortOrder'),
        ),
      ).thenAnswer((_) async => Right(tUpdatedSubCategory));

      // act
      final result = await useCase(
        subCategoryId: tSubCategoryId,
        name: tName,
        sortOrder: tSortOrder,
      );

      // assert
      expect(result, Right(tUpdatedSubCategory));
      verify(
        () => mockRepository.updateSubCategory(
          subCategoryId: tSubCategoryId,
          name: tName,
          sortOrder: tSortOrder,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should update a sub-category with only name', () async {
      // arrange
      when(
        () => mockRepository.updateSubCategory(
          subCategoryId: any(named: 'subCategoryId'),
          name: any(named: 'name'),
          sortOrder: any(named: 'sortOrder'),
        ),
      ).thenAnswer((_) async => Right(tUpdatedSubCategory));

      // act
      final result = await useCase(
        subCategoryId: tSubCategoryId,
        name: tName,
      );

      // assert
      expect(result, Right(tUpdatedSubCategory));
      verify(
        () => mockRepository.updateSubCategory(
          subCategoryId: tSubCategoryId,
          name: tName,
          sortOrder: null,
        ),
      ).called(1);
    });

    test('should update a sub-category with only sortOrder', () async {
      // arrange
      when(
        () => mockRepository.updateSubCategory(
          subCategoryId: any(named: 'subCategoryId'),
          name: any(named: 'name'),
          sortOrder: any(named: 'sortOrder'),
        ),
      ).thenAnswer((_) async => Right(tUpdatedSubCategory));

      // act
      final result = await useCase(
        subCategoryId: tSubCategoryId,
        sortOrder: tSortOrder,
      );

      // assert
      expect(result, Right(tUpdatedSubCategory));
      verify(
        () => mockRepository.updateSubCategory(
          subCategoryId: tSubCategoryId,
          name: null,
          sortOrder: tSortOrder,
        ),
      ).called(1);
    });

    test('should return ServerFailure when sub-category not found', () async {
      // arrange
      when(
        () => mockRepository.updateSubCategory(
          subCategoryId: any(named: 'subCategoryId'),
          name: any(named: 'name'),
          sortOrder: any(named: 'sortOrder'),
        ),
      ).thenAnswer(
        (_) async => Left(ServerFailure(message: 'Sub-category not found')),
      );

      // act
      final result = await useCase(
        subCategoryId: 'invalid-id',
        name: tName,
      );

      // assert
      expect(result, Left(ServerFailure(message: 'Sub-category not found')));
      verify(
        () => mockRepository.updateSubCategory(
          subCategoryId: 'invalid-id',
          name: tName,
          sortOrder: null,
        ),
      ).called(1);
    });
  });

  group('DeleteSubCategoryUsecase', () {
    late DeleteSubCategoryUsecase useCase;

    setUp(() {
      useCase = DeleteSubCategoryUsecase(mockRepository);
    });

    final tSubCategoryId = 'sub-1';

    test('should delete a sub-category successfully', () async {
      // arrange
      when(() => mockRepository.deleteSubCategory(any()))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(tSubCategoryId);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.deleteSubCategory(tSubCategoryId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when sub-category has products',
        () async {
      // arrange
      when(() => mockRepository.deleteSubCategory(any())).thenAnswer(
        (_) async => Left(
          ServerFailure(
            message: 'Cannot delete sub-category with existing products',
          ),
        ),
      );

      // act
      final result = await useCase(tSubCategoryId);

      // assert
      expect(
        result,
        Left(
          ServerFailure(
            message: 'Cannot delete sub-category with existing products',
          ),
        ),
      );
      verify(() => mockRepository.deleteSubCategory(tSubCategoryId)).called(1);
    });

    test('should return ServerFailure when sub-category not found', () async {
      // arrange
      when(() => mockRepository.deleteSubCategory(any())).thenAnswer(
        (_) async => Left(ServerFailure(message: 'Sub-category not found')),
      );

      // act
      final result = await useCase('invalid-id');

      // assert
      expect(result, Left(ServerFailure(message: 'Sub-category not found')));
      verify(() => mockRepository.deleteSubCategory('invalid-id')).called(1);
    });
  });
}
