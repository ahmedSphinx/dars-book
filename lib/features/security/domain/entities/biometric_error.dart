import 'package:equatable/equatable.dart';

/// Biometric authentication error types
enum BiometricErrorType {
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLocked,
  userCancel,
  systemCancel,
  invalidCredential,
  notInteractive,
  other,
}

/// Biometric authentication error entity
class BiometricError extends Equatable {
  final BiometricErrorType type;
  final String message;
  final String? details;

  const BiometricError({
    required this.type,
    required this.message,
    this.details,
  });

  @override
  List<Object?> get props => [type, message, details];

  /// Create error from exception
  factory BiometricError.fromException(dynamic exception) {
    final errorString = exception.toString().toLowerCase();
    
    if (errorString.contains('notavailable') || errorString.contains('not available')) {
      return const BiometricError(
        type: BiometricErrorType.notAvailable,
        message: 'Biometric authentication is not available on this device',
      );
    } else if (errorString.contains('notenrolled') || errorString.contains('not enrolled')) {
      return const BiometricError(
        type: BiometricErrorType.notEnrolled,
        message: 'No biometric data enrolled. Please set up biometric authentication in device settings',
      );
    } else if (errorString.contains('lockedout') || errorString.contains('locked out')) {
      return const BiometricError(
        type: BiometricErrorType.lockedOut,
        message: 'Biometric authentication is temporarily locked. Please try again later',
      );
    } else if (errorString.contains('permanentlylocked') || errorString.contains('permanently locked')) {
      return const BiometricError(
        type: BiometricErrorType.permanentlyLocked,
        message: 'Biometric authentication is permanently locked. Please use PIN instead',
      );
    } else if (errorString.contains('usercancel') || errorString.contains('user cancel')) {
      return const BiometricError(
        type: BiometricErrorType.userCancel,
        message: 'Authentication was cancelled by user',
      );
    } else if (errorString.contains('systemcancel') || errorString.contains('system cancel')) {
      return const BiometricError(
        type: BiometricErrorType.systemCancel,
        message: 'Authentication was cancelled by system',
      );
    } else if (errorString.contains('invalidcredential') || errorString.contains('invalid credential')) {
      return const BiometricError(
        type: BiometricErrorType.invalidCredential,
        message: 'Invalid biometric credential. Please try again',
      );
    } else if (errorString.contains('notinteractive') || errorString.contains('not interactive')) {
      return const BiometricError(
        type: BiometricErrorType.notInteractive,
        message: 'Authentication is not interactive',
      );
    } else {
      return BiometricError(
        type: BiometricErrorType.other,
        message: 'Biometric authentication failed. Please try again',
        details: exception.toString(),
      );
    }
  }

  /// Get user-friendly message based on error type
  String get userFriendlyMessage {
    switch (type) {
      case BiometricErrorType.notAvailable:
        return 'Biometric authentication is not available on this device';
      case BiometricErrorType.notEnrolled:
        return 'No biometric data enrolled. Please set up biometric authentication in device settings';
      case BiometricErrorType.lockedOut:
        return 'Biometric authentication is temporarily locked. Please try again later';
      case BiometricErrorType.permanentlyLocked:
        return 'Biometric authentication is permanently locked. Please use PIN instead';
      case BiometricErrorType.userCancel:
        return 'Authentication was cancelled';
      case BiometricErrorType.systemCancel:
        return 'Authentication was cancelled by system';
      case BiometricErrorType.invalidCredential:
        return 'Invalid biometric credential. Please try again';
      case BiometricErrorType.notInteractive:
        return 'Authentication is not interactive';
      case BiometricErrorType.other:
        return 'Biometric authentication failed. Please try again';
    }
  }

  /// Check if error is recoverable
  bool get isRecoverable {
    switch (type) {
      case BiometricErrorType.notAvailable:
      case BiometricErrorType.notEnrolled:
      case BiometricErrorType.permanentlyLocked:
        return false;
      case BiometricErrorType.lockedOut:
      case BiometricErrorType.userCancel:
      case BiometricErrorType.systemCancel:
      case BiometricErrorType.invalidCredential:
      case BiometricErrorType.notInteractive:
      case BiometricErrorType.other:
        return true;
    }
  }

  /// Check if user should be guided to settings
  bool get shouldGuideToSettings {
    return type == BiometricErrorType.notEnrolled;
  }
}
