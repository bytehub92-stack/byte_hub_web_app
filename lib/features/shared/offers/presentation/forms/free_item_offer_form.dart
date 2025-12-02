import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/shared/offers/presentation/widgets/product_selector_dialog.dart';

import 'package:flutter/material.dart';

class FreeItemOfferForm extends StatefulWidget {
  final FreeItemOfferDetails? initialDetails;
  final Function(FreeItemOfferDetails) onDetailsChanged;

  const FreeItemOfferForm({
    super.key,
    this.initialDetails,
    required this.onDetailsChanged,
  });

  @override
  State<FreeItemOfferForm> createState() => _FreeItemOfferFormState();
}

class _FreeItemOfferFormState extends State<FreeItemOfferForm> {
  final _minPurchaseController = TextEditingController();
  List<FreeItemOption> _freeItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialDetails != null) {
      _minPurchaseController.text = widget.initialDetails!.minPurchaseAmount
          .toString();
      _freeItems = List.from(widget.initialDetails!.freeItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Free Item Configuration', style: AppTextStyles.h4Light),
        const SizedBox(height: AppConstants.defaultPadding),

        // Minimum Purchase
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Purchase Threshold',
                      style: AppTextStyles.bodyLargeLight.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                TextFormField(
                  controller: _minPurchaseController,
                  decoration: const InputDecoration(
                    labelText: 'Minimum Purchase Amount *',
                    hintText: '0.00',
                    prefixText: 'EGP ',
                    helperText:
                        'Customer must spend this amount to choose a free item',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _updateDetails(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Free Items
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.redeem, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Free Items to Choose From',
                        style: AppTextStyles.bodyLargeLight.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer will select ONE item from this list',
                  style: AppTextStyles.bodySmallLight.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Items List
                if (_freeItems.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No items added yet',
                          style: AppTextStyles.bodySmallLight.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...List.generate(_freeItems.length, (index) {
                    final item = _freeItems[index];
                    return _buildFreeItemCard(index, item);
                  }),

                const SizedBox(height: AppConstants.defaultPadding),

                OutlinedButton.icon(
                  onPressed: _addFreeItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Free Item Option'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.largePadding),

        // Preview
        if (_freeItems.isNotEmpty)
          Container(
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
                  'Spend EGP ${_minPurchaseController.text} or more and choose 1 free item from ${_freeItems.length} options',
                  style: AppTextStyles.bodyMediumLight,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFreeItemCard(int index, FreeItemOption item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: item.productImage.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  item.productImage,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image),
                ),
              )
            : const Icon(Icons.redeem),
        title: Text(item.productName),
        subtitle: Text('Qty: ${item.quantity}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editFreeItem(index, item),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
              onPressed: () => _removeFreeItem(index),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addFreeItem() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ProductSelectorDialog(),
    );

    if (result != null) {
      final quantityController = TextEditingController(text: '1');

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Set Quantity'),
          content: TextFormField(
            controller: quantityController,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              hintText: '1',
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final quantity = int.tryParse(quantityController.text) ?? 1;
        setState(() {
          _freeItems.add(
            FreeItemOption(
              productId: result['id'],
              productName: result['name'],
              productImage: result['image'] ?? '',
              quantity: quantity,
            ),
          );
        });
        _updateDetails();
      }

      quantityController.dispose();
    }
  }

  Future<void> _editFreeItem(int index, FreeItemOption item) async {
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item.productName}'),
        content: TextFormField(
          controller: quantityController,
          decoration: const InputDecoration(labelText: 'Quantity'),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final quantity = int.tryParse(quantityController.text) ?? 1;
      setState(() {
        _freeItems[index] = FreeItemOption(
          productId: item.productId,
          productName: item.productName,
          productImage: item.productImage,
          quantity: quantity,
        );
      });
      _updateDetails();
    }

    quantityController.dispose();
  }

  void _removeFreeItem(int index) {
    setState(() => _freeItems.removeAt(index));
    _updateDetails();
  }

  void _updateDetails() {
    if (_freeItems.isEmpty) return;

    final minPurchase = double.tryParse(_minPurchaseController.text) ?? 0;

    final details = FreeItemOfferDetails(
      minPurchaseAmount: minPurchase,
      freeItems: _freeItems,
    );

    widget.onDetailsChanged(details);
  }

  @override
  void dispose() {
    _minPurchaseController.dispose();
    super.dispose();
  }
}
