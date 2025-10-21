import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service to manage app session timeout and authentication
class SessionService {
  static const String _lastAuthTimeKey = 'last_auth_time';
  static const String _sessionTimeoutKey = 'session_timeout';
  static const int _defaultTimeoutMinutes = 5;
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Timer? _sessionTimer;
  DateTime? _lastAuthTime;
  int _sessionTimeoutMinutes = _defaultTimeoutMinutes;
  
  // Stream controller for session events
  final StreamController<SessionEvent> _sessionController = 
      StreamController<SessionEvent>.broadcast();
  
  Stream<SessionEvent> get sessionStream => _sessionController.stream;
  
  /// Initialize the session service
  Future<void> initialize() async {
    await _loadSessionSettings();
    await _loadLastAuthTime();
  }
  
  /// Load session settings from storage
  Future<void> _loadSessionSettings() async {
    try {
      final timeoutStr = await _secureStorage.read(key: _sessionTimeoutKey);
      if (timeoutStr != null) {
        _sessionTimeoutMinutes = int.tryParse(timeoutStr) ?? _defaultTimeoutMinutes;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading session settings: $e');
      }
    }
  }
  
  /// Load last authentication time from storage
  Future<void> _loadLastAuthTime() async {
    try {
      final lastAuthStr = await _secureStorage.read(key: _lastAuthTimeKey);
      if (lastAuthStr != null) {
        _lastAuthTime = DateTime.tryParse(lastAuthStr);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading last auth time: $e');
      }
    }
  }
  
  /// Save last authentication time to storage
  Future<void> _saveLastAuthTime() async {
    try {
      await _secureStorage.write(
        key: _lastAuthTimeKey,
        value: _lastAuthTime?.toIso8601String(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saving last auth time: $e');
      }
    }
  }
  
  /// Save session timeout setting
  Future<void> _saveSessionTimeout() async {
    try {
      await _secureStorage.write(
        key: _sessionTimeoutKey,
        value: _sessionTimeoutMinutes.toString(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saving session timeout: $e');
      }
    }
  }
  
  /// Start a new session (call when user authenticates)
  void startSession() {
    _lastAuthTime = DateTime.now();
    _saveLastAuthTime();
    _startSessionTimer();
    _sessionController.add(SessionStarted());
  }
  
  /// Extend the current session
  void extendSession() {
    if (_lastAuthTime != null) {
      _lastAuthTime = DateTime.now();
      _saveLastAuthTime();
      _startSessionTimer();
      _sessionController.add(SessionExtended());
    }
  }
  
  /// End the current session
  void endSession() {
    _lastAuthTime = null;
    _saveLastAuthTime();
    _stopSessionTimer();
    _sessionController.add(SessionEnded());
  }
  
  /// Check if session is still valid
  bool isSessionValid() {
    if (_lastAuthTime == null) return false;
    
    final now = DateTime.now();
    final timeDifference = now.difference(_lastAuthTime!);
    final timeoutDuration = Duration(minutes: _sessionTimeoutMinutes);
    
    return timeDifference < timeoutDuration;
  }
  
  /// Get remaining session time in seconds
  int getRemainingSessionTime() {
    if (_lastAuthTime == null) return 0;
    
    final now = DateTime.now();
    final timeDifference = now.difference(_lastAuthTime!);
    final timeoutDuration = Duration(minutes: _sessionTimeoutMinutes);
    
    final remaining = timeoutDuration - timeDifference;
    return remaining.inSeconds > 0 ? remaining.inSeconds : 0;
  }
  
  /// Set session timeout in minutes
  Future<void> setSessionTimeout(int minutes) async {
    _sessionTimeoutMinutes = minutes;
    await _saveSessionTimeout();
    
    // Restart timer with new timeout
    if (_lastAuthTime != null) {
      _startSessionTimer();
    }
  }
  
  /// Get current session timeout in minutes
  int get sessionTimeoutMinutes => _sessionTimeoutMinutes;
  
  /// Start the session timer
  void _startSessionTimer() {
    _stopSessionTimer();
    
    _sessionTimer = Timer(
      Duration(minutes: _sessionTimeoutMinutes),
      () {
        _sessionController.add(SessionExpired());
      },
    );
  }
  
  /// Stop the session timer
  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }
  
  /// Handle app pause (user leaves app)
  void onAppPaused() {
    // Don't end session immediately on pause
    // Session will be checked when app resumes
  }
  
  /// Handle app resume (user returns to app)
  void onAppResumed() {
    // Only check session validity, don't extend automatically
    if (!isSessionValid()) {
      _sessionController.add(SessionExpired());
    }
    // Don't automatically extend session on resume to avoid loops
  }
  
  /// Force session expiration (for testing or manual lock)
  void forceSessionExpiration() {
    _sessionController.add(SessionExpired());
  }
  
  /// Dispose resources
  void dispose() {
    _stopSessionTimer();
    _sessionController.close();
  }
}

/// Session events
abstract class SessionEvent {}

class SessionStarted extends SessionEvent {}

class SessionExtended extends SessionEvent {}

class SessionEnded extends SessionEvent {}

class SessionExpired extends SessionEvent {}
