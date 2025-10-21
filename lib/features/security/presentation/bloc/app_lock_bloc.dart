import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../settings/domain/repositories/settings_repository.dart';


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

// Bloc
class AppLockBloc extends Bloc<AppLockEvent, AppLockState> {
  final SettingsRepository settingsRepository;
  final FlutterSecureStorage secureStorage;
  final LocalAuthentication localAuth = LocalAuthentication();

  AppLockBloc({
    required this.settingsRepository,
    required this.secureStorage,
  }) : super(const AppLockInitial()) {
    on<CheckLockStatusEvent>(_onCheckLockStatus);
    on<CheckBiometricAvailabilityEvent>(_onCheckBiometricAvailability);
    on<AuthenticateWithBiometricEvent>(_onAuthenticateWithBiometric);
    on<VerifyPinEvent>(_onVerifyPin);
    on<SetPinEvent>(_onSetPin);
    on<LockAppEvent>(_onLockApp);
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

      final available = canCheckBiometrics && isDeviceSupported;
      emit(BiometricAvailable(available));
    } catch (e) {
      emit(AppLockError(e.toString()));
    }
  }

  Future<void> _onAuthenticateWithBiometric(
    AuthenticateWithBiometricEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      final authenticated = await localAuth.authenticate(
        localizedReason: 'يرجى التحقق من هويتك لفتح التطبيق',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        emit(const AppUnlocked());
      }
    } catch (e) {
      emit(AppLockError(e.toString()));
    }
  }

  Future<void> _onVerifyPin(
    VerifyPinEvent event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      final storedPin = await secureStorage.read(key: 'app_pin');

      if (storedPin == event.pin) {
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
    emit(const AppLocked());
  }
}

