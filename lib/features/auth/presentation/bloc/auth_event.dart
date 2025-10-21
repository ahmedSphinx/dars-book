import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;

  const SendOtpRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtpRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;

  const VerifyOtpRequested({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object?> get props => [verificationId, smsCode];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

