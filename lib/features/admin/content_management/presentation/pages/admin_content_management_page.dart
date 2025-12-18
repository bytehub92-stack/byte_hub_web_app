// lib/features/admin/content_management/presentation/pages/admin_content_management_page.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/app_settings/domain/entities/app_setting.dart';
import 'package:admin_panel/features/shared/app_settings/presentation/bloc/app_settings_bloc.dart';
import 'package:admin_panel/features/shared/app_settings/presentation/bloc/app_settings_event.dart';
import 'package:admin_panel/features/shared/app_settings/presentation/bloc/app_settings_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/content_editor_dialog.dart';

class AdminContentManagementPage extends StatelessWidget {
  const AdminContentManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<AppSettingsBloc>()..add(const LoadAboutSectionSettings()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Content Management').tr(),
          centerTitle: true,
        ),
        body: BlocConsumer<AppSettingsBloc, AppSettingsState>(
          listener: (context, state) {
            if (state is AppSettingUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Content updated successfully').tr(),
                  backgroundColor: AppColors.success,
                ),
              );
              // Reload settings
              context.read<AppSettingsBloc>().add(
                    const LoadAboutSectionSettings(),
                  );
            }

            if (state is AppSettingCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Content created successfully').tr(),
                  backgroundColor: AppColors.success,
                ),
              );
              // Reload settings
              context.read<AppSettingsBloc>().add(
                    const LoadAboutSectionSettings(),
                  );
            }
          },
          builder: (context, state) {
            if (state is AppSettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AppSettingsError) {
              return _buildErrorState(context, state.message);
            }

            if (state is AboutSectionSettingsLoaded) {
              return _buildContentList(context, state.settings);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContentList(BuildContext context, List<AppSetting> settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage About Section Content',
            style: AppTextStyles.getH3(context),
          ).tr(),
          const SizedBox(height: 8),
          Text(
            'Edit content that will be displayed to all merchandisers in the About section.',
            style: AppTextStyles.getBodyMedium(
              context,
            ).copyWith(color: AppColors.grey500),
          ).tr(),
          const SizedBox(height: AppConstants.largePadding),

          // Content Cards
          ...AppSettingKeys.aboutSectionKeys.map((key) {
            final setting = _findSettingByKey(settings, key);
            return Padding(
              padding: const EdgeInsets.only(
                bottom: AppConstants.defaultPadding,
              ),
              child: _buildContentCard(context, key, setting),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContentCard(
    BuildContext context,
    String settingKey,
    AppSetting? setting,
  ) {
    final hasContent = setting != null;
    final enContent = setting?.settingValue['en'] as String? ?? '';
    final arContent = setting?.settingValue['ar'] as String? ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasContent
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconForKey(settingKey),
                    color: hasContent ? AppColors.success : AppColors.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppSettingKeys.getDisplayName(settingKey),
                        style: AppTextStyles.getH4(context),
                      ).tr(),
                      if (hasContent)
                        Text(
                          'Last updated: ${_formatDate(setting.updatedAt)}',
                          style: AppTextStyles.getBodySmall(
                            context,
                          ).copyWith(color: AppColors.grey500),
                        ),
                    ],
                  ),
                ),
                _buildStatusChip(context, hasContent),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Content Preview
            if (hasContent) ...[
              _buildContentPreview(context, 'English', enContent),
              const SizedBox(height: 8),
              _buildContentPreview(context, 'Arabic', arContent),
            ] else
              Text(
                'No content set',
                style: AppTextStyles.getBodyMedium(context).copyWith(
                  color: AppColors.grey400,
                  fontStyle: FontStyle.italic,
                ),
              ).tr(),

            const SizedBox(height: AppConstants.defaultPadding),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _showContentEditor(context, settingKey, setting),
                icon: Icon(hasContent ? Icons.edit : Icons.add),
                label: Text(hasContent ? 'Edit Content' : 'Add Content').tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, bool hasContent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasContent
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        hasContent ? 'Published' : 'Not Set',
        style: AppTextStyles.getBodySmall(context).copyWith(
          color: hasContent ? AppColors.success : AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      ).tr(),
    );
  }

  Widget _buildContentPreview(
    BuildContext context,
    String language,
    String content,
  ) {
    final preview =
        content.length > 100 ? '${content.substring(0, 100)}...' : content;

    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.grey50
            : AppColors.grey800,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language,
            style: AppTextStyles.getBodySmall(
              context,
            ).copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            preview,
            style: AppTextStyles.getBodySmall(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
                    const LoadAboutSectionSettings(),
                  );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry').tr(),
          ),
        ],
      ),
    );
  }

  void _showContentEditor(
    BuildContext context,
    String settingKey,
    AppSetting? existingSetting,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AppSettingsBloc>(),
        child: ContentEditorDialog(
          settingKey: settingKey,
          existingSetting: existingSetting,
        ),
      ),
    );
  }

  AppSetting? _findSettingByKey(List<AppSetting> settings, String key) {
    try {
      return settings.firstWhere((s) => s.settingKey == key);
    } catch (e) {
      return null;
    }
  }

  IconData _getIconForKey(String key) {
    switch (key) {
      case AppSettingKeys.termsConditions:
        return Icons.description_outlined;
      case AppSettingKeys.privacyPolicy:
        return Icons.privacy_tip_outlined;
      case AppSettingKeys.helpSupport:
        return Icons.help_outline;
      default:
        return Icons.info_outline;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
