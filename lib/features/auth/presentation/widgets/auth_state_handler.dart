import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/routes.dart';
import '../bloc/auth_bloc.dart';
import '../../../subscriptions/presentation/bloc/subscription_bloc.dart';
import '../../../security/presentation/bloc/app_lock_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../teacher_profile/domain/repositories/teacher_repository.dart';

/// Widget to handle authentication state changes
/// Automatically navigates based on auth status and app lock
class AuthStateHandler extends StatelessWidget {
  final Widget child;

  const AuthStateHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(CheckAuthStatus()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated) {
            // Check teacher profile completeness before proceeding
            final teacherRepo = sl<TeacherRepository>();
            final result = await teacherRepo.isProfileComplete(state.user.uid);
            result.fold(
              (_) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.teacherProfileComplete,
                  (route) => false,
                );
              },
              (complete) {
                if (complete) {
                  // Check if app is locked
                  final appLockState = context.read<AppLockBloc>().state;
                  if (appLockState is AppLocked) {
                    // App is locked, navigate to lock screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.appLock,
                      (route) => false,
                    );
                  } else {
                    // App is unlocked, proceed to dashboard
                    context.read<SubscriptionBloc>().add(const LoadSubscription());
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.dashboard,
                      (route) => false,
                    );
                  }
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.teacherProfileComplete,
                    (route) => false,
                  );
                }
              },
            );
          } else if (state is AuthUnauthenticated) {
            // User is not authenticated, navigate to auth screen
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.phoneAuth,
              (route) => false,
            );
          }
        },
        child: child,
      ),
    );
  }
}


