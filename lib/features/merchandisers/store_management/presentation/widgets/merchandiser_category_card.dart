import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/category_bloc/category_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/category_bloc/category_event.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/widgets/update_category_dialog.dart';
import 'package:admin_panel/features/shared/offers/presentation/widgets/offer_badge_widget.dart';
import 'package:admin_panel/features/shared/offers/services/offer_indicator_service.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MerchandiserCategoryCard extends StatelessWidget {
  final Category category;
  final String merchandiserId;
  final VoidCallback? onTap;

  const MerchandiserCategoryCard({
    super.key,
    required this.category,
    required this.merchandiserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final offerService = sl<OfferIndicatorService>();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Category Image
                  category.imageThumbnail != null
                      ? CachedNetworkImage(
                          imageUrl: category.imageThumbnail!,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.grey300,
                              child: const Icon(Icons.category, size: 48),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.grey300,
                          child: const Center(
                            child: Icon(Icons.category, size: 48),
                          ),
                        ),

                  // Offer Badge Overlay
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: CategoryOfferBadges(
                      categoryId: category.id,
                      offerService: offerService,
                      isSmall: false,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name['en'] ?? 'Unnamed',
                              style: AppTextStyles.bodyLargeLight,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (category.name['ar'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                category.name['ar']!,
                                style: AppTextStyles.bodySmallLight,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: Icons.inventory_2,
                        label: '${category.productCount}',
                        color: AppColors.info,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: category.isActive
                              ? AppColors.success
                              : AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: Icons.folder,
                        label: '${category.subCategoryCount}',
                        color: AppColors.secondary,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (dialogContext) => BlocProvider.value(
                              value: context.read<CategoryBloc>(),
                              child: UpdateCategoryDialog(
                                category: category,
                                merchandiserId: merchandiserId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: 'Edit Category',
                      ),
                      IconButton(
                        onPressed: () => _showDeleteConfirmation(
                          context,
                          category,
                          merchandiserId,
                        ),
                        icon: const Icon(Icons.delete, size: 20),
                        tooltip: 'Delete Category',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmallLight.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Category category,
    String merchandiserId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name['en']}"? '
          'This will also delete ${category.subCategoryCount} sub-categories '
          'and ${category.productCount} products.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryBloc>().add(
                DeleteCategory(
                  categoryId: category.id,
                  merchandiserId: merchandiserId,
                ),
              );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
