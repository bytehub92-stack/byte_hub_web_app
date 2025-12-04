import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/sub_category/create_sub_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/sub_category/delete_sub_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/sub_category/update_sub_category_usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_sub_categories_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sub_category_event.dart';
import 'sub_category_state.dart';

class SubCategoryBloc extends Bloc<SubCategoryEvent, SubCategoryState> {
  final GetSubCategoriesByCategoryId getSubCategoriesByCategoryId;
  final CreateSubCategoryUsecase createSubCategory;
  final UpdateSubCategoryUsecase updateSubCategory;
  final DeleteSubCategoryUsecase deleteSubCategory;

  SubCategoryBloc({
    required this.getSubCategoriesByCategoryId,
    required this.createSubCategory,
    required this.updateSubCategory,
    required this.deleteSubCategory,
  }) : super(SubCategoryInitial()) {
    on<LoadSubCategories>(_onLoadSubCategories);
    on<CreateSubCategory>(_onCreateSubCategory);
    on<UpdateSubCategory>(_onUpdateSubCategory);
    on<DeleteSubCategory>(_onDeleteSubCategory);
  }

  Future<void> _onLoadSubCategories(
    LoadSubCategories event,
    Emitter<SubCategoryState> emit,
  ) async {
    emit(SubCategoryLoading());

    final result = await getSubCategoriesByCategoryId(event.categoryId);

    result.fold(
      (failure) => emit(SubCategoryError(failure.message)),
      (subCategories) => emit(SubCategoriesLoaded(subCategories)),
    );
  }

  Future<void> _onCreateSubCategory(
    CreateSubCategory event,
    Emitter<SubCategoryState> emit,
  ) async {
    emit(SubCategoryLoading());

    final params = CreateSubCategoryParams(
      merchandiserId: event.merchandiserId,
      categoryId: event.categoryId,
      name: event.name,
    );

    final result = await createSubCategory.call(params);

    result.fold((failure) => emit(SubCategoryError(failure.message)), (
      category,
    ) {
      emit(
        const SubCategoryOperationSuccess('Sub Category created successfully'),
      );
      // Reload Sub categories
      add(LoadSubCategories(event.categoryId));
    });
  }

  Future<void> _onUpdateSubCategory(
    UpdateSubCategory event,
    Emitter<SubCategoryState> emit,
  ) async {
    emit(SubCategoryLoading());

    final result = await updateSubCategory.call(
      subCategoryId: event.subCategoryId,
      name: event.name,
    );

    result.fold((failure) => emit(SubCategoryError(failure.message)), (
      category,
    ) {
      emit(
        const SubCategoryOperationSuccess('Sub-Category updated successfully'),
      );
      add(LoadSubCategories(event.categoryId));
    });
  }

  Future<void> _onDeleteSubCategory(
    DeleteSubCategory event,
    Emitter<SubCategoryState> emit,
  ) async {
    emit(SubCategoryLoading());

    final result = await deleteSubCategory.call(event.subCategoryId);

    result.fold((failure) => emit(SubCategoryError(failure.message)), (_) {
      emit(
        const SubCategoryOperationSuccess('Sub-Category deleted successfully'),
      );
      add(LoadSubCategories(event.categoryId));
    });
  }
}
