/* // Demo script showing how to use the Session Management feature
// This file is for demonstration purposes only

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/features/security/presentation/bloc/app_lock_bloc.dart';
import 'lib/core/services/session_service.dart';
import 'lib/core/di/injection_container.dart' as di;
import 'lib/features/security/presentation/widgets/session_timeout_warning.dart';

/// Demo class showing how to use session management
class SessionFeatureDemo {
  
  /// Example 1: Basic session management
  static void basicSessionManagement(BuildContext context) {
    final appLockBloc = context.read<AppLockBloc>();
    
    // Start a new session after authentication
    appLockBloc.add(StartSessionEvent());
    
    // Extend session when user is active
    appLockBloc.add(ExtendSessionEvent());
    
    // Check session validity
    appLockBloc.add(CheckSessionValidityEvent());
  }
  
  /// Example 2: Using SessionService directly
  static void directSessionService() {
    final sessionService = di.sl<SessionService>();
    
    // Check if session is valid
    bool isValid = sessionService.isSessionValid();
    print('Session valid: $isValid');
    
    // Get remaining time
    int remaining = sessionService.getRemainingSessionTime();
    print('Remaining time: $remaining seconds');
    
    // Start session
    sessionService.startSession();
    
    // Extend session
    sessionService.extendSession();
    
    // Set custom timeout (10 minutes)
    sessionService.setSessionTimeout(10);
  }
  
  /// Example 3: Listening to session events
  static Widget sessionListenerExample() {
    return BlocListener<AppLockBloc, AppLockState>(
      listener: (context, state) {
        if (state.runtimeType.toString() == 'SessionExpired') {
          // Navigate to lock screen
          Navigator.pushNamed(context, '/app-lock');
        } else if (state is SessionActive) {
          // Show remaining time
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session active: ${state.remainingSeconds}s remaining'),
            ),
          );
        }
      },
      child: Container(), // Your actual widget
    );
  }
  
  /// Example 4: Custom session timeout widget
  static Widget customSessionWidget() {
    return SessionTimeoutWarning(
      warningThresholdSeconds: 60, // Show warning 1 minute before expiry
      child: Scaffold(
        appBar: AppBar(title: const Text('My Screen')),
        body: const Center(
          child: Text('This screen has session management!'),
        ),
      ),
    );
  }
  
  /// Example 5: Testing session functionality
  static void testSessionFeature() {
    print('=== Session Management Demo ===');
    
    final sessionService = di.sl<SessionService>();
    
    // Test 1: Start session
    print('1. Starting session...');
    sessionService.startSession();
    print('   Session valid: ${sessionService.isSessionValid()}');
    print('   Remaining time: ${sessionService.getRemainingSessionTime()}s');
    
    // Test 2: Extend session
    print('\n2. Extending session...');
    sessionService.extendSession();
    print('   Remaining time: ${sessionService.getRemainingSessionTime()}s');
    
    // Test 3: Set custom timeout
    print('\n3. Setting timeout to 1 minute...');
    sessionService.setSessionTimeout(1);
    print('   Timeout set to: ${sessionService.sessionTimeoutMinutes} minutes');
    
    // Test 4: Force expiration
    print('\n4. Forcing session expiration...');
    sessionService.forceSessionExpiration();
    print('   Session valid: ${sessionService.isSessionValid()}');
    
    print('\n=== Demo Complete ===');
  }
}

/// Example usage in a Flutter widget
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});
  
  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Demo')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => SessionFeatureDemo.basicSessionManagement(context),
            child: const Text('Start Session'),
          ),
          ElevatedButton(
            onPressed: () => SessionFeatureDemo.directSessionService(),
            child: const Text('Check Session'),
          ),
          ElevatedButton(
            onPressed: () => SessionFeatureDemo.testSessionFeature(),
            child: const Text('Run Demo'),
          ),
        ],
      ),
    );
  }
}
 */