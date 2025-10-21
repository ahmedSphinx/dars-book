import 'package:flutter/material.dart';
import '../routing/routes.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/phone_auth_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/students/presentation/screens/students_list_screen.dart';
import '../../features/students/presentation/screens/student_form_screen.dart';
import '../../features/students/presentation/screens/student_detail_screen.dart';
import '../../features/pricing/presentation/screens/pricing_screen.dart';
import '../../features/sessions/presentation/screens/sessions_list_screen.dart';
import '../../features/sessions/presentation/screens/create_session_screen.dart';
import '../../features/payments/presentation/screens/record_payment_screen.dart';
import '../../features/reports/presentation/screens/collections_screen.dart';
import '../../features/reports/presentation/screens/reports_dashboard_screen.dart';
import '../../features/reports/presentation/screens/student_report_screen.dart';
import '../../features/reports/presentation/screens/year_report_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/subscriptions/presentation/screens/subscription_screen.dart';
import '../../features/templates/presentation/screens/templates_list_screen.dart';
import '../../features/templates/presentation/screens/template_form_screen.dart';
import '../../features/templates/presentation/screens/template_detail_screen.dart';
import '../../features/students/domain/entities/student.dart';
import '../../features/templates/domain/entities/session_template.dart';
import '../../features/teacher_profile/presentation/screens/teacher_profile_completion_screen.dart';
import '../../features/security/presentation/screens/app_lock_screen.dart';
import '../../features/security/presentation/screens/session_test_screen.dart';
import '../../features/settings/presentation/screens/theme_test_screen.dart';

class AppRouter {
 Route? generateRoute(RouteSettings settings) {
   switch (settings.name) {
     case Routes.splashScreen:
       return _createRoute(const SplashScreen());
     case Routes.onBoardingScreen:
       return _createRoute(const OnboardingScreen());
     case Routes.phoneAuth:
       return _createRoute(const PhoneAuthScreen());
     case Routes.dashboard:
       return _createRoute(const DashboardScreen());
     case Routes.students:
       return _createRoute(const StudentsListScreen());
     case Routes.studentForm:
       final student = settings.arguments as Student?;
       return _createRoute(StudentFormScreen(student: student));
     case Routes.studentDetail:
       final student = settings.arguments as Student;
       return _createRoute(StudentDetailScreen(student: student));
     case Routes.pricing:
       return _createRoute(const PricingScreen());
     case Routes.sessions:
       return _createRoute(const SessionsListScreen());
     case Routes.createSession:
       return _createRoute(const CreateSessionScreen());
     case Routes.recordPayment:
       final student = settings.arguments as Student;
       return _createRoute(RecordPaymentScreen(student: student));
     case Routes.collections:
       return _createRoute(const CollectionsScreen());
     case Routes.reports:
       return _createRoute(const ReportsDashboardScreen());
     case Routes.studentReport:
       return _createRoute(const StudentReportScreen());
     case Routes.yearReport:
       return _createRoute(const YearReportScreen());
     case Routes.templates:
       return _createRoute(const TemplatesListScreen());
     case Routes.templateForm:
       final template = settings.arguments as SessionTemplate?;
       return _createRoute(TemplateFormScreen(template: template));
     case Routes.templateDetail:
       final template = settings.arguments as SessionTemplate;
       return _createRoute(TemplateDetailScreen(template: template));
     case Routes.settings:
       return _createRoute(const SettingsScreen());
     case Routes.subscription:
       return _createRoute(const SubscriptionScreen());
     case Routes.teacherProfileComplete:
       return _createRoute(const TeacherProfileCompletionScreen());
    case Routes.appLock:
      return _createRoute(const AppLockScreen());
    case Routes.sessionTest:
      return _createRoute(const SessionTestScreen());
    case Routes.themeTest:
      return _createRoute(const ThemeTestScreen());

    default:
       return null;
   }
 }


 PageRouteBuilder _createRoute(Widget page) {
   return PageRouteBuilder(
     transitionDuration: const Duration(milliseconds: 400),
     pageBuilder: (context, animation, secondaryAnimation) => page,
     transitionsBuilder: (context, animation, secondaryAnimation, child) {
       return FadeTransition(
         opacity: animation,
         child: Directionality(textDirection: TextDirection.rtl, child: child),
       );
     },
   );
 }
}
