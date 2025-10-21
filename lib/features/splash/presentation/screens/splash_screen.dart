import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/extensions/navigation_extensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../subscriptions/presentation/bloc/subscription_bloc.dart';
import '../../../security/presentation/bloc/app_lock_bloc.dart';
import '../../../teacher_profile/domain/repositories/teacher_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check authentication status
    final authBloc = sl<AuthBloc>();
    authBloc.add(CheckAuthStatus());

    // Listen to auth state
    authBloc.stream.first.then((state) async {
      if (!mounted) return;

      if (state is AuthAuthenticated) {
        // Check teacher profile completeness
        final teacherRepo = sl<TeacherRepository>();
        final result = await teacherRepo.isProfileComplete(state.user.uid);
        result.fold(
          (failure) {
            // On error, send to completion to be safe
            context.pushNamedAndRemoveUntil(Routes.teacherProfileComplete, (route) => false);
          },
          (complete) {
            if (complete) {
              // Check if app is locked
              final appLockState = context.read<AppLockBloc>().state;
              if (appLockState is AppLocked) {
                // App is locked, navigate to lock screen
                context.pushNamedAndRemoveUntil(Routes.appLock, (route) => false);
              } else {
                // App is unlocked, proceed to dashboard
                context.read<SubscriptionBloc>().add(const LoadSubscription());
                context.pushNamedAndRemoveUntil(Routes.dashboard, (route) => false);
              }
            } else {
              context.pushNamedAndRemoveUntil(Routes.teacherProfileComplete, (route) => false);
            }
          },
        );
      } else {
        // User is not authenticated, go to onboarding
        context.pushNamed(Routes.onBoardingScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  size: 80,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 32),
              
              // App Name
              const Text(
                'DarsBook',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              
              // Tagline
              Text(
                'إدارة الطلاب والحصص',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 48),
              
              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



