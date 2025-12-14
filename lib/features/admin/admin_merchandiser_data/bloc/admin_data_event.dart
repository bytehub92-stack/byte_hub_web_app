import 'package:equatable/equatable.dart';

abstract class AdminDataEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminLoadCategories extends AdminDataEvent {
  final String merchandiserId;
  AdminLoadCategories({required this.merchandiserId});

  @override
  List<Object> get props => [merchandiserId];
}

class AdminLoadSubCategories extends AdminDataEvent {
  final String categoryId;

  AdminLoadSubCategories({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}

class AdminLoadProducts extends AdminDataEvent {
  final String subCategoryId;
  final int page;
  final int limit;
  final String? searchQuery;
  final String? sortBy;

  AdminLoadProducts({
    required this.subCategoryId,
    this.page = 1,
    this.limit = 20,
    this.searchQuery,
    this.sortBy,
  });

  @override
  List<Object?> get props => [subCategoryId, page, searchQuery, sortBy];
}

class AdminLoadMoreProducts extends AdminDataEvent {}

class AdminSearchProducts extends AdminDataEvent {
  final String query;

  AdminSearchProducts({required this.query});

  @override
  List<Object> get props => [query];
}

class AdminSortProducts extends AdminDataEvent {
  final String sortBy;

  AdminSortProducts({required this.sortBy});

  @override
  List<Object> get props => [sortBy];
}
