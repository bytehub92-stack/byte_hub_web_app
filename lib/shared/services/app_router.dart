import 'package:admin_panel/core/constants/route_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/features/shared/auth/presentation/bloc/auth_bloc.dart';
import 'package:admin_panel/features/shared/auth/presentation/bloc/auth_event.dart';
import 'package:admin_panel/features/shared/auth/presentation/pages/login_page.dart';
import 'package:admin_panel/features/shared/auth/presentation/widgets/password_change_guard.dart';
import 'package:admin_panel/features/merchandisers/chats/presentation/bloc/chat_bloc.dart';
import 'package:admin_panel/features/merchandisers/chats/presentation/bloc/chat_event.dart';
import 'package:admin_panel/features/merchandisers/chats/presentation/pages/chat_room_page.dart';
import 'package:admin_panel/features/merchandisers/chats/presentation/pages/chats_page.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/pages/admin_dashboard_page.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/pages/admin_merchandiser_management_page.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/pages/merchandiser_layout_overview_page.dart';
import 'package:admin_panel/features/shared/profile/presentation/bloc/profile_bloc.dart';
import 'package:admin_panel/features/shared/profile/presentation/bloc/profile_event.dart';
import 'package:admin_panel/features/shared/profile/presentation/pages/merchandiser_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter router(AuthService authService) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: RouteConstants.login,
      redirect: (context, state) async {
        final isLoginRoute = state.matchedLocation == RouteConstants.login;
        final session = authService.currentSession;
        final isAuthenticated = session != null && session.isExpired == false;

        // If not authenticated and trying to access protected route
        if (!isAuthenticated && !isLoginRoute) {
          return RouteConstants.login;
        }

        // If authenticated, check if it's a valid web user (not customer)
        if (isAuthenticated) {
          final isValidWebUser = await authService.isValidWebUser();

          if (!isValidWebUser) {
            // Customer or invalid user type - sign out and redirect to login
            sl<AuthBloc>().add(LogoutRequested());
            return RouteConstants.login;
          }

          // If on login page, redirect based on user type
          if (isLoginRoute) {
            try {
              final userType = await authService.getUserType();

              if (userType == 'admin') {
                return RouteConstants.adminDashboard;
              } else if (userType == 'merchandiser') {
                return RouteConstants.merchandiserDashboard;
              }
            } catch (e) {
              debugPrint('Error getting user type: $e');
              return RouteConstants.login;
            }
          }
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: RouteConstants.login,
          name: RouteConstants.loginName,
          pageBuilder: (context, state) => MaterialPage(
            child: BlocProvider(
              create: (context) => sl<AuthBloc>()..add(CheckAuthStatus()),
              child: LoginPage(),
            ),
          ),
        ),
        GoRoute(
          path: RouteConstants.adminDashboard,
          name: RouteConstants.adminDashboardName,
          pageBuilder: (context, state) =>
              MaterialPage(child: AdminDashboardPage()),
        ),
        GoRoute(
          path: RouteConstants.merchandiserManagment,
          name: RouteConstants.merchandiserManagmentName,
          pageBuilder: (context, state) =>
              MaterialPage(child: AdminMerchandiserManagementPage()),
        ),
        GoRoute(
          path: RouteConstants.merchandiserDashboard,
          name: RouteConstants.merchandiserDashboardName,
          pageBuilder: (context, state) => MaterialPage(
            child: PasswordChangeGuard(child: MerchandiserLayoutPage()),
          ),
        ),
        GoRoute(
          path: RouteConstants.chats,
          name: RouteConstants.chatsName,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final merchandiserId = extra?['merchandiserId'] ?? '';
            return MaterialPage(
              child: BlocProvider(
                create: (context) => sl<ChatBloc>()
                  ..add(LoadChatPreviews(merchandiserId: merchandiserId))
                  ..add(const SubscribeToGlobalMessages()),
                child: ChatsPage(
                  merchandiserId: merchandiserId,
                  initialCustomerId: extra?['selectedCustomerId'],
                  initialCustomerName: extra?['selectedCustomerName'],
                  initialCustomerAvatar: extra?['selectedCustomerAvatar'],
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: RouteConstants.chatRoom,
          name: RouteConstants.chatRoomName,
          pageBuilder: (context, state) {
            final args = state.extra as Map<String, dynamic>;
            return MaterialPage(
              child: BlocProvider.value(
                value: sl<ChatBloc>()
                  ..add(
                    LoadChatMessages(
                      customerProfileId: args['customerProfileId'],
                      customerName: args['customerName'],
                    ),
                  )
                  ..add(
                    SubscribeToChatRoom(
                      customerProfileId: args['customerProfileId'],
                    ),
                  ),
                child: ChatRoomPage(
                  customerProfileId: args['customerProfileId'],
                  customerName: args['customerName'],
                  customerAvatar: args['customerAvatar'],
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: RouteConstants.merchandiserProfile,
          name: RouteConstants.merchandiserProfileName,
          pageBuilder: (context, state) => MaterialPage(
            child: BlocProvider(
              create: (context) => sl<ProfileBloc>()..add(const LoadProfile()),
              child: const MerchandiserProfilePage(),
            ),
          ),
        ),
      ],
      errorPageBuilder: (context, state) {
        return MaterialPage(
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 24),
                  Text('Page Not Found: ${state.uri.path}'),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
