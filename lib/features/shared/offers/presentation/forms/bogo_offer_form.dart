import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/shared/offers/presentation/widgets/product_selector_dialog.dart';

import 'package:flutter/material.dart';

class BOGOOfferForm extends StatefulWidget {
  final BOGOOfferDetails? initialDetails;
  final Function(BOGOOfferDetails) onDetailsChanged;

  const BOGOOfferForm({
    super.key,
    this.initialDetails,
    required this.onDetailsChanged,
  });

  @override
  State<BOGOOfferForm> createState() => _BOGOOfferFormState();
}

class _BOGOOfferFormState extends State<BOGOOfferForm> {
  final _buyQuantityController = TextEditingController(text: '1');
  final _getQuantityController = TextEditingController(text: '1');

  String? _buyProductId;
  String? _buyProductName;
  String? _buyProductImage;

  String? _getProductId;
  String? _getProductName;
  String? _getProductImage;

  @override
  void initState() {
    super.initState();
    if (widget.initialDetails != null) {
      final details = widget.initialDetails!;
      _buyQuantityController.text = details.buyQuantity.toString();
      _getQuantityController.text = details.getQuantity.toString();
      _buyProductId = details.buyProductId;
      _buyProductName = details.buyProductName;
      _buyProductImage = details.buyProductImage;
      _getProductId = details.getProductId;
      _getProductName = details.getProductName;
      _getProductImage = details.getProductImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BOGO Configuration', style: AppTextStyles.h4Light),
        const SizedBox(height: AppConstants.defaultPadding),

        // Buy Section
        Card(
          color: AppColors.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_bag, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Buy Product',
                      style: AppTextStyles.bodyLargeLight.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                if (_buyProductId != null)
                  _buildProductCard(
                    _buyProductName!,
                    _buyProductImage,
                    onRemove: () {
                      setState(() {
                        _buyProductId = null;
                        _buyProductName = null;
                        _buyProductImage = null;
                      });
                      _updateDetails();
                    },
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => _selectProduct(isBuyProduct: true),
                    icon: const Icon(Icons.add),
                    label: const Text('Select Product to Buy'),
                  ),

                const SizedBox(height: AppConstants.defaultPadding),

                TextFormField(
                  controller: _buyQuantityController,
                  decoration: const InputDecoration(
                    labelText: 'Buy Quantity *',
                    hintText: '1',
                    helperText: 'Number of items customer must buy',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _updateDetails(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.largePadding),

        // Get Section
        Card(
          color: AppColors.success.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.card_giftcard, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      'Get Free Product',
                      style: AppTextStyles.bodyLargeLight.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                if (_getProductId != null)
                  _buildProductCard(
                    _getProductName!,
                    _getProductImage,
                    onRemove: () {
                      setState(() {
                        _getProductId = null;
                        _getProductName = null;
                        _getProductImage = null;
                      });
                      _updateDetails();
                    },
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => _selectProduct(isBuyProduct: false),
                    icon: const Icon(Icons.add),
                    label: const Text('Select Free Product'),
                  ),

                const SizedBox(height: AppConstants.defaultPadding),

                TextFormField(
                  controller: _getQuantityController,
                  decoration: const InputDecoration(
                    labelText: 'Get Quantity *',
                    hintText: '1',
                    helperText: 'Number of free items',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _updateDetails(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.largePadding),

        // Example Preview
        if (_buyProductId != null && _getProductId != null)
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
                  'Buy ${_buyQuantityController.text}x $_buyProductName, Get ${_getQuantityController.text}x $_getProductName FREE!',
                  style: AppTextStyles.bodyMediumLight,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(
    String name,
    String? imageUrl, {
    required VoidCallback onRemove,
  }) {
    return Card(
      child: ListTile(
        leading: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image),
                ),
              )
            : const Icon(Icons.inventory_2),
        title: Text(name, style: AppTextStyles.bodyMediumLight),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: AppColors.error),
          onPressed: onRemove,
        ),
      ),
    );
  }

  Future<void> _selectProduct({required bool isBuyProduct}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ProductSelectorDialog(),
    );

    if (result != null) {
      setState(() {
        if (isBuyProduct) {
          _buyProductId = result['id'];
          _buyProductName = result['name'];
          _buyProductImage = result['image'];
        } else {
          _getProductId = result['id'];
          _getProductName = result['name'];
          _getProductImage = result['image'];
        }
      });
      _updateDetails();
    }
  }

  void _updateDetails() {
    if (_buyProductId == null || _getProductId == null) return;

    final buyQuantity = int.tryParse(_buyQuantityController.text) ?? 1;
    final getQuantity = int.tryParse(_getQuantityController.text) ?? 1;

    final details = BOGOOfferDetails(
      buyProductId: _buyProductId!,
      buyQuantity: buyQuantity,
      getProductId: _getProductId!,
      getQuantity: getQuantity,
      buyProductName: _buyProductName!,
      getProductName: _getProductName!,
      buyProductImage: _buyProductImage ?? '',
      getProductImage: _getProductImage ?? '',
    );

    widget.onDetailsChanged(details);
  }

  @override
  void dispose() {
    _buyQuantityController.dispose();
    _getQuantityController.dispose();
    super.dispose();
  }
}
