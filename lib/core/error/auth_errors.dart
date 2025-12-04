// lib/core/error/auth_errors.dart
class AuthErrors {
  static String getDisplayMessage(String error) {
    if (error.contains('determine user type')) {
      return 'Unable to determine user permissions. Please contact support.';
    }
    if (error.contains('Cannot send Null')) {
      return 'Authentication data is incomplete. Please try logging in again.';
    }
    return error;
  }
}
