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
    
    _initializeSessionListener();
  }

  Future<void> _onCheckLockStatus(
    CheckLockStatusEvent event,
    Emitter<AppLockState> emit,
  ) async {
    final pinEnabled = settingsRepository.getPinEnabled();
    final biometricEnabled = settingsRepository.getBiometricEnabled();

    if (pinEnabled || biometricEnabled) {
      emit(const AppLocked());
    } else {
      emit(const AppUnlocked());
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
      }
    } catch (e) {
      emit(AppLockError(e.toString()));
    }
  }

  Future<void> _onSetPin(
    SetPinEvent event,
    Emitter<AppLockState> emit,
  ) async {
    await settingsRepository.setPin(event.pin);
    await settingsRepository.setPinEnabled(true);
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
    // Only start the session, don't change the state
    // State changes should only happen through proper authentication
    sessionService.startSession();
  }

  Future<void> _onExtendSession(
    ExtendSessionEvent event,
    Emitter<AppLockState> emit,
  ) async {
    sessionService.extendSession();
    final remainingSeconds = sessionService.getRemainingSessionTime();
    emit(SessionActive(remainingSeconds));
  }

  Future<void> _onCheckSessionValidity(
    CheckSessionValidityEvent event,
    Emitter<AppLockState> emit,
  ) async {
    if (sessionService.isSessionValid()) {
      final remainingSeconds = sessionService.getRemainingSessionTime();
      emit(SessionActive(remainingSeconds));
    } else {
      emit(const SessionExpired());
    }
  }

  Future<void> _onSetSessionTimeout(
    SetSessionTimeoutEvent event,
    Emitter<AppLockState> emit,
  ) async {
    await sessionService.setSessionTimeout(event.minutes);
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}

