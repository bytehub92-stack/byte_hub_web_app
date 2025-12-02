// lib/features/offers/presentation/pages/create_offer_page.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/shared/offers/presentation/bloc/offers_bloc.dart';
import 'package:admin_panel/features/shared/offers/presentation/bloc/offers_event.dart';
import 'package:admin_panel/features/shared/offers/presentation/forms/bogo_offer_form.dart';
import 'package:admin_panel/features/shared/offers/presentation/forms/bundle_offer_form.dart';
import 'package:admin_panel/features/shared/offers/presentation/forms/discount_offer_form.dart';
import 'package:admin_panel/features/shared/offers/presentation/forms/free_item_offer_form.dart';
import 'package:admin_panel/features/shared/offers/presentation/forms/min_purchase_offer_form.dart';
import 'package:admin_panel/features/shared/offers/presentation/widgets/offer_image_upload_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class CreateOfferPage extends StatefulWidget {
  final Offer? offer; // null for create, non-null for edit

  const CreateOfferPage({super.key, this.offer});

  @override
  State<CreateOfferPage> createState() => _CreateOfferPageState();
}

class _CreateOfferPageState extends State<CreateOfferPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  late final AuthService authService;

  // Step management
  int _currentStep = 0;

  // Common fields
  final _titleEnController = TextEditingController();
  final _titleArController = TextEditingController();
  final _descriptionEnController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _sortOrderController = TextEditingController(text: '1');

  OfferType? _selectedType;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;

  // Offer details (will be populated by specific forms)
  OfferDetails? _offerDetails;

  @override
  void initState() {
    super.initState();
    authService = sl<AuthService>();
    if (widget.offer != null) {
      _loadExistingOffer();
    }
  }

  void _loadExistingOffer() {
    final offer = widget.offer!;
    _titleEnController.text = offer.title['en'] ?? '';
    _titleArController.text = offer.title['ar'] ?? '';
    _descriptionEnController.text = offer.description['en'] ?? '';
    _descriptionArController.text = offer.description['ar'] ?? '';
    _imageUrlController.text = offer.imageUrl;
    _sortOrderController.text = offer.sortOrder.toString();
    _selectedType = offer.type;
    _startDate = offer.startDate;
    _endDate = offer.endDate;
    _isActive = offer.isActive;
    _offerDetails = offer.details;
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleArController.dispose();
    _descriptionEnController.dispose();
    _descriptionArController.dispose();
    _imageUrlController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.offer == null ? 'Create Offer' : 'Edit Offer',
          style: AppTextStyles.h4Light,
        ),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        onStepTapped: (step) => setState(() => _currentStep = step),
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: AppConstants.defaultPadding),
            child: Row(
              children: [
                if (_currentStep < 2)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: const Text('Continue'),
                  )
                else
                  ElevatedButton(
                    onPressed: _saveOffer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: Text(
                      widget.offer == null ? 'Create Offer' : 'Update Offer',
                    ),
                  ),
                const SizedBox(width: AppConstants.smallPadding),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Basic Information'),
            content: _buildBasicInfoStep(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Offer Type'),
            content: _buildOfferTypeStep(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Offer Details'),
            content: _buildOfferDetailsStep(),
            isActive: _currentStep >= 2,
            state: _currentStep == 2 ? StepState.indexed : StepState.indexed,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title English
          TextFormField(
            controller: _titleEnController,
            decoration: const InputDecoration(
              labelText: 'Title (English) *',
              hintText: 'e.g., Summer Sale 2024',
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Title Arabic
          TextFormField(
            controller: _titleArController,
            decoration: const InputDecoration(
              labelText: 'Title (Arabic) *',
              hintText: 'e.g., تخفيضات الصيف 2024',
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Description English
          TextFormField(
            controller: _descriptionEnController,
            decoration: const InputDecoration(
              labelText: 'Description (English) *',
              hintText: 'Describe your offer...',
            ),
            maxLines: 3,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Description Arabic
          TextFormField(
            controller: _descriptionArController,
            decoration: const InputDecoration(
              labelText: 'Description (Arabic) *',
              hintText: 'وصف العرض...',
            ),
            maxLines: 3,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Image Upload Widget
          FutureBuilder<String?>(
            future: authService.getMerchandiserId(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              return OfferImageUploadWidget(
                initialImageUrl: _imageUrlController.text.isEmpty
                    ? null
                    : _imageUrlController.text,
                merchandiserId: snapshot.data!,
                onImageUrlChanged: (url) {
                  _imageUrlController.text = url;
                },
              );
            },
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Date Range
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('Start Date'),
                  subtitle: Text(_startDate.toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _startDate = date);
                    }
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text('End Date'),
                  subtitle: Text(_endDate.toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: _startDate,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _endDate = date);
                    }
                  },
                ),
              ),
            ],
          ),

          // Sort Order
          TextFormField(
            controller: _sortOrderController,
            decoration: const InputDecoration(
              labelText: 'Sort Order',
              hintText: '1',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (int.tryParse(value!) == null) return 'Must be a number';
              return null;
            },
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Active Toggle
          SwitchListTile(
            title: const Text('Active'),
            subtitle: const Text('Make this offer visible to customers'),
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select the type of offer you want to create:',
          style: AppTextStyles.bodyMediumLight,
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        _buildOfferTypeCard(
          type: OfferType.bundle,
          title: 'Bundle Offer',
          description: 'Sell multiple products together at a discounted price',
          icon: Icons.inventory_2,
          color: AppColors.primary,
        ),

        _buildOfferTypeCard(
          type: OfferType.bogo,
          title: 'Buy One Get One (BOGO)',
          description: 'Buy X quantity, get Y quantity free',
          icon: Icons.card_giftcard,
          color: AppColors.secondary,
        ),

        _buildOfferTypeCard(
          type: OfferType.discount,
          title: 'Discount Offer',
          description: 'Percentage or fixed discount on products',
          icon: Icons.discount,
          color: AppColors.accent,
        ),

        _buildOfferTypeCard(
          type: OfferType.minPurchase,
          title: 'Minimum Purchase',
          description: 'Discount or free shipping on minimum purchase',
          icon: Icons.shopping_cart,
          color: AppColors.info,
        ),

        _buildOfferTypeCard(
          type: OfferType.freeItem,
          title: 'Free Item',
          description: 'Customer chooses a free item with minimum purchase',
          icon: Icons.redeem,
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildOfferTypeCard({
    required OfferType type,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == type;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLargeLight.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(description, style: AppTextStyles.bodySmallLight),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferDetailsStep() {
    if (_selectedType == null) {
      return const Center(child: Text('Please select an offer type first'));
    }

    switch (_selectedType!) {
      case OfferType.bundle:
        return BundleOfferForm(
          initialDetails: _offerDetails as BundleOfferDetails?,
          onDetailsChanged: (details) => _offerDetails = details,
        );
      case OfferType.bogo:
        return BOGOOfferForm(
          initialDetails: _offerDetails as BOGOOfferDetails?,
          onDetailsChanged: (details) => _offerDetails = details,
        );
      case OfferType.discount:
        return DiscountOfferForm(
          initialDetails: _offerDetails as DiscountOfferDetails?,
          onDetailsChanged: (details) => _offerDetails = details,
        );
      case OfferType.minPurchase:
        return MinPurchaseOfferForm(
          initialDetails: _offerDetails as MinPurchaseOfferDetails?,
          onDetailsChanged: (details) => _offerDetails = details,
        );
      case OfferType.freeItem:
        return FreeItemOfferForm(
          initialDetails: _offerDetails as FreeItemOfferDetails?,
          onDetailsChanged: (details) => _offerDetails = details,
        );
    }
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_selectedType != null) {
        setState(() => _currentStep++);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an offer type')),
        );
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _saveOffer() async {
    if (_offerDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the offer details')),
      );
      return;
    }

    try {
      final merchandiserId = await authService.getMerchandiserId();

      if (merchandiserId == null) {
        throw Exception('Merchandiser ID not found');
      }

      final offer = Offer(
        id: widget.offer?.id ?? _uuid.v4(),
        merchandiserId: merchandiserId,
        title: {'en': _titleEnController.text, 'ar': _titleArController.text},
        description: {
          'en': _descriptionEnController.text,
          'ar': _descriptionArController.text,
        },
        imageUrl: _imageUrlController.text,
        type: _selectedType!,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        sortOrder: int.parse(_sortOrderController.text),
        details: _offerDetails!,
      );

      if (widget.offer == null) {
        context.read<OffersBloc>().add(CreateOffer(offer));
      } else {
        context.read<OffersBloc>().add(UpdateOffer(offer));
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
