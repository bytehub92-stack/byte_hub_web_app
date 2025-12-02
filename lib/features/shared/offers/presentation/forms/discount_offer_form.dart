import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/shared/offers/presentation/widgets/category_selector_dialog.dart';
import 'package:admin_panel/features/shared/offers/presentation/widgets/product_selector_dialog.dart';
import 'package:admin_panel/features/shared/offers/presentation/widgets/sub_category_selector_dialog.dart';

import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';
import 'package:flutter/material.dart';

class DiscountOfferForm extends StatefulWidget {
  final DiscountOfferDetails? initialDetails;
  final Function(DiscountOfferDetails) onDetailsChanged;

  const DiscountOfferForm({
    super.key,
    this.initialDetails,
    required this.onDetailsChanged,
  });

  @override
  State<DiscountOfferForm> createState() => _DiscountOfferFormState();
}

class _DiscountOfferFormState extends State<DiscountOfferForm> {
  final _discountValueController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  final _minPurchaseController = TextEditingController();

  String _applicableTo = 'all'; // all, product, category, subcategory
  bool _isPercentage = true;

  // Selected items
  String? _selectedProductId;
  String? _selectedProductName;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedSubCategoryId;
  String? _selectedSubCategoryName;

  @override
  void initState() {
    super.initState();
    if (widget.initialDetails != null) {
      final details = widget.initialDetails!;
      _discountValueController.text = details.discountValue.toString();
      _maxDiscountController.text = details.maxDiscountAmount?.toString() ?? '';
      _minPurchaseController.text = details.minPurchaseAmount?.toString() ?? '';
      _isPercentage = details.isPercentage;

      if (details.productId != null) {
        _applicableTo = 'product';
        _selectedProductId = details.productId;
        // You might want to fetch product name if needed
      } else if (details.subCategoryId != null) {
        _applicableTo = 'subcategory';
        _selectedSubCategoryId = details.subCategoryId;
        // You might want to fetch subcategory name if needed
      } else if (details.categoryId != null) {
        _applicableTo = 'category';
        _selectedCategoryId = details.categoryId;
        // You might want to fetch category name if needed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Discount Configuration', style: AppTextStyles.h4Light),
        const SizedBox(height: AppConstants.defaultPadding),

        // Discount Type
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discount Type',
                  style: AppTextStyles.bodyLargeLight.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Percentage (%)'),
                        value: true,
                        groupValue: _isPercentage,
                        onChanged: (value) {
                          setState(() => _isPercentage = value!);
                          _updateDetails();
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Fixed Amount (EGP)'),
                        value: false,
                        groupValue: _isPercentage,
                        onChanged: (value) {
                          setState(() => _isPercentage = value!);
                          _updateDetails();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Discount Value
        TextFormField(
          controller: _discountValueController,
          decoration: InputDecoration(
            labelText: 'Discount Value *',
            hintText: _isPercentage ? '0-100' : '0.00',
            prefixText: _isPercentage ? null : 'EGP ',
            suffixText: _isPercentage ? '%' : null,
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => _updateDetails(),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Max Discount (for percentage only)
        if (_isPercentage)
          TextFormField(
            controller: _maxDiscountController,
            decoration: const InputDecoration(
              labelText: 'Maximum Discount Amount (Optional)',
              hintText: '0.00',
              prefixText: 'EGP ',
              helperText: 'Cap the discount to a maximum amount',
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _updateDetails(),
          ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Min Purchase
        TextFormField(
          controller: _minPurchaseController,
          decoration: const InputDecoration(
            labelText: 'Minimum Purchase Amount (Optional)',
            hintText: '0.00',
            prefixText: 'EGP ',
            helperText: 'Minimum cart value to apply discount',
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => _updateDetails(),
        ),

        const SizedBox(height: AppConstants.largePadding),

        // Applicable To
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apply Discount To',
                  style: AppTextStyles.bodyLargeLight.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: const Text('All Products (Store-wide)'),
                  subtitle: const Text('Discount applies to entire store'),
                  value: 'all',
                  groupValue: _applicableTo,
                  onChanged: (value) {
                    setState(() {
                      _applicableTo = value!;
                      _clearSelections();
                    });
                    _updateDetails();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Specific Product'),
                  subtitle: const Text('Discount applies to one product'),
                  value: 'product',
                  groupValue: _applicableTo,
                  onChanged: (value) {
                    setState(() {
                      _applicableTo = value!;
                      _clearSelections();
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Specific Category'),
                  subtitle: const Text(
                    'Discount applies to all products in category',
                  ),
                  value: 'category',
                  groupValue: _applicableTo,
                  onChanged: (value) {
                    setState(() {
                      _applicableTo = value!;
                      _clearSelections();
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Specific Sub-Category'),
                  subtitle: const Text(
                    'Discount applies to all products in sub-category',
                  ),
                  value: 'subcategory',
                  groupValue: _applicableTo,
                  onChanged: (value) {
                    setState(() {
                      _applicableTo = value!;
                      _clearSelections();
                    });
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Selection UI based on applicable_to
        if (_applicableTo == 'product') _buildProductSelection(),
        if (_applicableTo == 'category') _buildCategorySelection(),
        if (_applicableTo == 'subcategory') _buildSubCategorySelection(),

        const SizedBox(height: AppConstants.largePadding),

        // Preview of discount
        if (_applicableTo != 'all' && _hasValidSelection())
          _buildDiscountPreview(),
      ],
    );
  }

  Widget _buildProductSelection() {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Product',
              style: AppTextStyles.bodyLargeLight.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedProductId != null)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.smallPadding),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultRadius,
                        ),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.inventory_2,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedProductName ?? 'Product Selected',
                              style: AppTextStyles.bodyMediumLight,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedProductId = null;
                                _selectedProductName = null;
                              });
                              _updateDetails();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: _selectProduct,
                icon: const Icon(Icons.search),
                label: const Text('Select Product'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Card(
      color: AppColors.secondary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Category',
              style: AppTextStyles.bodyLargeLight.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedCategoryId != null)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.smallPadding),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultRadius,
                        ),
                        border: Border.all(color: AppColors.secondary),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.category,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedCategoryName ?? 'Category Selected',
                              style: AppTextStyles.bodyMediumLight,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedCategoryId = null;
                                _selectedCategoryName = null;
                              });
                              _updateDetails();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: _selectCategory,
                icon: const Icon(Icons.search),
                label: const Text('Select Category'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategorySelection() {
    return Card(
      color: AppColors.accent.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Sub-Category',
              style: AppTextStyles.bodyLargeLight.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedSubCategoryId != null)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.smallPadding),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultRadius,
                        ),
                        border: Border.all(color: AppColors.accent),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.folder, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedSubCategoryName ??
                                  'Sub-Category Selected',
                              style: AppTextStyles.bodyMediumLight,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedSubCategoryId = null;
                                _selectedSubCategoryName = null;
                              });
                              _updateDetails();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: _selectSubCategory,
                icon: const Icon(Icons.search),
                label: const Text('Select Sub-Category'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountPreview() {
    final discountValue = double.tryParse(_discountValueController.text) ?? 0;
    final discountText = _isPercentage
        ? '$discountValue% OFF'
        : 'EGP $discountValue OFF';

    String targetText = '';
    if (_applicableTo == 'product' && _selectedProductName != null) {
      targetText = 'on $_selectedProductName';
    } else if (_applicableTo == 'category' && _selectedCategoryName != null) {
      targetText = 'on all products in $_selectedCategoryName';
    } else if (_applicableTo == 'subcategory' &&
        _selectedSubCategoryName != null) {
      targetText = 'on all products in $_selectedSubCategoryName';
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: AppColors.info),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.preview, color: AppColors.info),
              const SizedBox(width: 8),
              Text(
                'Offer Preview',
                style: AppTextStyles.bodyLargeLight.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$discountText $targetText',
            style: AppTextStyles.bodyMediumLight.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_minPurchaseController.text.isNotEmpty)
            Text(
              'Minimum purchase: EGP ${_minPurchaseController.text}',
              style: AppTextStyles.bodySmallLight,
            ),
          if (_isPercentage && _maxDiscountController.text.isNotEmpty)
            Text(
              'Maximum discount: EGP ${_maxDiscountController.text}',
              style: AppTextStyles.bodySmallLight,
            ),
        ],
      ),
    );
  }

  Future<void> _selectProduct() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ProductSelectorDialog(),
    );

    if (result != null) {
      setState(() {
        _selectedProductId = result['id'];
        _selectedProductName = result['name'];
      });
      _updateDetails();
    }
  }

  Future<void> _selectCategory() async {
    final result = await showDialog<Category>(
      context: context,
      builder: (context) => const CategorySelectorDialog(),
    );

    if (result != null) {
      setState(() {
        _selectedCategoryId = result.id;
        _selectedCategoryName = result.name['en'] ?? 'Unknown';
      });
      _updateDetails();
    }
  }

  Future<void> _selectSubCategory() async {
    final result = await showDialog<SubCategory>(
      context: context,
      builder: (context) => const SubCategorySelectorDialog(),
    );

    if (result != null) {
      setState(() {
        _selectedSubCategoryId = result.id;
        _selectedSubCategoryName = result.name['en'] ?? 'Unknown';
      });
      _updateDetails();
    }
  }

  void _clearSelections() {
    _selectedProductId = null;
    _selectedProductName = null;
    _selectedCategoryId = null;
    _selectedCategoryName = null;
    _selectedSubCategoryId = null;
    _selectedSubCategoryName = null;
  }

  bool _hasValidSelection() {
    switch (_applicableTo) {
      case 'product':
        return _selectedProductId != null;
      case 'category':
        return _selectedCategoryId != null;
      case 'subcategory':
        return _selectedSubCategoryId != null;
      default:
        return true;
    }
  }

  void _updateDetails() {
    final discountValue = double.tryParse(_discountValueController.text) ?? 0;
    final maxDiscount = _maxDiscountController.text.isEmpty
        ? null
        : double.tryParse(_maxDiscountController.text);
    final minPurchase = _minPurchaseController.text.isEmpty
        ? null
        : double.tryParse(_minPurchaseController.text);

    final details = DiscountOfferDetails(
      productId: _applicableTo == 'product' ? _selectedProductId : null,
      categoryId: _applicableTo == 'category' ? _selectedCategoryId : null,
      subCategoryId: _applicableTo == 'subcategory'
          ? _selectedSubCategoryId
          : null,
      discountValue: discountValue,
      isPercentage: _isPercentage,
      maxDiscountAmount: maxDiscount,
      minPurchaseAmount: minPurchase,
    );

    widget.onDetailsChanged(details);
  }

  @override
  void dispose() {
    _discountValueController.dispose();
    _maxDiscountController.dispose();
    _minPurchaseController.dispose();
    super.dispose();
  }
}
