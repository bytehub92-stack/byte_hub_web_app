// test/features/shared/domain/usecases/get_categories_usecase_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/category_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_categories_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/fake_datasources/fake_category_remote_datasource.dart';

void main() {
  late GetCategoriesByMerchandiserIdUseCase useCase;
  late CategoryRepositoryImpl repository;
  late FakeCategoryRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeCategoryRemoteDataSource();
    repository = CategoryRepositoryImpl(remoteDataSource: fakeDataSource);
    useCase = GetCategoriesByMerchandiserIdUseCase(repository);
  });

  tearDown(() {
    fakeDataSource.clear();
  });

  group('GetCategoriesUseCase', () {
    const tMerchandiserId = 'merch-1';

    group('Success Cases', () {
      test('should return list of categories from repository', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase(tMerchandiserId);

        // Assert
        expect(result, isA<Right<Failure, List<Category>>>());
        result.fold((failure) => fail('Should not return failure'), (
          categories,
        ) {
          expect(categories, isA<List<Category>>());
          expect(categories.length, 2);
          expect(categories[0].id, 'cat-1');
          expect(categories[1].id, 'cat-2');
        });
      });

      test('should return categories in correct order', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase(tMerchandiserId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          categories,
        ) {
          expect(categories[0].sortOrder, 1);
          expect(categories[1].sortOrder, 2);
          // Verify ascending order
          for (int i = 0; i < categories.length - 1; i++) {
            expect(
              categories[i].sortOrder <= categories[i + 1].sortOrder,
              true,
            );
          }
        });
      });

      test('should return categories with all required fields', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase(tMerchandiserId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          categories,
        ) {
          final category = categories.first;
          expect(category.id, isNotEmpty);
          expect(category.merchandiserId, tMerchandiserId);
          expect(category.name, isNotEmpty);
          expect(category.name['en'], isNotNull);
          expect(category.name['ar'], isNotNull);
          expect(category.isActive, isA<bool>());
          expect(category.createdAt, isA<DateTime>());
          expect(category.updatedAt, isA<DateTime>());
          expect(category.productCount, isA<int>());
          expect(category.subCategoryCount, isA<int>());
        });
      });

      test('should return empty list when no categories exist', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentMerchId = 'merch-999';

        // Act
        final result = await useCase(nonExistentMerchId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          categories,
        ) {
          expect(categories, isEmpty);
          expect(categories, isA<List<Category>>());
        });
      });

      test('should return only active categories if filtered', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase(tMerchandiserId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          categories,
        ) {
          // merch-1 has 2 active categories
          final activeCategories = categories.where((c) => c.isActive).toList();
          expect(activeCategories.length, 2);
        });
      });

      test('should handle multiple calls correctly', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result1 = await useCase(tMerchandiserId);
        final result2 = await useCase(tMerchandiserId);

        // Assert
        expect(result1, isA<Right<Failure, List<Category>>>());
        expect(result2, isA<Right<Failure, List<Category>>>());

        late List<Category> categories1;
        late List<Category> categories2;

        result1.fold(
          (failure) => fail('Should not return failure'),
          (categories) => categories1 = categories,
        );

        result2.fold(
          (failure) => fail('Should not return failure'),
          (categories) => categories2 = categories,
        );

        expect(categories1.length, categories2.length);
        expect(categories1.first.id, categories2.first.id);
      });
    });

    group('Failure Cases', () {
      test('should return ServerFailure when repository fails', () async {
        // Arrange
        fakeDataSource.throwError('Database connection failed');

        // Act
        final result = await useCase(tMerchandiserId);

        // Assert
        expect(result, isA<Left<Failure, List<Category>>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Database connection failed'));
        }, (categories) => fail('Should not return categories'));
      });

      test('should return ServerFailure on network error', () async {
        // Arrange
        fakeDataSource.throwError('Network timeout');

        // Act
        final result = await useCase(tMerchandiserId);

        // Assert
        expect(result, isA<Left<Failure, List<Category>>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Network timeout'));
        }, (categories) => fail('Should not return categories'));
      });

      test('should return ServerFailure with proper error message', () async {
        // Arrange
        const customError = 'Custom error message';
        fakeDataSource.throwError(customError);

        // Act
        final result = await useCase(tMerchandiserId);

        // Assert
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains(customError));
        }, (categories) => fail('Should not return categories'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty merchandiser ID gracefully', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase('');

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (categories) => expect(categories, isEmpty),
        );
      });

      test('should handle categories with missing optional fields', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase(tMerchandiserId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          categories,
        ) {
          for (final category in categories) {
            // Image fields are optional
            expect(category.imageThumbnail, isA<String?>());
            expect(category.image, isA<String?>());
          }
        });
      });

      test('should handle categories with zero counts', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await useCase(tMerchandiserId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          categories,
        ) {
          // Should not throw on zero counts
          for (final category in categories) {
            expect(category.productCount >= 0, true);
            expect(category.subCategoryCount >= 0, true);
          }
        });
      });

      test('should maintain data consistency across calls', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result1 = await useCase(tMerchandiserId);
        final result2 = await useCase(tMerchandiserId);

        // Assert - Data should be consistent
        late List<Category> categories1;
        late List<Category> categories2;

        result1.fold(
          (failure) => fail('Should not return failure'),
          (categories) => categories1 = categories,
        );

        result2.fold(
          (failure) => fail('Should not return failure'),
          (categories) => categories2 = categories,
        );

        expect(categories1.length, categories2.length);
        for (int i = 0; i < categories1.length; i++) {
          expect(categories1[i].id, categories2[i].id);
          expect(categories1[i].name, categories2[i].name);
        }
      });
    });

    group('Integration Tests', () {
      test('should work with multiple merchandisers', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result1 = await useCase('merch-1');
        final result2 = await useCase('merch-2');

        // Assert
        expect(result1, isA<Right<Failure, List<Category>>>());
        expect(result2, isA<Right<Failure, List<Category>>>());

        late List<Category> categories1;
        late List<Category> categories2;

        result1.fold(
          (failure) => fail('Should not return failure'),
          (categories) => categories1 = categories,
        );

        result2.fold(
          (failure) => fail('Should not return failure'),
          (categories) => categories2 = categories,
        );

        expect(categories1.length, 2);
        expect(categories2.length, 1);
        expect(categories1.first.merchandiserId, 'merch-1');
        expect(categories2.first.merchandiserId, 'merch-2');
      });

      test('should isolate data between different merchandisers', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final merch1Result = await useCase('merch-1');
        final merch2Result = await useCase('merch-2');

        // Assert
        late List<Category> merch1Categories;
        late List<Category> merch2Categories;

        merch1Result.fold(
          (failure) => fail('Should not return failure'),
          (categories) => merch1Categories = categories,
        );

        merch2Result.fold(
          (failure) => fail('Should not return failure'),
          (categories) => merch2Categories = categories,
        );

        // No overlap in categories
        final merch1Ids = merch1Categories.map((c) => c.id).toSet();
        final merch2Ids = merch2Categories.map((c) => c.id).toSet();
        expect(merch1Ids.intersection(merch2Ids).isEmpty, true);
      });
    });
  });
}
