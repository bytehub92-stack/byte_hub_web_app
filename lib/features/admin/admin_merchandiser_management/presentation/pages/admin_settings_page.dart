// lib/features/admin/admin_dashboard/presentation/pages/admin_settings_page.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/services/theme_service.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/admin/content_management/presentation/pages/admin_content_management_page.dart';
import 'package:admin_panel/features/shared/notifications/presentation/widgets/admin_send_notification_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: AppTextStyles.getH3(context)).tr(),
            const SizedBox(height: AppConstants.largePadding),

            // Notifications Section
            _buildSectionCard(
              context,
              title: 'Notifications',
              icon: Icons.notifications_active,
              color: AppColors.primary,
              children: [
                _buildActionTile(
                  context,
                  icon: Icons.send,
                  title: 'Send Global Notification',
                  subtitle: 'Send notification to all users or specific groups',
                  onTap: () => _showSendNotificationDialog(context),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Content Management Section
            _buildSectionCard(
              context,
              title: 'Content Management',
              icon: Icons.edit_note,
              color: AppColors.secondary,
              children: [
                _buildActionTile(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Manage About Content',
                  subtitle: 'Edit Terms, Privacy Policy, and Help pages',
                  onTap: () => _navigateToContentManagement(context),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Appearance Section
            _buildSectionCard(
              context,
              title: 'Appearance',
              icon: Icons.palette,
              color: AppColors.accent,
              children: [_buildThemeToggle(context)],
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Language Section
            _buildSectionCard(
              context,
              title: 'Language',
              icon: Icons.language,
              color: AppColors.info,
              children: [_buildLanguageSelector(context)],
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // About Section
            _buildSectionCard(
              context,
              title: 'About',
              icon: Icons.info_outline,
              color: AppColors.grey600,
              children: [
                _buildInfoTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'App Version',
                  subtitle: AppConstants.appVersion,
                ),
                const Divider(),
                _buildInfoTile(
                  context,
                  icon: Icons.business,
                  title: 'App Name',
                  subtitle: AppConstants.appName,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSendNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AdminSendNotificationDialog(),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
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
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title, style: AppTextStyles.getH4(context)).tr(),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: AppColors.primary,
          ),
          title: Text(
            'Dark Mode',
            style: AppTextStyles.getBodyLarge(context),
          ).tr(),
          subtitle: Text(
            isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
            style: AppTextStyles.getBodySmall(context),
          ).tr(),
          trailing: Switch(
            value: isDarkMode,
            onChanged: (value) {
              themeService.setThemeMode(
                value ? AppThemeMode.dark : AppThemeMode.light,
              );
            },
            activeThumbColor: AppColors.primary,
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final currentLocale = context.locale.languageCode;

    return Column(
      children: [
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          title: const Text('English'),
          subtitle: const Text('English'),
          value: 'en',
          groupValue: currentLocale,
          onChanged: (value) {
            if (value != null) {
              context.setLocale(Locale(value));
            }
          },
          activeColor: AppColors.primary,
        ),
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          title: const Text('العربية'),
          subtitle: const Text('Arabic'),
          value: 'ar',
          groupValue: currentLocale,
          onChanged: (value) {
            if (value != null) {
              context.setLocale(Locale(value));
            }
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.getBodyLarge(context)).tr(),
      subtitle: Text(subtitle, style: AppTextStyles.getBodySmall(context)),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.getBodyLarge(context)).tr(),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.getBodySmall(context)).tr()
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _navigateToContentManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminContentManagementPage(),
      ),
    );
  }
}
