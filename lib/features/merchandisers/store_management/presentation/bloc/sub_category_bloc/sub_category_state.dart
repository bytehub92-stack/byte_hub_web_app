import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:equatable/equatable.dart';

abstract class SubCategoryState extends Equatable {
  const SubCategoryState();

  @override
  List<Object?> get props => [];
}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryLoading extends SubCategoryState {}

class SubCategoriesLoaded extends SubCategoryState {
  final List<SubCategory> subCategories;

  const SubCategoriesLoaded(this.subCategories);

  @override
  List<Object> get props => [subCategories];
}

class SubCategoryOperationSuccess extends SubCategoryState {
  final String message;

  const SubCategoryOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class SubCategoryError extends SubCategoryState {
  final String message;

  const SubCategoryError(this.message);

  @override
  List<Object> get props => [message];
}
