import 'package:dars_book/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'core/theme/flex_theme.dart';
import 'core/routing/app_router.dart';
import 'core/constants/app_constants.dart';

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: FlexTheme.lightTheme,
        darkTheme: FlexTheme.darkTheme,
        themeMode: settingsState.themeMode,
        onGenerateRoute: appRouter.generateRoute,
        initialRoute: '/',
        builder: EasyLoading.init(),
      ),
    );
  }
}
