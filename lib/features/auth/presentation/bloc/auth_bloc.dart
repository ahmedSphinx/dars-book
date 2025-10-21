import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      dev.log(
        'Checking authentication status',
        name: 'AuthBloc',
      );

      final user = authRepository.currentUser;
      
      if (user != null) {
        dev.log(
          'User authenticated: ${user.uid}',
          name: 'AuthBloc',
        );
        emit(AuthAuthenticated(user));
      } else {
        dev.log(
          'No authenticated user found',
          name: 'AuthBloc',
        );
        emit(const AuthUnauthenticated());
      }
    } catch (e, stackTrace) {
      dev.log(
        'Error checking auth status: $e',
        name: 'AuthBloc',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AuthError('Failed to check authentication status: ${e.toString()}'));
    }
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      dev.log(
        'Sending OTP to: ${event.phoneNumber}',
        name: 'AuthBloc',
      );

      emit(const AuthLoading());

      final result = await authRepository.sendOtp(event.phoneNumber);

      result.fold(
        (failure) {
          dev.log(
            'OTP send failed: ${failure.message}',
            name: 'AuthBloc',
            error: failure.message,
          );
          emit(AuthError(failure.message));
        },
        (verificationId) {
          dev.log(
            'OTP sent successfully. Verification ID: ${verificationId.substring(0, 10)}...',
            name: 'AuthBloc',
          );
          emit(OtpSent(verificationId));
        },
      );
    } catch (e, stackTrace) {
      dev.log(
        'Unexpected error sending OTP: $e',
        name: 'AuthBloc',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AuthError('Failed to send OTP: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      dev.log(
        'Verifying OTP with code: ${event.smsCode}',
        name: 'AuthBloc',
      );

      emit(const AuthLoading());

      final result = await authRepository.verifyOtp(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );

      result.fold(
        (failure) {
          dev.log(
            'OTP verification failed: ${failure.message}',
            name: 'AuthBloc',
            error: failure.message,
          );
          emit(AuthError(failure.message));
        },
        (user) {
          dev.log(
            'OTP verified successfully. User ID: ${user.uid}',
            name: 'AuthBloc',
          );
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e, stackTrace) {
      dev.log(
        'Unexpected error verifying OTP: $e',
        name: 'AuthBloc',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AuthError('Failed to verify OTP: ${e.toString()}'));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      dev.log(
        'Signing out user',
        name: 'AuthBloc',
      );

      emit(const AuthLoading());

      final result = await authRepository.signOut();

      result.fold(
        (failure) {
          dev.log(
            'Sign out failed: ${failure.message}',
            name: 'AuthBloc',
            error: failure.message,
          );
          emit(AuthError(failure.message));
        },
        (_) {
          dev.log(
            'User signed out successfully',
            name: 'AuthBloc',
          );
          emit(const AuthUnauthenticated());
        },
      );
    } catch (e, stackTrace) {
      dev.log(
        'Unexpected error signing out: $e',
        name: 'AuthBloc',
        error: e,
        stackTrace: stackTrace,
      );
      emit(AuthError('Failed to sign out: ${e.toString()}'));
    }
  }
}

