import 'package:flutter_test/flutter_test.dart';
import 'package:dars_book/core/services/session_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SessionService Tests', () {
    late SessionService sessionService;

    setUp(() {
      sessionService = SessionService();
    });

    tearDown(() {
      sessionService.dispose();
    });

    test('should start session and be valid initially', () async {
      await sessionService.initialize();
      sessionService.startSession();
      
      expect(sessionService.isSessionValid(), isTrue);
      expect(sessionService.getRemainingSessionTime(), greaterThan(0));
    });

    test('should extend session', () async {
      await sessionService.initialize();
      sessionService.startSession();
      
      final initialTime = sessionService.getRemainingSessionTime();
      await Future.delayed(const Duration(milliseconds: 100));
      
      sessionService.extendSession();
      final extendedTime = sessionService.getRemainingSessionTime();
      
      // Extended time should be close to initial time (within 1 second)
      expect(extendedTime, greaterThan(initialTime - 1));
    });

    test('should set custom session timeout', () async {
      await sessionService.initialize();
      await sessionService.setSessionTimeout(1); // 1 minute
      
      expect(sessionService.sessionTimeoutMinutes, equals(1));
    });

    test('should end session', () async {
      await sessionService.initialize();
      sessionService.startSession();
      
      expect(sessionService.isSessionValid(), isTrue);
      
      sessionService.endSession();
      
      expect(sessionService.isSessionValid(), isFalse);
      expect(sessionService.getRemainingSessionTime(), equals(0));
    });
  });
}
