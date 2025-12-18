// lib/features/offers/presentation/widgets/product_selector_dialog.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/category_repository.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/product_repository.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/sub_category_repository.dart';
import 'package:flutter/material.dart';

class ProductSelectorDialog extends StatefulWidget {
  final bool allowMultiple;
  final int? maxQuantity;

  const ProductSelectorDialog({
    super.key,
    this.allowMultiple = false,
    this.maxQuantity,
  });

  @override
  State<ProductSelectorDialog> createState() => _ProductSelectorDialogState();
}

class _ProductSelectorDialogState extends State<ProductSelectorDialog> {
  final _categoryRepo = sl<CategoryRepository>();
  final _subCategoryRepo = sl<SubCategoryRepository>();
  final _productRepo = sl<ProductRepository>();
  final _authService = sl<AuthService>();

  List<Category> _categories = [];
  List<SubCategory> _subCategories = [];
  List<Product> _products = [];

  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;
  Product? _selectedProduct;
  int _quantity = 1;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final merchandiserId = await _authService.getMerchandiserId();
      if (merchandiserId == null) {
        throw Exception('Merchandiser ID not found');
      }

      final result = await _categoryRepo.getCategories(merchandiserId);
      result.fold(
        (failure) => setState(() {
          _error = failure.message;
          _isLoading = false;
        }),
        (categories) => setState(() {
          _categories = categories;
          _isLoading = false;
        }),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSubCategories(String categoryId) async {
    setState(() {
      _isLoading = true;
      _selectedSubCategory = null;
      _selectedProduct = null;
      _products = [];
    });

    try {
      final result = await _subCategoryRepo.getSubCategories(categoryId);
      result.fold(
        (failure) => setState(() {
          _error = failure.message;
          _isLoading = false;
        }),
        (subCategories) => setState(() {
          _subCategories = subCategories;
          _isLoading = false;
        }),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProducts(String subCategoryId) async {
    setState(() {
      _isLoading = true;
      _selectedProduct = null;
    });

    try {
      final result = await _productRepo.getProductsBySubCategory(
        subCategoryId: subCategoryId,
        limit: 100,
      );
      result.fold(
        (failure) => setState(() {
          _error = failure.message;
          _isLoading = false;
        }),
        (products) => setState(() {
          _products = products;
          _isLoading = false;
        }),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text('Select Product', style: AppTextStyles.h3Light),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: AppConstants.defaultPadding),

            // Step 1: Category Selection
            Text('1. Select Category', style: AppTextStyles.h4Light),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
            const SizedBox(height: AppConstants.largePadding),

            // Step 2: Sub-Category Selection
            if (_selectedCategory != null) ...[
              Text('2. Select Sub-Category', style: AppTextStyles.h4Light),
              const SizedBox(height: 8),
              _buildSubCategoryDropdown(),
              const SizedBox(height: AppConstants.largePadding),
            ],

            // Step 3: Product List
            if (_selectedSubCategory != null) ...[
              Text('3. Select Product', style: AppTextStyles.h4Light),
              const SizedBox(height: 8),
              Expanded(child: _buildProductList()),
            ],

            // Quantity Selector (if applicable)
            if (widget.allowMultiple && _selectedProduct != null) ...[
              const Divider(),
              Row(
                children: [
                  Text('Quantity:', style: AppTextStyles.bodyLargeLight),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text(_quantity.toString(), style: AppTextStyles.h4Light),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed:
                        (widget.maxQuantity == null ||
                            _quantity < widget.maxQuantity!)
                        ? () => setState(() => _quantity++)
                        : null,
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
                  onPressed: _selectedProduct != null
                      ? _confirmSelection
                      : null,
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    if (_isLoading && _categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _categories.isEmpty) {
      return Text(
        'Error: $_error',
        style: const TextStyle(color: AppColors.error),
      );
    }

    return DropdownButtonFormField<Category>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        hintText: 'Choose a category',
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category.name['en'] ?? 'Unknown'),
        );
      }).toList(),
      onChanged: (category) {
        setState(() {
          _selectedCategory = category;
          _selectedSubCategory = null;
          _selectedProduct = null;
          _subCategories = [];
          _products = [];
        });
        if (category != null) {
          _loadSubCategories(category.id);
        }
      },
    );
  }

  Widget _buildSubCategoryDropdown() {
    if (_isLoading && _subCategories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<SubCategory>(
      initialValue: _selectedSubCategory,
      decoration: const InputDecoration(
        hintText: 'Choose a sub-category',
        border: OutlineInputBorder(),
      ),
      items: _subCategories.map((subCategory) {
        return DropdownMenuItem(
          value: subCategory,
          child: Text(subCategory.name['en'] ?? 'Unknown'),
        );
      }).toList(),
      onChanged: (subCategory) {
        setState(() {
          _selectedSubCategory = subCategory;
          _selectedProduct = null;
          _products = [];
        });
        if (subCategory != null) {
          _loadProducts(subCategory.id);
        }
      },
    );
  }

  Widget _buildProductList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text('No products found in this sub-category'),
      );
    }

    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        final isSelected = _selectedProduct?.id == product.id;

        return Card(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
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
            title: Text(product.name['en'] ?? 'Unknown'),
            subtitle: Text(
              'EGP ${product.currentPrice?.toStringAsFixed(2) ?? product.price.toStringAsFixed(2)}',
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : null,
            onTap: () {
              setState(() {
                _selectedProduct = product;
              });
            },
          ),
        );
      },
    );
  }

  void _confirmSelection() {
    if (_selectedProduct == null) return;

    Navigator.pop(context, {
      'id': _selectedProduct!.id,
      'name': _selectedProduct!.name['en'] ?? 'Unknown',
      'image': _selectedProduct!.images.isNotEmpty
          ? _selectedProduct!.images.first
          : null,
      'price': _selectedProduct!.currentPrice ?? _selectedProduct!.price,
      'quantity': widget.allowMultiple ? _quantity : 1,
    });
  }
}
