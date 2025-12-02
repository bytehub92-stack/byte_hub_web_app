import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:equatable/equatable.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<Category> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class CategoryOperationSuccess extends CategoryState {
  final String message;

  const CategoryOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}
