import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/app_lock_bloc.dart';

/// Widget to show session timeout warning
class SessionTimeoutWarning extends StatefulWidget {
  final Widget child;
  final int warningThresholdSeconds; // Show warning when this many seconds remain
  
  const SessionTimeoutWarning({
    super.key,
    required this.child,
    this.warningThresholdSeconds = 30, // Show warning 30 seconds before expiry
  });

  @override
  State<SessionTimeoutWarning> createState() => _SessionTimeoutWarningState();
}

class _SessionTimeoutWarningState extends State<SessionTimeoutWarning> {
  bool _showWarning = false;
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final appLockBloc = context.read<AppLockBloc>();
      appLockBloc.add(CheckSessionValidityEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppLockBloc, AppLockState>(
      listener: (context, state) {
        if (state is SessionActive) {
          setState(() {
            _remainingSeconds = state.remainingSeconds;
            _showWarning = _remainingSeconds <= widget.warningThresholdSeconds && 
                          _remainingSeconds > 0;
          });
        } else if (state is SessionExpired) {
          setState(() {
            _showWarning = false;
          });
        }
      },
      child: Stack(
        children: [
          widget.child,
          if (_showWarning)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.orange.shade300,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ستنتهي جلسة العمل خلال $_remainingSeconds ثانية',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AppLockBloc>().add(ExtendSessionEvent());
                        setState(() {
                          _showWarning = false;
                        });
                      },
                      child: Text(
                        'تمديد',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
