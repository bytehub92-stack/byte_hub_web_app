import 'package:admin_panel/features/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:admin_panel/features/shared/auth/data/models/user_model.dart';
import 'package:admin_panel/core/error/exceptions.dart';

import '../fixtures/auth_fixtures.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  bool shouldFail = false;
  String? failureMessage;
  UserModel? userToReturn;

  @override
  Future<UserModel> login(String email, String password) async {
    if (shouldFail) {
      throw ServerException(message: failureMessage ?? 'Login failed');
    }

    // Simulate different user types based on email
    if (email == AuthFixtures.validEmail) {
      return userToReturn ?? AuthFixtures.adminUser;
    } else if (email == 'merchandiser@bytehub.com') {
      return AuthFixtures.merchandiserUser;
    } else if (email == 'customer@bytehub.com') {
      throw const ServerException(
        message: 'Invalid user type for this application: customer',
      );
    } else if (email == 'inactive@bytehub.com') {
      throw const ServerException(message: 'Account has been deactivated');
    } else if (email == AuthFixtures.invalidEmail) {
      throw const ServerException(message: 'Invalid email or password');
    }

    return AuthFixtures.adminUser;
  }

  @override
  Future<void> logout() async {
    if (shouldFail) {
      throw ServerException(message: failureMessage ?? 'Logout failed');
    }
  }
}
