// test/features/shared/data/repositories/sub_category_repository_impl_test.dart

import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/sub_category_repositoy_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fake_datasources/fake_sub_category_remote_datasource.dart';

void main() {
  late SubCategoryRepositoryImpl repository;
  late FakeSubCategoryRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeSubCategoryRemoteDataSource();
    repository = SubCategoryRepositoryImpl(remoteDataSource: fakeDataSource);
  });

  tearDown(() {
    fakeDataSource.clear();
  });

  group('SubCategoryRepositoryImpl - Admin (Read Only)', () {
    const tCategoryId = 'cat-1';
    const tSubCategoryId = 'sub-1';

    group('getSubCategories', () {
      test('should return list of sub-categories for category', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getSubCategories(tCategoryId);

        // Assert
        expect(result, isA<Right<Failure, List<SubCategory>>>());
        result.fold((failure) => fail('Should not return failure'), (
          subCategories,
        ) {
          expect(subCategories.length, 2);
          expect(subCategories[0].id, 'sub-1');
          expect(subCategories[0].name['en'], 'Smartphones');
          expect(subCategories[1].id, 'sub-2');
          expect(subCategories[1].name['en'], 'Laptops');
        });
      });

      test('should return empty list when no sub-categories exist', () async {
        // Arrange
        fakeDataSource.seedData();
        const categoryWithNoSubs = 'cat-999';

        // Act
        final result = await repository.getSubCategories(categoryWithNoSubs);

        // Assert
        result.fold(
          (failure) => fail('Should not return failure'),
          (subCategories) => expect(subCategories, isEmpty),
        );
      });

      test('should return sub-categories sorted by sort_order', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getSubCategories(tCategoryId);

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          subCategories,
        ) {
          for (int i = 0; i < subCategories.length - 1; i++) {
            expect(
              subCategories[i].sortOrder <= subCategories[i + 1].sortOrder,
              true,
            );
          }
        });
      });

      test('should return ServerFailure on data source error', () async {
        // Arrange
        fakeDataSource.throwError('Database error');

        // Act
        final result = await repository.getSubCategories(tCategoryId);

        // Assert
        expect(result, isA<Left<Failure, List<SubCategory>>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Database error'));
        }, (subCategories) => fail('Should not return sub-categories'));
      });
    });

    group('getSubCategoryById', () {
      test('should return sub-category when found', () async {
        // Arrange
        fakeDataSource.seedData();

        // Act
        final result = await repository.getSubCategoryById(tSubCategoryId);

        // Assert
        expect(result, isA<Right<Failure, SubCategory>>());
        result.fold((failure) => fail('Should not return failure'), (
          subCategory,
        ) {
          expect(subCategory.id, tSubCategoryId);
          expect(subCategory.name['en'], 'Smartphones');
          expect(subCategory.categoryId, tCategoryId);
        });
      });

      test('should return ServerFailure when sub-category not found', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentId = 'sub-999';

        // Act
        final result = await repository.getSubCategoryById(nonExistentId);

        // Assert
        expect(result, isA<Left<Failure, SubCategory>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Sub-category not found');
        }, (subCategory) => fail('Should not return sub-category'));
      });

      test('should return ServerFailure on data source error', () async {
        // Arrange
        fakeDataSource.throwError('Network timeout');

        // Act
        final result = await repository.getSubCategoryById(tSubCategoryId);

        // Assert
        expect(result, isA<Left<Failure, SubCategory>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Network timeout'));
        }, (subCategory) => fail('Should not return sub-category'));
      });
    });
  });

  group('SubCategoryRepositoryImpl - Merchandiser (Full CRUD)', () {
    const tMerchandiserId = 'merch-1';
    const tCategoryId = 'cat-1';

    group('createSubCategory', () {
      test('should create and return sub-category successfully', () async {
        // Arrange
        final nameMap = {'en': 'Tablets', 'ar': 'أجهزة لوحية'};
        final initialCount = fakeDataSource.getSubCategoryCount();

        // Act
        final result = await repository.createSubCategory(
          merchandiserId: tMerchandiserId,
          categoryId: tCategoryId,
          name: nameMap,
          sortOrder: 3,
        );

        // Assert
        expect(result, isA<Right<Failure, SubCategory>>());
        result.fold((failure) => fail('Should not return failure'), (
          subCategory,
        ) {
          expect(subCategory.name, nameMap);
          expect(subCategory.merchandiserId, tMerchandiserId);
          expect(subCategory.categoryId, tCategoryId);
          expect(subCategory.sortOrder, 3);
          expect(subCategory.isActive, true);
          expect(fakeDataSource.getSubCategoryCount(), initialCount + 1);
        });
      });

      test('should create sub-category with default values', () async {
        // Arrange
        final nameMap = {'en': 'Accessories', 'ar': 'إكسسوارات'};

        // Act
        final result = await repository.createSubCategory(
          merchandiserId: tMerchandiserId,
          categoryId: tCategoryId,
          name: nameMap,
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          subCategory,
        ) {
          expect(subCategory.sortOrder, 0);
          expect(subCategory.isActive, true);
          expect(subCategory.productCount, 0);
        });
      });

      test('should return ServerFailure on creation error', () async {
        // Arrange
        fakeDataSource.throwError('Insert constraint violation');
        final nameMap = {'en': 'New Sub-Category', 'ar': 'فئة فرعية جديدة'};

        // Act
        final result = await repository.createSubCategory(
          merchandiserId: tMerchandiserId,
          categoryId: tCategoryId,
          name: nameMap,
        );

        // Assert
        expect(result, isA<Left<Failure, SubCategory>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Insert constraint violation'));
        }, (subCategory) => fail('Should not return sub-category'));
      });
    });

    group('updateSubCategory', () {
      test('should update sub-category name successfully', () async {
        // Arrange
        fakeDataSource.seedData();
        const subCategoryId = 'sub-1';
        final newName = {'en': 'Smart Phones', 'ar': 'هواتف ذكية محدثة'};

        // Act
        final result = await repository.updateSubCategory(
          subCategoryId: subCategoryId,
          name: newName,
        );

        // Assert
        expect(result, isA<Right<Failure, SubCategory>>());
        result.fold((failure) => fail('Should not return failure'), (
          subCategory,
        ) {
          expect(subCategory.id, subCategoryId);
          expect(subCategory.name, newName);
        });
      });

      test('should update sub-category sort order', () async {
        // Arrange
        fakeDataSource.seedData();
        const subCategoryId = 'sub-1';
        const newSortOrder = 10;

        // Act
        final result = await repository.updateSubCategory(
          subCategoryId: subCategoryId,
          sortOrder: newSortOrder,
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          subCategory,
        ) {
          expect(subCategory.id, subCategoryId);
          expect(subCategory.sortOrder, newSortOrder);
        });
      });

      test('should update multiple fields at once', () async {
        // Arrange
        fakeDataSource.seedData();
        const subCategoryId = 'sub-1';
        final newName = {'en': 'Mobile Phones', 'ar': 'هواتف محمولة'};
        const newSortOrder = 5;

        // Act
        final result = await repository.updateSubCategory(
          subCategoryId: subCategoryId,
          name: newName,
          sortOrder: newSortOrder,
        );

        // Assert
        result.fold((failure) => fail('Should not return failure'), (
          subCategory,
        ) {
          expect(subCategory.name, newName);
          expect(subCategory.sortOrder, newSortOrder);
        });
      });

      test('should return ServerFailure when no fields provided', () async {
        // Arrange
        fakeDataSource.seedData();
        const subCategoryId = 'sub-1';

        // Act
        final result = await repository.updateSubCategory(
          subCategoryId: subCategoryId,
        );

        // Assert
        expect(result, isA<Left<Failure, SubCategory>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('No fields provided for update'));
        }, (subCategory) => fail('Should not return sub-category'));
      });

      test('should return ServerFailure when sub-category not found', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentId = 'sub-999';

        // Act
        final result = await repository.updateSubCategory(
          subCategoryId: nonExistentId,
          sortOrder: 5,
        );

        // Assert
        expect(result, isA<Left<Failure, SubCategory>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Sub-category not found');
        }, (subCategory) => fail('Should not return sub-category'));
      });

      test('should return ServerFailure on update error', () async {
        // Arrange
        fakeDataSource.seedData();
        fakeDataSource.throwError('Update failed');
        const subCategoryId = 'sub-1';

        // Act
        final result = await repository.updateSubCategory(
          subCategoryId: subCategoryId,
          sortOrder: 5,
        );

        // Assert
        expect(result, isA<Left<Failure, SubCategory>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Update failed'));
        }, (subCategory) => fail('Should not return sub-category'));
      });
    });

    group('deleteSubCategory', () {
      test(
        'should delete sub-category successfully when no products exist',
        () async {
          // Arrange
          fakeDataSource.seedData();
          // Create a sub-category with no products
          final createResult = await repository.createSubCategory(
            merchandiserId: tMerchandiserId,
            categoryId: tCategoryId,
            name: {'en': 'Temp Sub-Category', 'ar': 'فئة فرعية مؤقتة'},
          );

          String? subCategoryId;
          createResult.fold(
            (failure) => fail('Failed to create sub-category'),
            (subCategory) => subCategoryId = subCategory.id,
          );

          final initialCount = fakeDataSource.getSubCategoryCount();

          // Act
          final result = await repository.deleteSubCategory(subCategoryId!);

          // Assert
          expect(result, isA<Right<Failure, void>>());
          result.fold((failure) => fail('Should not return failure'), (_) {
            expect(fakeDataSource.getSubCategoryCount(), initialCount - 1);
            expect(fakeDataSource.subCategoryExists(subCategoryId!), false);
          });
        },
      );

      test(
        'should return ServerFailure when sub-category has products',
        () async {
          // Arrange
          fakeDataSource.seedData();
          // sub-1 has products (productCount > 0)
          const subCategoryId = 'sub-1';

          // Act
          final result = await repository.deleteSubCategory(subCategoryId);

          // Assert
          expect(result, isA<Left<Failure, void>>());
          result.fold((failure) {
            expect(failure, isA<ServerFailure>());
            expect(
              failure.message,
              contains('Cannot delete sub-category with existing products'),
            );
          }, (_) => fail('Should not delete sub-category with dependencies'));
        },
      );

      test('should return ServerFailure when sub-category not found', () async {
        // Arrange
        fakeDataSource.seedData();
        const nonExistentId = 'sub-999';

        // Act
        final result = await repository.deleteSubCategory(nonExistentId);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Sub-category not found');
        }, (_) => fail('Should not succeed'));
      });

      test('should return ServerFailure on deletion error', () async {
        // Arrange
        fakeDataSource.seedData();
        fakeDataSource.throwError('Database lock timeout');
        const subCategoryId = 'sub-1';

        // Act
        final result = await repository.deleteSubCategory(subCategoryId);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Database lock timeout'));
        }, (_) => fail('Should not succeed'));
      });
    });
  });
}
