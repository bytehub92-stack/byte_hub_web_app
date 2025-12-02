import 'package:admin_panel/core/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthService implements AuthService {
  String? _currentUserId;
  String? _userType;
  bool _isAuthenticated = false;

  @override
  String? get currentUserId => _currentUserId;

  @override
  User? get currentUser => null;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  Session? get currentSession => null;

  @override
  Future<String?> getMerchandiserId() async {
    if (_userType == 'merchandiser') {
      return 'merchandiser-123';
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getMerchandiserData() async {
    if (_userType == 'merchandiser') {
      return {
        'id': 'merchandiser-123',
        'business_name': {'en': 'Test Business'},
      };
    }
    return null;
  }

  @override
  Future<String> getUserType() async {
    return _userType ?? 'customer';
  }

  @override
  Future<bool> isValidWebUser() async {
    return _userType == 'admin' || _userType == 'merchandiser';
  }

  // Helper methods for testing
  void setAuthenticatedUser(String userId, String userType) {
    _currentUserId = userId;
    _userType = userType;
    _isAuthenticated = true;
  }

  void clearAuth() {
    _currentUserId = null;
    _userType = null;
    _isAuthenticated = false;
  }
}
