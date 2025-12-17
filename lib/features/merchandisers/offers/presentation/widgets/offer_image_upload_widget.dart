// lib/features/offers/presentation/widgets/offer_image_upload_widget.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/services/image_upload_service.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class OfferImageUploadWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String) onImageUrlChanged;
  final String merchandiserId;

  const OfferImageUploadWidget({
    super.key,
    this.initialImageUrl,
    required this.onImageUrlChanged,
    required this.merchandiserId,
  });

  @override
  State<OfferImageUploadWidget> createState() => _OfferImageUploadWidgetState();
}

class _OfferImageUploadWidgetState extends State<OfferImageUploadWidget> {
  final _urlController = TextEditingController();
  bool _isUploading = false;
  String _uploadMethod = 'url'; // 'url' or 'upload'

  @override
  void initState() {
    super.initState();
    if (widget.initialImageUrl != null) {
      _urlController.text = widget.initialImageUrl!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.image, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Offer Image',
                  style: AppTextStyles.bodyLargeLight.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Method Selector
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Image URL'),
                    value: 'url',
                    groupValue: _uploadMethod,
                    onChanged: (value) =>
                        setState(() => _uploadMethod = value!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Upload Image'),
                    value: 'upload',
                    groupValue: _uploadMethod,
                    onChanged: (value) =>
                        setState(() => _uploadMethod = value!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // URL Input or Upload Button
            if (_uploadMethod == 'url')
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL *',
                  hintText: 'https://example.com/image.jpg',
                  prefixIcon: Icon(Icons.link),
                ),
                onChanged: (value) => widget.onImageUrlChanged(value),
              )
            else
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickAndUploadImage,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file),
                    label: Text(
                      _isUploading ? 'Uploading...' : 'Choose & Upload Image',
                    ),
                  ),
                  if (_urlController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Image uploaded successfully',
                      style: AppTextStyles.bodySmallLight.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ],
              ),

            const SizedBox(height: AppConstants.defaultPadding),

            // Image Preview
            if (_urlController.text.isNotEmpty)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultRadius,
                  ),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultRadius,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: _urlController.text,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.grey200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.grey200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.broken_image,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: AppTextStyles.bodySmallLight.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultRadius,
                  ),
                  border: Border.all(
                    color: AppColors.grey300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No image selected',
                      style: AppTextStyles.bodySmallLight.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      setState(() => _isUploading = true);

      final imageUploadService = sl<ImageUploadService>();

      // Pick image
      final imageBytes = await imageUploadService.pickImage();
      if (imageBytes == null) {
        setState(() => _isUploading = false);
        return;
      }

      // Generate unique ID for offer image
      final offerId = const Uuid().v4();

      // Upload to Supabase Storage: offers/{merchandiser_id}/{offer_id}.jpg
      final result = await imageUploadService.uploadCategoryImage(
        merchandiserId: widget.merchandiserId,
        categoryId:
            'offer_$offerId', // Using category upload function for offers
        imageBytes: imageBytes,
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload failed: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          setState(() => _isUploading = false);
        },
        (data) {
          final imageUrl = data['url']!;
          setState(() {
            _urlController.text = imageUrl;
            _isUploading = false;
          });
          widget.onImageUrlChanged(imageUrl);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image uploaded successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
