import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/product_bloc/product_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/product_bloc/product_event.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/product_bloc/product_state.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/sub_category_bloc/sub_category_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/sub_category_bloc/sub_category_event.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/sub_category_bloc/sub_category_state.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/widgets/product_card.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/widgets/product_form_dialog.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/widgets/subcategory_card.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/widgets/subcategory_form_dialog.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:admin_panel/shared/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

class SubCategoriesProductsPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String merchandiserId;

  const SubCategoriesProductsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.merchandiserId,
  });

  @override
  State<SubCategoriesProductsPage> createState() =>
      _SubCategoriesProductsPageState();
}

class _SubCategoriesProductsPageState extends State<SubCategoriesProductsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SubCategory? _selectedSubCategory;
  String _productSearchQuery = '';
  String _productSortBy = 'newest';
  int _currentPage = 1;
  final int _itemsPerPage = 24;

  // Debouncing for search
  DateTime _lastSearchTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSubCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSubCategories() {
    context.read<SubCategoryBloc>().add(LoadSubCategories(widget.categoryId));
  }

  void _loadProducts() {
    if (_selectedSubCategory != null) {
      context.read<ProductBloc>().add(
            LoadProducts(
              subCategoryId: _selectedSubCategory!.id,
              page: _currentPage,
              limit: _itemsPerPage,
              searchQuery:
                  _productSearchQuery.isEmpty ? null : _productSearchQuery,
              sortBy: _productSortBy,
            ),
          );
    }
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadProducts();
  }

  // Debounced search to avoid too many API calls
  void _onSearchChanged(String value) {
    final now = DateTime.now();
    _lastSearchTime = now;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_lastSearchTime == now) {
        setState(() {
          _productSearchQuery = value;
          _currentPage = 1; // Reset to first page on search
        });
        _loadProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
        title: Text(widget.categoryName),
        backgroundColor: Colors.pink,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Sub-Categories', icon: Icon(Icons.category)),
            Tab(text: 'Products', icon: Icon(Icons.inventory_2)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSubCategoriesTab(), _buildProductsTab()],
      ),
    );
  }

  Widget _buildSubCategoriesTab() {
    return BlocConsumer<SubCategoryBloc, SubCategoryState>(
      listener: (context, state) {
        if (state is SubCategoryOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is SubCategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is SubCategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SubCategoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(state.message, style: AppTextStyles.bodyLargeLight),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadSubCategories,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is SubCategoriesLoaded) {
          if (state.subCategories.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.category_outlined,
              title: 'No Sub-Categories',
              message: 'Create your first sub-category to get started',
              actionLabel: 'Create Sub-Category',
              onAction: () => _showSubCategoryDialog(),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.subCategories.length} Sub-Categories',
                      style: AppTextStyles.h4Light,
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showSubCategoryDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Sub-Category'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.subCategories.length,
                  itemBuilder: (context, index) {
                    final subCategory = state.subCategories[index];
                    return SubCategoryCard(
                      subCategory: subCategory,
                      isSelected: _selectedSubCategory?.id == subCategory.id,
                      onTap: () {
                        setState(() {
                          _selectedSubCategory = subCategory;
                          _currentPage = 1;
                        });
                        _loadProducts();
                        _tabController.animateTo(1);
                      },
                      onEdit: () => _showSubCategoryDialog(subCategory),
                      onDelete: () => _showDeleteSubCategoryDialog(subCategory),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductsTab() {
    if (_selectedSubCategory == null) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: 'No Sub-Category Selected',
        message:
            'Please select a sub-category from the first tab to view products',
        actionLabel: 'Go to Sub-Categories',
        onAction: () => _tabController.animateTo(0),
      );
    }

    return BlocConsumer<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          _loadProducts();
        } else if (state is ProductError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            _buildProductsHeader(),
            _buildProductsSearchAndFilter(),
            Expanded(child: _buildProductsList(state)),
            if (state is ProductsLoaded && state.products.isNotEmpty)
              _buildPaginationControls(state.products.length),
          ],
        );
      },
    );
  }

  Widget _buildProductsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedSubCategory!.name['en'] ?? 'Sub-Category',
                style: AppTextStyles.h4Light,
              ),
              Text(
                '${_selectedSubCategory!.productCount} Total Products',
                style: AppTextStyles.bodyMediumLight.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _showProductDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _productSortBy,
            items: const [
              DropdownMenuItem(value: 'newest', child: Text('Newest')),
              DropdownMenuItem(value: 'name', child: Text('Name')),
              DropdownMenuItem(
                value: 'price_asc',
                child: Text('Price: Low to High'),
              ),
              DropdownMenuItem(
                value: 'price_desc',
                child: Text('Price: High to Low'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _productSortBy = value;
                  _currentPage = 1;
                });
                _loadProducts();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductState state) {
    if (state is ProductLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProductError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(state.message, style: AppTextStyles.bodyLargeLight),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is ProductsLoaded) {
      if (state.products.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.inventory_2_outlined,
          title: 'No Products',
          message: _productSearchQuery.isEmpty
              ? 'Add your first product to this sub-category'
              : 'No products found matching your search',
          actionLabel: _productSearchQuery.isEmpty ? 'Add Product' : null,
          onAction:
              _productSearchQuery.isEmpty ? () => _showProductDialog() : null,
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.products.length,
        itemBuilder: (context, index) {
          final product = state.products[index];
          return ProductCard(
            key: ValueKey(product.id),
            product: product,
            onEdit: () => _showProductDialog(product),
            onDelete: () => _showDeleteProductDialog(product),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPaginationControls(int currentPageItemCount) {
    final totalProducts = _selectedSubCategory?.productCount ?? 0;
    final totalPages = (totalProducts / _itemsPerPage).ceil();

    if (totalPages <= 1) return const SizedBox.shrink();

    // Calculate page range to show
    int startPage = math.max(1, _currentPage - 2);
    int endPage = math.min(totalPages, _currentPage + 2);

    // Adjust if we're at the beginning or end
    if (_currentPage <= 3) {
      endPage = math.min(5, totalPages);
    }
    if (_currentPage >= totalPages - 2) {
      startPage = math.max(1, totalPages - 4);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            onPressed:
                _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous',
          ),
          const SizedBox(width: 8),

          // First page
          if (startPage > 1) ...[
            _buildPageButton(1),
            if (startPage > 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text('...', style: AppTextStyles.bodyMediumLight),
              ),
          ],

          // Page numbers
          ...List.generate(
            endPage - startPage + 1,
            (index) => _buildPageButton(startPage + index),
          ),

          // Last page
          if (endPage < totalPages) ...[
            if (endPage < totalPages - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text('...', style: AppTextStyles.bodyMediumLight),
              ),
            _buildPageButton(totalPages),
          ],

          const SizedBox(width: 8),
          // Next button
          IconButton(
            onPressed: _currentPage < totalPages
                ? () => _goToPage(_currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next',
          ),

          const SizedBox(width: 16),
          // Page info
          Text(
            'Page $_currentPage of $totalPages',
            style: AppTextStyles.bodyMediumLight,
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(int page) {
    final isCurrentPage = page == _currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isCurrentPage ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isCurrentPage ? null : () => _goToPage(page),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    isCurrentPage ? AppColors.primary : AppColors.borderLight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$page',
              style: AppTextStyles.bodyMediumLight.copyWith(
                color: isCurrentPage ? AppColors.white : AppColors.textDark,
                fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSubCategoryDialog([SubCategory? subCategory]) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SubCategoryBloc>(),
        child: SubCategoryFormDialog(
          categoryId: widget.categoryId,
          merchandiserId: widget.merchandiserId,
          subCategory: subCategory,
        ),
      ),
    );
  }

  void _showProductDialog([Product? product]) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ProductBloc>(),
        child: ProductFormDialog(
          merchandiserId: widget.merchandiserId,
          categoryId: widget.categoryId,
          subCategoryId: _selectedSubCategory!.id,
          product: product,
        ),
      ),
    );
  }

  void _showDeleteSubCategoryDialog(SubCategory subCategory) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Sub-Category'),
        content: Text(
          'Are you sure you want to delete "${subCategory.name['en']}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SubCategoryBloc>().add(
                    DeleteSubCategory(
                      subCategoryId: subCategory.id,
                      categoryId: widget.categoryId,
                    ),
                  );
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.name['en']}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProductBloc>().add(
                    DeleteProduct(product.id, product.subCategoryId),
                  );
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
