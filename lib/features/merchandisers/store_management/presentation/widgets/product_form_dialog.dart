import 'dart:typed_data';

import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/services/image_upload_service.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/core/usecases/usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/product_bloc/product_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/product_bloc/product_event.dart';

import 'package:admin_panel/features/shared/shared_feature/domain/entities/product.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/unit_of_measurement.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_units_usecase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductFormDialog extends StatefulWidget {
  final String merchandiserId;
  final String categoryId;
  final String subCategoryId;
  final Product? product;

  const ProductFormDialog({
    super.key,
    required this.merchandiserId,
    required this.categoryId,
    required this.subCategoryId,
    this.product,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _imageUploadService = sl<ImageUploadService>();
  final _getUnitsUsecase = sl<GetUnitsUsecase>();

  // Image management
  final List<Uint8List> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool _isUploading = false;

  // Units of Measurement
  List<UnitOfMeasurement> _units = [];
  bool _isLoadingUnits = true;
  String? _selectedUnitId;

  // Text Controllers
  late TextEditingController _nameEnController;
  late TextEditingController _nameArController;
  late TextEditingController _descEnController;
  late TextEditingController _descArController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _skuController;
  late TextEditingController _discountPriceController;
  late TextEditingController _costPriceController;
  late TextEditingController _weightController;

  // Form Values
  bool _isAvailable = true;
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    setState(() {
      _isLoadingUnits = true;
    });

    final result = await _getUnitsUsecase(NoParams());

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load units: ${failure.message}'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() {
          _isLoadingUnits = false;
        });
      },
      (units) {
        setState(() {
          _units = units;
          _isLoadingUnits = false;
        });
      },
    );
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length + _existingImageUrls.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 images allowed'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final imageBytes = await _imageUploadService.pickImage();
    if (imageBytes != null) {
      setState(() {
        _selectedImages.add(imageBytes);
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _initializeControllers() {
    final product = widget.product;
    _nameEnController = TextEditingController(text: product?.name['en'] ?? '');
    _nameArController = TextEditingController(text: product?.name['ar'] ?? '');
    _descEnController = TextEditingController(
      text: product?.description['en'] ?? '',
    );
    _descArController = TextEditingController(
      text: product?.description['ar'] ?? '',
    );
    _priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: product?.stockQuantity.toString() ?? '',
    );
    _skuController = TextEditingController(text: product?.sku ?? '');
    _discountPriceController = TextEditingController(
      text: product?.discountPrice?.toString() ?? '',
    );
    _costPriceController = TextEditingController(
      text: product?.costPrice?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: product?.weight?.toString() ?? '',
    );

    _existingImageUrls = List.from(product?.images ?? []);
    _isAvailable = product?.isAvailable ?? true;
    _isFeatured = product?.isFeatured ?? false;
    _selectedUnitId = product?.unitOfMeasurementId;
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _descEnController.dispose();
    _descArController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    _discountPriceController.dispose();
    _costPriceController.dispose();
    _weightController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.product != null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a unit of measurement'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedImages.isEmpty && _existingImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload new images if any
      List<String> newImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final productId =
            widget.product?.id ??
            DateTime.now().millisecondsSinceEpoch.toString();

        final result = await _imageUploadService.uploadProductImages(
          merchandiserId: widget.merchandiserId,
          productId: productId,
          imageBytesList: _selectedImages,
        );

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image upload failed: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
            setState(() {
              _isUploading = false;
            });
            return;
          },
          (urls) {
            newImageUrls = urls;
          },
        );
      }

      // Combine existing and new image URLs
      final allImageUrls = [..._existingImageUrls, ...newImageUrls];

      final name = {
        'en': _nameEnController.text.trim(),
        'ar': _nameArController.text.trim(),
      };

      final description = {
        'en': _descEnController.text.trim(),
        'ar': _descArController.text.trim(),
      };

      if (_isEditing) {
        context.read<ProductBloc>().add(
          UpdateProduct(
            productId: widget.product!.id,
            name: name,
            description: description,
            price: double.parse(_priceController.text),
            images: allImageUrls,
            stockQuantity: int.parse(_stockController.text),
            unitOfMeasurementId: _selectedUnitId!,
            sku: _skuController.text.trim().isEmpty
                ? null
                : _skuController.text.trim(),
            isAvailable: _isAvailable,
            isFeatured: _isFeatured,
            discountPrice: _discountPriceController.text.trim().isEmpty
                ? null
                : double.parse(_discountPriceController.text),
            costPrice: _costPriceController.text.trim().isEmpty
                ? null
                : double.parse(_costPriceController.text),
            weight: _weightController.text.trim().isEmpty
                ? null
                : double.parse(_weightController.text),
            subCategoryId: widget.subCategoryId,
          ),
        );
      } else {
        context.read<ProductBloc>().add(
          CreateProduct(
            merchandiserId: widget.merchandiserId,
            categoryId: widget.categoryId,
            subCategoryId: widget.subCategoryId,
            name: name,
            description: description,
            price: double.parse(_priceController.text),
            images: allImageUrls,
            stockQuantity: int.parse(_stockController.text),
            unitOfMeasurementId: _selectedUnitId!,
            sku: _skuController.text.trim().isEmpty
                ? null
                : _skuController.text.trim(),
            isAvailable: _isAvailable,
            isFeatured: _isFeatured,
            discountPrice: _discountPriceController.text.trim().isEmpty
                ? null
                : double.parse(_discountPriceController.text),
            costPrice: _costPriceController.text.trim().isEmpty
                ? null
                : double.parse(_costPriceController.text),
            weight: _weightController.text.trim().isEmpty
                ? null
                : double.parse(_weightController.text),
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection('Product Images', _buildImageSection()),
                        const SizedBox(height: 24),
                        _buildSection('Basic Information', _buildBasicInfo()),
                        const SizedBox(height: 24),
                        _buildSection('Pricing', _buildPricingInfo()),
                        const SizedBox(height: 24),
                        _buildSection('Inventory', _buildInventoryInfo()),
                        const SizedBox(height: 24),
                        _buildSection(
                          'Additional Details',
                          _buildAdditionalInfo(),
                        ),
                        const SizedBox(height: 24),
                        _buildSection('Settings', _buildSettings()),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          _isEditing ? Icons.edit : Icons.add_circle_outline,
          color: AppColors.primary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _isEditing ? 'Edit Product' : 'Create Product',
            style: AppTextStyles.h3Light,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h4Light.copyWith(color: AppColors.primary),
        ),
        const Divider(height: 16),
        child,
      ],
    );
  }

  Widget _buildImageSection() {
    final totalImages = _existingImageUrls.length + _selectedImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Images ($totalImages/5)',
              style: AppTextStyles.bodyMediumLight.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'First image will be primary',
              style: AppTextStyles.bodySmallLight.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Display existing images
        if (_existingImageUrls.isNotEmpty) ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _existingImageUrls.asMap().entries.map((entry) {
              final index = entry.key;
              final url = entry.value;
              return _buildExistingImageThumbnail(url, index);
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Display newly selected images
        if (_selectedImages.isNotEmpty) ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _selectedImages.asMap().entries.map((entry) {
              final index = entry.key;
              final imageBytes = entry.value;
              return _buildNewImageThumbnail(imageBytes, index);
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Add image button
        if (totalImages < 5)
          OutlinedButton.icon(
            onPressed: _isUploading ? null : _pickImage,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add Image'),
          ),
      ],
    );
  }

  Widget _buildExistingImageThumbnail(String url, int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 40);
              },
            ),
          ),
        ),
        if (index == 0 && _selectedImages.isEmpty)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Primary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              padding: const EdgeInsets.all(4),
            ),
            onPressed: () => _removeExistingImage(index),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImageThumbnail(Uint8List imageBytes, int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(imageBytes, fit: BoxFit.cover),
          ),
        ),
        if (index == 0 && _existingImageUrls.isEmpty)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Primary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              padding: const EdgeInsets.all(4),
            ),
            onPressed: () => _removeNewImage(index),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'New',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameEnController,
          label: 'Product Name (English)',
          hint: 'Enter product name in English',
          icon: Icons.title,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter product name in English';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameArController,
          label: 'Product Name (Arabic)',
          hint: 'أدخل اسم المنتج بالعربية',
          icon: Icons.title,
          textDirection: TextDirection.rtl,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter product name in Arabic';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descEnController,
          label: 'Description (English)',
          hint: 'Enter product description in English',
          icon: Icons.description,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descArController,
          label: 'Description (Arabic)',
          hint: 'أدخل وصف المنتج بالعربية',
          icon: Icons.description,
          textDirection: TextDirection.rtl,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPricingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _priceController,
                label: 'Price',
                hint: '0.00',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid price';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _discountPriceController,
                label: 'Discount Price (Optional)',
                hint: '0.00',
                icon: Icons.discount,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _costPriceController,
                label: 'Cost Price (Optional)',
                hint: '0.00',
                icon: Icons.money_off,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _weightController,
                label: 'Weight (kg) (Optional)',
                hint: '0.0',
                icon: Icons.scale,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _stockController,
                label: 'Stock Quantity',
                hint: '0',
                icon: Icons.inventory,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter valid quantity';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _skuController,
                label: 'SKU (Optional)',
                hint: 'PROD-001',
                icon: Icons.qr_code,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Unit of Measurement Dropdown
        _buildUnitDropdown(),
      ],
    );
  }

  Widget _buildUnitDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unit of Measurement *',
          style: AppTextStyles.bodyMediumLight.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoadingUnits)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          DropdownButtonFormField<String>(
            initialValue: _selectedUnitId,
            decoration: InputDecoration(
              hintText: 'Select unit',
              prefixIcon: const Icon(Icons.straighten),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: _units.map((unit) {
              return DropdownMenuItem<String>(
                value: unit.id,
                child: Row(
                  children: [
                    Text(unit.name['en'] ?? ''),
                    const Text(' / '),
                    Text(
                      unit.name['ar'] ?? '',
                      style: const TextStyle(fontFamily: 'Cairo'),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedUnitId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a unit of measurement';
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return const Text(
      'Additional settings like tags can be added here',
      style: TextStyle(color: AppColors.grey500),
    );
  }

  Widget _buildSettings() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Available'),
          subtitle: Text(
            _isAvailable
                ? 'Product is available for purchase'
                : 'Product is not available',
            style: AppTextStyles.bodySmallLight,
          ),
          value: _isAvailable,
          onChanged: (value) {
            setState(() {
              _isAvailable = value;
            });
          },
          activeThumbColor: AppColors.primary,
        ),
        SwitchListTile(
          title: const Text('Featured'),
          subtitle: Text(
            _isFeatured
                ? 'Product will be featured'
                : 'Product is not featured',
            style: AppTextStyles.bodySmallLight,
          ),
          value: _isFeatured,
          onChanged: (value) {
            setState(() {
              _isFeatured = value;
            });
          },
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    TextDirection? textDirection,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMediumLight.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textDirection: textDirection,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _submit,
          icon: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(_isEditing ? Icons.save : Icons.add),
          label: Text(
            _isUploading
                ? 'Uploading...'
                : (_isEditing ? 'Update Product' : 'Create Product'),
          ),
        ),
      ],
    );
  }
}
