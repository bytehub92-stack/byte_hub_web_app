// lib/features/shared/app_settings/presentation/pages/content_viewer_page.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_setting.dart';
import '../bloc/app_settings_bloc.dart';
import '../bloc/app_settings_event.dart';
import '../bloc/app_settings_state.dart';

class ContentViewerPage extends StatelessWidget {
  final String settingKey;
  final String title;
  final IconData icon;

  const ContentViewerPage({
    super.key,
    required this.settingKey,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<AppSettingsBloc>()..add(LoadAppSetting(settingKey: settingKey)),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 12),
              Text(title).tr(),
            ],
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<AppSettingsBloc, AppSettingsState>(
          builder: (context, state) {
            if (state is AppSettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AppSettingsError) {
              return _buildErrorState(context, state.message);
            }

            if (state is AppSettingLoaded) {
              return _buildContentView(context, state.setting);
            }

            return _buildEmptyState(context);
          },
        ),
      ),
    );
  }

  Widget _buildContentView(BuildContext context, AppSetting setting) {
    final locale = context.locale.languageCode;
    final content = setting.getLocalizedContent(locale);

    if (content.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last updated info
          Container(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.info),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${_formatDate(setting.updatedAt)}',
                  style: AppTextStyles.getBodySmall(
                    context,
                  ).copyWith(color: AppColors.info),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),

          // Content
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: SelectableText(
                content,
                style: AppTextStyles.getBodyLarge(
                  context,
                ).copyWith(height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text(
            'No content available',
            style: AppTextStyles.getH4(
              context,
            ).copyWith(color: AppColors.grey500),
          ).tr(),
          const SizedBox(height: 8),
          Text(
            'Content for this section has not been set yet.',
            style: AppTextStyles.getBodyMedium(
              context,
            ).copyWith(color: AppColors.grey400),
            textAlign: TextAlign.center,
          ).tr(),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Error loading content',
            style: AppTextStyles.getH4(
              context,
            ).copyWith(color: AppColors.error),
          ).tr(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: AppTextStyles.getBodyMedium(
                context,
              ).copyWith(color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AppSettingsBloc>().add(
                LoadAppSetting(settingKey: settingKey),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry').tr(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
