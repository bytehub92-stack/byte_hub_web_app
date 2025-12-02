import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/features/shared/auth/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../../core/debug/debug_config.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final AuthService authService;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.authService,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      DebugConfig.logInfo('Login requested for: ${event.email}');

      final result = await loginUseCase(
        LoginParams(email: event.email, password: event.password),
      );

      result.fold(
        (failure) {
          DebugConfig.logError('Login failed: ${failure.message}');
          emit(AuthError(failure.message));
        },
        (user) {
          DebugConfig.logInfo(
            'Login successful for user type: ${user.userType.name}',
          );
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e, stackTrace) {
      DebugConfig.logError(
        'Unexpected error in login bloc',
        error: e,
        stackTrace: stackTrace,
      );
      emit(const AuthError('An unexpected error occurred'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final result = await logoutUseCase(NoParams());

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) => emit(AuthUnauthenticated()),
      );
    } catch (e, stackTrace) {
      DebugConfig.logError(
        'Unexpected error in logout bloc',
        error: e,
        stackTrace: stackTrace,
      );
      emit(const AuthError('Logout failed'));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      // Check if user is authenticated
      if (!authService.isAuthenticated) {
        emit(AuthUnauthenticated());
        return;
      }

      // Validate if it's a valid web user (admin or merchandiser, not customer)
      final isValidWebUser = await authService.isValidWebUser();

      if (!isValidWebUser) {
        DebugConfig.logInfo('Invalid web user type detected - signing out');
        await Supabase.instance.client.auth.signOut();
        emit(AuthUnauthenticated());
        return;
      }

      // Get current user ID
      final userId = authService.currentUserId;
      if (userId == null) {
        emit(AuthUnauthenticated());
        return;
      }

      // Get profile data
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select(
            'id, email, full_name, user_type, is_active, must_change_password',
          )
          .eq('id', userId)
          .single();

      // Get current user email
      final currentUser = authService.currentUser;

      final userData = {
        'id': userId,
        'email': currentUser?.email ?? profileResponse['email'] ?? '',
        'full_name': profileResponse['full_name'],
        'user_type': profileResponse['user_type'],
        'token': authService.currentSession?.accessToken,
        'must_change_password':
            profileResponse['must_change_password'] ?? false,
        'is_active': profileResponse['is_active'] ?? true,
      };

      final user = UserModel.fromJson(userData);

      DebugConfig.logInfo(
        'Auth status checked - User type: ${user.userType.name}',
      );

      emit(AuthAuthenticated(user));
    } catch (e, stackTrace) {
      DebugConfig.logError(
        'Unexpected error checking auth status',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AuthUnauthenticated());
    }
  }
}
