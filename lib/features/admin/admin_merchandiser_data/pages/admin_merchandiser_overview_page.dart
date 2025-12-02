import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/entities/merchandiser.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/entities/merchandiser_stats.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/merchandiser_stats_repository.dart';
import 'package:admin_panel/features/shared/shared_feature/presentation/widgets/merchandiser_stats_grid.dart';
import 'package:flutter/material.dart';

class AdminMerchandiserOverviewPage extends StatefulWidget {
  final Merchandiser merchandiser;
  const AdminMerchandiserOverviewPage({super.key, required this.merchandiser});

  @override
  State<AdminMerchandiserOverviewPage> createState() =>
      _AdminMerchandiserOverviewPageState();
}

class _AdminMerchandiserOverviewPageState
    extends State<AdminMerchandiserOverviewPage> {
  MerchandiserStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final repository = sl<MerchandiserStatsRepository>();
      final stats = await repository.getStats(widget.merchandiser.id);

      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Merchandiser Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Information',
                    style: AppTextStyles.getH4(context),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Business Name',
                    widget.merchandiser.businessName['en']!,
                  ),
                  _buildInfoRow(
                    'Business Type',
                    widget.merchandiser.businessType!['en']!,
                  ),
                  _buildInfoRow(
                    'Contact',
                    widget.merchandiser.contactName ?? 'N/A',
                  ),
                  _buildInfoRow('Email', widget.merchandiser.email ?? 'N/A'),
                  _buildInfoRow(
                    'Phone',
                    widget.merchandiser.phoneNumber ?? 'N/A',
                  ),
                  _buildInfoRow(
                    'Status',
                    widget.merchandiser.isActive ? 'Active' : 'Inactive',
                  ),
                  _buildInfoRow(
                    'Created',
                    widget.merchandiser.createdAt.toString().substring(0, 19),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Statistics', style: AppTextStyles.getH4(context)),
          const SizedBox(height: 16),
          Expanded(
            child: _stats != null
                ? MerchandiserStatsGrid(stats: _stats!, isLoading: _isLoading)
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
