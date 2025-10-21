import 'dart:async';
import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;

  AuthRepositoryImpl({required this.firebaseAuth});

  @override
  Future<Either<Failure, String>> sendOtp(String phoneNumber) async {
    try {
      dev.log(
        'Starting OTP send process for: $phoneNumber',
        name: 'AuthRepository',
      );

      final completer = Completer<Either<Failure, String>>();
      bool codeSentCalled = false;
      bool verificationFailedCalled = false;
      bool autoRetrievalTimeoutCalled = false;

      dev.log(
        'Calling Firebase verifyPhoneNumber...',
        name: 'AuthRepository',
      );

      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          dev.log(
            'Callback: verificationCompleted triggered',
            name: 'AuthRepository',
          );
          try {
            await firebaseAuth.signInWithCredential(credential);
            dev.log(
              'Auto-verification sign-in successful',
              name: 'AuthRepository',
            );
          } catch (e) {
            dev.log(
              'Auto-verification sign-in failed: $e',
              name: 'AuthRepository',
              error: e,
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          verificationFailedCalled = true;
          dev.log(
            'Callback: verificationFailed triggered - ${e.code}: ${e.message}',
            name: 'AuthRepository',
            error: e,
          );
          final errorMsg = _getFirebaseAuthErrorMessage(e);
          if (!completer.isCompleted) {
            completer.complete(Left(ServerFailure(errorMsg)));
          }
        },
        codeSent: (String verId, int? resendToken) {
          codeSentCalled = true;
          dev.log(
            'Callback: codeSent triggered - Verification ID: ${verId.substring(0, 10)}..., ResendToken: ${resendToken != null ? "present" : "null"}',
            name: 'AuthRepository',
          );
          if (!completer.isCompleted) {
            dev.log(
              'OTP sent successfully with verification ID',
              name: 'AuthRepository',
            );
            completer.complete(Right(verId));
          }
        },
        codeAutoRetrievalTimeout: (String verId) {
          autoRetrievalTimeoutCalled = true;
          dev.log(
            'Callback: codeAutoRetrievalTimeout triggered - Verification ID: ${verId.substring(0, 10)}...',
            name: 'AuthRepository',
          );
          // Don't complete here, wait for codeSent
        },
        timeout: const Duration(seconds: 60),
      );

      dev.log(
        'verifyPhoneNumber initiated. Waiting for callbacks...',
        name: 'AuthRepository',
      );

      // Wait for either success or failure callback with timeout
      final result = await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          dev.log(
            'Timeout waiting for Firebase callbacks',
            name: 'AuthRepository',
          );
          dev.log(
            'Callback Status - codeSent: $codeSentCalled, verificationFailed: $verificationFailedCalled, autoRetrievalTimeout: $autoRetrievalTimeoutCalled',
            name: 'AuthRepository',
          );
          dev.log(
            'No verification ID received. This usually means:',
            name: 'AuthRepository',
          );
          dev.log(
            '1. reCAPTCHA is not configured (see FIREBASE_AUTH_SETUP.md)',
            name: 'AuthRepository',
          );
          dev.log(
            '2. Phone number format is incorrect',
            name: 'AuthRepository',
          );
          dev.log(
            '3. Firebase Phone Auth is not enabled',
            name: 'AuthRepository',
          );
          dev.log(
            '4. App is not registered in Firebase Console',
            name: 'AuthRepository',
          );
          
          return Left(ServerFailure(
            'فشل إرسال رمز التحقق. يرجى التأكد من:\n'
            '1. تكوين reCAPTCHA في Firebase\n'
            '2. تنسيق رقم الهاتف صحيح (+20...)\n'
            '3. تفعيل Phone Auth في Firebase\n\n'
            'راجع FIREBASE_AUTH_SETUP.md للمزيد من التفاصيل'
          ));
        },
      );

      return result;
    } on FirebaseAuthException catch (e, stackTrace) {
      final errorMsg = _getFirebaseAuthErrorMessage(e);
      dev.log(
        'FirebaseAuthException caught: ${e.code} - $errorMsg',
        name: 'AuthRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(errorMsg));
    } catch (e, stackTrace) {
      dev.log(
        'Unexpected error sending OTP: $e',
        name: 'AuthRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure('خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      dev.log(
        'Verifying OTP code: $smsCode',
        name: 'AuthRepository',
      );

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      dev.log(
        'Signing in with credential...',
        name: 'AuthRepository',
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        dev.log(
          'Sign-in succeeded but user is null',
          name: 'AuthRepository',
        );
        return Left(ServerFailure('User not found'));
      }

      dev.log(
        'OTP verified successfully. User ID: ${userCredential.user!.uid}',
        name: 'AuthRepository',
      );
      return Right(userCredential.user!);
    } on FirebaseAuthException catch (e, stackTrace) {
      final errorMsg = _getFirebaseAuthErrorMessage(e);
      dev.log(
        'FirebaseAuthException during OTP verification: $errorMsg',
        name: 'AuthRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(errorMsg));
    } catch (e, stackTrace) {
      dev.log(
        'Unexpected error verifying OTP: $e',
        name: 'AuthRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  User? get currentUser => firebaseAuth.currentUser;

  @override
  bool get isSignedIn => firebaseAuth.currentUser != null;

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      dev.log(
        'Signing out user',
        name: 'AuthRepository',
      );

      await firebaseAuth.signOut();

      dev.log(
        'User signed out successfully',
        name: 'AuthRepository',
      );
      return const Right(null);
    } catch (e, stackTrace) {
      dev.log(
        'Error signing out: $e',
        name: 'AuthRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  /// Convert Firebase Auth error codes to user-friendly messages
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    dev.log(
      'Firebase Auth Error Code: ${e.code}',
      name: 'AuthRepository',
    );

    switch (e.code) {
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح. يرجى التحقق من الرقم والمحاولة مرة أخرى.';
      case 'too-many-requests':
        return 'تم إرسال عدد كبير من الطلبات. يرجى الانتظار قليلاً والمحاولة مرة أخرى.';
      case 'operation-not-allowed':
        return 'تسجيل الدخول برقم الهاتف غير مفعل. يرجى التواصل مع الدعم الفني.';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح. يرجى التحقق من الرمز والمحاولة مرة أخرى.';
      case 'invalid-verification-id':
        return 'جلسة التحقق انتهت. يرجى طلب رمز جديد.';
      case 'session-expired':
        return 'انتهت صلاحية الجلسة. يرجى المحاولة مرة أخرى.';
      case 'network-request-failed':
        return 'فشل الاتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب. يرجى التواصل مع الدعم الفني.';
      case 'quota-exceeded':
        return 'تم تجاوز حد الرسائل. يرجى المحاولة لاحقاً.';
      case 'app-not-authorized':
        return 'التطبيق غير مصرح له. يرجى التواصل مع الدعم الفني.';
      case 'captcha-check-failed':
        return 'فشل التحقق الأمني. يرجى المحاولة مرة أخرى.';
      default:
        return e.message ?? 'حدث خطأ أثناء المصادقة. يرجى المحاولة مرة أخرى.';
    }
  }
}
