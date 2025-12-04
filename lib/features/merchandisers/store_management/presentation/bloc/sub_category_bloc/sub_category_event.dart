import 'package:equatable/equatable.dart';

abstract class SubCategoryEvent extends Equatable {
  const SubCategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubCategories extends SubCategoryEvent {
  final String categoryId;

  const LoadSubCategories(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class CreateSubCategory extends SubCategoryEvent {
  final String merchandiserId;
  final String categoryId;
  final Map<String, String> name;

  const CreateSubCategory({
    required this.merchandiserId,
    required this.categoryId,
    required this.name,
  });

  @override
  List<Object?> get props => [merchandiserId, name, categoryId];
}

class UpdateSubCategory extends SubCategoryEvent {
  final String subCategoryId;
  final String categoryId;
  final Map<String, String>? name;

  const UpdateSubCategory({
    required this.subCategoryId,
    required this.categoryId,
    this.name,
  });

  @override
  List<Object?> get props => [subCategoryId, name];
}

class DeleteSubCategory extends SubCategoryEvent {
  final String subCategoryId;
  final String categoryId;

  const DeleteSubCategory({
    required this.subCategoryId,
    required this.categoryId,
  });

  @override
  List<Object> get props => [subCategoryId];
}
