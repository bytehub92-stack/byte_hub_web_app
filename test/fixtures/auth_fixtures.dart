import 'package:admin_panel/features/shared/auth/data/models/user_model.dart';
import 'package:admin_panel/features/shared/auth/domain/entities/user.dart';

// Test User Data
class AuthFixtures {
  // Valid Admin User
  static const adminUser = UserModel(
    id: 'admin-123',
    email: 'admin@bytehub.com',
    fullName: 'Admin User',
    userType: UserType.admin,
    token: 'valid-admin-token',
    mustChangePassword: false,
    isActive: true,
  );

  static Map<String, dynamic> get adminUserJson => {
    'id': 'admin-123',
    'email': 'admin@bytehub.com',
    'full_name': 'Admin User',
    'user_type': 'admin',
    'token': 'valid-admin-token',
    'must_change_password': false,
    'is_active': true,
  };

  // Valid Merchandiser User
  static const merchandiserUser = UserModel(
    id: 'merchandiser-123',
    email: 'merchandiser@bytehub.com',
    fullName: 'Merchandiser User',
    userType: UserType.merchandiser,
    token: 'valid-merchandiser-token',
    mustChangePassword: false,
    isActive: true,
  );

  static Map<String, dynamic> get merchandiserUserJson => {
    'id': 'merchandiser-123',
    'email': 'merchandiser@bytehub.com',
    'full_name': 'Merchandiser User',
    'user_type': 'merchandiser',
    'token': 'valid-merchandiser-token',
    'must_change_password': false,
    'is_active': true,
  };

  // Merchandiser with Password Change Required
  static const merchandiserNeedsPasswordChange = UserModel(
    id: 'merchandiser-456',
    email: 'newmerch@bytehub.com',
    fullName: 'New Merchandiser',
    userType: UserType.merchandiser,
    token: 'temp-token',
    mustChangePassword: true,
    isActive: true,
  );

  static Map<String, dynamic> get merchandiserNeedsPasswordChangeJson => {
    'id': 'merchandiser-456',
    'email': 'newmerch@bytehub.com',
    'full_name': 'New Merchandiser',
    'user_type': 'merchandiser',
    'token': 'temp-token',
    'must_change_password': true,
    'is_active': true,
  };

  // Invalid Customer User (should be rejected)
  static const customerUser = UserModel(
    id: 'customer-123',
    email: 'customer@bytehub.com',
    fullName: 'Customer User',
    userType: UserType.customer,
    token: 'customer-token',
    mustChangePassword: false,
    isActive: true,
  );

  static Map<String, dynamic> get customerUserJson => {
    'id': 'customer-123',
    'email': 'customer@bytehub.com',
    'full_name': 'Customer User',
    'user_type': 'customer',
    'token': 'customer-token',
    'must_change_password': false,
    'is_active': true,
  };

  // Inactive User
  static const inactiveUser = UserModel(
    id: 'inactive-123',
    email: 'inactive@bytehub.com',
    fullName: 'Inactive User',
    userType: UserType.merchandiser,
    token: 'inactive-token',
    mustChangePassword: false,
    isActive: false,
  );

  static Map<String, dynamic> get inactiveUserJson => {
    'id': 'inactive-123',
    'email': 'inactive@bytehub.com',
    'full_name': 'Inactive User',
    'user_type': 'merchandiser',
    'token': 'inactive-token',
    'must_change_password': false,
    'is_active': false,
  };

  // Profile Response from Supabase
  static Map<String, dynamic> get validAdminProfile => {
    'id': 'admin-123',
    'email': 'admin@bytehub.com',
    'full_name': 'Admin User',
    'user_type': 'admin',
    'is_active': true,
    'must_change_password': false,
  };

  static Map<String, dynamic> get validMerchandiserProfile => {
    'id': 'merchandiser-123',
    'email': 'merchandiser@bytehub.com',
    'full_name': 'Merchandiser User',
    'user_type': 'merchandiser',
    'is_active': true,
    'must_change_password': false,
  };

  static Map<String, dynamic> get customerProfile => {
    'id': 'customer-123',
    'email': 'customer@bytehub.com',
    'full_name': 'Customer User',
    'user_type': 'customer',
    'is_active': true,
    'must_change_password': false,
  };

  static Map<String, dynamic> get inactiveProfile => {
    'id': 'inactive-123',
    'email': 'inactive@bytehub.com',
    'full_name': 'Inactive User',
    'user_type': 'merchandiser',
    'is_active': false,
    'must_change_password': false,
  };

  // Valid credentials
  static const String validEmail = 'admin@bytehub.com';
  static const String validPassword = 'password123';
  static const String invalidEmail = 'wrong@bytehub.com';
  static const String invalidPassword = 'wrongpassword';
}
