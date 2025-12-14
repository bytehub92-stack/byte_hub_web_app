import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/helpers/localization_helper.dart';
import '../../../shared/shared_feature/data/models/category_model.dart';

class AdminCategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const AdminCategoryCard({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Image or Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(8),
                  image: category.image != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(category.image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: category.image == null
                    ? const Icon(Icons.category, color: AppColors.grey500)
                    : null,
              ),

              const SizedBox(width: 16),

              // Category Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationHelper.getLocalizedString(category.name),
                      style: AppTextStyles.getH4(context),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.subdirectory_arrow_right,
                          label: '${category.subCategoryCount} Sub-categories',
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          icon: Icons.inventory,
                          label: '${category.productCount} Products',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status and Arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.grey500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
