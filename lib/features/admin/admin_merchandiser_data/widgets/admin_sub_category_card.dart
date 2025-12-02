import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/helpers/localization_helper.dart';
import '../../../shared/shared_feature/data/models/sub_category_model.dart';

class AdminSubCategoryCard extends StatelessWidget {
  final SubCategoryModel subCategory;
  final VoidCallback? onTap;
  final bool isSelected;

  const AdminSubCategoryCard({
    super.key,
    required this.subCategory,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with image and status
              Row(
                children: [
                  // Name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocalizationHelper.getLocalizedString(
                            subCategory.name,
                          ),
                          style: AppTextStyles.getH4(context).copyWith(
                            color: isSelected ? AppColors.primary : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: subCategory.isActive
                                    ? AppColors.success
                                    : AppColors.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                subCategory.isActive ? 'Active' : 'Inactive',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Product count and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory, size: 14, color: AppColors.info),
                        const SizedBox(width: 4),
                        Text(
                          '${subCategory.productCount} Products',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.info,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isSelected ? AppColors.primary : AppColors.grey500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
