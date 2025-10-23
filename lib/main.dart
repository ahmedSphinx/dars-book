import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/utils/app_shared_preferences.dart';
import 'core/routing/app_router.dart';
import 'core/services/firebase_service.dart';
import 'core/services/session_service.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/payments/presentation/bloc/payments_bloc.dart';
import 'features/pricing/presentation/bloc/prices_bloc.dart';
import 'features/reports/presentation/bloc/collections_bloc.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'features/sessions/presentation/bloc/sessions_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/students/presentation/bloc/students_bloc.dart';
import 'features/subscriptions/presentation/bloc/subscription_bloc.dart';
import 'features/security/presentation/bloc/app_lock_bloc.dart';
import 'app.dart';
import 'app_bloc_observer.dart';
import 'features/teacher_profile/presentation/bloc/teacher_profile_bloc.dart';
import 'features/templates/presentation/bloc/templates_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase Stick to the plan
  await FirebaseService.initialize();
  
  
  // Set BLoC observer
  Bloc.observer = AppBlocObserver();
  
  // Initialize shared preferences
  await AppPreferences().init();
  
  // Initialize dependency injection
  await di.initializeDependencies();
  
  // Initialize session service
  await di.sl<SessionService>().initialize();

  runApp(MultiBlocProvider(
    providers: [
       BlocProvider(create: (_) => di.sl<AuthBloc>()),
      BlocProvider(create: (_) => di.sl<SettingsBloc>()),
      BlocProvider(create: (_) => di.sl<SubscriptionBloc>()),
      BlocProvider(create: (_) => di.sl<AppLockBloc>()..add(CheckLockStatusEvent())),
      BlocProvider(create: (_) => di.sl<ReportsBloc>()),
      BlocProvider(create: (_) => di.sl<CollectionsBloc>()),
      BlocProvider(create: (_) => di.sl<TemplatesBloc>()),
      BlocProvider(create: (_) => di.sl<PaymentsBloc>()),
      BlocProvider(create: (_) => di.sl<SessionsBloc>()),
      BlocProvider(create: (_) => di.sl<PricesBloc>()),
      BlocProvider(create: (_) => di.sl<StudentsBloc>()),
      BlocProvider(create: (_) => di.sl<TeacherProfileBloc>()),
    ],
    child: ScreenUtilInit(child: MyApp(appRouter: AppRouter())),
  ));
}
