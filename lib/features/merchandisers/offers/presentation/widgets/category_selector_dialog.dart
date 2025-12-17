// lib/features/offers/presentation/widgets/category_selector_dialog.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/category_repository.dart';
import 'package:flutter/material.dart';

class CategorySelectorDialog extends StatefulWidget {
  const CategorySelectorDialog({super.key});

  @override
  State<CategorySelectorDialog> createState() => _CategorySelectorDialogState();
}

class _CategorySelectorDialogState extends State<CategorySelectorDialog> {
  final _categoryRepo = sl<CategoryRepository>();
  final _authService = sl<AuthService>();
  final _searchController = TextEditingController();

  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  Category? _selectedCategory;

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
          _categories = categories.where((c) => c.isActive).toList();
          _filteredCategories = _categories;
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

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _categories;
      } else {
        _filteredCategories = _categories.where((category) {
          final nameEn = category.name['en']?.toLowerCase() ?? '';
          final nameAr = category.name['ar']?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return nameEn.contains(searchLower) || nameAr.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.category, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Select Category', style: AppTextStyles.h3Light),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: AppConstants.defaultPadding),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterCategories,
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Categories List
            Expanded(child: _buildContent()),

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
                  onPressed: _selectedCategory != null
                      ? () => Navigator.pop(context, _selectedCategory)
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

  Widget _buildContent() {
    if (_isLoading) {
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
              'Error loading categories',
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
              onPressed: _loadCategories,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No categories found'
                  : 'No categories match your search',
              style: AppTextStyles.bodyLargeLight.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredCategories.length,
      itemBuilder: (context, index) {
        final category = _filteredCategories[index];
        final isSelected = _selectedCategory?.id == category.id;

        return Card(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ListTile(
            leading: category.image != null && category.image!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      category.image!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.category,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.category, color: AppColors.primary),
                  ),
            title: Text(
              category.name['en'] ?? 'Unknown',
              style: AppTextStyles.bodyLargeLight.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: category.name['ar'] != null
                ? Text(
                    category.name['ar']!,
                    style: AppTextStyles.bodySmallLight,
                  )
                : null,
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : null,
            onTap: () {
              setState(() {
                _selectedCategory = category;
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
