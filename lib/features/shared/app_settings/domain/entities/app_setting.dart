// lib/features/shared/app_settings/domain/entities/app_setting.dart
import 'package:equatable/equatable.dart';

class AppSetting extends Equatable {
  final String id;
  final String? merchandiserId;
  final String settingKey;
  final Map<String, dynamic> settingValue;
  final Map<String, String>? description;
  final DateTime updatedAt;

  const AppSetting({
    required this.id,
    this.merchandiserId,
    required this.settingKey,
    required this.settingValue,
    this.description,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    merchandiserId,
    settingKey,
    settingValue,
    description,
    updatedAt,
  ];

  /// Helper method to get localized content
  String getLocalizedContent(String locale) {
    if (settingValue.containsKey(locale)) {
      return settingValue[locale] as String? ?? '';
    }
    // Fallback to English if locale not found
    return settingValue['en'] as String? ?? '';
  }

  /// Helper method to get localized description
  String? getLocalizedDescription(String locale) {
    if (description == null) return null;
    return description![locale] ?? description!['en'];
  }

  /// Check if setting is global (admin-managed)
  bool get isGlobal => merchandiserId == null;
}

/// Predefined setting keys for About section
class AppSettingKeys {
  static const String termsConditions = 'terms_conditions';
  static const String privacyPolicy = 'privacy_policy';
  static const String helpSupport = 'help_support';

  /// Get all about section keys
  static List<String> get aboutSectionKeys => [
    termsConditions,
    privacyPolicy,
    helpSupport,
  ];

  /// Get display name for setting key
  static String getDisplayName(String key) {
    switch (key) {
      case termsConditions:
        return 'Terms & Conditions';
      case privacyPolicy:
        return 'Privacy Policy';
      case helpSupport:
        return 'Help & Support';
      default:
        return key;
    }
  }

  /// Get icon for setting key
  static String getIconName(String key) {
    switch (key) {
      case termsConditions:
        return 'description_outlined';
      case privacyPolicy:
        return 'privacy_tip_outlined';
      case helpSupport:
        return 'help_outline';
      default:
        return 'info_outline';
    }
  }
}
