import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  final String merchandiserId;

  const LoadCategories(this.merchandiserId);

  @override
  List<Object> get props => [merchandiserId];
}

class CreateCategory extends CategoryEvent {
  final String merchandiserId;
  final Map<String, String> name;
  final String? imageThumbnail;
  final String? image;

  const CreateCategory({
    required this.merchandiserId,
    required this.name,
    this.imageThumbnail,
    this.image,
  });

  @override
  List<Object?> get props => [merchandiserId, name, imageThumbnail, image];
}

class UpdateCategory extends CategoryEvent {
  final String merchandiserId;
  final String categoryId;
  final Map<String, String>? name;
  final String? imageThumbnail;
  final String? image;
  final bool? isActive;

  const UpdateCategory({
    required this.merchandiserId,
    required this.categoryId,
    this.name,
    this.imageThumbnail,
    this.image,
    this.isActive,
  });

  @override
  List<Object?> get props => [
    categoryId,
    name,
    imageThumbnail,
    image,
    isActive,
  ];
}

class DeleteCategory extends CategoryEvent {
  final String merchandiserId;
  final String categoryId;

  const DeleteCategory({
    required this.categoryId,
    required this.merchandiserId,
  });

  @override
  List<Object> get props => [categoryId];
}
