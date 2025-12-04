class JsonbHelper {
  /// Creates JSONB object with both languages
  static Map<String, String> createBilingualJson(
    String englishValue, {
    String? arabicValue,
  }) {
    final result = <String, String>{};

    // Always include English if not empty
    if (englishValue.trim().isNotEmpty) {
      result['en'] = englishValue.trim();
    }

    // Include Arabic only if provided and not empty
    if (arabicValue != null && arabicValue.trim().isNotEmpty) {
      result['ar'] = arabicValue.trim();
    }

    // Ensure at least English exists
    if (result.isEmpty) {
      throw Exception('At least English name is required');
    }

    return result;
  }

  static String getLocalizedValue(
    Map<String, String>? jsonbField,
    String languageCode,
  ) {
    if (jsonbField == null || jsonbField.isEmpty) {
      return '';
    }
    return jsonbField[languageCode] ?? jsonbField['en'] ?? '';
  }
}
