// lib/features/shared/data/repositories/sub_category_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/sub_category.dart';
import '../../domain/repositories/sub_category_repository.dart';
import '../datasources/sub_category_remote_datasource.dart';

class SubCategoryRepositoryImpl implements SubCategoryRepository {
  final SubCategoryRemoteDataSource remoteDataSource;

  const SubCategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SubCategory>>> getSubCategories(
    String categoryId,
  ) async {
    try {
      final subCategories = await remoteDataSource.getSubCategoriesByCategoryId(
        categoryId,
      );
      return Right(subCategories);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SubCategory>> getSubCategoryById(
    String subCategoryId,
  ) async {
    try {
      final subCategory = await remoteDataSource.getSubCategoryById(
        subCategoryId,
      );
      return Right(subCategory);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SubCategory>> createSubCategory({
    required String merchandiserId,
    required String categoryId,
    required Map<String, String> name,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    try {
      final subCategoryData = {
        'merchandiser_id': merchandiserId,
        'category_id': categoryId,
        'name': name,
        'sort_order': sortOrder,
        'is_active': isActive,
      };

      final subCategory = await remoteDataSource.createSubCategory(
        subCategoryData,
      );
      return Right(subCategory);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SubCategory>> updateSubCategory({
    required String subCategoryId,
    Map<String, String>? name,
    int? sortOrder,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (sortOrder != null) updates['sort_order'] = sortOrder;

      if (updates.isEmpty) {
        return Left(ServerFailure(message: 'No fields provided for update'));
      }

      final subCategory = await remoteDataSource.updateSubCategory(
        subCategoryId,
        updates,
      );
      return Right(subCategory);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSubCategory(String subCategoryId) async {
    try {
      await remoteDataSource.deleteSubCategory(subCategoryId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
