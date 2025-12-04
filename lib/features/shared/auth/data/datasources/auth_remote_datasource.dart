// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:admin_panel/core/constants/api_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/debug/debug_config.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  const AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> login(String email, String password) async {
    DebugConfig.logInfo('auth remote datasource: start login');
    try {
      DebugConfig.logInfo('Attempting Supabase login for email: $email');

      // Sign in with Supabase Auth
      final AuthResponse response = await supabaseClient.auth
          .signInWithPassword(email: email, password: password);

      if (response.user == null) {
        throw const ServerException(message: 'Login failed: No user returned');
      }

      // Get user profile data from your users table
      final userProfileResponse = await supabaseClient
          .from(ApiConstants.profilesTable)
          .select('is_active, user_type')
          .eq('id', response.user!.id)
          .single();

      DebugConfig.logInfo('User profile data: $userProfileResponse');

      // Check if user is active
      if (userProfileResponse['is_active'] != true) {
        throw const ServerException(message: 'Account has been deactivated');
      }
      // Validate user_type (only admin and merchandiser can login)
      final userType = userProfileResponse['user_type']
          ?.toString()
          .toLowerCase();
      if (userType == null || !['admin', 'merchandiser'].contains(userType)) {
        throw ServerException(
          message: 'Invalid user type for this application: $userType',
        );
      }

      // Prepare user data
      final userData = {
        'id': response.user!.id,
        'email': response.user!.email ?? email,
        'full_name': userProfileResponse['full_name'],
        'user_type': userProfileResponse['user_type'],
        'token': response.session?.accessToken,
        'must_change_password':
            userProfileResponse['must_change_password'] ?? false,
        'is_active': userProfileResponse['is_active'] ?? true,
      };

      final user = UserModel.fromJson(userData);
      DebugConfig.logInfo('Supabase login successful: ${user.userType.name}');

      return user;
    } on AuthException catch (e) {
      DebugConfig.logError('Supabase Auth error', error: e);
      throw ServerException(message: _getAuthErrorMessage(e));
    } on PostgrestException catch (e) {
      DebugConfig.logError('Supabase database error', error: e);
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e, stackTrace) {
      DebugConfig.logError(
        'Unexpected Supabase login error',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException(message: 'Login failed: ${e.toString()}');
    }
  }

  String _getAuthErrorMessage(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return 'Invalid email or password';
      case 'Email not confirmed':
        return 'Please verify your email address';
      case 'Too many requests':
        return 'Too many login attempts. Please try again later';
      default:
        return e.message;
    }
  }

  @override
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }
}
