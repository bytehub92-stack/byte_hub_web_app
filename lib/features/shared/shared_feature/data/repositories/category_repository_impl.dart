import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  const CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Category>>> getCategories(
    String merchandiserId,
  ) async {
    try {
      final categories = await remoteDataSource.getCategories(merchandiserId);
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(String categoryId) async {
    try {
      final category = await remoteDataSource.getCategoryById(categoryId);
      return Right(category);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory({
    required String merchandiserId,
    required Map<String, String> name,
    String? imageThumbnail,
    String? image,
    int sortOrder = 0,
  }) async {
    try {
      // Generate category ID
      final categoryId = const Uuid().v4();

      final category = await remoteDataSource.createCategory(
        categoryId: categoryId,
        merchandiserId: merchandiserId,
        name: name,
        imageThumbnail: imageThumbnail,
        image: image,
        sortOrder: sortOrder,
      );
      return Right(category);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory({
    required String categoryId,
    Map<String, String>? name,
    String? imageThumbnail,
    String? image,
    int? sortOrder,
    bool? isActive,
  }) async {
    try {
      final category = await remoteDataSource.updateCategory(
        categoryId: categoryId,
        name: name,
        imageThumbnail: imageThumbnail,
        image: image,
        sortOrder: sortOrder,
        isActive: isActive,
      );
      return Right(category);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    try {
      await remoteDataSource.deleteCategory(categoryId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
