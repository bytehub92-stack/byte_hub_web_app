import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';

abstract class AdminDataState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MerchandiserDataStateInitial extends AdminDataState {}

class CategoriesLoading extends AdminDataState {}

class CategoriesLoaded extends AdminDataState {
  final List<Category> categories;

  CategoriesLoaded({
    required this.categories,
  });

  @override
  List<Object> get props => [categories];
}

class SubCategoriesLoading extends AdminDataState {}

class SubCategoriesLoaded extends AdminDataState {
  final List<SubCategory> subCategories;
  final String selectedSubCategoryId;

  SubCategoriesLoaded({
    required this.subCategories,
    required this.selectedSubCategoryId,
  });

  @override
  List<Object> get props => [subCategories, selectedSubCategoryId];
}

class ProductsLoading extends AdminDataState {}

class ProductsLoaded extends AdminDataState {
  final List<SubCategory> subCategories;
  final String selectedSubCategoryId;
  final List<Product> products;
  final bool hasMore;
  final int currentPage;
  final String? currentSearchQuery;
  final String? currentSortBy;

  ProductsLoaded({
    required this.subCategories,
    required this.selectedSubCategoryId,
    required this.products,
    required this.hasMore,
    required this.currentPage,
    this.currentSearchQuery,
    this.currentSortBy,
  });

  @override
  List<Object?> get props => [
        subCategories,
        selectedSubCategoryId,
        products,
        hasMore,
        currentPage,
        currentSearchQuery,
        currentSortBy,
      ];
}

class ProductsLoadingMore extends AdminDataState {
  final List<SubCategory> subCategories;
  final String selectedSubCategoryId;
  final List<Product> products;
  final String? currentSearchQuery;
  final String? currentSortBy;

  ProductsLoadingMore({
    required this.subCategories,
    required this.selectedSubCategoryId,
    required this.products,
    this.currentSearchQuery,
    this.currentSortBy,
  });

  @override
  List<Object?> get props => [
        subCategories,
        selectedSubCategoryId,
        products,
        currentSearchQuery,
        currentSortBy,
      ];
}

class MerchandiserDataStateError extends AdminDataState {
  final String message;

  MerchandiserDataStateError({required this.message});

  @override
  List<Object> get props => [message];
}
