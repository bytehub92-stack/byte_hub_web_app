import 'package:equatable/equatable.dart';

abstract class MerchandiserDataEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminLoadCategories extends MerchandiserDataEvent {
  final String merchandiserId;
  AdminLoadCategories({required this.merchandiserId});

  @override
  List<Object> get props => [merchandiserId];
}

class AdminLoadSubCategories extends MerchandiserDataEvent {
  final String categoryId;

  AdminLoadSubCategories({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}

class AdminLoadProducts extends MerchandiserDataEvent {
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

class AdminLoadMoreProducts extends MerchandiserDataEvent {}

class AdminSearchProducts extends MerchandiserDataEvent {
  final String query;

  AdminSearchProducts({required this.query});

  @override
  List<Object> get props => [query];
}

class AdminSortProducts extends MerchandiserDataEvent {
  final String sortBy;

  AdminSortProducts({required this.sortBy});

  @override
  List<Object> get props => [sortBy];
}
