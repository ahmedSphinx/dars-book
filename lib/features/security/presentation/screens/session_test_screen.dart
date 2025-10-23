import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/app_lock_bloc.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/di/injection_container.dart' as di;

/// Test screen to demonstrate session management features
class SessionTestScreen extends StatefulWidget {
  const SessionTestScreen({super.key});

  @override
  State<SessionTestScreen> createState() => _SessionTestScreenState();
}

class _SessionTestScreenState extends State<SessionTestScreen> {
  late SessionService _sessionService;
  int _remainingSeconds = 0;
  bool _isSessionValid = false;

  @override
  void initState() {
    super.initState();
    _sessionService = di.sl<SessionService>();
    _updateSessionInfo();
    
    // Update every second
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) {
        _updateSessionInfo();
      }
    });
  }

  void _updateSessionInfo() {
    setState(() {
      _isSessionValid = _sessionService.isSessionValid();
      _remainingSeconds = _sessionService.getRemainingSessionTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Management Test'),
        backgroundColor: const Color(0xFF1F21A8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Session Status Card
            Card(
              color: _isSessionValid ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isSessionValid ? Icons.check_circle : Icons.cancel,
                      color: _isSessionValid ? Colors.green : Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSessionValid ? 'Session Active' : 'Session Expired',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isSessionValid ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Remaining Time: ${_remainingSeconds}s',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            ElevatedButton.icon(
              onPressed: () {
                context.read<AppLockBloc>().add(StartSessionEvent());
                _updateSessionInfo();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Session started!')),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () {
                context.read<AppLockBloc>().add(ExtendSessionEvent());
                _updateSessionInfo();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Session extended!')),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Extend Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () {
                context.read<AppLockBloc>().add(CheckSessionValidityEvent());
                _updateSessionInfo();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Session validity checked!')),
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text('Check Session Validity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () {
                _sessionService.forceSessionExpiration();
                _updateSessionInfo();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Session expired!')),
                );
              },
              icon: const Icon(Icons.stop),
              label: const Text('Force Session Expiration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Session Timeout Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Timeout Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<AppLockBloc>().add(
                                const SetSessionTimeoutEvent(1), // 1 minute
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Timeout set to 1 minute')),
                              );
                            },
                            child: const Text('1 min'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<AppLockBloc>().add(
                                const SetSessionTimeoutEvent(5), // 5 minutes
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Timeout set to 5 minutes')),
                              );
                            },
                            child: const Text('5 min'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<AppLockBloc>().add(
                                const SetSessionTimeoutEvent(10), // 10 minutes
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Timeout set to 10 minutes')),
                              );
                            },
                            child: const Text('10 min'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Test:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Start a session'),
                    const Text('2. Wait for the countdown'),
                    const Text('3. Try extending the session'),
                    const Text('4. Force expiration to test lock'),
                    const Text('5. Change timeout duration'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
