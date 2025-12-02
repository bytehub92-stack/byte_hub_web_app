import 'package:admin_panel/features/admin/admin_merchandiser_data/pages/admin_merchandiser_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../domain/entities/merchandiser.dart';
import '../bloc/merchandiser_bloc/merchandiser_bloc.dart';
import '../bloc/merchandiser_bloc/merchandiser_event.dart';

class MerchandiserCard extends StatelessWidget {
  final Merchandiser merchandiser;

  const MerchandiserCard({super.key, required this.merchandiser});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetails(context),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              merchandiser.businessName['en']!.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            merchandiser.businessName['en']!,
            style: AppTextStyles.getBodyLarge(context),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(merchandiser.businessType!['en']!),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: merchandiser.isActive
                          ? AppColors.success
                          : AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      merchandiser.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.grey500,
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view_details',
                    child: ListTile(
                      leading: Icon(Icons.visibility),
                      title: Text('View Details'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_status',
                    child: ListTile(
                      leading: Icon(
                        merchandiser.isActive
                            ? Icons.block
                            : Icons.check_circle,
                      ),
                      title: Text(
                        merchandiser.isActive ? 'Deactivate' : 'Activate',
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AdminMerchandiserDetailPage(merchandiser: merchandiser),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'view_details':
        _showMerchandiserDetails(context);
        break;
      case 'toggle_status':
        _toggleMerchandiserStatus(context);
        break;
    }
  }

  void _toggleMerchandiserStatus(BuildContext context) {
    context.read<MerchandiserBloc>().add(
      ToggleMerchandiserStatusEvent(
        merchandiserId: merchandiser.id,
        newStatus: !merchandiser.isActive,
      ),
    );
  }

  void _showMerchandiserDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Merchandiser Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'Business Name',
                merchandiser.businessName['en']!,
              ),
              _buildDetailRow(
                'Business Type',
                merchandiser.businessName['ar']!,
              ),
              _buildDetailRow(
                'Contact Name',
                merchandiser.contactName ?? 'N/A',
              ),
              _buildDetailRow('Phone', merchandiser.phoneNumber ?? 'N/A'),
              _buildDetailRow('Email', merchandiser.email ?? 'N/A'),
              _buildDetailRow(
                'Status',
                merchandiser.isActive ? 'Active' : 'Inactive',
              ),
              _buildDetailRow(
                'Created',
                merchandiser.createdAt.toString().substring(0, 19),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
