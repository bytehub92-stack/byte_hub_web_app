import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/merchandisers/offers/presentation/widgets/bundle_item_dialog.dart';

import 'package:flutter/material.dart';

class BundleOfferForm extends StatefulWidget {
  final BundleOfferDetails? initialDetails;
  final Function(BundleOfferDetails) onDetailsChanged;

  const BundleOfferForm({
    super.key,
    this.initialDetails,
    required this.onDetailsChanged,
  });

  @override
  State<BundleOfferForm> createState() => _BundleOfferFormState();
}

class _BundleOfferFormState extends State<BundleOfferForm> {
  final _bundlePriceController = TextEditingController();
  List<BundleItem> _items = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialDetails != null) {
      _items = List.from(widget.initialDetails!.items);
      _bundlePriceController.text =
          widget.initialDetails!.bundlePrice.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Bundle Items', style: AppTextStyles.h4Light)),
            if (_items.isNotEmpty)
              Text(
                '${_items.length} items',
                style: AppTextStyles.bodySmallLight.copyWith(
                  color: AppColors.grey500,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Items List
        if (_items.isNotEmpty) ...[
          ..._items.asMap().entries.map((entry) {
            return _buildBundleItemCard(entry.key, entry.value);
          }),
          const SizedBox(height: AppConstants.defaultPadding),
        ] else
          Container(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              border: Border.all(
                color: AppColors.borderLight,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No items in bundle',
                    style: AppTextStyles.bodyMediumLight.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add at least 2 products to create a bundle',
                    style: AppTextStyles.bodySmallLight.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Add Item Button
        OutlinedButton.icon(
          onPressed: _showAddItemDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Product to Bundle'),
        ),

        const SizedBox(height: AppConstants.largePadding),

        // Bundle Price
        TextFormField(
          controller: _bundlePriceController,
          decoration: InputDecoration(
            labelText: 'Bundle Price (Total) *',
            hintText: '0.00',
            prefixText: 'EGP ',
            helperText: _items.length < 2
                ? 'Add at least 2 products first'
                : 'Price for the entire bundle',
            enabled: _items.length >= 2,
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => _updateDetails(),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Savings Preview
        if (_items.length >= 2 && _bundlePriceController.text.isNotEmpty)
          _buildSavingsPreview(),
      ],
    );
  }

  Widget _buildBundleItemCard(int index, BundleItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: ListTile(
        leading: item.productImage.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  item.productImage,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: AppColors.grey500,
                    ),
                  ),
                ),
              )
            : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.inventory_2, color: AppColors.primary),
              ),
        title: Text(
          item.productName,
          style: AppTextStyles.bodyMediumLight.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Qty: ${item.quantity} × EGP ${item.productPrice.toStringAsFixed(2)} = EGP ${(item.quantity * item.productPrice).toStringAsFixed(2)}',
          style: AppTextStyles.bodySmallLight,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editItem(index, item),
              tooltip: 'Edit quantity',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _removeItem(index),
              tooltip: 'Remove item',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsPreview() {
    final originalTotal = _items.fold<double>(
      0,
      (sum, item) => sum + (item.productPrice * item.quantity),
    );
    final bundlePrice = double.tryParse(_bundlePriceController.text) ?? 0;
    final savings = originalTotal - bundlePrice;
    final savingsPercent =
        originalTotal > 0 ? (savings / originalTotal) * 100 : 0;

    final isValidBundle = bundlePrice > 0 && bundlePrice < originalTotal;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: isValidBundle
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: isValidBundle ? AppColors.success : AppColors.warning,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValidBundle ? Icons.check_circle : Icons.warning,
                color: isValidBundle ? AppColors.success : AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isValidBundle ? 'Bundle Preview' : 'Bundle Warning',
                style: AppTextStyles.bodyLargeLight.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isValidBundle ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Original Total:', style: AppTextStyles.bodyMediumLight),
              Text(
                'EGP ${originalTotal.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMediumLight.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bundle Price:', style: AppTextStyles.bodyMediumLight),
              Text(
                'EGP ${bundlePrice.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMediumLight.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isValidBundle ? 'Customer Saves:' : 'Invalid Bundle:',
                style: AppTextStyles.bodyLargeLight.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isValidBundle
                    ? 'EGP ${savings.toStringAsFixed(2)} (${savingsPercent.toStringAsFixed(1)}%)'
                    : bundlePrice >= originalTotal
                        ? 'Price must be lower'
                        : 'Enter bundle price',
                style: AppTextStyles.bodyLargeLight.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isValidBundle ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showAddItemDialog() async {
    final result = await showDialog<BundleItem>(
      context: context,
      builder: (context) => const BundleItemDialog(),
    );

    if (result != null) {
      // Check if product already exists
      final existingIndex = _items.indexWhere(
        (item) => item.productId == result.productId,
      );

      if (existingIndex != -1) {
        // Show warning that product already exists
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.productName} is already in the bundle'),
              backgroundColor: AppColors.warning,
              action: SnackBarAction(
                label: 'Update',
                textColor: AppColors.white,
                onPressed: () {
                  setState(() => _items[existingIndex] = result);
                  _updateDetails();
                },
              ),
            ),
          );
        }
      } else {
        setState(() => _items.add(result));
        _updateDetails();
      }
    }
  }

  Future<void> _editItem(int index, BundleItem item) async {
    final result = await showDialog<BundleItem>(
      context: context,
      builder: (context) => BundleItemDialog(initialItem: item),
    );

    if (result != null) {
      setState(() => _items[index] = result);
      _updateDetails();
    }
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
    _updateDetails();
  }

  void _updateDetails() {
    if (_items.length < 2) {
      // Don't update details if we don't have at least 2 items
      return;
    }

    final originalTotal = _items.fold<double>(
      0,
      (sum, item) => sum + (item.productPrice * item.quantity),
    );
    final bundlePrice = double.tryParse(_bundlePriceController.text) ?? 0;

    // Only update if bundle price is valid
    if (bundlePrice > 0 && bundlePrice < originalTotal) {
      final details = BundleOfferDetails(
        items: _items,
        bundlePrice: bundlePrice,
        originalTotalPrice: originalTotal,
      );

      widget.onDetailsChanged(details);
    }
  }

  @override
  void dispose() {
    _bundlePriceController.dispose();
    super.dispose();
  }
}
