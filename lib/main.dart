import 'package:admin_panel/app_bloc_observer.dart';
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/core/services/theme_service.dart';
import 'package:admin_panel/core/theme/app_theme.dart';
import 'package:admin_panel/shared/services/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load();
  Bloc.observer = const AppBlocObserver();
  await initializeDependencies();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(),
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
          return MaterialApp.router(
            routerConfig: AppRouter.router(authService),
            title: 'Byte Hub Admin Panel',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.materialThemeMode,
          );
        },
      ),
    );
  }
}
