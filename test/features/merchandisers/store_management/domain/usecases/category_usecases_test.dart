// test/features/merchandisers/store_management/domain/usecases/category/category_usecases_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/category/create_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/category/delete_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/category/update_category_usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/data/models/category_model.dart';
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

  group('CreateCategoryUseCase', () {
    late CreateCategoryUseCase useCase;

    setUp(() {
      useCase = CreateCategoryUseCase(mockRepository);
    });

    final tMerchandiserId = 'merch-1';
    final tName = {'en': 'Electronics', 'ar': 'إلكترونيات'};
    final tImageThumbnail = 'https://example.com/electronics-thumb.jpg';
    final tImage = 'https://example.com/electronics.jpg';
    final tSortOrder = 1;

    final tCategory = CategoryModel(
      id: 'cat-1',
      merchandiserId: tMerchandiserId,
      name: tName,
      imageThumbnail: tImageThumbnail,
      image: tImage,
      sortOrder: tSortOrder,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      productCount: 0,
      subCategoryCount: 0,
    );

    test('should create a category successfully', () async {
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

      final params = CreateCategoryParams(
        merchandiserId: tMerchandiserId,
        name: tName,
        imageThumbnail: tImageThumbnail,
        image: tImage,
        sortOrder: tSortOrder,
      );

      // act
      final result = await useCase(params);

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
    });

    test('should create a category without optional fields', () async {
      // arrange
      final categoryWithoutOptionals = CategoryModel(
        id: 'cat-2',
        merchandiserId: tMerchandiserId,
        name: tName,
        imageThumbnail: null,
        image: null,
        sortOrder: 0,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        productCount: 0,
        subCategoryCount: 0,
      );

      when(
        () => mockRepository.createCategory(
          merchandiserId: any(named: 'merchandiserId'),
          name: any(named: 'name'),
          imageThumbnail: any(named: 'imageThumbnail'),
          image: any(named: 'image'),
          sortOrder: any(named: 'sortOrder'),
        ),
      ).thenAnswer((_) async => Right(categoryWithoutOptionals));

      final params = CreateCategoryParams(
        merchandiserId: tMerchandiserId,
        name: tName,
      );

      // act
      final result = await useCase(params);

      // assert
      expect(result, Right(categoryWithoutOptionals));
      verify(
        () => mockRepository.createCategory(
          merchandiserId: tMerchandiserId,
          name: tName,
          imageThumbnail: null,
          image: null,
          sortOrder: 0,
        ),
      ).called(1);
    });

    test('should return ServerFailure when repository fails', () async {
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
        (_) async => Left(ServerFailure(message: 'Failed to create category')),
      );

      final params = CreateCategoryParams(
        merchandiserId: tMerchandiserId,
        name: tName,
      );

      // act
      final result = await useCase(params);

      // assert
      expect(result, Left(ServerFailure(message: 'Failed to create category')));
      verify(
        () => mockRepository.createCategory(
          merchandiserId: tMerchandiserId,
          name: tName,
          imageThumbnail: null,
          image: null,
          sortOrder: 0,
        ),
      ).called(1);
    });
  });

  group('UpdateCategoryUseCase', () {
    late UpdateCategoryUseCase useCase;

    setUp(() {
      useCase = UpdateCategoryUseCase(mockRepository);
    });

    final tCategoryId = 'cat-1';
    final tName = {'en': 'Updated Electronics', 'ar': 'إلكترونيات محدثة'};
    final tImageThumbnail = 'https://example.com/updated-thumb.jpg';
    final tImage = 'https://example.com/updated.jpg';
    final tSortOrder = 2;
    final tIsActive = false;

    final tUpdatedCategory = CategoryModel(
      id: tCategoryId,
      merchandiserId: 'merch-1',
      name: tName,
      imageThumbnail: tImageThumbnail,
      image: tImage,
      sortOrder: tSortOrder,
      isActive: tIsActive,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
      productCount: 15,
      subCategoryCount: 3,
    );

    test('should update a category with all fields', () async {
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

      final params = UpdateCategoryParams(
        categoryId: tCategoryId,
        name: tName,
        imageThumbnail: tImageThumbnail,
        image: tImage,
        sortOrder: tSortOrder,
        isActive: tIsActive,
      );

      // act
      final result = await useCase(params);

      // assert
      expect(result, Right(tUpdatedCategory));
      verify(
        () => mockRepository.updateCategory(
          categoryId: tCategoryId,
          name: tName,
          imageThumbnail: tImageThumbnail,
          image: tImage,
          sortOrder: tSortOrder,
          isActive: tIsActive,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should update a category with only name', () async {
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

      final params = UpdateCategoryParams(
        categoryId: tCategoryId,
        name: tName,
      );

      // act
      final result = await useCase(params);

      // assert
      expect(result, Right(tUpdatedCategory));
      verify(
        () => mockRepository.updateCategory(
          categoryId: tCategoryId,
          name: tName,
          imageThumbnail: null,
          image: null,
          sortOrder: null,
          isActive: null,
        ),
      ).called(1);
    });

    test('should return ServerFailure when category not found', () async {
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

      final params = UpdateCategoryParams(
        categoryId: 'invalid-id',
        name: tName,
      );

      // act
      final result = await useCase(params);

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
    });
  });

  group('DeleteCategoryUseCase', () {
    late DeleteCategoryUseCase useCase;

    setUp(() {
      useCase = DeleteCategoryUseCase(mockRepository);
    });

    final tCategoryId = 'cat-1';

    test('should delete a category successfully', () async {
      // arrange
      when(() => mockRepository.deleteCategory(any()))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(tCategoryId);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.deleteCategory(tCategoryId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when category has sub-categories',
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
      final result = await useCase(tCategoryId);

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
    });

    test('should return ServerFailure when category not found', () async {
      // arrange
      when(() => mockRepository.deleteCategory(any())).thenAnswer(
        (_) async => Left(ServerFailure(message: 'Category not found')),
      );

      // act
      final result = await useCase('invalid-id');

      // assert
      expect(result, Left(ServerFailure(message: 'Category not found')));
      verify(() => mockRepository.deleteCategory('invalid-id')).called(1);
    });
  });
}
