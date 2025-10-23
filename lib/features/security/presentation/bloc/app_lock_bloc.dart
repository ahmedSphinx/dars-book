import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/entities/biometric_error.dart';


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

  const BiometricAvailable(this.available);

  @override
  List<Object?> get props => [available];
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

// Bloc
class AppLockBloc extends Bloc<AppLockEvent, AppLockState> {
  final SettingsRepository settingsRepository;
  final FlutterSecureStorage secureStorage;
  final SessionService sessionService;
  final LocalAuthentication localAuth = LocalAuthentication();
  StreamSubscription<SessionEvent>? _sessionSubscription;
  Timer? _debounceTimer;

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
    
    _initializeSessionListener();
  }

  Future<void> _onCheckLockStatus(
    CheckLockStatusEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
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

      emit(const BiometricAvailable(true));
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

      final authenticated = await localAuth.authenticate(
        localizedReason: 'يرجى التحقق من هويتك لفتح التطبيق',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        sessionService.startSession();
        emit(const AppUnlocked());
      } else {
        // Authentication failed but no exception thrown
        emit(const AppLockError('Authentication failed. Please try again.'));
      }
    } catch (e) {
      final biometricError = BiometricError.fromException(e);
      
      // Handle specific error types
      if (biometricError.type == BiometricErrorType.notEnrolled) {
        emit(const BiometricNotEnrolledState());
      } else if (biometricError.type == BiometricErrorType.notAvailable) {
        emit(const BiometricNotAvailableState());
      } else if (biometricError.type == BiometricErrorType.userCancel) {
        // Don't show error for user cancellation
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
      final storedPin = await secureStorage.read(key: 'app_pin');

      if (storedPin == event.pin) {
        sessionService.startSession();
        emit(const AppUnlocked());
      } else {
        emit(const AppLockError('رمز القفل غير صحيح'));
      }
    } catch (e) {
      emit(AppLockError('حدث خطأ في التحقق من الرمز: ${e.toString()}'));
    }
  }

  Future<void> _onSetPin(
    SetPinEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      // Validate PIN format (4 digits)
      if (event.pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(event.pin)) {
        emit(const AppLockError('يجب أن يكون الرمز 4 أرقام'));
        return;
      }
      
      await settingsRepository.setPin(event.pin);
      await settingsRepository.setPinEnabled(true);
      
      // Emit success state or return to previous state
      emit(const AppUnlocked());
    } catch (e) {
      emit(AppLockError('حدث خطأ في حفظ الرمز: ${e.toString()}'));
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
      if (event.minutes <= 0 || event.minutes > 1440) { // Max 24 hours
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
      'AppLocked': ['AppUnlocked', 'AppLockError', 'BiometricErrorState'],
      'AppUnlocked': ['AppLocked', 'SessionActive', 'SessionExpired'],
      'BiometricAvailable': ['AppUnlocked', 'AppLockError', 'BiometricErrorState'],
      'BiometricNotEnrolledState': ['AppLocked', 'AppLockError'],
      'BiometricNotAvailableState': ['AppLocked', 'AppLockError'],
      'BiometricErrorState': ['AppLocked', 'AppUnlocked'],
      'AppLockError': ['AppLocked', 'AppUnlocked'],
      'SessionActive': ['SessionExpired', 'AppLocked'],
      'SessionExpired': ['AppLocked'],
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
      print('Invalid state transition: ${state.runtimeType} -> ${newState.runtimeType}');
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


  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}

