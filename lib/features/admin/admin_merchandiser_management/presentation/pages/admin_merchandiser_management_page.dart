import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/widgets/add_merchandiser_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../bloc/merchandiser_bloc/merchandiser_bloc.dart';
import '../bloc/merchandiser_bloc/merchandiser_event.dart';
import '../bloc/merchandiser_bloc/merchandiser_state.dart';
import '../widgets/merchandiser_card.dart';

class AdminMerchandiserManagementPage extends StatelessWidget {
  const AdminMerchandiserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MerchandiserBloc>(),
      child: BlocConsumer<MerchandiserBloc, MerchandiserState>(
        listener: (context, state) {
          if (state is MerchandiserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is MerchandiserStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Merchandiser status updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is MerchandiserCreated) {
            _showCredentialsDialog(context, state.email, state.tempPassword);
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  Expanded(child: _buildContent(context, state)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Merchandiser Management', style: AppTextStyles.getH2(context)),
        ElevatedButton.icon(
          onPressed: () => _showAddMerchandiserDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Merchandiser'),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, MerchandiserState state) {
    if (state is MerchandiserLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is MerchandiserLoaded) {
      if (state.merchandisers.isEmpty) {
        return _buildEmptyState(context);
      }
      return _buildMerchandiserList(state.merchandisers);
    } else if (state is MerchandiserError) {
      return _buildErrorState(context, state.message);
    } else {
      // Initial state - trigger load
      context.read<MerchandiserBloc>().add(LoadMerchandisers());
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text('No merchandisers yet', style: AppTextStyles.getH4(context)),
          const SizedBox(height: 8),
          Text(
            'Add your first merchandiser to get started',
            style: AppTextStyles.getBodyMedium(context),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Error loading merchandisers',
            style: AppTextStyles.getH4(context),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.getBodyMedium(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<MerchandiserBloc>().add(LoadMerchandisers());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchandiserList(List merchandisers) {
    return ListView.builder(
      itemCount: merchandisers.length,
      itemBuilder: (context, index) {
        return MerchandiserCard(merchandiser: merchandisers[index]);
      },
    );
  }

  void _showAddMerchandiserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<MerchandiserBloc>(),
        child: const AddMerchandiserDialog(),
      ),
    );
  }

  void _showCredentialsDialog(
    BuildContext context,
    String email,
    String tempPassword,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Merchandiser Created Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share these credentials with the merchandiser:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: $email'),
                  Text('Temporary Password: $tempPassword'),
                  const SizedBox(height: 8),
                  const Text(
                    'Note: The merchandiser must change this password on first login.',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
