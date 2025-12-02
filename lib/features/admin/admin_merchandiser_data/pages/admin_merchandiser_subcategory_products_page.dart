import 'package:admin_panel/core/helpers/localization_helper.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_data/bloc/merchandiser_data_bloc.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_data/bloc/merchandiser_data_event.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_data/bloc/merchandiser_data_states.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_data/widgets/products_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminMerchandiserSubcategoryProductsPage extends StatefulWidget {
  final String merchandiserId;
  final String merchandiserName;
  final Category category;

  const AdminMerchandiserSubcategoryProductsPage({
    super.key,
    required this.merchandiserId,
    required this.merchandiserName,
    required this.category,
  });

  @override
  State<AdminMerchandiserSubcategoryProductsPage> createState() =>
      _AdminMerchandiserSubcategoryProductsPageState();
}

class _AdminMerchandiserSubcategoryProductsPageState
    extends State<AdminMerchandiserSubcategoryProductsPage>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<SubCategory> _subCategories = [];

  @override
  void initState() {
    super.initState();
    // Load sub-categories on init
    context.read<MerchandiserDataBloc>().add(
          AdminLoadSubCategories(categoryId: widget.category.id),
        );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initializeTabController(List<SubCategory> subCategories) {
    if (_subCategories.length != subCategories.length) {
      _tabController?.dispose();
      _subCategories = subCategories;
      _tabController = TabController(length: subCategories.length, vsync: this);
      _tabController?.addListener(_onTabChanged);

      // Load products for first tab
      if (subCategories.isNotEmpty) {
        Future.microtask(() {
          context.read<MerchandiserDataBloc>().add(
                AdminLoadProducts(subCategoryId: subCategories.first.id),
              );
        });
      }
    }
  }

  void _onTabChanged() {
    if (_tabController?.indexIsChanging == true && _subCategories.isNotEmpty) {
      final selectedSubCategory = _subCategories[_tabController!.index];
      context.read<MerchandiserDataBloc>().add(
            AdminLoadProducts(subCategoryId: selectedSubCategory.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = LocalizationHelper.getLocalizedString(
      widget.category.name,
    );

    return BlocConsumer<MerchandiserDataBloc, MerchandiserDataState>(
      listener: (context, state) {
        if (state is SubCategoriesLoaded) {
          _initializeTabController(state.subCategories);
        } else if (state is MerchandiserDataStateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is SubCategoriesLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Handle empty sub-categories
        if (_subCategories.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text('${widget.merchandiserName} - $categoryName'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.subdirectory_arrow_right,
                    size: 64,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sub-categories found',
                    style: AppTextStyles.getH4(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This category doesn\'t have any sub-categories yet',
                    style: AppTextStyles.getBodyMedium(context),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${widget.merchandiserName} - $categoryName'),
            bottom: _tabController != null
                ? TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: _subCategories.map((subCategory) {
                      return Tab(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              LocalizationHelper.getLocalizedString(
                                subCategory.name,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (subCategory.productCount > 0)
                              Text(
                                '(${subCategory.productCount})',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.grey500,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                : null,
          ),
          body: _tabController != null
              ? TabBarView(
                  controller: _tabController,
                  children: _subCategories
                      .map(
                        (subCategory) => _buildProductsTab(state, subCategory),
                      )
                      .toList(),
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildProductsTab(
    MerchandiserDataState state,
    SubCategory subCategory,
  ) {
    if (state is ProductsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProductsLoaded &&
        state.selectedSubCategoryId == subCategory.id) {
      return _buildProductsContent(state);
    }

    if (state is ProductsLoadingMore &&
        state.selectedSubCategoryId == subCategory.id) {
      return _buildProductsContent(
        ProductsLoaded(
          subCategories: state.subCategories,
          selectedSubCategoryId: state.selectedSubCategoryId,
          products: state.products,
          hasMore: true,
          currentPage: 1,
          currentSearchQuery: state.currentSearchQuery,
          currentSortBy: state.currentSortBy,
        ),
        isLoadingMore: true,
      );
    }

    // Show placeholder when tab is not selected or no products loaded
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_outlined, size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text(
            'Select tab to load products',
            style: AppTextStyles.getH4(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsContent(
    ProductsLoaded state, {
    bool isLoadingMore = false,
  }) {
    if (state.products.isEmpty && !isLoadingMore) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_outlined, size: 64, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text('No products found', style: AppTextStyles.getH4(context)),
            const SizedBox(height: 8),
            Text(
              'This sub-category doesn\'t have any products yet',
              style: AppTextStyles.getBodyMedium(context),
            ),
          ],
        ),
      );
    }

    return ProductsGridView(
      products: state.products,
      isLoading: isLoadingMore,
      hasMore: state.hasMore,
      onLoadMore: () {
        context.read<MerchandiserDataBloc>().add(AdminLoadMoreProducts());
      },
      onProductTap: (product) {
        _showProductDetails(product);
      },
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          LocalizationHelper.getLocalizedString(product.name),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product image
                if (product.images.isNotEmpty)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(product.images[0]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Product details
                _buildDetailRow(
                  'Price',
                  '\$${product.price.toStringAsFixed(2)}',
                ),
                if (product.discountPrice != null)
                  _buildDetailRow(
                    'Discount Price',
                    '\$${product.discountPrice!.toStringAsFixed(2)}',
                  ),
                _buildDetailRow('Stock Quantity', '${product.stockQuantity}'),
                if (product.sku != null) _buildDetailRow('SKU', product.sku!),
                _buildDetailRow(
                  'Status',
                  product.isAvailable ? 'Available' : 'Unavailable',
                ),
                _buildDetailRow(
                  'Stock Status',
                  product.stockQuantity > 0 ? 'In Stock' : 'Out of Stock',
                ),
                if (product.rating > 0)
                  _buildDetailRow(
                    'Rating',
                    '${product.rating.toStringAsFixed(1)} ⭐',
                  ),
                _buildDetailRow('Featured', product.isFeatured ? 'Yes' : 'No'),

                // Description
                if (LocalizationHelper.getLocalizedString(
                  product.description,
                ).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: AppTextStyles.getBodyMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LocalizationHelper.getLocalizedString(product.description),
                    style: AppTextStyles.getBodyMedium(context),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
