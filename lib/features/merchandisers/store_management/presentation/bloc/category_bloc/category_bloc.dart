import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/category/create_category_usecase.dart';
import '../../../domain/usecases/category/update_category_usecase.dart';
import '../../../domain/usecases/category/delete_category_usecase.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesByMerchandiserIdUseCase getCategoriesUseCase;
  final CreateCategoryUseCase createCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await getCategoriesUseCase(event.merchandiserId);

    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final params = CreateCategoryParams(
      merchandiserId: event.merchandiserId,
      name: event.name,
      imageThumbnail: event.imageThumbnail,
      image: event.image,
    );

    final result = await createCategoryUseCase(params);

    result.fold((failure) => emit(CategoryError(failure.message)), (category) {
      emit(const CategoryOperationSuccess('Category created successfully'));
      // Reload categories
      add(LoadCategories(event.merchandiserId));
    });
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final params = UpdateCategoryParams(
      categoryId: event.categoryId,
      name: event.name,
      imageThumbnail: event.imageThumbnail,
      image: event.image,
      isActive: event.isActive,
    );

    final result = await updateCategoryUseCase(params);

    result.fold((failure) => emit(CategoryError(failure.message)), (category) {
      emit(const CategoryOperationSuccess('Category updated successfully'));
      add(LoadCategories(event.merchandiserId));
    });
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await deleteCategoryUseCase(event.categoryId);

    result.fold((failure) => emit(CategoryError(failure.message)), (_) {
      emit(const CategoryOperationSuccess('Category deleted successfully'));
      add(LoadCategories(event.merchandiserId));
    });
  }
}
