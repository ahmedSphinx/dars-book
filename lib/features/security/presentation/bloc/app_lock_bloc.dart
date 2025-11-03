import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/services/app_logging_services.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/entities/biometric_error.dart';
import '../../domain/entities/biometric_type_info.dart';

abstract class AppLockEvent extends Equatable {
  const AppLockEvent();

  @override
  List<Object?> get props => [];
}

class CheckLockStatusEvent extends AppLockEvent {}

class CheckBiometricAvailabilityEvent extends AppLockEvent {}

class AuthenticateWithBiometricEvent extends AppLockEvent {}

class VerifyPinEvent extends AppLockEvent {
  final String pin;

  const VerifyPinEvent(this.pin);

  @override
  List<Object?> get props => [pin];
}

class SetPinEvent extends AppLockEvent {
  final String pin;

  const SetPinEvent(this.pin);

  @override
  List<Object?> get props => [pin];
}

class LockAppEvent extends AppLockEvent {}

class StartSessionEvent extends AppLockEvent {}

class ExtendSessionEvent extends AppLockEvent {}

class CheckSessionValidityEvent extends AppLockEvent {}

class SetSessionTimeoutEvent extends AppLockEvent {
  final int minutes;

  const SetSessionTimeoutEvent(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

class RecoverFromErrorEvent extends AppLockEvent {}

class ResetPinEvent extends AppLockEvent {
  final String newPin;

  const ResetPinEvent(this.newPin);

  @override
  List<Object?> get props => [newPin];
}

class VerifyBiometricForResetEvent extends AppLockEvent {}

// States
abstract class AppLockState extends Equatable {
  const AppLockState();

  @override
  List<Object?> get props => [];
}

class AppLockInitial extends AppLockState {
  const AppLockInitial();
}

class AppLocked extends AppLockState {
  const AppLocked();
}

class AppUnlocked extends AppLockState {
  const AppUnlocked();
}

class BiometricAvailable extends AppLockState {
  final bool available;
  final BiometricTypeInfo? biometricInfo;

  const BiometricAvailable(this.available, {this.biometricInfo});

  @override
  List<Object?> get props => [available, biometricInfo];
}

class PinLockedOut extends AppLockState {
  final int lockoutDurationMinutes;
  final DateTime unlockTime;

  const PinLockedOut({
    required this.lockoutDurationMinutes,
    required this.unlockTime,
  });

  @override
  List<Object?> get props => [lockoutDurationMinutes, unlockTime];
}

class AppLockError extends AppLockState {
  final String message;

  const AppLockError(this.message);

  @override
  List<Object?> get props => [message];
}

class BiometricErrorState extends AppLockState {
  final BiometricError error;

  const BiometricErrorState(this.error);

  @override
  List<Object?> get props => [error];
}

class BiometricNotEnrolledState extends AppLockState {
  const BiometricNotEnrolledState();
}

class BiometricNotAvailableState extends AppLockState {
  const BiometricNotAvailableState();
}

class SessionActive extends AppLockState {
  final int remainingSeconds;

  const SessionActive(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

class SessionExpired extends AppLockState {
  const SessionExpired();
}

class BiometricVerifiedForReset extends AppLockState {
  const BiometricVerifiedForReset();
}

class PinResetSuccess extends AppLockState {
  final String message;

  const PinResetSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AppLockBloc extends Bloc<AppLockEvent, AppLockState> {
  final SettingsRepository settingsRepository;
  final FlutterSecureStorage secureStorage;
  final SessionService sessionService;
  final LocalAuthentication localAuth = LocalAuthentication();
  StreamSubscription<SessionEvent>? _sessionSubscription;
  Timer? _debounceTimer;

  // Callback to notify SettingsBloc of PIN changes
  void Function()? _onPinSettingChanged;

  // Rate limiting for PIN attempts
  static const int _maxFailedAttempts = 5;
  static const int _lockoutDurationMinutes = 15;
  static const String _failedAttemptsKey = 'pin_failed_attempts';
  static const String _lastFailedAttemptKey = 'pin_last_failed_attempt';
  static const String _lockoutUntilKey = 'pin_lockout_until';

  AppLockBloc({
    required this.settingsRepository,
    required this.secureStorage,
    required this.sessionService,
  }) : super(const AppLockInitial()) {
    on<CheckLockStatusEvent>(_onCheckLockStatus);
    on<CheckBiometricAvailabilityEvent>(_onCheckBiometricAvailability);
    on<AuthenticateWithBiometricEvent>(_onAuthenticateWithBiometric);
    on<VerifyPinEvent>(_onVerifyPin);
    on<SetPinEvent>(_onSetPin);
    on<LockAppEvent>(_onLockApp);
    on<StartSessionEvent>(_onStartSession);
    on<ExtendSessionEvent>(_onExtendSession);
    on<CheckSessionValidityEvent>(_onCheckSessionValidity);
    on<SetSessionTimeoutEvent>(_onSetSessionTimeout);
    on<RecoverFromErrorEvent>(_onRecoverFromError);
    on<ResetPinEvent>(_onResetPin);
    on<VerifyBiometricForResetEvent>(_onVerifyBiometricForReset);

    _initializeSessionListener();
    _checkInitialSession();
  }

  /// Set callback for settings bloc synchronization
  void setSettingsChangeCallback(void Function() callback) {
    _onPinSettingChanged = callback;
  }

  /// Notify settings bloc of PIN changes
  void _notifySettingsChange() {
    _onPinSettingChanged?.call();
  }

  /// Check initial session validity on startup
  Future<void> _checkInitialSession() async {
    try {
      // Check if session is still valid
      if (sessionService.isSessionValid()) {
        // Check if lock is enabled
        final pinEnabled = settingsRepository.getPinEnabled();
        final biometricEnabled = settingsRepository.getBiometricEnabled();

        if (!pinEnabled && !biometricEnabled) {
          // No lock enabled, session valid - check status
          add(CheckLockStatusEvent());
        } else {
          // Lock enabled - check if session expired
          final remainingSeconds = sessionService.getRemainingSessionTime();
          if (remainingSeconds > 0) {
            // Session still active, check validity to emit SessionActive state
            add(CheckSessionValidityEvent());
          } else {
            // Session expired
            add(CheckSessionValidityEvent());
            add(LockAppEvent());
          }
        }
      } else {
        // Session expired - check lock status and lock if needed
        final pinEnabled = settingsRepository.getPinEnabled();
        final biometricEnabled = settingsRepository.getBiometricEnabled();

        if (pinEnabled || biometricEnabled) {
          add(CheckSessionValidityEvent());
          add(LockAppEvent());
        } else {
          add(CheckLockStatusEvent());
        }
      }
    } catch (e) {
      AppLogging.logError('Error checking initial session: $e');
      // Default to checking lock status
      add(CheckLockStatusEvent());
    }
  }

  Future<void> _onCheckLockStatus(
    CheckLockStatusEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      // Check if PIN is locked out first
      final lockoutUntil = await _checkPinLockout();
      if (lockoutUntil != null && DateTime.now().isBefore(lockoutUntil)) {
        final lockoutMinutes = lockoutUntil.difference(DateTime.now()).inMinutes;
        emit(PinLockedOut(
          lockoutDurationMinutes: lockoutMinutes,
          unlockTime: lockoutUntil,
        ));
        return;
      } else if (lockoutUntil != null) {
        // Lockout expired, clear it
        await _clearPinLockout();
      }

      final pinEnabled = settingsRepository.getPinEnabled();
      final biometricEnabled = settingsRepository.getBiometricEnabled();

      if (pinEnabled || biometricEnabled) {
        _safeEmit(emit, const AppLocked());
      } else {
        _safeEmit(emit, const AppUnlocked());
      }
    } catch (e) {
      _safeEmit(emit, AppLockError('خطأ في التحقق من حالة القفل: ${e.toString()}'));
    }
  }

  Future<void> _onCheckBiometricAvailability(
    CheckBiometricAvailabilityEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();

      if (!isDeviceSupported) {
        emit(const BiometricNotAvailableState());
        return;
      }

      if (!canCheckBiometrics) {
        emit(const BiometricNotAvailableState());
        return;
      }

      // Check if biometrics are enrolled
      final availableBiometrics = await localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        emit(const BiometricNotEnrolledState());
        return;
      }

      // Create BiometricTypeInfo for better handling
      final biometricInfo = BiometricTypeInfo.fromTypes(availableBiometrics);
      emit(BiometricAvailable(true, biometricInfo: biometricInfo));
    } catch (e) {
      final biometricError = BiometricError.fromException(e);
      emit(BiometricErrorState(biometricError));
    }
  }

  Future<void> _onAuthenticateWithBiometric(
    AuthenticateWithBiometricEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      // First check if biometrics are still available
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();
      final availableBiometrics = await localAuth.getAvailableBiometrics();

      if (!isDeviceSupported || !canCheckBiometrics || availableBiometrics.isEmpty) {
        emit(const BiometricNotAvailableState());
        return;
      }

      // Get biometric info for localized reason
      final biometricInfo = BiometricTypeInfo.fromTypes(availableBiometrics);
      final language = settingsRepository.getLanguage();
      final localizedReason = biometricInfo.getAuthReason(language);

      final authenticated = await localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        // Clear any PIN lockout on successful authentication
        await _clearPinLockout();
        await _resetFailedAttempts();
        sessionService.startSession();
        emit(const AppUnlocked());
      } else {
        // Authentication failed but no exception thrown
        final errorMsg = language == 'ar' ? 'فشل التحقق من الهوية. يرجى المحاولة مرة أخرى.' : 'Authentication failed. Please try again.';
        emit(AppLockError(errorMsg));
      }
    } catch (e) {
      final biometricError = BiometricError.fromException(e);

      // Handle specific error types
      if (biometricError.type == BiometricErrorType.notEnrolled) {
        emit(const BiometricNotEnrolledState());
      } else if (biometricError.type == BiometricErrorType.notAvailable) {
        emit(const BiometricNotAvailableState());
      } else if (biometricError.type == BiometricErrorType.userCancel || biometricError.type == BiometricErrorType.systemCancel) {
        // Don't show error for user/system cancellation
        return;
      } else {
        emit(BiometricErrorState(biometricError));
      }
    }
  }

  Future<void> _onVerifyPin(
    VerifyPinEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      // Check if PIN is locked out
      final lockoutUntil = await _checkPinLockout();
      if (lockoutUntil != null && DateTime.now().isBefore(lockoutUntil)) {
        final lockoutMinutes = lockoutUntil.difference(DateTime.now()).inMinutes;
        emit(PinLockedOut(
          lockoutDurationMinutes: lockoutMinutes,
          unlockTime: lockoutUntil,
        ));
        return;
      }

      // Check if PIN is enabled
      if (!settingsRepository.getPinEnabled()) {
        emit(const AppLockError('رمز القفل غير مفعّل'));
        return;
      }

      // Use repository's secure verifyPin method (handles hashing)
      final isValid = await settingsRepository.verifyPin(event.pin);

      if (isValid) {
        // Successful authentication - clear lockout and reset attempts
        await _clearPinLockout();
        await _resetFailedAttempts();
        sessionService.startSession();
        emit(const AppUnlocked());
      } else {
        // Failed attempt - increment counter
        final failedAttempts = await _incrementFailedAttempts();

        if (failedAttempts >= _maxFailedAttempts) {
          // Lock out for specified duration
          final lockoutUntil = DateTime.now().add(
            Duration(minutes: _lockoutDurationMinutes),
          );
          await _setPinLockout(lockoutUntil);
          emit(PinLockedOut(
            lockoutDurationMinutes: _lockoutDurationMinutes,
            unlockTime: lockoutUntil,
          ));
        } else {
          final remainingAttempts = _maxFailedAttempts - failedAttempts;
          final language = settingsRepository.getLanguage();
          final errorMsg = language == 'ar' ? 'رمز القفل غير صحيح. المحاولات المتبقية: $remainingAttempts' : 'Incorrect PIN. Remaining attempts: $remainingAttempts';
          emit(AppLockError(errorMsg));
        }
      }
    } catch (e) {
      final language = settingsRepository.getLanguage();
      final errorMsg = language == 'ar' ? 'حدث خطأ في التحقق من الرمز: ${e.toString()}' : 'Error verifying PIN: ${e.toString()}';
      emit(AppLockError(errorMsg));
    }
  }

  Future<void> _onSetPin(
    SetPinEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      // Validate PIN format (4 digits)
      if (event.pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(event.pin)) {
        final language = settingsRepository.getLanguage();
        final errorMsg = language == 'ar' ? 'يجب أن يكون الرمز 4 أرقام' : 'PIN must be 4 digits';
        emit(AppLockError(errorMsg));
        return;
      }

      await settingsRepository.setPin(event.pin);
      await settingsRepository.setPinEnabled(true);

      // Clear any lockout when setting a new PIN
      await _clearPinLockout();

      // Notify SettingsBloc to reload settings
      _notifySettingsChange();

      // Emit success state or return to previous state
      emit(const AppUnlocked());
    } catch (e) {
      final language = settingsRepository.getLanguage();
      final errorMsg = language == 'ar' ? 'حدث خطأ في حفظ الرمز: ${e.toString()}' : 'Error saving PIN: ${e.toString()}';
      emit(AppLockError(errorMsg));
    }
  }

  Future<void> _onVerifyBiometricForReset(
    VerifyBiometricForResetEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      // First check if biometrics are available
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();
      final availableBiometrics = await localAuth.getAvailableBiometrics();

      if (!isDeviceSupported || !canCheckBiometrics || availableBiometrics.isEmpty) {
        emit(const BiometricNotAvailableState());
        return;
      }

      // Get biometric info for localized reason
      final biometricInfo = BiometricTypeInfo.fromTypes(availableBiometrics);
      final language = settingsRepository.getLanguage();
      final localizedReason = biometricInfo.getAuthReason(language);

      final authenticated = await localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        // Verified for reset - emit special state that doesn't unlock app
        emit(const BiometricVerifiedForReset());
      } else {
        final language = settingsRepository.getLanguage();
        final errorMsg = language == 'ar' ? 'فشل التحقق من الهوية. يرجى المحاولة مرة أخرى.' : 'Authentication failed. Please try again.';
        emit(AppLockError(errorMsg));
      }
    } catch (e) {
      final biometricError = BiometricError.fromException(e);

      // Handle specific error types
      if (biometricError.type == BiometricErrorType.notEnrolled) {
        emit(const BiometricNotEnrolledState());
      } else if (biometricError.type == BiometricErrorType.notAvailable) {
        emit(const BiometricNotAvailableState());
      } else if (biometricError.type == BiometricErrorType.userCancel || biometricError.type == BiometricErrorType.systemCancel) {
        // Don't show error for user/system cancellation - just return to previous state
        return;
      } else {
        emit(BiometricErrorState(biometricError));
      }
    }
  }

  Future<void> _onResetPin(
    ResetPinEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      // Check if we're in the right state (biometric verified for reset)
      if (state is! BiometricVerifiedForReset) {
        final language = settingsRepository.getLanguage();
        final errorMsg = language == 'ar' ? 'يجب التحقق من الهوية أولاً' : 'Biometric verification required first';
        emit(AppLockError(errorMsg));
        return;
      }

      // Validate PIN format (4 digits)
      if (event.newPin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(event.newPin)) {
        final language = settingsRepository.getLanguage();
        final errorMsg = language == 'ar' ? 'يجب أن يكون الرمز 4 أرقام' : 'PIN must be 4 digits';
        emit(AppLockError(errorMsg));
        return;
      }

      // Set the new PIN
      await settingsRepository.setPin(event.newPin);
      await settingsRepository.setPinEnabled(true);

      // Clear any lockout when resetting PIN
      await _clearPinLockout();
      await _resetFailedAttempts();

      // Notify SettingsBloc to reload settings
      _notifySettingsChange();

      final language = settingsRepository.getLanguage();
      final successMsg = language == 'ar' ? 'تم إعادة تعيين رمز القفل بنجاح' : 'PIN reset successfully';

      // Emit success state (UI will handle locking after showing success message)
      emit(PinResetSuccess(successMsg));
    } catch (e) {
      final language = settingsRepository.getLanguage();
      final errorMsg = language == 'ar' ? 'حدث خطأ في إعادة تعيين الرمز: ${e.toString()}' : 'Error resetting PIN: ${e.toString()}';
      emit(AppLockError(errorMsg));
    }
  }

  Future<void> _onLockApp(
    LockAppEvent event,
    Emitter<AppLockState> emit,
  ) async {
    // Prevent rapid state cycling
    if (state is! AppLocked) {
      emit(const AppLocked());
    }
  }

  void _initializeSessionListener() {
    _sessionSubscription = sessionService.sessionStream.listen((event) {
      if (event is SessionExpired) {
        // Debounce rapid session events and only lock if not already locked
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
          // Only add LockAppEvent if not already locked to prevent cycling
          if (state is! AppLocked) {
            add(LockAppEvent());
          }
        });
      }
    });
  }

  Future<void> _onStartSession(
    StartSessionEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      // Only start the session, don't change the state
      // State changes should only happen through proper authentication
      sessionService.startSession();
    } catch (e) {
      emit(AppLockError('حدث خطأ في بدء الجلسة: ${e.toString()}'));
    }
  }

  Future<void> _onExtendSession(
    ExtendSessionEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      sessionService.extendSession();
      final remainingSeconds = sessionService.getRemainingSessionTime();
      emit(SessionActive(remainingSeconds));
    } catch (e) {
      emit(AppLockError('حدث خطأ في تمديد الجلسة: ${e.toString()}'));
    }
  }

  Future<void> _onCheckSessionValidity(
    CheckSessionValidityEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      if (sessionService.isSessionValid()) {
        final remainingSeconds = sessionService.getRemainingSessionTime();
        emit(SessionActive(remainingSeconds));
      } else {
        emit(const SessionExpired());
      }
    } catch (e) {
      emit(AppLockError('حدث خطأ في التحقق من صحة الجلسة: ${e.toString()}'));
    }
  }

  Future<void> _onSetSessionTimeout(
    SetSessionTimeoutEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      // Validate timeout value
      if (event.minutes <= 0 || event.minutes > 1440) {
        // Max 24 hours
        emit(const AppLockError('مهلة الجلسة يجب أن تكون بين 1 و 1440 دقيقة'));
        return;
      }

      await sessionService.setSessionTimeout(event.minutes);
    } catch (e) {
      emit(AppLockError('حدث خطأ في تعيين مهلة الجلسة: ${e.toString()}'));
    }
  }

  Future<void> _onRecoverFromError(
    RecoverFromErrorEvent event,
    Emitter<AppLockState> emit,
  ) async {
    await _recoverFromError(emit);
  }

  /// Validate state transitions to prevent invalid states
  bool _isValidStateTransition(AppLockState currentState, AppLockState newState) {
    // Define valid state transitions
    const validTransitions = {
      'AppLockInitial': ['AppLocked', 'AppUnlocked', 'BiometricAvailable', 'BiometricNotAvailableState', 'BiometricNotEnrolledState'],
      'AppLocked': ['AppUnlocked', 'AppLockError', 'BiometricErrorState', 'BiometricVerifiedForReset', 'BiometricNotAvailableState', 'BiometricNotEnrolledState', 'BiometricAvailable', 'PinLockedOut'],
      'AppUnlocked': ['AppLocked', 'SessionActive', 'SessionExpired'],
      'BiometricAvailable': ['AppUnlocked', 'AppLocked', 'AppLockError', 'BiometricErrorState', 'BiometricVerifiedForReset', 'BiometricNotAvailableState', 'BiometricNotEnrolledState'],
      'BiometricVerifiedForReset': ['PinResetSuccess', 'AppLockError', 'BiometricErrorState'],
      'PinResetSuccess': ['AppLocked'],
      'BiometricNotEnrolledState': ['AppLocked', 'AppUnlocked', 'AppLockError', 'BiometricAvailable'],
      'BiometricNotAvailableState': ['AppLocked', 'AppUnlocked', 'AppLockError', 'BiometricAvailable'],
      'BiometricErrorState': ['AppLocked', 'AppUnlocked', 'BiometricVerifiedForReset', 'AppLockError', 'BiometricAvailable'],
      'AppLockError': ['AppLocked', 'AppUnlocked', 'BiometricVerifiedForReset', 'BiometricAvailable', 'BiometricNotAvailableState'],
      'SessionActive': ['SessionExpired', 'AppLocked'],
      'SessionExpired': ['AppLocked'],
      'PinLockedOut': ['AppLocked', 'AppUnlocked', 'AppLockError'],
    };

    final currentStateName = currentState.runtimeType.toString();
    final newStateName = newState.runtimeType.toString();

    return validTransitions[currentStateName]?.contains(newStateName) ?? true;
  }

  /// Safe state emission with validation
  void _safeEmit(Emitter<AppLockState> emit, AppLockState newState) {
    if (_isValidStateTransition(state, newState)) {
      emit(newState);
    } else {
      // Log invalid transition for debugging (only in debug mode)
      // ignore: avoid_print
      AppLogging.logError('Invalid state transition: ${state.runtimeType} -> ${newState.runtimeType}');
      emit(const AppLockError('Invalid state transition'));
    }
  }

  /// Recover from error states
  Future<void> _recoverFromError(Emitter<AppLockState> emit) async {
    try {
      // Check if we should be locked or unlocked
      final pinEnabled = settingsRepository.getPinEnabled();
      final biometricEnabled = settingsRepository.getBiometricEnabled();

      if (pinEnabled || biometricEnabled) {
        _safeEmit(emit, const AppLocked());
      } else {
        _safeEmit(emit, const AppUnlocked());
      }
    } catch (e) {
      // If recovery fails, go to locked state for security
      _safeEmit(emit, const AppLocked());
    }
  }

  // PIN rate limiting helpers
  Future<int> _incrementFailedAttempts() async {
    try {
      final attemptsStr = await secureStorage.read(key: _failedAttemptsKey);
      int attempts = (attemptsStr != null) ? int.tryParse(attemptsStr) ?? 0 : 0;
      attempts++;
      await secureStorage.write(key: _failedAttemptsKey, value: attempts.toString());
      await secureStorage.write(
        key: _lastFailedAttemptKey,
        value: DateTime.now().toIso8601String(),
      );
      return attempts;
    } catch (e) {
      AppLogging.logError('Error incrementing failed attempts: $e');
      return 1;
    }
  }

  Future<void> _resetFailedAttempts() async {
    try {
      await secureStorage.delete(key: _failedAttemptsKey);
      await secureStorage.delete(key: _lastFailedAttemptKey);
    } catch (e) {
      AppLogging.logError('Error resetting failed attempts: $e');
    }
  }

  Future<DateTime?> _checkPinLockout() async {
    try {
      final lockoutUntilStr = await secureStorage.read(key: _lockoutUntilKey);
      if (lockoutUntilStr != null) {
        final lockoutUntil = DateTime.tryParse(lockoutUntilStr);
        if (lockoutUntil != null && DateTime.now().isBefore(lockoutUntil)) {
          return lockoutUntil;
        } else {
          // Lockout expired, clear it
          await _clearPinLockout();
        }
      }
      return null;
    } catch (e) {
      AppLogging.logError('Error checking PIN lockout: $e');
      return null;
    }
  }

  Future<void> _setPinLockout(DateTime lockoutUntil) async {
    try {
      await secureStorage.write(
        key: _lockoutUntilKey,
        value: lockoutUntil.toIso8601String(),
      );
    } catch (e) {
      AppLogging.logError('Error setting PIN lockout: $e');
    }
  }

  Future<void> _clearPinLockout() async {
    try {
      await secureStorage.delete(key: _lockoutUntilKey);
      await _resetFailedAttempts();
    } catch (e) {
      AppLogging.logError('Error clearing PIN lockout: $e');
    }
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}
