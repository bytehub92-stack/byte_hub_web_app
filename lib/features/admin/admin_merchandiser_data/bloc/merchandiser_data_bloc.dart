import 'package:admin_panel/features/admin/admin_merchandiser_data/bloc/merchandiser_data_event.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_data/bloc/merchandiser_data_states.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_categories_usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_products_usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_sub_categories_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MerchandiserDataBloc
    extends Bloc<MerchandiserDataEvent, MerchandiserDataState> {
  final GetCategoriesByMerchandiserIdUseCase
      getCategoriesByMerchandiserIdUseCase;
  final GetSubCategoriesByCategoryId getSubCategoriesByCategoryId;
  final GetProductsBySubCategoryUsecase getProductsBySubCategoryUsecase;

  MerchandiserDataBloc({
    required this.getCategoriesByMerchandiserIdUseCase,
    required this.getSubCategoriesByCategoryId,
    required this.getProductsBySubCategoryUsecase,
  }) : super(MerchandiserDataStateInitial()) {
    on<AdminLoadCategories>(_onAdminLoadCategories);
    on<AdminLoadSubCategories>(_onLoadSubCategories);
    on<AdminLoadProducts>(_onLoadProducts);
    on<AdminLoadMoreProducts>(_onLoadMoreProducts);
    on<AdminSearchProducts>(_onSearchProducts);
    on<AdminSortProducts>(_onSortProducts);
  }

  Future<void> _onAdminLoadCategories(
    AdminLoadCategories event,
    Emitter<MerchandiserDataState> emit,
  ) async {
    emit(CategoriesLoading());
    final result =
        await getCategoriesByMerchandiserIdUseCase(event.merchandiserId);

    result.fold(
        (failure) => emit(MerchandiserDataStateError(message: failure.message)),
        (categories) {
      if (categories.isEmpty) {
        emit(CategoriesLoaded(categories: []));
      } else {
        emit(CategoriesLoaded(categories: categories));
      }
    });
  }

  Future<void> _onLoadSubCategories(
    AdminLoadSubCategories event,
    Emitter<MerchandiserDataState> emit,
  ) async {
    emit(SubCategoriesLoading());

    final result = await getSubCategoriesByCategoryId(event.categoryId);

    result.fold(
      (failure) => emit(MerchandiserDataStateError(message: failure.message)),
      (subCategories) {
        if (subCategories.isEmpty) {
          emit(
            SubCategoriesLoaded(subCategories: [], selectedSubCategoryId: ''),
          );
        } else {
          emit(
            SubCategoriesLoaded(
              subCategories: subCategories,
              selectedSubCategoryId: subCategories.first.id,
            ),
          );
        }
      },
    );
  }

  Future<void> _onLoadProducts(
    AdminLoadProducts event,
    Emitter<MerchandiserDataState> emit,
  ) async {
    // Get current sub-categories from state
    List<SubCategory> subCategories = [];
    if (state is SubCategoriesLoaded) {
      subCategories = (state as SubCategoriesLoaded).subCategories;
    } else if (state is ProductsLoaded) {
      subCategories = (state as ProductsLoaded).subCategories;
    }

    final params = GetProductsParams(
      subCategoryId: event.subCategoryId,
      page: event.page,
      limit: event.limit,
      searchQuery: event.searchQuery,
      sortBy: event.sortBy,
    );

    try {
      emit(ProductsLoading());
      final result = await getProductsBySubCategoryUsecase(params);

      result.fold(
        (failure) {
          emit(MerchandiserDataStateError(message: failure.message));
        },
        (products) {
          emit(
            ProductsLoaded(
              subCategories: subCategories,
              selectedSubCategoryId: event.subCategoryId,
              products: products,
              hasMore: products.length >= event.limit,
              currentPage: event.page,
              currentSearchQuery: event.searchQuery,
              currentSortBy: event.sortBy,
            ),
          );
        },
      );
    } catch (e) {
      emit(MerchandiserDataStateError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreProducts(
    AdminLoadMoreProducts event,
    Emitter<MerchandiserDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductsLoaded || !currentState.hasMore) {
      return;
    }

    emit(
      ProductsLoadingMore(
        subCategories: currentState.subCategories,
        selectedSubCategoryId: currentState.selectedSubCategoryId,
        products: currentState.products,
        currentSearchQuery: currentState.currentSearchQuery,
        currentSortBy: currentState.currentSortBy,
      ),
    );

    final params = GetProductsParams(
      subCategoryId: currentState.selectedSubCategoryId,
      page: currentState.currentPage + 1,
      limit: 20,
      searchQuery: currentState.currentSearchQuery,
      sortBy: currentState.currentSortBy,
    );

    try {
      final result = await getProductsBySubCategoryUsecase(params);

      result.fold(
        (failure) {
          emit(MerchandiserDataStateError(message: failure.message));
        },
        (moreProducts) {
          emit(
            ProductsLoaded(
              subCategories: currentState.subCategories,
              selectedSubCategoryId: currentState.selectedSubCategoryId,
              products: [...currentState.products, ...moreProducts],
              hasMore: moreProducts.length >= 20,
              currentPage: currentState.currentPage + 1,
              currentSearchQuery: currentState.currentSearchQuery,
              currentSortBy: currentState.currentSortBy,
            ),
          );
        },
      );
    } catch (e) {
      emit(MerchandiserDataStateError(message: e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    AdminSearchProducts event,
    Emitter<MerchandiserDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductsLoaded) return;
    add(
      AdminLoadProducts(
        subCategoryId: currentState.selectedSubCategoryId,
        searchQuery: event.query,
        sortBy: currentState.currentSortBy,
      ),
    );
  }

  Future<void> _onSortProducts(
    AdminSortProducts event,
    Emitter<MerchandiserDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductsLoaded) return;

    add(
      AdminLoadProducts(
        subCategoryId: currentState.selectedSubCategoryId,
        searchQuery: currentState.currentSearchQuery,
        sortBy: event.sortBy,
      ),
    );
  }
}
