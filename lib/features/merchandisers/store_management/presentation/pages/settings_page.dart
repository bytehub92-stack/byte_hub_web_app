// lib/features/merchandiser/presentation/pages/merchandiser_settings_page.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/core/services/theme_service.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/app_settings/domain/entities/app_setting.dart';
import 'package:admin_panel/features/shared/app_settings/presentation/pages/content_viewer_page.dart';
import 'package:admin_panel/features/shared/notifications/presentation/widgets/send_promotion_dialog.dart';
import 'package:admin_panel/features/shared/offers/presentation/bloc/offers_bloc.dart';
import 'package:admin_panel/features/shared/offers/presentation/pages/offers_management_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class MerchandiserSettingsPage extends StatefulWidget {
  const MerchandiserSettingsPage({super.key});

  @override
  State<MerchandiserSettingsPage> createState() =>
      _MerchandiserSettingsPageState();
}

class _MerchandiserSettingsPageState extends State<MerchandiserSettingsPage> {
  String? _merchandiserId;

  @override
  void initState() {
    super.initState();
    _loadMerchandiserId();
  }

  Future<void> _loadMerchandiserId() async {
    final authService = sl<AuthService>();
    final id = await authService.getMerchandiserId();
    if (mounted) {
      setState(() => _merchandiserId = id);
    }
  }

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

            // Promotional Offers Section
            _buildSectionCard(
              context,
              title: 'Promotional Offers',
              icon: Icons.local_offer,
              color: AppColors.primary,
              children: [
                _buildActionTile(
                  context,
                  icon: Icons.campaign,
                  title: 'Manage Offers',
                  subtitle: 'Create and manage promotional offers',
                  onTap: () => _navigateToOffersManagement(context),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Notifications Section
            _buildSectionCard(
              context,
              title: 'Notifications',
              icon: Icons.notifications_active,
              color: AppColors.secondary,
              children: [
                _buildActionTile(
                  context,
                  icon: Icons.send,
                  title: 'Send Custom Notification',
                  subtitle: 'Send a notification to all your customers',
                  onTap: _merchandiserId != null
                      ? () => _showSendPromotionDialog(context)
                      : null,
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

            // Legal Section
            _buildSectionCard(
              context,
              title: 'Legal & Support',
              icon: Icons.description,
              color: AppColors.grey600,
              children: [
                _buildActionTile(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () => _navigateToContent(
                    context,
                    AppSettingKeys.termsConditions,
                    'Terms & Conditions',
                    Icons.description_outlined,
                  ),
                ),
                const Divider(),
                _buildActionTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _navigateToContent(
                    context,
                    AppSettingKeys.privacyPolicy,
                    'Privacy Policy',
                    Icons.privacy_tip_outlined,
                  ),
                ),
                const Divider(),
                _buildActionTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => _navigateToContent(
                    context,
                    AppSettingKeys.helpSupport,
                    'Help & Support',
                    Icons.help_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSendPromotionDialog(BuildContext context) {
    if (_merchandiserId == null) return;

    showDialog(
      context: context,
      builder: (context) =>
          SendPromotionDialog(merchandiserId: _merchandiserId!),
    );
  }

  void _navigateToContent(
    BuildContext context,
    String settingKey,
    String title,
    IconData icon,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ContentViewerPage(settingKey: settingKey, title: title, icon: icon),
      ),
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

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.getBodyLarge(context)).tr(),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.getBodySmall(context))
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
      enabled: onTap != null,
    );
  }

  void _navigateToOffersManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<OffersBloc>(),
          child: const OffersManagementPage(),
        ),
      ),
    );
  }
}
