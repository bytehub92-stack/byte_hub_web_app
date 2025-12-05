import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get supabaseUrl {
    // For web builds, use compile-time environment variables
    if (kIsWeb) {
      const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
      if (url.isNotEmpty) return url;
    }
    // Fall back to .env file for local development
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    // For web builds, use compile-time environment variables
    if (kIsWeb) {
      const key = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
      if (key.isNotEmpty) return key;
    }
    // Fall back to .env file for local development
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  static const String profilesTable = 'profiles';
  static const String merchandisersTable = 'merchandisers';
}
