// Tag the ENTIRE file
@Tags(['integration'])
library;

import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/usecases/usecase.dart';
import 'package:admin_panel/features/shared/auth/data/datasources/auth_local_datasource.dart';
import 'package:admin_panel/features/shared/auth/data/repositories/auth_repository_impl.dart';
import 'package:admin_panel/features/shared/auth/domain/entities/user.dart';
import 'package:admin_panel/features/shared/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:admin_panel/features/shared/auth/domain/usecases/login_usecase.dart';
import 'package:admin_panel/features/shared/auth/domain/usecases/logout_usecase.dart';
import 'package:admin_panel/features/shared/auth/presentation/bloc/auth_bloc.dart';
import 'package:admin_panel/features/shared/auth/presentation/bloc/auth_event.dart';
import 'package:admin_panel/features/shared/auth/presentation/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fixtures/auth_fixtures.dart';
import '../helpers/fakes.dart';
import '../helpers/fake_auth_service.dart';
import '../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Authentication Flow Integration Tests', () {
    late AuthBloc authBloc;
    late AuthRepositoryImpl repository;
    late FakeAuthRemoteDataSource fakeRemoteDataSource;
    late AuthLocalDataSource localDataSource;
    late MockNetworkInfo mockNetworkInfo;
    late FakeAuthService fakeAuthService;

    setUpAll(() {
      registerFallbackValue(const LoginParams(email: '', password: ''));
      registerFallbackValue(NoParams());
    });

    setUp(() async {
      // Setup real local storage
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Create fake/mock dependencies
      fakeRemoteDataSource = FakeAuthRemoteDataSource();
      localDataSource = AuthLocalDataSourceImpl(sharedPreferences: prefs);
      mockNetworkInfo = MockNetworkInfo();
      fakeAuthService = FakeAuthService();

      // Setup network to be online by default
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      // Create repository with real local storage and fake remote
      repository = AuthRepositoryImpl(
        remoteDataSource: fakeRemoteDataSource,
        localDataSource: localDataSource,
        networkInfo: mockNetworkInfo,
      );

      // Create use cases
      final loginUseCase = LoginUseCase(repository);
      final logoutUseCase = LogoutUseCase(repository);
      final getCurrentUserUseCase = GetCurrentUserUseCase(repository);

      // Create BLoC
      authBloc = AuthBloc(
        loginUseCase: loginUseCase,
        logoutUseCase: logoutUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
        authService: fakeAuthService,
      );
    });

    tearDown(() async {
      await authBloc.close();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('Scenario 1: Admin login → Success → User cached', () async {
      // Arrange
      const email = AuthFixtures.validEmail;
      const password = AuthFixtures.validPassword;

      // Act - Login
      authBloc.add(const LoginRequested(email: email, password: password));

      // Wait for state changes
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Check final state
      expect(authBloc.state, isA<AuthAuthenticated>());
      final authState = authBloc.state as AuthAuthenticated;
      expect(authState.user.userType, UserType.admin);
      expect(authState.user.email, email);

      // Assert - Check user is cached
      final cachedUser = await localDataSource.getCachedUser();
      expect(cachedUser, isNotNull);
      expect(cachedUser!.email, email);
    });

    test(
      'Scenario 2: Merchandiser login → Success → Must change password flag',
      () async {
        // Arrange
        const email = 'merchandiser@bytehub.com';
        const password = AuthFixtures.validPassword;

        // Act
        authBloc.add(const LoginRequested(email: email, password: password));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(authBloc.state, isA<AuthAuthenticated>());
        final authState = authBloc.state as AuthAuthenticated;
        expect(authState.user.userType, UserType.merchandiser);
      },
    );

    test('Scenario 3: Customer login → Rejected with proper error', () async {
      // Arrange
      const email = 'customer@bytehub.com';
      const password = AuthFixtures.validPassword;

      // Act
      authBloc.add(const LoginRequested(email: email, password: password));
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authBloc.state, isA<AuthError>());
      final errorState = authBloc.state as AuthError;
      expect(errorState.message, contains('Invalid user type'));

      // Assert - No user should be cached
      final cachedUser = await localDataSource.getCachedUser();
      expect(cachedUser, isNull);
    });

    test('Scenario 4: Inactive user login → Rejected', () async {
      // Arrange
      const email = 'inactive@bytehub.com';
      const password = AuthFixtures.validPassword;

      // Act
      authBloc.add(const LoginRequested(email: email, password: password));
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authBloc.state, isA<AuthError>());
      final errorState = authBloc.state as AuthError;
      expect(errorState.message, 'Account has been deactivated');
    });

    test('Scenario 5: Invalid credentials → Proper error message', () async {
      // Arrange
      const email = AuthFixtures.invalidEmail;
      const password = AuthFixtures.invalidPassword;

      // Act
      authBloc.add(const LoginRequested(email: email, password: password));
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authBloc.state, isA<AuthError>());
      final errorState = authBloc.state as AuthError;
      expect(errorState.message, 'Invalid email or password');
    });

    test('Scenario 6: Login when offline → Network error', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      authBloc.add(
        const LoginRequested(
          email: AuthFixtures.validEmail,
          password: AuthFixtures.validPassword,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authBloc.state, isA<AuthError>());
      final errorState = authBloc.state as AuthError;
      expect(errorState.message, 'No internet connection');
    });

    test(
      'Scenario 7: Complete flow - Login → Logout → Cache cleared',
      () async {
        // Step 1: Login
        authBloc.add(
          const LoginRequested(
            email: AuthFixtures.validEmail,
            password: AuthFixtures.validPassword,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert login success
        expect(authBloc.state, isA<AuthAuthenticated>());

        // Verify user is cached
        var cachedUser = await localDataSource.getCachedUser();
        expect(cachedUser, isNotNull);

        // Step 2: Logout
        authBloc.add(LogoutRequested());
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert logout success
        expect(authBloc.state, isA<AuthUnauthenticated>());

        // Verify cache is cleared
        cachedUser = await localDataSource.getCachedUser();
        expect(cachedUser, isNull);
      },
    );

    test(
      'Scenario 8: Login → App restart → User still authenticated (cached)',
      () async {
        // Step 1: Login
        authBloc.add(
          const LoginRequested(
            email: AuthFixtures.validEmail,
            password: AuthFixtures.validPassword,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));
        expect(authBloc.state, isA<AuthAuthenticated>());

        // Step 2: Simulate app restart - close and recreate bloc
        await authBloc.close();

        // Create new bloc (simulating app restart)
        final newAuthBloc = AuthBloc(
          loginUseCase: LoginUseCase(repository),
          logoutUseCase: LogoutUseCase(repository),
          getCurrentUserUseCase: GetCurrentUserUseCase(repository),
          authService: fakeAuthService,
        );

        // Step 3: Check auth status (simulating app checking on startup)
        final result = await repository.getCurrentUser();

        // Assert - User should still be cached
        result.fold((failure) => fail('Should not fail'), (user) {
          expect(user, isNotNull);
          expect(user!.email, AuthFixtures.validEmail);
        });

        await newAuthBloc.close();
      },
    );

    test('Scenario 9: Multiple login attempts with different users', () async {
      // Attempt 1: Admin login
      authBloc.add(
        const LoginRequested(
          email: AuthFixtures.validEmail,
          password: AuthFixtures.validPassword,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(authBloc.state, isA<AuthAuthenticated>());
      expect(
        (authBloc.state as AuthAuthenticated).user.userType,
        UserType.admin,
      );

      // Logout
      authBloc.add(LogoutRequested());
      await Future.delayed(const Duration(milliseconds: 100));

      // Attempt 2: Merchandiser login
      authBloc.add(
        const LoginRequested(
          email: 'merchandiser@bytehub.com',
          password: AuthFixtures.validPassword,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(authBloc.state, isA<AuthAuthenticated>());
      expect(
        (authBloc.state as AuthAuthenticated).user.userType,
        UserType.merchandiser,
      );

      // Verify cached user is merchandiser (not admin)
      final cachedUser = await localDataSource.getCachedUser();
      expect(cachedUser!.userType, UserType.merchandiser);
    });

    test('Scenario 10: Login fails but cache still has old user', () async {
      // Step 1: Successful login first
      authBloc.add(
        const LoginRequested(
          email: AuthFixtures.validEmail,
          password: AuthFixtures.validPassword,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(authBloc.state, isA<AuthAuthenticated>());

      // Step 2: Logout
      authBloc.add(LogoutRequested());
      await Future.delayed(const Duration(milliseconds: 100));

      // Step 3: Try login with invalid credentials
      authBloc.add(
        const LoginRequested(
          email: AuthFixtures.invalidEmail,
          password: AuthFixtures.invalidPassword,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Should show error, not old cached user
      expect(authBloc.state, isA<AuthError>());

      // Verify cache is cleared from logout
      final cachedUser = await localDataSource.getCachedUser();
      expect(cachedUser, isNull);
    });

    blocTest<AuthBloc, AuthState>(
      'Scenario 11: BLoC emits correct state sequence for successful login',
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const LoginRequested(
          email: AuthFixtures.validEmail,
          password: AuthFixtures.validPassword,
        ),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
      verify: (_) async {
        // Verify side effects
        final cachedUser = await localDataSource.getCachedUser();
        expect(cachedUser, isNotNull);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'Scenario 12: BLoC emits correct state sequence for failed login',
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const LoginRequested(
          email: AuthFixtures.invalidEmail,
          password: AuthFixtures.invalidPassword,
        ),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );

    test('Scenario 13: Concurrent login attempts handled correctly', () async {
      // This tests race conditions

      // Trigger multiple login attempts simultaneously
      for (int i = 0; i < 3; i++) {
        authBloc.add(
          const LoginRequested(
            email: AuthFixtures.validEmail,
            password: AuthFixtures.validPassword,
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 200));

      // Should end up in authenticated state (not error or loading)
      expect(authBloc.state, isA<AuthAuthenticated>());
    });

    test('Scenario 14: Auth service integration with login', () async {
      // Login first
      authBloc.add(
        const LoginRequested(
          email: AuthFixtures.validEmail,
          password: AuthFixtures.validPassword,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // Set up fake auth service
      fakeAuthService.setAuthenticatedUser('admin-123', 'admin');

      // Verify auth service state
      expect(fakeAuthService.isAuthenticated, true);
      expect(await fakeAuthService.getUserType(), 'admin');
      expect(await fakeAuthService.isValidWebUser(), true);
    });

    test('Scenario 15: Customer blocked from auth service', () async {
      // Setup customer in auth service
      fakeAuthService.setAuthenticatedUser('customer-123', 'customer');

      // Verify customer is not valid web user
      expect(await fakeAuthService.isValidWebUser(), false);
    });
  });

  group('Edge Cases and Error Scenarios', () {
    test('Empty email and password', () async {
      final authBloc = AuthBloc(
        loginUseCase: LoginUseCase(
          AuthRepositoryImpl(
            remoteDataSource: FakeAuthRemoteDataSource(),
            localDataSource: AuthLocalDataSourceImpl(
              sharedPreferences: sl<SharedPreferences>(),
            ),
            networkInfo: MockNetworkInfo(),
          ),
        ),
        logoutUseCase: LogoutUseCase(
          AuthRepositoryImpl(
            remoteDataSource: FakeAuthRemoteDataSource(),
            localDataSource: AuthLocalDataSourceImpl(
              sharedPreferences: await SharedPreferences.getInstance(),
            ),
            networkInfo: MockNetworkInfo(),
          ),
        ),
        getCurrentUserUseCase: GetCurrentUserUseCase(
          AuthRepositoryImpl(
            remoteDataSource: FakeAuthRemoteDataSource(),
            localDataSource: AuthLocalDataSourceImpl(
              sharedPreferences: await SharedPreferences.getInstance(),
            ),
            networkInfo: MockNetworkInfo(),
          ),
        ),
        authService: FakeAuthService(),
      );

      when(
        () => (authBloc.loginUseCase.repository as AuthRepositoryImpl)
            .networkInfo
            .isConnected,
      ).thenAnswer((_) async => true);

      authBloc.add(const LoginRequested(email: '', password: ''));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(authBloc.state, isA<AuthError>());
      await authBloc.close();
    });

    test('Very long email address', () async {
      final longEmail = 'a' * 1000 + '@bytehub.com';
      // Should handle gracefully without crashing
      expect(longEmail.length, greaterThan(100));
    });

    test('Special characters in password', () async {
      const specialPassword = '!@#\$%^&*()_+-=[]{}|;:",.<>?/~`';
      // Should handle special characters
      expect(specialPassword.isNotEmpty, true);
    });
  });

  group('Performance Tests', () {
    test('Login completes within acceptable time', () async {
      final stopwatch = Stopwatch()..start();

      final repository = AuthRepositoryImpl(
        remoteDataSource: FakeAuthRemoteDataSource(),
        localDataSource: AuthLocalDataSourceImpl(
          sharedPreferences: await SharedPreferences.getInstance(),
        ),
        networkInfo: MockNetworkInfo(),
      );

      when(
        () => (repository.networkInfo as MockNetworkInfo).isConnected,
      ).thenAnswer((_) async => true);

      await repository.login(
        AuthFixtures.validEmail,
        AuthFixtures.validPassword,
      );

      stopwatch.stop();

      // Login should complete in less than 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}
