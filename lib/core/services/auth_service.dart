// lib/core/services/auth_service.dart
import 'package:admin_panel/core/constants/api_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  /// Get current user ID (profile_id)
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Get merchandiser ID for current user
  Future<String?> getMerchandiserId() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final response = await _supabase
          .from('merchandisers')
          .select('id')
          .eq('profile_id', userId)
          .maybeSingle();

      return response?['id'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get merchandiser data for current user
  Future<Map<String, dynamic>?> getMerchandiserData() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final response = await _supabase
          .from('merchandisers')
          .select('*')
          .eq('profile_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<String> getUserType() async {
    _supabase.from('profiles').select('user_type');

    final userProfileResponse = await _supabase
        .from(ApiConstants.profilesTable)
        .select('is_active, user_type')
        .eq('id', currentUserId!)
        .single();

    final userType = userProfileResponse['user_type']?.toString().toLowerCase();
    return userType!;
  }

  /// Check if user type is valid for web access (admin or merchandiser only)
  Future<bool> isValidWebUser() async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final response = await _supabase
          .from('profiles')
          .select('user_type')
          .eq('id', userId)
          .single();

      final userType = response['user_type']?.toString().toLowerCase();
      return userType == 'admin' || userType == 'merchandiser';
    } catch (e) {
      return false;
    }
  }
}
