import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/product_bloc/product_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/sub_category_bloc/sub_category_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/pages/subcategories_products_page.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/widgets/merchandiser_category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/category_bloc/category_bloc.dart';
import '../bloc/category_bloc/category_event.dart';
import '../bloc/category_bloc/category_state.dart';
import '../widgets/add_category_dialog.dart';

class MerchandiserCategoriesPage extends StatelessWidget {
  const MerchandiserCategoriesPage({super.key});
  Future<String> _getCurrentMerchandiserId() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final response = await Supabase.instance.client
        .from('merchandisers')
        .select('id')
        .eq('profile_id', user.id)
        .single();
    return response['id'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CategoryBloc>(),
      child: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return FutureBuilder<String>(
            future: _getCurrentMerchandiserId(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final merchandiserId = snapshot.data!;
              // Load categories when page is first loaded
              if (state is CategoryInitial) {
                context.read<CategoryBloc>().add(
                  LoadCategories(merchandiserId),
                );
                return const Center(child: CircularProgressIndicator());
              }
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Categories Management',
                            style: AppTextStyles.getH2(context),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (dialogContext) => BlocProvider.value(
                                  value: context.read<CategoryBloc>(),
                                  child: AddCategoryDialog(
                                    merchandiserId: merchandiserId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Category'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: _buildCategoryList(state, merchandiserId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(CategoryState state, String merchandiserId) {
    if (state is CategoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is CategoriesLoaded) {
      if (state.categories.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined, size: 64, color: AppColors.grey400),
              const SizedBox(height: 16),
              Text('No categories yet', style: AppTextStyles.h4Light),
              const SizedBox(height: 8),
              Text(
                'Add your first category to get started',
                style: AppTextStyles.bodyMediumLight,
              ),
            ],
          ),
        );
      }
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          return MerchandiserCategoryCard(
            category: category,
            merchandiserId: merchandiserId,
            onTap: () {
              _navigateToSubCategories(
                context,
                category.id,
                merchandiserId,
                category.name['en']!,
              );
            },
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  void _navigateToSubCategories(
    BuildContext context,
    String categoryId,
    String merchandiserId,
    String categoryName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => sl<SubCategoryBloc>()),
            BlocProvider(create: (context) => sl<ProductBloc>()),
          ],
          child: SubCategoriesProductsPage(
            categoryId: categoryId,
            merchandiserId: merchandiserId,
            categoryName: categoryName,
          ),
        ),
      ),
    );
  }
}
