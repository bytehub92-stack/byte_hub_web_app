import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/product/create_product_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/product/delete_product_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/product/update_product_usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_products_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsBySubCategoryUsecase getProducts;
  final CreateProductUsecase createProduct;
  final UpdateProductUsecase updateProduct;
  final DeleteProductUsecase deleteProduct;

  ProductBloc({
    required this.getProducts,
    required this.createProduct,
    required this.updateProduct,
    required this.deleteProduct,
  }) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final params = GetProductsParams(
      subCategoryId: event.subCategoryId,
      page: event.page,
      limit: event.limit,
      searchQuery: event.searchQuery,
      sortBy: event.sortBy,
    );

    final result = await getProducts(params);

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final params = CreateProductParams(
      merchandiserId: event.merchandiserId,
      categoryId: event.categoryId,
      subCategoryId: event.subCategoryId,
      name: event.name,
      description: event.description,
      price: event.price,
      images: event.images,
      stockQuantity: event.stockQuantity,
      unitOfMeasurementId: event.unitOfMeasurementId, // NEW
      sku: event.sku,
      isAvailable: event.isAvailable,
      isFeatured: event.isFeatured,
      discountPrice: event.discountPrice,
      discountStartDate: event.discountStartDate,
      discountEndDate: event.discountEndDate,
      costPrice: event.costPrice,
      weight: event.weight,
      tags: event.tags,
    );

    final result = await createProduct(params);

    result.fold((failure) => emit(ProductError(failure.message)), (product) {
      emit(const ProductOperationSuccess('Product created successfully'));
      add(LoadProducts(subCategoryId: event.subCategoryId));
    });
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final params = UpdateProductParams(
      productId: event.productId,
      name: event.name,
      description: event.description,
      price: event.price,
      images: event.images,
      stockQuantity: event.stockQuantity,
      unitOfMeasurementId: event.unitOfMeasurementId, // NEW
      sku: event.sku,
      isAvailable: event.isAvailable,
      isFeatured: event.isFeatured,
      discountPrice: event.discountPrice,
      discountStartDate: event.discountStartDate,
      discountEndDate: event.discountEndDate,
      costPrice: event.costPrice,
      weight: event.weight,
      tags: event.tags,
    );

    final result = await updateProduct(params);

    result.fold((failure) => emit(ProductError(failure.message)), (product) {
      emit(const ProductOperationSuccess('Product updated successfully'));
      add(LoadProducts(subCategoryId: event.subCategoryId));
    });
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await deleteProduct(event.productId);

    result.fold((failure) => emit(ProductError(failure.message)), (_) {
      emit(const ProductOperationSuccess('Product deleted successfully'));
      add(LoadProducts(subCategoryId: event.subCategoryId));
    });
  }
}
