import 'package:admin_panel/app_bloc_observer.dart';
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/core/services/theme_service.dart';
import 'package:admin_panel/core/theme/app_theme.dart';
import 'package:admin_panel/features/shared/auth/presentation/bloc/auth_bloc.dart';
import 'package:admin_panel/shared/services/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Only load .env file for local development (not web)
  // For web, we ALWAYS use --dart-define flags
  if (!kIsWeb) {
    // Native platforms always load .env
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('✅ Loaded .env file successfully');
    } catch (e) {
      debugPrint('⚠️ Could not load .env file: $e');
      debugPrint(
          '💡 Tip: Create a .env file in the project root with SUPABASE_URL and SUPABASE_ANON_KEY');
    }
  } else {
    // Web platform - NEVER load .env file, always use --dart-define
    debugPrint(
        '🌐 Web mode - environment variables must be provided via --dart-define flags');
    debugPrint(
        '💡 Run with: flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...');
  }

  Bloc.observer = const AppBlocObserver();
  await initializeDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = sl<AuthService>();
    return ChangeNotifierProvider<ThemeService>(
      create: (_) => sl<ThemeService>(),
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return BlocProvider(
            create: (context) => sl<AuthBloc>(),
            child: MaterialApp.router(
              routerConfig: AppRouter.router(authService),
              title: 'Byte Hub Admin Panel',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeService.materialThemeMode,
            ),
          );
        },
      ),
    );
  }
}
