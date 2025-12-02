// test/features/shared/shared_feature/domain/repositories/sub_category_repository_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/data/models/sub_category_model.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
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

  final tMerchandiserId = 'merch-1';
  final tCategoryId = 'cat-1';
  final tSubCategoryId = 'sub-1';
  final tName = {'en': 'Smartphones', 'ar': 'هواتف ذكية'};
  final tSortOrder = 1;

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

  final tSubCategory = tSubCategories[0];

  group('SubCategoryRepository', () {
    group('getSubCategories', () {
      test(
        'should return List<SubCategory> when call to repository is successful',
        () async {
          // arrange
          when(() => mockRepository.getSubCategories(any()))
              .thenAnswer((_) async => Right(tSubCategories));

          // act
          final result = await mockRepository.getSubCategories(tCategoryId);

          // assert
          expect(result, Right(tSubCategories));
          verify(() => mockRepository.getSubCategories(tCategoryId)).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return empty list when no sub-categories exist',
        () async {
          // arrange
          when(() => mockRepository.getSubCategories(any()))
              .thenAnswer((_) async => const Right([]));

          // act
          final result = await mockRepository.getSubCategories(tCategoryId);

          // assert
          expect(result, equals(const Right<Failure, List<SubCategory>>([])));
          verify(() => mockRepository.getSubCategories(tCategoryId)).called(1);
        },
      );

      test(
        'should return ServerFailure when repository call fails',
        () async {
          // arrange
          when(() => mockRepository.getSubCategories(any())).thenAnswer(
            (_) async =>
                Left(ServerFailure(message: 'Failed to fetch sub-categories')),
          );

          // act
          final result = await mockRepository.getSubCategories(tCategoryId);

          // assert
          expect(
            result,
            Left(ServerFailure(message: 'Failed to fetch sub-categories')),
          );
          verify(() => mockRepository.getSubCategories(tCategoryId)).called(1);
        },
      );
    });

    group('getSubCategoryById', () {
      test(
        'should return SubCategory when call to repository is successful',
        () async {
          // arrange
          when(() => mockRepository.getSubCategoryById(any()))
              .thenAnswer((_) async => Right(tSubCategory));

          // act
          final result =
              await mockRepository.getSubCategoryById(tSubCategoryId);

          // assert
          expect(result, Right(tSubCategory));
          verify(() => mockRepository.getSubCategoryById(tSubCategoryId))
              .called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return ServerFailure when sub-category not found',
        () async {
          // arrange
          when(() => mockRepository.getSubCategoryById(any())).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Sub-category not found')),
          );

          // act
          final result = await mockRepository.getSubCategoryById('invalid-id');

          // assert
          expect(
            result,
            Left(ServerFailure(message: 'Sub-category not found')),
          );
          verify(() => mockRepository.getSubCategoryById('invalid-id'))
              .called(1);
        },
      );
    });

    group('createSubCategory', () {
      test(
        'should return SubCategory when creation is successful',
        () async {
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

          // act
          final result = await mockRepository.createSubCategory(
            merchandiserId: tMerchandiserId,
            categoryId: tCategoryId,
            name: tName,
            sortOrder: tSortOrder,
            isActive: true,
          );

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
        },
      );

      test(
        'should return SubCategory when creating with default values',
        () async {
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

          // act
          final result = await mockRepository.createSubCategory(
            merchandiserId: tMerchandiserId,
            categoryId: tCategoryId,
            name: tName,
          );

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
        },
      );

      test(
        'should return ServerFailure when creation fails',
        () async {
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

          // act
          final result = await mockRepository.createSubCategory(
            merchandiserId: tMerchandiserId,
            categoryId: tCategoryId,
            name: tName,
          );

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
        },
      );

      test(
        'should return ServerFailure when category does not exist',
        () async {
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

          // act
          final result = await mockRepository.createSubCategory(
            merchandiserId: tMerchandiserId,
            categoryId: 'invalid-cat-id',
            name: tName,
          );

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
        },
      );
    });

    group('updateSubCategory', () {
      final tUpdatedSubCategory = SubCategoryModel(
        id: tSubCategoryId,
        categoryId: tCategoryId,
        merchandiserId: tMerchandiserId,
        name: {'en': 'Updated Smartphones', 'ar': 'هواتف ذكية محدثة'},
        sortOrder: 2,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 3),
        subCategoryName: {'en': 'Electronics', 'ar': 'إلكترونيات'},
        productCount: 10,
      );

      test(
        'should return updated SubCategory when update is successful',
        () async {
          // arrange
          when(
            () => mockRepository.updateSubCategory(
              subCategoryId: any(named: 'subCategoryId'),
              name: any(named: 'name'),
              sortOrder: any(named: 'sortOrder'),
            ),
          ).thenAnswer((_) async => Right(tUpdatedSubCategory));

          // act
          final result = await mockRepository.updateSubCategory(
            subCategoryId: tSubCategoryId,
            name: {'en': 'Updated Smartphones', 'ar': 'هواتف ذكية محدثة'},
            sortOrder: 2,
          );

          // assert
          expect(result, Right(tUpdatedSubCategory));
          verify(
            () => mockRepository.updateSubCategory(
              subCategoryId: tSubCategoryId,
              name: {'en': 'Updated Smartphones', 'ar': 'هواتف ذكية محدثة'},
              sortOrder: 2,
            ),
          ).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return updated SubCategory when updating only name',
        () async {
          // arrange
          when(
            () => mockRepository.updateSubCategory(
              subCategoryId: any(named: 'subCategoryId'),
              name: any(named: 'name'),
              sortOrder: any(named: 'sortOrder'),
            ),
          ).thenAnswer((_) async => Right(tUpdatedSubCategory));

          // act
          final result = await mockRepository.updateSubCategory(
            subCategoryId: tSubCategoryId,
            name: {'en': 'Updated Smartphones', 'ar': 'هواتف ذكية محدثة'},
          );

          // assert
          expect(result, Right(tUpdatedSubCategory));
          verify(
            () => mockRepository.updateSubCategory(
              subCategoryId: tSubCategoryId,
              name: {'en': 'Updated Smartphones', 'ar': 'هواتف ذكية محدثة'},
              sortOrder: null,
            ),
          ).called(1);
        },
      );

      test(
        'should return updated SubCategory when updating only sortOrder',
        () async {
          // arrange
          when(
            () => mockRepository.updateSubCategory(
              subCategoryId: any(named: 'subCategoryId'),
              name: any(named: 'name'),
              sortOrder: any(named: 'sortOrder'),
            ),
          ).thenAnswer((_) async => Right(tUpdatedSubCategory));

          // act
          final result = await mockRepository.updateSubCategory(
            subCategoryId: tSubCategoryId,
            sortOrder: 2,
          );

          // assert
          expect(result, Right(tUpdatedSubCategory));
          verify(
            () => mockRepository.updateSubCategory(
              subCategoryId: tSubCategoryId,
              name: null,
              sortOrder: 2,
            ),
          ).called(1);
        },
      );

      test(
        'should return ServerFailure when sub-category not found',
        () async {
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
          final result = await mockRepository.updateSubCategory(
            subCategoryId: 'invalid-id',
            name: tName,
          );

          // assert
          expect(
            result,
            Left(ServerFailure(message: 'Sub-category not found')),
          );
          verify(
            () => mockRepository.updateSubCategory(
              subCategoryId: 'invalid-id',
              name: tName,
              sortOrder: null,
            ),
          ).called(1);
        },
      );
    });

    group('deleteSubCategory', () {
      test(
        'should return void when deletion is successful',
        () async {
          // arrange
          when(() => mockRepository.deleteSubCategory(any()))
              .thenAnswer((_) async => const Right(null));

          // act
          final result = await mockRepository.deleteSubCategory(tSubCategoryId);

          // assert
          expect(result, const Right(null));
          verify(() => mockRepository.deleteSubCategory(tSubCategoryId))
              .called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return ServerFailure when sub-category has products',
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
          final result = await mockRepository.deleteSubCategory(tSubCategoryId);

          // assert
          expect(
            result,
            Left(
              ServerFailure(
                message: 'Cannot delete sub-category with existing products',
              ),
            ),
          );
          verify(() => mockRepository.deleteSubCategory(tSubCategoryId))
              .called(1);
        },
      );

      test(
        'should return ServerFailure when sub-category not found',
        () async {
          // arrange
          when(() => mockRepository.deleteSubCategory(any())).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Sub-category not found')),
          );

          // act
          final result = await mockRepository.deleteSubCategory('invalid-id');

          // assert
          expect(
            result,
            Left(ServerFailure(message: 'Sub-category not found')),
          );
          verify(() => mockRepository.deleteSubCategory('invalid-id'))
              .called(1);
        },
      );
    });
  });
}
