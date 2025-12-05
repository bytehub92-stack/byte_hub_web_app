import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get supabaseUrl {
    // Priority 1: Compile-time environment variables (required for web)
    const envUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      if (kDebugMode) {
        print('✅ Using SUPABASE_URL from --dart-define');
      }
      return envUrl;
    }
    
    // Priority 2: Runtime .env file (only for non-web platforms)
    if (!kIsWeb) {
      try {
        final dotenvUrl = dotenv.env['SUPABASE_URL'];
        if (dotenvUrl != null && dotenvUrl.isNotEmpty) {
          if (kDebugMode) {
            print('✅ Using SUPABASE_URL from .env file');
          }
          return dotenvUrl;
        }
      } catch (e) {
        // Silent catch
      }
    }
    
    // Configuration missing
    if (kDebugMode) {
      print('❌ SUPABASE_URL not configured!');
      if (kIsWeb) {
        print('   For web: flutter run -d chrome --dart-define=SUPABASE_URL=your_url');
      } else {
        print('   Create a .env file with SUPABASE_URL=your_url');
      }
    }
    return '';
  }

  static String get supabaseAnonKey {
    // Priority 1: Compile-time environment variables (required for web)
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (envKey.isNotEmpty) {
      if (kDebugMode) {
        print('✅ Using SUPABASE_ANON_KEY from --dart-define');
      }
      return envKey;
    }
    
    // Priority 2: Runtime .env file (only for non-web platforms)
    if (!kIsWeb) {
      try {
        final dotenvKey = dotenv.env['SUPABASE_ANON_KEY'];
        if (dotenvKey != null && dotenvKey.isNotEmpty) {
          if (kDebugMode) {
            print('✅ Using SUPABASE_ANON_KEY from .env file');
          }
          return dotenvKey;
        }
      } catch (e) {
        // Silent catch
      }
    }
    
    // Configuration missing
    if (kDebugMode) {
      print('❌ SUPABASE_ANON_KEY not configured!');
      if (kIsWeb) {
        print('   For web: flutter run -d chrome --dart-define=SUPABASE_ANON_KEY=your_key');
      } else {
        print('   Create a .env file with SUPABASE_ANON_KEY=your_key');
      }
    }
    return '';
  }

  static const String profilesTable = 'profiles';
  static const String merchandisersTable = 'merchandisers';
}