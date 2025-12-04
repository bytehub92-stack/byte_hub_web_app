import 'package:admin_panel/core/network/network_info.dart';
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/features/shared/auth/data/datasources/auth_local_datasource.dart';
import 'package:admin_panel/features/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:admin_panel/features/shared/auth/domain/repositories/auth_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

// Network Mocks
class MockConnectivity extends Mock implements Connectivity {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

// Storage Mocks
class MockSharedPreferences extends Mock implements SharedPreferences {}

// Auth Mocks
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthService extends Mock implements AuthService {}

// Register fallback values for Mocktail
void registerFallbackValues() {
  registerFallbackValue(ConnectivityResult.wifi);
}
