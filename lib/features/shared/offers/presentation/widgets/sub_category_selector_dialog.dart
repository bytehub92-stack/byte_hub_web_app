// lib/features/offers/presentation/widgets/sub_category_selector_dialog.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/category_repository.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/sub_category_repository.dart';
import 'package:flutter/material.dart';

class SubCategorySelectorDialog extends StatefulWidget {
  const SubCategorySelectorDialog({super.key});

  @override
  State<SubCategorySelectorDialog> createState() =>
      _SubCategorySelectorDialogState();
}

class _SubCategorySelectorDialogState extends State<SubCategorySelectorDialog> {
  final _categoryRepo = sl<CategoryRepository>();
  final _subCategoryRepo = sl<SubCategoryRepository>();
  final _authService = sl<AuthService>();
  final _searchController = TextEditingController();

  List<Category> _categories = [];
  List<SubCategory> _subCategories = [];
  List<SubCategory> _filteredSubCategories = [];

  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;

  bool _isLoadingCategories = true;
  bool _isLoadingSubCategories = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
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
          _isLoadingCategories = false;
        }),
        (categories) => setState(() {
          _categories = categories.where((c) => c.isActive).toList();
          _isLoadingCategories = false;
        }),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadSubCategories(String categoryId) async {
    setState(() {
      _isLoadingSubCategories = true;
      _error = null;
      _selectedSubCategory = null;
      _subCategories = [];
      _filteredSubCategories = [];
      _searchController.clear();
    });

    try {
      final result = await _subCategoryRepo.getSubCategories(categoryId);
      result.fold(
        (failure) => setState(() {
          _error = failure.message;
          _isLoadingSubCategories = false;
        }),
        (subCategories) => setState(() {
          _subCategories = subCategories.where((sc) => sc.isActive).toList();
          _filteredSubCategories = _subCategories;
          _isLoadingSubCategories = false;
        }),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingSubCategories = false;
      });
    }
  }

  void _filterSubCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSubCategories = _subCategories;
      } else {
        _filteredSubCategories = _subCategories.where((subCategory) {
          final nameEn = subCategory.name['en']?.toLowerCase() ?? '';
          final nameAr = subCategory.name['ar']?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return nameEn.contains(searchLower) || nameAr.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 650),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.folder, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select Sub-Category',
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

              // Step 1: Category Selection
              Text('1. Select Category', style: AppTextStyles.h4Light),
              const SizedBox(height: 8),
              _buildCategoryDropdown(),
              const SizedBox(height: AppConstants.largePadding),

              // Step 2: Sub-Category Selection
              Expanded(
                child: _selectedCategory != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '2. Select Sub-Category',
                                  style: AppTextStyles.h4Light,
                                ),
                              ),
                              if (_subCategories.isNotEmpty)
                                Text(
                                  '${_filteredSubCategories.length} items',
                                  style: AppTextStyles.bodySmallLight.copyWith(
                                    color: AppColors.grey500,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Search Bar
                          TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search sub-categories...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: _filterSubCategories,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),

                          // Sub-Categories List
                          Expanded(child: _buildSubCategoriesList()),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              size: 48,
                              color: AppColors.grey400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Please select a category first',
                              style: AppTextStyles.bodyLargeLight.copyWith(
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

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
                    onPressed: _selectedSubCategory != null
                        ? () => Navigator.pop(context, _selectedSubCategory)
                        : null,
                    child: const Text('Select'),
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

    if (_error != null && _categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(color: AppColors.error),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
            TextButton(onPressed: _loadCategories, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(color: AppColors.borderLight),
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
          child: Row(
            children: [
              if (category.image != null && category.image!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      category.image!,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.category, size: 20),
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  category.name['en'] ?? 'Unknown',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (category) {
        setState(() {
          _selectedCategory = category;
        });
        if (category != null) {
          _loadSubCategories(category.id);
        }
      },
    );
  }

  Widget _buildSubCategoriesList() {
    if (_isLoadingSubCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading sub-categories',
              style: AppTextStyles.bodyLargeLight.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: AppTextStyles.bodySmallLight,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_selectedCategory != null) {
                  _loadSubCategories(_selectedCategory!.id);
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredSubCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 64, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No sub-categories in this category'
                  : 'No sub-categories match your search',
              style: AppTextStyles.bodyLargeLight.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredSubCategories.length,
      itemBuilder: (context, index) {
        final subCategory = _filteredSubCategories[index];
        final isSelected = _selectedSubCategory?.id == subCategory.id;

        return Card(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : null,
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.folder, color: AppColors.accent),
            ),
            title: Text(
              subCategory.name['en'] ?? 'Unknown',
              style: AppTextStyles.bodyLargeLight.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: subCategory.name['ar'] != null
                ? Text(
                    subCategory.name['ar']!,
                    style: AppTextStyles.bodySmallLight,
                  )
                : null,
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : null,
            onTap: () {
              setState(() {
                _selectedSubCategory = subCategory;
              });
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
