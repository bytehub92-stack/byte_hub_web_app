import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_data/bloc/merchandiser_data_event.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_data/bloc/merchandiser_data_bloc.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_data/bloc/merchandiser_data_states.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_data/pages/admin_merchandiser_subcategory_products_page.dart';
import 'package:admin_panel/features/shared/shared_feature/data/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/helpers/localization_helper.dart';
import '../../../shared/shared_feature/domain/entities/category.dart';
import '../widgets/admin_category_card.dart';

class AdminMerchandiserCategoriesPage extends StatefulWidget {
  final String merchandiserId;
  final String merchandiserName;

  const AdminMerchandiserCategoriesPage({
    super.key,
    required this.merchandiserId,
    required this.merchandiserName,
  });

  @override
  State<AdminMerchandiserCategoriesPage> createState() =>
      _AdminMerchandiserCategoriesPageState();
}

class _AdminMerchandiserCategoriesPageState
    extends State<AdminMerchandiserCategoriesPage> {
  String _searchQuery = '';

  List<Category> _filterCategories(List<Category> categories) {
    if (_searchQuery.isEmpty) return categories;

    return categories.where((category) {
      final nameEn = LocalizationHelper.getLocalizedString(category.name);
      final nameAr = category.name['ar'] ?? '';

      return nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          nameAr.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MerchandiserDataBloc>()
        ..add(AdminLoadCategories(merchandiserId: widget.merchandiserId)),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with search
              BlocBuilder<MerchandiserDataBloc, MerchandiserDataState>(
                builder: (context, state) {
                  final categoryCount =
                      state is CategoriesLoaded ? state.categories.length : 0;

                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Categories ($categoryCount)',
                          style: AppTextStyles.getH3(context),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<MerchandiserDataBloc>().add(
                              AdminLoadCategories(
                                  merchandiserId: widget.merchandiserId));
                        },
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Search bar
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: BlocBuilder<MerchandiserDataBloc, MerchandiserDataState>(
                  builder: (context, state) {
                    if (state is CategoriesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is MerchandiserDataStateError) {
                      return _buildErrorState(context, state.message);
                    }

                    if (state is CategoriesLoaded) {
                      final filteredCategories =
                          _filterCategories(state.categories);
                      return _buildCategoriesList(context, filteredCategories);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Error loading categories',
            style: AppTextStyles.getH4(context),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: AppTextStyles.getBodyMedium(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<MerchandiserDataBloc>().add(
                  AdminLoadCategories(merchandiserId: widget.merchandiserId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
      BuildContext context, List<Category> filteredCategories) {
    if (filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category_outlined,
                size: 64, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No categories found'
                  : 'No categories match your search',
              style: AppTextStyles.getH4(context),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'This merchandiser hasn\'t created any categories yet'
                  : 'Try adjusting your search terms',
              style: AppTextStyles.getBodyMedium(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        return AdminCategoryCard(
          category: CategoryModel.fromEntity(category),
          onTap: () {
            _navigateToSubCategories(
              category,
              widget.merchandiserId,
              widget.merchandiserName,
            );
          },
        );
      },
    );
  }

  void _navigateToSubCategories(
    Category category,
    String merchandiserId,
    String merchandiserName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<MerchandiserDataBloc>()
            ..add(AdminLoadSubCategories(categoryId: category.id)),
          child: AdminMerchandiserSubcategoryProductsPage(
            merchandiserId: merchandiserId,
            merchandiserName: merchandiserName,
            category: category,
          ),
        ),
      ),
    );
  }
}
