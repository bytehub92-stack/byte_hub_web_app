// lib/features/offers/presentation/widgets/bundle_item_dialog.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/category_repository.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/product_repository.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/sub_category_repository.dart';
import 'package:flutter/material.dart';

class BundleItemDialog extends StatefulWidget {
  final BundleItem? initialItem;

  const BundleItemDialog({super.key, this.initialItem});

  @override
  State<BundleItemDialog> createState() => _BundleItemDialogState();
}

class _BundleItemDialogState extends State<BundleItemDialog> {
  final _categoryRepo = sl<CategoryRepository>();
  final _subCategoryRepo = sl<SubCategoryRepository>();
  final _productRepo = sl<ProductRepository>();
  final _authService = sl<AuthService>();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  List<Category> _categories = [];
  List<SubCategory> _subCategories = [];
  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;
  Product? _selectedProduct;
  int _quantity = 1;

  bool _isLoadingCategories = true;
  bool _isLoadingSubCategories = false;
  bool _isLoadingProducts = false;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.initialItem != null) {
      _quantity = widget.initialItem!.quantity;
      _quantityController.text = _quantity.toString();
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      error = null;
    });

    try {
      final merchandiserId = await _authService.getMerchandiserId();
      if (merchandiserId == null) {
        throw Exception('Merchandiser ID not found');
      }

      final result = await _categoryRepo.getCategories(merchandiserId);
      result.fold(
        (failure) => setState(() {
          error = failure.message;
          _isLoadingCategories = false;
        }),
        (categories) => setState(() {
          _categories = categories.where((c) => c.isActive).toList();
          _isLoadingCategories = false;
        }),
      );
    } catch (e) {
      setState(() {
        error = e.toString();
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadSubCategories(String categoryId) async {
    setState(() {
      _isLoadingSubCategories = true;
      _selectedSubCategory = null;
      _selectedProduct = null;
      _subCategories = [];
      _products = [];
      _filteredProducts = [];
    });

    try {
      final result = await _subCategoryRepo.getSubCategories(categoryId);
      result.fold(
        (failure) => setState(() {
          error = failure.message;
          _isLoadingSubCategories = false;
        }),
        (subCategories) => setState(() {
          _subCategories = subCategories.where((sc) => sc.isActive).toList();
          _isLoadingSubCategories = false;
        }),
      );
    } catch (e) {
      setState(() {
        error = e.toString();
        _isLoadingSubCategories = false;
      });
    }
  }

  Future<void> _loadProducts(String subCategoryId) async {
    setState(() {
      _isLoadingProducts = true;
      _selectedProduct = null;
      _searchController.clear();
    });

    try {
      final result = await _productRepo.getProductsBySubCategory(
        subCategoryId: subCategoryId,
        limit: 100,
      );
      result.fold(
        (failure) => setState(() {
          error = failure.message;
          _isLoadingProducts = false;
        }),
        (products) => setState(() {
          _products = products;
          _filteredProducts = products;
          _isLoadingProducts = false;
        }),
      );
    } catch (e) {
      setState(() {
        error = e.toString();
        _isLoadingProducts = false;
      });
    }
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) {
          final nameEn = product.name['en']?.toLowerCase() ?? '';
          final nameAr = product.name['ar']?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return nameEn.contains(searchLower) || nameAr.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialItem != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add_shopping_cart,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Bundle Item' : 'Add Item to Bundle',
                      style: AppTextStyles.h3Light,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppConstants.defaultPadding),

              // Step 1: Category
              Text('1. Select Category', style: AppTextStyles.h4Light),
              const SizedBox(height: 8),
              _buildCategoryDropdown(),
              const SizedBox(height: AppConstants.defaultPadding),

              // Step 2: Sub-Category
              if (_selectedCategory != null) ...[
                Text('2. Select Sub-Category', style: AppTextStyles.h4Light),
                const SizedBox(height: 8),
                _buildSubCategoryDropdown(),
                const SizedBox(height: AppConstants.defaultPadding),
              ],

              // Step 3: Product Selection
              if (_selectedSubCategory != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '3. Select Product',
                        style: AppTextStyles.h4Light,
                      ),
                    ),
                    if (_products.isNotEmpty)
                      Text(
                        '${_filteredProducts.length} items',
                        style: AppTextStyles.bodySmallLight.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _filterProducts,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                Expanded(child: _buildProductsList()),
              ] else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedCategory == null
                              ? Icons.arrow_upward
                              : Icons.folder_open,
                          size: 48,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategory == null
                              ? 'Please select a category first'
                              : 'Please select a sub-category',
                          style: AppTextStyles.bodyLargeLight.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Step 4: Quantity
              if (_selectedProduct != null) ...[
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected: ${_selectedProduct!.name['en']}',
                            style: AppTextStyles.bodyMediumLight.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Price: EGP ${(_selectedProduct!.currentPrice ?? _selectedProduct!.price).toStringAsFixed(2)}',
                            style: AppTextStyles.bodySmallLight,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _quantity = int.tryParse(value) ?? 1;
                            if (_quantity < 1) {
                              _quantity = 1;
                              _quantityController.text = '1';
                            }
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _quantity > 1
                          ? () {
                              setState(() {
                                _quantity--;
                                _quantityController.text = _quantity.toString();
                              });
                            }
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                          _quantityController.text = _quantity.toString();
                        });
                      },
                    ),
                  ],
                ),
              ],

              // Action Buttons
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed:
                        _selectedProduct != null ? _confirmSelection : null,
                    child: Text(isEditing ? 'Update' : 'Add to Bundle'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        child: const Text('No categories available'),
      );
    }

    return DropdownButtonFormField<Category>(
      initialValue: _selectedCategory,
      isExpanded: true,
      decoration: const InputDecoration(
        hintText: 'Choose a category',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(
            category.name['en'] ?? 'Unknown',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (category) {
        setState(() => _selectedCategory = category);
        if (category != null) {
          _loadSubCategories(category.id);
        }
      },
    );
  }

  Widget _buildSubCategoryDropdown() {
    if (_isLoadingSubCategories) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_subCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        child: const Text('No sub-categories in this category'),
      );
    }

    return DropdownButtonFormField<SubCategory>(
      initialValue: _selectedSubCategory,
      isExpanded: true,
      decoration: const InputDecoration(
        hintText: 'Choose a sub-category',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.folder),
      ),
      items: _subCategories.map((subCategory) {
        return DropdownMenuItem(
          value: subCategory,
          child: Text(
            subCategory.name['en'] ?? 'Unknown',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (subCategory) {
        setState(() => _selectedSubCategory = subCategory);
        if (subCategory != null) {
          _loadProducts(subCategory.id);
        }
      },
    );
  }

  Widget _buildProductsList() {
    if (_isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No products in this sub-category'
                  : 'No products match your search',
              style: AppTextStyles.bodyLargeLight.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        final isSelected = _selectedProduct?.id == product.id;
        final price = product.currentPrice ?? product.price;

        return Card(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ListTile(
            leading: product.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      product.images.first,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                  )
                : const Icon(Icons.inventory_2),
            title: Text(
              product.name['en'] ?? 'Unknown',
              style: AppTextStyles.bodyMediumLight.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text('EGP ${price.toStringAsFixed(2)}'),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : null,
            onTap: () {
              setState(() => _selectedProduct = product);
            },
          ),
        );
      },
    );
  }

  void _confirmSelection() {
    if (_selectedProduct == null) return;

    final bundleItem = BundleItem(
      productId: _selectedProduct!.id,
      quantity: _quantity,
      productName: _selectedProduct!.name['en'] ?? 'Unknown',
      productImage: _selectedProduct!.images.isNotEmpty
          ? _selectedProduct!.images.first
          : '',
      productPrice: _selectedProduct!.currentPrice ?? _selectedProduct!.price,
    );

    Navigator.pop(context, bundleItem);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
