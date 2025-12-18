// lib/features/offers/presentation/pages/offers_management_page.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/merchandisers/offers/domain/entities/offer.dart';
import 'package:admin_panel/features/merchandisers/offers/presentation/bloc/offers_bloc.dart';
import 'package:admin_panel/features/merchandisers/offers/presentation/bloc/offers_event.dart';
import 'package:admin_panel/features/merchandisers/offers/presentation/bloc/offers_state.dart';
import 'package:admin_panel/features/merchandisers/offers/presentation/pages/create_offer_page.dart';
import 'package:admin_panel/features/merchandisers/offers/presentation/widgets/offer_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class OffersManagementPage extends StatefulWidget {
  const OffersManagementPage({super.key});

  @override
  State<OffersManagementPage> createState() => _OffersManagementPageState();
}

class _OffersManagementPageState extends State<OffersManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<OffersBloc>().add(LoadOffers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offers Management', style: AppTextStyles.h4Light),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OffersBloc>().add(LoadOffers()),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<OffersBloc, OffersState>(
        listener: (context, state) {
          if (state is OffersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is OfferCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Offer created successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is OfferUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Offer updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is OfferDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Offer deleted successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OffersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OffersLoaded) {
            if (state.offers.isEmpty) {
              return _buildEmptyState(context);
            }

            return _buildOffersList(context, state.offers);
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateOffer(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Offer'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 80, color: AppColors.grey400),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No Offers Yet',
            style: AppTextStyles.h3Light.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Create your first promotional offer',
            style: AppTextStyles.bodyMediumLight.copyWith(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateOffer(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Offer'),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersList(BuildContext context, List<Offer> offers) {
    // Group offers by type
    final bundleOffers =
        offers.where((o) => o.type == OfferType.bundle).toList();
    final bogoOffers = offers.where((o) => o.type == OfferType.bogo).toList();
    final discountOffers =
        offers.where((o) => o.type == OfferType.discount).toList();
    final minPurchaseOffers =
        offers.where((o) => o.type == OfferType.minPurchase).toList();
    final freeItemOffers =
        offers.where((o) => o.type == OfferType.freeItem).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Card
          _buildStatisticsCard(context, offers),
          const SizedBox(height: AppConstants.largePadding),

          // Bundle Offers
          if (bundleOffers.isNotEmpty) ...[
            _buildSectionHeader(context, 'Bundle Offers', Icons.inventory_2),
            const SizedBox(height: AppConstants.defaultPadding),
            ...bundleOffers.map(
              (offer) => OfferCard(
                offer: offer,
                onEdit: () => _navigateToEditOffer(context, offer),
                onDelete: () => _confirmDeleteOffer(context, offer),
                onDuplicate: () => _duplicateOffer(context, offer),
                onToggleStatus: (isActive) =>
                    _toggleOfferStatus(context, offer, isActive),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
          ],

          // BOGO Offers
          if (bogoOffers.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              'Buy One Get One',
              Icons.card_giftcard,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ...bogoOffers.map(
              (offer) => OfferCard(
                offer: offer,
                onEdit: () => _navigateToEditOffer(context, offer),
                onDelete: () => _confirmDeleteOffer(context, offer),
                onDuplicate: () => _duplicateOffer(context, offer),
                onToggleStatus: (isActive) =>
                    _toggleOfferStatus(context, offer, isActive),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
          ],

          // Discount Offers
          if (discountOffers.isNotEmpty) ...[
            _buildSectionHeader(context, 'Discount Offers', Icons.discount),
            const SizedBox(height: AppConstants.defaultPadding),
            ...discountOffers.map(
              (offer) => OfferCard(
                offer: offer,
                onEdit: () => _navigateToEditOffer(context, offer),
                onDelete: () => _confirmDeleteOffer(context, offer),
                onDuplicate: () => _duplicateOffer(context, offer),
                onToggleStatus: (isActive) =>
                    _toggleOfferStatus(context, offer, isActive),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
          ],

          // Min Purchase Offers
          if (minPurchaseOffers.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              'Minimum Purchase',
              Icons.shopping_cart,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ...minPurchaseOffers.map(
              (offer) => OfferCard(
                offer: offer,
                onEdit: () => _navigateToEditOffer(context, offer),
                onDelete: () => _confirmDeleteOffer(context, offer),
                onDuplicate: () => _duplicateOffer(context, offer),
                onToggleStatus: (isActive) =>
                    _toggleOfferStatus(context, offer, isActive),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
          ],

          // Free Item Offers
          if (freeItemOffers.isNotEmpty) ...[
            _buildSectionHeader(context, 'Free Item Offers', Icons.redeem),
            const SizedBox(height: AppConstants.defaultPadding),
            ...freeItemOffers.map(
              (offer) => OfferCard(
                offer: offer,
                onEdit: () => _navigateToEditOffer(context, offer),
                onDelete: () => _confirmDeleteOffer(context, offer),
                onDuplicate: () => _duplicateOffer(context, offer),
                onToggleStatus: (isActive) =>
                    _toggleOfferStatus(context, offer, isActive),
              ),
            ),
          ],

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, List<Offer> offers) {
    final activeOffers = offers.where((o) => o.isActive).length;
    final inactiveOffers = offers.where((o) => !o.isActive).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                'Total Offers',
                offers.length.toString(),
                Icons.local_offer,
                AppColors.primary,
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: _buildStatItem(
                context,
                'Active',
                activeOffers.toString(),
                Icons.check_circle,
                AppColors.success,
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: _buildStatItem(
                context,
                'Inactive',
                inactiveOffers.toString(),
                Icons.cancel,
                AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.h2Light.copyWith(color: color)),
        Text(
          label,
          style: AppTextStyles.bodySmallLight.copyWith(
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.h3Light),
      ],
    );
  }

  void _navigateToCreateOffer(BuildContext context) {
    // Get the bloc instance before navigation
    final offersBloc = context.read<OffersBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider<OffersBloc>.value(
          value: offersBloc,
          child: const CreateOfferPage(),
        ),
      ),
    ).then((_) {
      // Reload offers after returning
      offersBloc.add(LoadOffers());
    });
  }

  void _navigateToEditOffer(BuildContext context, Offer offer) {
    // Get the bloc instance before navigation
    final offersBloc = context.read<OffersBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider<OffersBloc>.value(
          value: offersBloc,
          child: CreateOfferPage(offer: offer),
        ),
      ),
    ).then((_) {
      // Reload offers after returning
      offersBloc.add(LoadOffers());
    });
  }

  void _confirmDeleteOffer(BuildContext context, Offer offer) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Offer'),
        content: Text(
          'Are you sure you want to delete "${offer.getTitle('en')}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OffersBloc>().add(DeleteOffer(offer.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleOfferStatus(BuildContext context, Offer offer, bool isActive) {
    context.read<OffersBloc>().add(ToggleOfferStatus(offer.id, isActive));
  }

  void _duplicateOffer(BuildContext context, Offer offer) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Duplicate Offer'),
        content: Text('Create a copy of "${offer.getTitle('en')}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _createDuplicateOffer(context, offer);
            },
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );
  }

  void _createDuplicateOffer(BuildContext context, Offer offer) async {
    try {
      final authService = sl<AuthService>();
      final merchandiserId = await authService.getMerchandiserId();

      if (merchandiserId == null) {
        throw Exception('Merchandiser ID not found');
      }

      // Create a copy with new ID and updated title
      final duplicatedOffer = Offer(
        id: const Uuid().v4(),
        merchandiserId: merchandiserId,
        title: {
          'en': '${offer.title['en']} (Copy)',
          'ar': '${offer.title['ar']} (نسخة)',
        },
        description: offer.description,
        imageUrl: offer.imageUrl,
        type: offer.type,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: false, // Start as inactive
        sortOrder: offer.sortOrder + 1,
        details: offer.details,
      );

      context.read<OffersBloc>().add(CreateOffer(duplicatedOffer));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer duplicated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
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
