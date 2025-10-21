import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  /// Send OTP to phone number
  Future<Either<Failure, String>> sendOtp(String phoneNumber);
  
  /// Verify OTP and sign in
  Future<Either<Failure, User>> verifyOtp({
    required String verificationId,
    required String smsCode,
  });
  
  /// Get current user
  User? get currentUser;
  
  /// Check if user is signed in
  bool get isSignedIn;
  
  /// Sign out
  Future<Either<Failure, void>> signOut();
  
  /// Stream of auth state changes
  Stream<User?> get authStateChanges;
}

