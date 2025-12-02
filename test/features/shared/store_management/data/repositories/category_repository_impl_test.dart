// test/features/shared/data/repositories/category_repository_impl_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/category_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../datasources/fake_category_remote_datasource.dart';

void main() {
  late CategoryRepositoryImpl repository;
  late FakeCategoryRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeCategoryRemoteDataSource();
    repository = CategoryRepositoryImpl(remoteDataSource: fakeDataSource);
  });

  tearDown(() {
    fakeDataSource.clear();
  });

  group('CategoryRepositoryImpl - Admin (Read Only)', () {
    const tMerchandiserId = 'merch-1';
    const tCategoryId = 'cat-1';

    group('getCategories', () {
      test(
        'should return list of categories when call is successful',
        () async {
          // Arrange
          fakeDataSource.seedData();

          // Act
          final result = await repository.getCategories(tMerchandiserId);

          // Assert
          expect(result, isA<Right<Failure, List<Category>>>());
          result.fold((failure) => fail('Should not return failure'), (
            categories,
          ) {
            expect(categories.length, 2);
            expect(categories[0].id, 'cat-1');
            expect(categories[0].name['en'], 'Electronics');
            expect(categories[1].id, 'cat-2');
            expect(categories[1].name['en'], 'Clothing');
          });
        },
      );

      test(
        'should return empty list when no categories exist for merchandiser',
        () async {
          // Arrange
          fakeDataSource.seedData();
          const nonExistentMerchId = 'merch-999';

          // Act
          final result = await repository.getCategories(nonExistentMerchId);

          // Assert
          expect(result, isA<Right<Failure, List<Category>>>());
          result.fold(
            (failure) => fail('Should not return failure'),
            (categories) => expect(categories, isEmpty),
          );
        },
      );

      test('should return categories sorted by sort_order', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getCategories(tMerchandiserId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          categories,
        ) {
          expect(categories[0].sortOrder, 1);
          expect(categories[1].sortOrder, 2);
          // Verify they're in ascending order
          for (int i = 0; i < categories.length - 1; i++) {
            expect(
              categories[i].sortOrder <= categories[i + 1].sortOrder,
              true,
            );
          }
        });
      });

      test(
        'should return ServerFailure when data source throws exception',
        () async {
          // Arrange
          fakeDataSource.throwError('Database connection failed');

          // Act
          final result = await repository.getCategories(tMerchandiserId);

          // Assert
          expect(result, isA<Left<Failure, List<Category>>>());
          result.fold((failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Database connection failed'));
          }, (categories) => fail('Should not return categories'));
        },
      );
    });

    group('getCategoryById', () {
      test('should return category when found', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getCategoryById(tCategoryId);

        // Assert
        expect(result, isA<Right<Failure, Category>>());
        result.fold((failure) => fail('Should not return failure'), (category) {
          expect(category.id, tCategoryId);
          expect(category.name['en'], 'Electronics');
          expect(category.merchandiserId, tMerchandiserId);
        });
      });

      test('should return ServerFailure when category not found', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentId = 'cat-999';

        // Act
        final result = await repository.getCategoryById(nonExistentId);

        // Assert
        expect(result, isA<Left<Failure, Category>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Category not found');
        }, (category) => fail('Should not return category'));
      });

      test('should return ServerFailure on data source error', () async {
        // Arrange
        fakeDataSource.throwError('Network error');

        // Act
        final result = await repository.getCategoryById(tCategoryId);

        // Assert
        expect(result, isA<Left<Failure, Category>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Network error'));
        }, (category) => fail('Should not return category'));
      });
    });
  });

  group('CategoryRepositoryImpl - Merchandiser (Full CRUD)', () {
    const tMerchandiserId = 'merch-1';

    group('createCategory', () {
      test('should create and return category successfully', () async {
        // Arrange
        final nameMap = {'en': 'New Category', 'ar': 'فئة جديدة'};
        final initialCount = fakeDataSource.getCategoryCount();

        // Act
        final result = await repository.createCategory(
          merchandiserId: tMerchandiserId,
          name: nameMap,
          sortOrder: 10,
        );

        // Assert
        expect(result, isA<Right<Failure, Category>>());
        result.fold((failure) => fail('Should not return failure'), (category) {
          expect(category.name, nameMap);
          expect(category.merchandiserId, tMerchandiserId);
          expect(category.sortOrder, 10);
          expect(category.isActive, true);
          expect(fakeDataSource.getCategoryCount(), initialCount + 1);
        });
      });

      test('should create category with optional image fields', () async {
        // Arrange
        final nameMap = {'en': 'Category with Image', 'ar': 'فئة بصورة'};
        const imageThumbnail = 'https://example.com/thumb.jpg';
        const image = 'https://example.com/image.jpg';

        // Act
        final result = await repository.createCategory(
          merchandiserId: tMerchandiserId,
          name: nameMap,
          imageThumbnail: imageThumbnail,
          image: image,
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (category) {
          expect(category.imageThumbnail, imageThumbnail);
          expect(category.image, image);
        });
      });

      test('should return ServerFailure on creation error', () async {
        // Arrange
        fakeDataSource.throwError('Insert failed');
        final nameMap = {'en': 'New Category', 'ar': 'فئة جديدة'};

        // Act
        final result = await repository.createCategory(
          merchandiserId: tMerchandiserId,
          name: nameMap,
        );

        // Assert
        expect(result, isA<Left<Failure, Category>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Insert failed'));
        }, (category) => fail('Should not return category'));
      });
    });

    group('updateCategory', () {
      test('should update category name successfully', () async {
        // Arrange
        fakeDataSource.seedData();
        const categoryId = 'cat-1';
        final newName = {'en': 'Updated Electronics', 'ar': 'إلكترونيات محدثة'};

        // Act
        final result = await repository.updateCategory(
          categoryId: categoryId,
          name: newName,
        );

        // Assert
        expect(result, isA<Right<Failure, Category>>());
        result.fold((failure) => fail('Should not return failure'), (category) {
          expect(category.id, categoryId);
          expect(category.name, newName);
        });
      });

      test('should update category status (isActive)', () async {
        // Arrange
        fakeDataSource.seedData();
        const categoryId = 'cat-1';

        // Act
        final result = await repository.updateCategory(
          categoryId: categoryId,
          isActive: false,
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (category) {
          expect(category.id, categoryId);
          expect(category.isActive, false);
        });
      });

      test('should update multiple fields at once', () async {
        // Arrange
        fakeDataSource.seedData();
        const categoryId = 'cat-1';
        final newName = {'en': 'Super Electronics', 'ar': 'إلكترونيات سوبر'};
        const newImage = 'https://example.com/new-image.jpg';
        const newSortOrder = 5;

        // Act
        final result = await repository.updateCategory(
          categoryId: categoryId,
          name: newName,
          image: newImage,
          sortOrder: newSortOrder,
          isActive: false,
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (category) {
          expect(category.name, newName);
          expect(category.image, newImage);
          expect(category.sortOrder, newSortOrder);
          expect(category.isActive, false);
        });
      });

      test('should return ServerFailure when category not found', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentId = 'cat-999';

        // Act
        final result = await repository.updateCategory(
          categoryId: nonExistentId,
          isActive: false,
        );

        // Assert
        expect(result, isA<Left<Failure, Category>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Category not found');
        }, (category) => fail('Should not return category'));
      });

      test('should return ServerFailure on update error', () async {
        // Arrange
        fakeDataSource.seedData();
        fakeDataSource.throwError('Update failed');
        const categoryId = 'cat-1';

        // Act
        final result = await repository.updateCategory(
          categoryId: categoryId,
          isActive: false,
        );

        // Assert
        expect(result, isA<Left<Failure, Category>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Update failed'));
        }, (category) => fail('Should not return category'));
      });
    });

    group('deleteCategory', () {
      test('should delete category successfully', () async {
        // Arrange
        fakeDataSource.seedData();
        // Create a category with no sub-categories
        final createResult = await repository.createCategory(
          merchandiserId: tMerchandiserId,
          name: {'en': 'Temp Category', 'ar': 'فئة مؤقتة'},
        );

        String? categoryId;
        createResult.fold(
          (failure) => fail('Failed to create category'),
          (category) => categoryId = category.id,
        );

        final initialCount = fakeDataSource.getCategoryCount();

        // Act
        final result = await repository.deleteCategory(categoryId!);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        result.fold((failure) => fail('Should not return failure'), (_) {
          expect(fakeDataSource.getCategoryCount(), initialCount - 1);
          expect(fakeDataSource.categoryExists(categoryId!), false);
        });
      });

      test(
        'should return ServerFailure when category has sub-categories',
        () async {
          // Arrange
          fakeDataSource.seedData();
          // cat-1 has sub-categories (subCategoryCount > 0)
          const categoryId = 'cat-1';

          // Act
          final result = await repository.deleteCategory(categoryId);

          // Assert
          expect(result, isA<Left<Failure, void>>());
          result.fold((failure) {
            expect(failure, isA<ServerFailure>());
            expect(
              failure.message,
              contains('Cannot delete category with existing sub-categories'),
            );
          }, (_) => fail('Should not delete category with dependencies'));
        },
      );

      test('should return ServerFailure when category not found', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentId = 'cat-999';

        // Act
        final result = await repository.deleteCategory(nonExistentId);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Category not found');
        }, (_) => fail('Should not succeed'));
      });

      test('should return ServerFailure on deletion error', () async {
        // Arrange
        fakeDataSource.seedData();
        fakeDataSource.throwError('Delete operation failed');
        const categoryId = 'cat-1';

        // Act
        final result = await repository.deleteCategory(categoryId);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Delete operation failed'));
        }, (_) => fail('Should not succeed'));
      });
    });
  });
}
