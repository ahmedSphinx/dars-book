import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Repositories
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/students/data/repositories/student_repository_impl.dart';
import '../../features/students/domain/repositories/student_repository.dart';
import '../../features/pricing/data/repositories/price_repository_impl.dart';
import '../../features/pricing/domain/repositories/price_repository.dart';
import '../../features/sessions/data/repositories/session_repository_impl.dart';
import '../../features/sessions/domain/repositories/session_repository.dart';
import '../../features/templates/data/repositories/template_repository_impl.dart';
import '../../features/templates/domain/repositories/template_repository.dart';
import '../../features/payments/data/repositories/payment_repository_impl.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/subscriptions/data/repositories/subscription_repository_impl.dart';
import '../../features/subscriptions/domain/repositories/subscription_repository.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/teacher_profile/data/repositories/teacher_repository_impl.dart';
import '../../features/teacher_profile/domain/repositories/teacher_repository.dart';

// BLoCs/Cubits
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/students/presentation/bloc/students_bloc.dart';
import '../../features/pricing/presentation/bloc/prices_bloc.dart';
import '../../features/sessions/presentation/bloc/sessions_bloc.dart';
import '../../features/templates/presentation/bloc/templates_bloc.dart';
import '../../features/payments/presentation/bloc/payments_bloc.dart';
import '../../features/reports/presentation/bloc/reports_bloc.dart';
import '../../features/reports/presentation/bloc/collections_bloc.dart';
import '../../features/subscriptions/presentation/bloc/subscription_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/security/presentation/bloc/app_lock_bloc.dart';
import '../../features/teacher_profile/presentation/bloc/teacher_profile_bloc.dart';
import '../services/session_service.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseFunctions.instance);
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Services
  sl.registerLazySingleton(() => SessionService());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(firebaseAuth: sl()),
  );

  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(firestore: sl(), firebaseAuth: sl()),
  );

  sl.registerLazySingleton<PriceRepository>(
    () => PriceRepositoryImpl(firestore: sl(), firebaseAuth: sl()),
  );

  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(firestore: sl(), firebaseAuth: sl()),
  );

  sl.registerLazySingleton<TemplateRepository>(
    () => TemplateRepositoryImpl(firestore: sl(), firebaseAuth: sl()),
  );

  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(firestore: sl(), firebaseAuth: sl()),
  );

  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      functions: sl(),
    ),
  );

  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      functions: sl(),
    ),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(secureStorage: sl()),
  );

  sl.registerLazySingleton<TeacherRepository>(
    () => TeacherRepositoryImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );

  // BLoCs/Cubits
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  sl.registerFactory(() => StudentsBloc(studentRepository: sl()));

  sl.registerFactory(() => PricesBloc(priceRepository: sl()));

  sl.registerFactory(
    () => SessionsBloc(
      sessionRepository: sl(),
      studentRepository: sl(),
      priceRepository: sl(),
    ),
  );

  sl.registerFactory(() => TemplatesBloc(templateRepository: sl()));

  sl.registerFactory(
    () => PaymentsBloc(
      paymentRepository: sl(),
      studentRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => ReportsBloc(reportRepository: sl()),
  );

  sl.registerFactory(
    () => CollectionsBloc(reportRepository: sl()),
  );

  sl.registerFactory(() => SubscriptionBloc(subscriptionRepository: sl()));

  // Register AppLockBloc first (lazy singleton)
  sl.registerLazySingleton(
    () => AppLockBloc(
      settingsRepository: sl(),
      secureStorage: sl(),
      sessionService: sl(),
    ),
  );

  // Register SettingsBloc and set up bidirectional synchronization
  sl.registerFactory(() {
    final settingsBloc = SettingsBloc(settingsRepository: sl());
    final appLockBloc = sl<AppLockBloc>();

    // SettingsBloc -> AppLockBloc: When settings change, update lock status
    settingsBloc.setSecurityChangeCallback(() {
      appLockBloc.add(CheckLockStatusEvent());
    });

    // AppLockBloc -> SettingsBloc: When PIN changes, reload settings
    appLockBloc.setSettingsChangeCallback(() {
      settingsBloc.add(LoadSettingsEvent());
    });

    return settingsBloc;
  });

  sl.registerFactory(
    () => TeacherProfileBloc(teacherRepository: sl()),
  );
}
