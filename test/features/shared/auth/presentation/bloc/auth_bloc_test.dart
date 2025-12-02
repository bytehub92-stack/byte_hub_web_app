import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/core/usecases/usecase.dart';
import 'package:admin_panel/features/shared/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:admin_panel/features/shared/auth/domain/usecases/login_usecase.dart';
import 'package:admin_panel/features/shared/auth/domain/usecases/logout_usecase.dart';
import 'package:admin_panel/features/shared/auth/presentation/bloc/auth_bloc.dart';
import 'package:admin_panel/features/shared/auth/presentation/bloc/auth_event.dart';
import 'package:admin_panel/features/shared/auth/presentation/bloc/auth_state.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../fixtures/auth_fixtures.dart';
import '../../../../../helpers/mocks.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockAuthService mockAuthService;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockAuthService = MockAuthService();

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      authService: mockAuthService,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(NoParams());
  });

  group('LoginRequested', () {
    const tEmail = AuthFixtures.validEmail;
    const tPassword = AuthFixtures.validPassword;
    const tUser = AuthFixtures.adminUser;

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds with admin',
      build: () {
        when(
          () => mockLoginUseCase(any()),
        ).thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: tEmail, password: tPassword)),
      expect: () => [AuthLoading(), const AuthAuthenticated(tUser)],
      verify: (_) {
        verify(() => mockLoginUseCase(any())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds with merchandiser',
      build: () {
        when(
          () => mockLoginUseCase(any()),
        ).thenAnswer((_) async => const Right(AuthFixtures.merchandiserUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const LoginRequested(
          email: 'merchandiser@bytehub.com',
          password: tPassword,
        ),
      ),
      expect: () => [
        AuthLoading(),
        const AuthAuthenticated(AuthFixtures.merchandiserUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails with invalid credentials',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Invalid email or password')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const LoginRequested(
          email: AuthFixtures.invalidEmail,
          password: AuthFixtures.invalidPassword,
        ),
      ),
      expect: () => [
        AuthLoading(),
        const AuthError('Invalid email or password'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when user is inactive',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Account has been deactivated'),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const LoginRequested(
          email: 'inactive@bytehub.com',
          password: tPassword,
        ),
      ),
      expect: () => [
        AuthLoading(),
        const AuthError('Account has been deactivated'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when user type is customer',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer(
          (_) async => const Left(
            ServerFailure(
              message: 'Invalid user type for this application: customer',
            ),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const LoginRequested(
          email: 'customer@bytehub.com',
          password: tPassword,
        ),
      ),
      expect: () => [
        AuthLoading(),
        const AuthError('Invalid user type for this application: customer'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when network fails',
      build: () {
        when(
          () => mockLoginUseCase(any()),
        ).thenAnswer((_) async => const Left(NetworkFailure()));
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: tEmail, password: tPassword)),
      expect: () => [AuthLoading(), const AuthError('No internet connection')],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when logout succeeds',
      build: () {
        when(
          () => mockLogoutUseCase(any()),
        ).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
      verify: (_) {
        verify(() => mockLogoutUseCase(NoParams())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when logout fails',
      build: () {
        when(() => mockLogoutUseCase(any())).thenAnswer(
          (_) async => const Left(AuthFailure(message: 'Logout failed')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [AuthLoading(), const AuthError('Logout failed')],
    );
  });

  group('CheckAuthStatus', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when user is not authenticated',
      build: () {
        when(() => mockAuthService.isAuthenticated).thenReturn(false);
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when user type is invalid (customer)',
      build: () {
        when(() => mockAuthService.isAuthenticated).thenReturn(true);
        when(
          () => mockAuthService.isValidWebUser(),
        ).thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when current user ID is null',
      build: () {
        when(() => mockAuthService.isAuthenticated).thenReturn(true);
        when(
          () => mockAuthService.isValidWebUser(),
        ).thenAnswer((_) async => true);
        when(() => mockAuthService.currentUserId).thenReturn(null);
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
    );
  });
}
