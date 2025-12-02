import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:flutter/material.dart';

class MinPurchaseOfferForm extends StatefulWidget {
  final MinPurchaseOfferDetails? initialDetails;
  final Function(MinPurchaseOfferDetails) onDetailsChanged;

  const MinPurchaseOfferForm({
    super.key,
    this.initialDetails,
    required this.onDetailsChanged,
  });

  @override
  State<MinPurchaseOfferForm> createState() => _MinPurchaseOfferFormState();
}

class _MinPurchaseOfferFormState extends State<MinPurchaseOfferForm> {
  final _minPurchaseController = TextEditingController();
  final _discountValueController = TextEditingController();

  bool _hasDiscount = true;
  bool _isPercentage = true;
  bool _freeShipping = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDetails != null) {
      final details = widget.initialDetails!;
      _minPurchaseController.text = details.minPurchaseAmount.toString();
      _discountValueController.text = details.discountValue?.toString() ?? '';
      _hasDiscount = details.discountValue != null;
      _isPercentage = details.isPercentage ?? true;
      _freeShipping = details.freeShipping;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Minimum Purchase Configuration', style: AppTextStyles.h4Light),
        const SizedBox(height: AppConstants.defaultPadding),

        // Minimum Purchase Amount
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
                    helperText: 'Customer must spend this amount or more',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _updateDetails(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Benefits Section
        Card(
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
                      'Benefits',
                      style: AppTextStyles.bodyLargeLight.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Free Shipping Toggle
                SwitchListTile(
                  title: const Text('Free Shipping'),
                  subtitle: const Text('Waive shipping fees'),
                  value: _freeShipping,
                  onChanged: (value) {
                    setState(() => _freeShipping = value);
                    _updateDetails();
                  },
                  contentPadding: EdgeInsets.zero,
                ),

                const Divider(),

                // Discount Toggle
                SwitchListTile(
                  title: const Text('Add Discount'),
                  subtitle: const Text('Apply additional discount'),
                  value: _hasDiscount,
                  onChanged: (value) {
                    setState(() => _hasDiscount = value);
                    _updateDetails();
                  },
                  contentPadding: EdgeInsets.zero,
                ),

                if (_hasDiscount) ...[
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Discount Type
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
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Fixed Amount'),
                          value: false,
                          groupValue: _isPercentage,
                          onChanged: (value) {
                            setState(() => _isPercentage = value!);
                            _updateDetails();
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

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
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.largePadding),

        // Preview
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
              Text(_buildPreviewText(), style: AppTextStyles.bodyMediumLight),
            ],
          ),
        ),
      ],
    );
  }

  String _buildPreviewText() {
    final minAmount = _minPurchaseController.text;
    final List<String> benefits = [];

    if (_freeShipping) {
      benefits.add('Free Shipping');
    }

    if (_hasDiscount && _discountValueController.text.isNotEmpty) {
      final discount = _isPercentage
          ? '${_discountValueController.text}% Discount'
          : 'EGP ${_discountValueController.text} Off';
      benefits.add(discount);
    }

    if (benefits.isEmpty) {
      return 'Spend EGP $minAmount or more';
    }

    return 'Spend EGP $minAmount or more and get: ${benefits.join(" + ")}';
  }

  void _updateDetails() {
    final minPurchase = double.tryParse(_minPurchaseController.text) ?? 0;
    final discountValue = _hasDiscount
        ? double.tryParse(_discountValueController.text)
        : null;

    final details = MinPurchaseOfferDetails(
      minPurchaseAmount: minPurchase,
      discountValue: discountValue,
      isPercentage: _hasDiscount ? _isPercentage : null,
      freeShipping: _freeShipping,
    );

    widget.onDetailsChanged(details);
  }

  @override
  void dispose() {
    _minPurchaseController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }
}
