// test/features/shared/shared_feature/domain/repositories/category_repository_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/data/models/category_model.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
  });

  final tMerchandiserId = 'merch-1';
  final tCategoryId = 'cat-1';
  final tName = {'en': 'Electronics', 'ar': 'إلكترونيات'};
  final tImageThumbnail = 'https://example.com/electronics-thumb.jpg';
  final tImage = 'https://example.com/electronics.jpg';
  final tSortOrder = 1;

  final tCategories = [
    CategoryModel(
      id: 'cat-1',
      merchandiserId: tMerchandiserId,
      name: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      imageThumbnail: tImageThumbnail,
      image: tImage,
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

  final tCategory = tCategories[0];

  group('CategoryRepository', () {
    group('getCategories', () {
      test(
        'should return List<Category> when call to repository is successful',
        () async {
          // arrange
          when(() => mockRepository.getCategories(any()))
              .thenAnswer((_) async => Right(tCategories));

          // act
          final result = await mockRepository.getCategories(tMerchandiserId);

          // assert
          expect(result, Right(tCategories));
          verify(() => mockRepository.getCategories(tMerchandiserId)).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return empty list when no categories exist',
        () async {
          // arrange
          when(() => mockRepository.getCategories(any()))
              .thenAnswer((_) async => const Right([]));

          // act
          final result = await mockRepository.getCategories(tMerchandiserId);

          // assert
          expect(result, equals(const Right<Failure, List<Category>>([])));
          verify(() => mockRepository.getCategories(tMerchandiserId)).called(1);
        },
      );

      test(
        'should return ServerFailure when repository call fails',
        () async {
          // arrange
          when(() => mockRepository.getCategories(any())).thenAnswer(
            (_) async =>
                Left(ServerFailure(message: 'Failed to fetch categories')),
          );

          // act
          final result = await mockRepository.getCategories(tMerchandiserId);

          // assert
          expect(
            result,
            Left(ServerFailure(message: 'Failed to fetch categories')),
          );
          verify(() => mockRepository.getCategories(tMerchandiserId)).called(1);
        },
      );
    });

    group('getCategoryById', () {
      test(
        'should return Category when call to repository is successful',
        () async {
          // arrange
          when(() => mockRepository.getCategoryById(any()))
              .thenAnswer((_) async => Right(tCategory));

          // act
          final result = await mockRepository.getCategoryById(tCategoryId);

          // assert
          expect(result, Right(tCategory));
          verify(() => mockRepository.getCategoryById(tCategoryId)).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return ServerFailure when category not found',
        () async {
          // arrange
          when(() => mockRepository.getCategoryById(any())).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Category not found')),
          );

          // act
          final result = await mockRepository.getCategoryById('invalid-id');

          // assert
          expect(result, Left(ServerFailure(message: 'Category not found')));
          verify(() => mockRepository.getCategoryById('invalid-id')).called(1);
        },
      );
    });

    group('createCategory', () {
      test(
        'should return Category when creation is successful',
        () async {
          // arrange
          when(
            () => mockRepository.createCategory(
              merchandiserId: any(named: 'merchandiserId'),
              name: any(named: 'name'),
              imageThumbnail: any(named: 'imageThumbnail'),
              image: any(named: 'image'),
              sortOrder: any(named: 'sortOrder'),
            ),
          ).thenAnswer((_) async => Right(tCategory));

          // act
          final result = await mockRepository.createCategory(
            merchandiserId: tMerchandiserId,
            name: tName,
            imageThumbnail: tImageThumbnail,
            image: tImage,
            sortOrder: tSortOrder,
          );

          // assert
          expect(result, Right(tCategory));
          verify(
            () => mockRepository.createCategory(
              merchandiserId: tMerchandiserId,
              name: tName,
              imageThumbnail: tImageThumbnail,
              image: tImage,
              sortOrder: tSortOrder,
            ),
          ).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return Category when creating with only required fields',
        () async {
          // arrange
          when(
            () => mockRepository.createCategory(
              merchandiserId: any(named: 'merchandiserId'),
              name: any(named: 'name'),
              imageThumbnail: any(named: 'imageThumbnail'),
              image: any(named: 'image'),
              sortOrder: any(named: 'sortOrder'),
            ),
          ).thenAnswer((_) async => Right(tCategory));

          // act
          final result = await mockRepository.createCategory(
            merchandiserId: tMerchandiserId,
            name: tName,
          );

          // assert
          expect(result, Right(tCategory));
          verify(
            () => mockRepository.createCategory(
              merchandiserId: tMerchandiserId,
              name: tName,
              imageThumbnail: null,
              image: null,
              sortOrder: 0,
            ),
          ).called(1);
        },
      );

      test(
        'should return ServerFailure when creation fails',
        () async {
          // arrange
          when(
            () => mockRepository.createCategory(
              merchandiserId: any(named: 'merchandiserId'),
              name: any(named: 'name'),
              imageThumbnail: any(named: 'imageThumbnail'),
              image: any(named: 'image'),
              sortOrder: any(named: 'sortOrder'),
            ),
          ).thenAnswer(
            (_) async =>
                Left(ServerFailure(message: 'Failed to create category')),
          );

          // act
          final result = await mockRepository.createCategory(
            merchandiserId: tMerchandiserId,
            name: tName,
          );

          // assert
          expect(
            result,
            Left(ServerFailure(message: 'Failed to create category')),
          );
          verify(
            () => mockRepository.createCategory(
              merchandiserId: tMerchandiserId,
              name: tName,
              imageThumbnail: null,
              image: null,
              sortOrder: 0,
            ),
          ).called(1);
        },
      );
    });

    group('updateCategory', () {
      final tUpdatedCategory = CategoryModel(
        id: tCategoryId,
        merchandiserId: tMerchandiserId,
        name: {'en': 'Updated Electronics', 'ar': 'إلكترونيات محدثة'},
        imageThumbnail: tImageThumbnail,
        image: tImage,
        sortOrder: 2,
        isActive: false,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 3),
        productCount: 15,
        subCategoryCount: 3,
      );

      test(
        'should return updated Category when update is successful',
        () async {
          // arrange
          when(
            () => mockRepository.updateCategory(
              categoryId: any(named: 'categoryId'),
              name: any(named: 'name'),
              imageThumbnail: any(named: 'imageThumbnail'),
              image: any(named: 'image'),
              sortOrder: any(named: 'sortOrder'),
              isActive: any(named: 'isActive'),
            ),
          ).thenAnswer((_) async => Right(tUpdatedCategory));

          // act
          final result = await mockRepository.updateCategory(
            categoryId: tCategoryId,
            name: {'en': 'Updated Electronics', 'ar': 'إلكترونيات محدثة'},
            sortOrder: 2,
            isActive: false,
          );

          // assert
          expect(result, Right(tUpdatedCategory));
          verify(
            () => mockRepository.updateCategory(
              categoryId: tCategoryId,
              name: {'en': 'Updated Electronics', 'ar': 'إلكترونيات محدثة'},
              imageThumbnail: null,
              image: null,
              sortOrder: 2,
              isActive: false,
            ),
          ).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return updated Category when updating only one field',
        () async {
          // arrange
          when(
            () => mockRepository.updateCategory(
              categoryId: any(named: 'categoryId'),
              name: any(named: 'name'),
              imageThumbnail: any(named: 'imageThumbnail'),
              image: any(named: 'image'),
              sortOrder: any(named: 'sortOrder'),
              isActive: any(named: 'isActive'),
            ),
          ).thenAnswer((_) async => Right(tUpdatedCategory));

          // act
          final result = await mockRepository.updateCategory(
            categoryId: tCategoryId,
            isActive: false,
          );

          // assert
          expect(result, Right(tUpdatedCategory));
          verify(
            () => mockRepository.updateCategory(
              categoryId: tCategoryId,
              name: null,
              imageThumbnail: null,
              image: null,
              sortOrder: null,
              isActive: false,
            ),
          ).called(1);
        },
      );

      test(
        'should return ServerFailure when category not found',
        () async {
          // arrange
          when(
            () => mockRepository.updateCategory(
              categoryId: any(named: 'categoryId'),
              name: any(named: 'name'),
              imageThumbnail: any(named: 'imageThumbnail'),
              image: any(named: 'image'),
              sortOrder: any(named: 'sortOrder'),
              isActive: any(named: 'isActive'),
            ),
          ).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Category not found')),
          );

          // act
          final result = await mockRepository.updateCategory(
            categoryId: 'invalid-id',
            name: tName,
          );

          // assert
          expect(result, Left(ServerFailure(message: 'Category not found')));
          verify(
            () => mockRepository.updateCategory(
              categoryId: 'invalid-id',
              name: tName,
              imageThumbnail: null,
              image: null,
              sortOrder: null,
              isActive: null,
            ),
          ).called(1);
        },
      );
    });

    group('deleteCategory', () {
      test(
        'should return void when deletion is successful',
        () async {
          // arrange
          when(() => mockRepository.deleteCategory(any()))
              .thenAnswer((_) async => const Right(null));

          // act
          final result = await mockRepository.deleteCategory(tCategoryId);

          // assert
          expect(result, const Right(null));
          verify(() => mockRepository.deleteCategory(tCategoryId)).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test(
        'should return ServerFailure when category has sub-categories',
        () async {
          // arrange
          when(() => mockRepository.deleteCategory(any())).thenAnswer(
            (_) async => Left(
              ServerFailure(
                message: 'Cannot delete category with existing sub-categories',
              ),
            ),
          );

          // act
          final result = await mockRepository.deleteCategory(tCategoryId);

          // assert
          expect(
            result,
            Left(
              ServerFailure(
                message: 'Cannot delete category with existing sub-categories',
              ),
            ),
          );
          verify(() => mockRepository.deleteCategory(tCategoryId)).called(1);
        },
      );

      test(
        'should return ServerFailure when category not found',
        () async {
          // arrange
          when(() => mockRepository.deleteCategory(any())).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Category not found')),
          );

          // act
          final result = await mockRepository.deleteCategory('invalid-id');

          // assert
          expect(result, Left(ServerFailure(message: 'Category not found')));
          verify(() => mockRepository.deleteCategory('invalid-id')).called(1);
        },
      );
    });
  });
}
