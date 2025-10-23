import 'package:dars_book/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:dars_book/features/security/presentation/bloc/app_lock_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/flex_theme_new.dart' as flex_theme_new;
import 'core/routing/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/services/app_lifecycle_service.dart';
import 'core/di/injection_container.dart' as di;
import 'features/security/presentation/widgets/session_expired_dialog.dart';

class MyApp extends StatefulWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLifecycleService _lifecycleService;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _lifecycleService = AppLifecycleService(
      sessionService: di.sl(),
      appLockBloc: di.sl(),
    );
    _lifecycleService.initialize();
  }

  @override
  void dispose() {
    _lifecycleService.dispose();
    super.dispose();
  }

  void _handleSessionExpired(BuildContext context) {
    // Use the global navigator key to show dialog
    final navigator = _navigatorKey.currentState;
    if (navigator != null) {
      SessionExpiredDialog.show(navigator.context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) => MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: flex_theme_new.FlexThemeNew.getTheme(
          brightness: Brightness.light,
          locale: settingsState.locale,
        ),
        darkTheme: flex_theme_new.FlexThemeNew.getTheme(
          brightness: Brightness.dark,
          locale: settingsState.locale,
        ),
        themeMode: settingsState.themeMode,
        onGenerateRoute: widget.appRouter.generateRoute,
        initialRoute: '/',
        // RTL and Localization Support
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'SA'), // Arabic (Saudi Arabia)
          Locale('en', 'US'), // English (United States)
        ],
        locale: settingsState.locale,
        // Force RTL for Arabic locale
        builder: (context, child) {
          return Directionality(
            textDirection: settingsState.locale.languageCode == 'ar' 
                ? TextDirection.rtl 
                : TextDirection.ltr,
            child: BlocListener<AppLockBloc, AppLockState>(
              listener: (context, state) {
                if (state is SessionExpired) {
                  // Handle session expiration globally
                  _handleSessionExpired(context);
                }
              },
              child: EasyLoading.init()(context, child),
            ),
          );
        },
      ),
    );
  }
}
