import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/helpers/jsonb_helper.dart';
import 'package:admin_panel/core/services/image_upload_service.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/category_bloc/category_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/category_bloc/category_event.dart';

import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateCategoryDialog extends StatefulWidget {
  final Category category;
  final String merchandiserId;
  const UpdateCategoryDialog({
    super.key,
    required this.merchandiserId,
    required this.category,
  });

  @override
  State<UpdateCategoryDialog> createState() => _UpdateCategoryDialogState();
}

class _UpdateCategoryDialogState extends State<UpdateCategoryDialog> {
  Uint8List? _selectedImage;
  final _imageUploadService = sl<ImageUploadService>();
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _nameArController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    _nameEnController.text = widget.category.name['en']!;
    _nameArController.text = widget.category.name['ar'] ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageBytes = await _imageUploadService.pickImage();
    if (imageBytes != null) {
      setState(() {
        _selectedImage = imageBytes;
      });
    }
  }

  Future<void> _updateCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      // Upload images if selected
      String? thumbnailUrl;
      String? largeUrl;

      if (_selectedImage != null) {
        final result = await _imageUploadService.uploadCategoryImage(
          merchandiserId: widget.merchandiserId,
          categoryId: widget.category.id,
          imageBytes: _selectedImage!,
        );

        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          },
          (urls) {
            thumbnailUrl = urls['thumbnail'];
            largeUrl = urls['large'];
          },
        );
      }

      // Create category using BLoC
      if (mounted) {
        context.read<CategoryBloc>().add(
          UpdateCategory(
            categoryId: widget.category.id,
            merchandiserId: widget.merchandiserId,
            name: JsonbHelper.createBilingualJson(
              _nameEnController.text.trim(),
              arabicValue: _nameArController.text.trim().isEmpty
                  ? null
                  : _nameArController.text.trim(),
            ),
            imageThumbnail: thumbnailUrl,
            image: largeUrl,
          ),
        );

        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Category'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _isUploading ? null : _pickImage,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.grey400),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _selectedImage != null
                          ? Image.memory(_selectedImage!, fit: BoxFit.cover)
                          : (widget.category.imageThumbnail != null
                                ? CachedNetworkImage(
                                    imageUrl: widget.category.imageThumbnail!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, error, stack) =>
                                        const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image, size: 40),
                                            SizedBox(height: 8),
                                            Text('Failed to load'),
                                          ],
                                        ),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate, size: 40),
                                      SizedBox(height: 8),
                                      Text('Click to add image'),
                                    ],
                                  )),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameEnController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name (English)*',
                    hintText: 'Enter category name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameArController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name (Arabic)',
                    hintText: 'Enter Arabic name (optional)',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _updateCategory,
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
