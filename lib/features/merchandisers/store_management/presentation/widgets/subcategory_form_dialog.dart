import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/sub_category_bloc/sub_category_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/sub_category_bloc/sub_category_event.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';

class SubCategoryFormDialog extends StatefulWidget {
  final String categoryId;
  final String merchandiserId;
  final SubCategory? subCategory;

  const SubCategoryFormDialog({
    super.key,
    required this.categoryId,
    required this.merchandiserId,
    this.subCategory,
  });

  @override
  State<SubCategoryFormDialog> createState() => _SubCategoryFormDialogState();
}

class _SubCategoryFormDialogState extends State<SubCategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameEnController;
  late TextEditingController _nameArController;
  late TextEditingController _sortOrderController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController(
      text: widget.subCategory?.name['en'] ?? '',
    );
    _nameArController = TextEditingController(
      text: widget.subCategory?.name['ar'] ?? '',
    );
    _sortOrderController = TextEditingController(
      text: widget.subCategory?.sortOrder.toString() ?? '0',
    );
    _isActive = widget.subCategory?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.subCategory != null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = {
      'en': _nameEnController.text.trim(),
      'ar': _nameArController.text.trim(),
    };

    if (_isEditing) {
      context.read<SubCategoryBloc>().add(
        UpdateSubCategory(
          subCategoryId: widget.subCategory!.id,
          name: name,
          categoryId: widget.categoryId,
        ),
      );
    } else {
      context.read<SubCategoryBloc>().add(
        CreateSubCategory(
          merchandiserId: widget.merchandiserId,
          categoryId: widget.categoryId,
          name: name,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isEditing ? Icons.edit : Icons.add_circle_outline,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isEditing
                            ? 'Edit Sub-Category'
                            : 'Create Sub-Category',
                        style: AppTextStyles.h3Light,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'English Name',
                  style: AppTextStyles.bodyMediumLight.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameEnController,
                  decoration: const InputDecoration(
                    hintText: 'Enter sub-category name in English',
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter English name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Arabic Name',
                  style: AppTextStyles.bodyMediumLight.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameArController,
                  decoration: const InputDecoration(
                    hintText: 'أدخل اسم الفئة الفرعية بالعربية',
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                  textDirection: TextDirection.rtl,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter Arabic name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Sort Order',
                  style: AppTextStyles.bodyMediumLight.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sortOrderController,
                  decoration: const InputDecoration(
                    hintText: 'Enter sort order (0-999)',
                    prefixIcon: Icon(Icons.sort),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter sort order';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active Status'),
                  subtitle: Text(
                    _isActive
                        ? 'This sub-category is active'
                        : 'This sub-category is inactive',
                    style: AppTextStyles.bodySmallLight,
                  ),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  activeThumbColor: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: Icon(_isEditing ? Icons.save : Icons.add),
                      label: Text(_isEditing ? 'Update' : 'Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
