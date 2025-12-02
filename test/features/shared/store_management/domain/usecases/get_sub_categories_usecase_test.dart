// test/features/shared/domain/usecases/get_sub_categories_usecase_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/sub_category_repositoy_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_sub_categories_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/datasources/fake_sub_category_remote_datasource.dart';

void main() {
  late GetSubCategoriesByCategoryId useCase;
  late SubCategoryRepositoryImpl repository;
  late FakeSubCategoryRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeSubCategoryRemoteDataSource();
    repository = SubCategoryRepositoryImpl(remoteDataSource: fakeDataSource);
    useCase = GetSubCategoriesByCategoryId(repository);
  });

  tearDown(() {
    fakeDataSource.clear();
  });

  group('GetSubCategoriesByCategoryId', () {
    const tCategoryId = 'cat-1';

    group('Success Cases', () {
      test('should return list of sub-categories for category', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase(tCategoryId);

        // Assert
        expect(result, isA<Right<Failure, List<SubCategory>>>());
        result.fold((failure) => fail('Should not return failure'), (
          subCategories,
        ) {
          expect(subCategories, isA<List<SubCategory>>());
          expect(subCategories.length, 2);
          expect(subCategories[0].id, 'sub-1');
          expect(subCategories[1].id, 'sub-2');
        });
      });

      test('should return sub-categories in correct sort order', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase(tCategoryId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          subCategories,
        ) {
          expect(subCategories[0].sortOrder, 1);
          expect(subCategories[1].sortOrder, 2);
          // Verify ascending order
          for (int i = 0; i < subCategories.length - 1; i++) {
            expect(
              subCategories[i].sortOrder <= subCategories[i + 1].sortOrder,
              true,
            );
          }
        });
      });

      test('should return sub-categories with all required fields', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase(tCategoryId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          subCategories,
        ) {
          final subCategory = subCategories.first;
          expect(subCategory.id, isNotEmpty);
          expect(subCategory.categoryId, tCategoryId);
          expect(subCategory.merchandiserId, isNotEmpty);
          expect(subCategory.name, isNotEmpty);
          expect(subCategory.name['en'], isNotNull);
          expect(subCategory.name['ar'], isNotNull);
          expect(subCategory.isActive, isA<bool>());
          expect(subCategory.createdAt, isA<DateTime>());
          expect(subCategory.updatedAt, isA<DateTime>());
          expect(subCategory.productCount, isA<int>());
          expect(subCategory.subCategoryName, isNotEmpty);
        });
      });

      test('should return empty list when no sub-categories exist', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentCategoryId = 'cat-999';

        // Act
        final result = await useCase(nonExistentCategoryId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          subCategories,
        ) {
          expect(subCategories, isEmpty);
          expect(subCategories, isA<List<SubCategory>>());
        });
      });

      test(
        'should return correct sub-categories for different categories',
        () async {
          // Arrange
          fakeDataSource.seedData();

          // Act
          final result1 = await useCase('cat-1');
          final result2 = await useCase('cat-2');

          // Assert
          expect(result1, isA<Right<Failure, List<SubCategory>>>());
          expect(result2, isA<Right<Failure, List<SubCategory>>>());

          late List<SubCategory> subCategories1;
          late List<SubCategory> subCategories2;

          result1.fold(
            (failure) => fail('Should not return failure'),
            (subCategories) => subCategories1 = subCategories,
          );

          result2.fold(
            (failure) => fail('Should not return failure'),
            (subCategories) => subCategories2 = subCategories,
          );

          expect(subCategories1.length, 2);
          expect(subCategories2.length, 1);
          expect(subCategories1.first.categoryId, 'cat-1');
          expect(subCategories2.first.categoryId, 'cat-2');
        },
      );

      test('should handle multiple calls correctly', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result1 = await useCase(tCategoryId);
        final result2 = await useCase(tCategoryId);

        // Assert
        expect(result1, isA<Right<Failure, List<SubCategory>>>());
        expect(result2, isA<Right<Failure, List<SubCategory>>>());

        late List<SubCategory> subCategories1;
        late List<SubCategory> subCategories2;

        result1.fold(
          (failure) => fail('Should not return failure'),
          (subCategories) => subCategories1 = subCategories,
        );

        result2.fold(
          (failure) => fail('Should not return failure'),
          (subCategories) => subCategories2 = subCategories,
        );

        expect(subCategories1.length, subCategories2.length);
        expect(subCategories1.first.id, subCategories2.first.id);
      });
    });

    group('Failure Cases', () {
      test('should return ServerFailure when repository fails', () async {
        // Arrange
        fakeDataSource.throwError('Database connection failed');

        // Act
        final result = await useCase(tCategoryId);

        // Assert
        expect(result, isA<Left<Failure, List<SubCategory>>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Database connection failed'));
        }, (subCategories) => fail('Should not return sub-categories'));
      });

      test('should return ServerFailure on network error', () async {
        // Arrange
        fakeDataSource.throwError('Network timeout');

        // Act
        final result = await useCase(tCategoryId);

        // Assert
        expect(result, isA<Left<Failure, List<SubCategory>>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Network timeout'));
        }, (subCategories) => fail('Should not return sub-categories'));
      });

      test('should return ServerFailure with proper error message', () async {
        // Arrange
        const customError = 'Custom database error';
        fakeDataSource.throwError(customError);

        // Act
        final result = await useCase(tCategoryId);

        // Assert
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains(customError));
        }, (subCategories) => fail('Should not return sub-categories'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty category ID gracefully', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase('');

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (subCategories) => expect(subCategories, isEmpty),
        );
      });

      test('should handle sub-categories with zero product count', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase(tCategoryId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          subCategories,
        ) {
          for (final subCategory in subCategories) {
            expect(subCategory.productCount >= 0, true);
          }
        });
      });

      test('should maintain data consistency across calls', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result1 = await useCase(tCategoryId);
        final result2 = await useCase(tCategoryId);

        // Assert - Data should be consistent
        late List<SubCategory> subCategories1;
        late List<SubCategory> subCategories2;

        result1.fold(
          (failure) => fail('Should not return failure'),
          (subCategories) => subCategories1 = subCategories,
        );

        result2.fold(
          (failure) => fail('Should not return failure'),
          (subCategories) => subCategories2 = subCategories,
        );

        expect(subCategories1.length, subCategories2.length);
        for (int i = 0; i < subCategories1.length; i++) {
          expect(subCategories1[i].id, subCategories2[i].id);
          expect(subCategories1[i].name, subCategories2[i].name);
        }
      });

      test('should handle active and inactive sub-categories', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase(tCategoryId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          subCategories,
        ) {
          // All seeded sub-categories are active
          final activeSubCategories =
              subCategories.where((s) => s.isActive).toList();
          expect(activeSubCategories.length, 2);
        });
      });
    });

    group('Integration Tests', () {
      test('should isolate sub-categories by category', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final cat1Result = await useCase('cat-1');
        final cat2Result = await useCase('cat-2');

        // Assert
        late List<SubCategory> cat1SubCategories;
        late List<SubCategory> cat2SubCategories;

        cat1Result.fold(
          (failure) => fail('Should not return failure'),
          (subCategories) => cat1SubCategories = subCategories,
        );

        cat2Result.fold(
          (failure) => fail('Should not return failure'),
          (subCategories) => cat2SubCategories = subCategories,
        );

        // No overlap in sub-categories
        final cat1Ids = cat1SubCategories.map((s) => s.id).toSet();
        final cat2Ids = cat2SubCategories.map((s) => s.id).toSet();
        expect(cat1Ids.intersection(cat2Ids).isEmpty, true);
      });

      test('should return correct parent category name', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase(tCategoryId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          subCategories,
        ) {
          for (final subCategory in subCategories) {
            expect(subCategory.subCategoryName, isNotEmpty);
            expect(subCategory.subCategoryName['en'], isNotNull);
            expect(subCategory.subCategoryName['ar'], isNotNull);
          }
        });
      });
    });
  });

  group('GetSubCategoryById', () {
    const tSubCategoryId = 'sub-1';
    late GetSubCategoryById getByIdUseCase;

    setUp(() {
      getByIdUseCase = GetSubCategoryById(repository);
    });

    test('should return sub-category when found', () async {
      // Arrange
      fakeDataSource.seedData();

      // Act
      final result = await getByIdUseCase(tSubCategoryId);

      // Assert
      expect(result, isA<Right<Failure, SubCategory>>());
      result.fold((failure) => fail('Should not return failure'), (
        subCategory,
      ) {
        expect(subCategory.id, tSubCategoryId);
        expect(subCategory.name['en'], 'Smartphones');
      });
    });

    test('should return ServerFailure when sub-category not found', () async {
      // Arrange
      fakeDataSource.seedData();
      const nonExistentId = 'sub-999';

      // Act
      final result = await getByIdUseCase(nonExistentId);

      // Assert
      expect(result, isA<Left<Failure, SubCategory>>());
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Sub-category not found');
      }, (subCategory) => fail('Should not return sub-category'));
    });

    test('should return ServerFailure on error', () async {
      // Arrange
      fakeDataSource.throwError('Database error');

      // Act
      final result = await getByIdUseCase(tSubCategoryId);

      // Assert
      expect(result, isA<Left<Failure, SubCategory>>());
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('Database error'));
      }, (subCategory) => fail('Should not return sub-category'));
    });
  });
}
