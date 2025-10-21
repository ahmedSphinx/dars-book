import 'package:flutter/material.dart';
import 'session_service.dart';
import '../../features/security/presentation/bloc/app_lock_bloc.dart';

/// Service to manage app lifecycle events and session timeout
class AppLifecycleService with WidgetsBindingObserver {
  final SessionService sessionService;
  final AppLockBloc appLockBloc;
  
  AppLifecycleService({
    required this.sessionService,
    required this.appLockBloc,
  });
  
  /// Initialize the lifecycle service
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }
  
  /// Dispose the lifecycle service
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.inactive:
        // App is transitioning between foreground and background
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        break;
      case AppLifecycleState.hidden:
        // App is hidden (iOS only)
        break;
    }
  }
  
  /// Handle app resume
  void _onAppResumed() {
    // Let SessionService handle the logic to avoid conflicts
    sessionService.onAppResumed();
  }
  
  /// Handle app pause
  void _onAppPaused() {
    sessionService.onAppPaused();
  }
  
  /// Check session validity manually
  void checkSessionValidity() {
    appLockBloc.add(CheckSessionValidityEvent());
  }
  
  /// Start a new session (call after successful authentication)
  void startSession() {
    appLockBloc.add(StartSessionEvent());
  }
  
  /// Extend current session
  void extendSession() {
    appLockBloc.add(ExtendSessionEvent());
  }
}
