import 'package:admin_panel/shared/services/app_router.dart';
import 'package:easy_localization/easy_localization.dart';

class LocalizationHelper {
  /// Extract localized string from JSONB field based on current locale
  static String getLocalizedString(
    Map<String, dynamic>? jsonbField, {
    String? fallback,
    String defaultLang = 'en',
  }) {
    if (jsonbField == null || jsonbField.isEmpty) {
      return fallback ?? 'N/A';
    }

    final currentLocale = EasyLocalization.of(
      AppRouter.navigatorKey.currentContext!,
    )?.locale;
    final currentLangCode = currentLocale?.languageCode ?? defaultLang;

    // Try current language first
    if (jsonbField.containsKey(currentLangCode)) {
      final value = jsonbField[currentLangCode]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    // Fallback to default language
    if (jsonbField.containsKey(defaultLang)) {
      final value = jsonbField[defaultLang]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    // Fallback to first available language
    for (final entry in jsonbField.entries) {
      final value = entry.value?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return fallback ?? 'N/A';
  }

  /// Get all available translations for a field
  static Map<String, String> getAllTranslations(
    Map<String, dynamic>? jsonbField,
  ) {
    if (jsonbField == null) return {};

    return jsonbField.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
  }

  /// Check if a localized field has translation for current language
  static bool hasCurrentLanguageTranslation(Map<String, dynamic>? jsonbField) {
    if (jsonbField == null) return false;

    final currentLocale = EasyLocalization.of(
      AppRouter.navigatorKey.currentContext!,
    )?.locale;
    final currentLangCode = currentLocale?.languageCode ?? 'en';

    return jsonbField.containsKey(currentLangCode) &&
        jsonbField[currentLangCode]?.toString().trim().isNotEmpty == true;
  }
}
