import 'package:flutter/material.dart';
import '../../../../core/routing/routes.dart';

/// Dialog shown when session expires
class SessionExpiredDialog extends StatelessWidget {
  const SessionExpiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.timer_off, color: Colors.orange),
          SizedBox(width: 8),
          Text('انتهت الجلسة'),
        ],
      ),
      content: const Text(
        'انتهت جلسة العمل. يرجى إعادة تسجيل الدخول للمتابعة.',
        textAlign: TextAlign.center,
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.appLock,
              (route) => false,
            );
          },
          child: const Text('تسجيل الدخول'),
        ),
      ],
    );
  }

  /// Show the session expired dialog
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SessionExpiredDialog(),
    );
  }
}
