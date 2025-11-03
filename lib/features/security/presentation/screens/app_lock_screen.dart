import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/services/app_logging_services.dart';
import '../bloc/app_lock_bloc.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool _isBiometricAvailable = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // Check biometric availability when screen loads
    context.read<AppLockBloc>().add(CheckBiometricAvailabilityEvent());
  }

  void _authenticateWithBiometric() {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    context.read<AppLockBloc>().add(AuthenticateWithBiometricEvent());
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const _PinVerificationDialog(),
    );
  }

  void _showResetPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const _ResetPinDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppLockBloc, AppLockState>(
      listener: (context, state) {
        if (state is AppUnlocked) {
          Navigator.pushReplacementNamed(context, Routes.dashboard);
        } else if (state is BiometricAvailable) {
          try {
            setState(() {
              _isBiometricAvailable = state.available;
            });
            // Optionally use biometricInfo for better UI/UX
            if (state.biometricInfo != null) {
              // Could customize icon/text based on biometric type
            }
          } catch (e) {
            AppLogging.logError('Error handling BiometricAvailable state: $e');
          }
        } else if (state is PinLockedOut) {
          try {
            // Show lockout message
            final unlockTime = state.unlockTime;
            final now = DateTime.now();
            if (unlockTime.isAfter(now)) {
              final minutesRemaining = unlockTime.difference(now).inMinutes;
              EasyLoading.showError(
                'تم قفل PIN. يرجى المحاولة بعد $minutesRemaining دقيقة',
              );
            }
          } catch (e) {
            AppLogging.logError('Error handling PinLockedOut state: $e');
          }
        } else if (state is AppLockError) {
          EasyLoading.showError('فشل في التحقق من الهوية ${state.message}');
          setState(() {
            _isAuthenticating = false;
          });
        } else if (state is AppLocked) {
          // App is locked, ensure UI reflects locked state
          setState(() {
            _isAuthenticating = false;
          });
        } else if (state is AppLockInitial) {
          // Initial state, perhaps trigger check if needed
          // But since initState already checks biometric, maybe no action
        } else if (state is SessionExpired) {
          // Session expired, show lock screen
          setState(() {
            _isAuthenticating = false;
          });
        } else if (state is BiometricNotEnrolledState) {
          EasyLoading.showError('لم يتم تسجيل البصمة. يرجى إعداد البصمة في إعدادات الجهاز');
          setState(() {
            _isAuthenticating = false;
          });
        } else if (state is BiometricNotAvailableState) {
          EasyLoading.showError('البصمة غير متاحة على هذا الجهاز');
          setState(() {
            _isAuthenticating = false;
          });
        } else if (state is BiometricErrorState) {
          EasyLoading.showError(state.error.userFriendlyMessage);
          setState(() {
            _isAuthenticating = false;
          });
        } else if (state is PinLockedOut) {
          try {
            final unlockTime = state.unlockTime;
            final now = DateTime.now();
            final minutesRemaining = unlockTime.difference(now).inMinutes;
            EasyLoading.showError(
              'تم قفل PIN مؤقتاً بعد $minutesRemaining دقائق بسبب عدة محاولات فاشلة',
            );
            setState(() {
              _isAuthenticating = false;
            });
          } catch (e) {
            AppLogging.logError('Error handling PinLockedOut state: $e');
            setState(() {
              _isAuthenticating = false;
            });
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1F21A8).withValues(alpha: 0.15),
                const Color(0xFF1F21A8).withValues(alpha: 0.08),
                const Color(0xFFF8FBFC),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Lock Icon with Animation
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF1F21A8),
                                  const Color(0xFF1F21A8).withValues(alpha: 0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1F21A8).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              size: 60,
                              color: Colors.white,
                            ),
                          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).fadeIn(duration: 400.ms),

                          const SizedBox(height: 32),

                          // Title
                          const Text(
                            'التطبيق مقفل',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F21A8),
                              fontFamily: 'Nunito',
                            ),
                            textAlign: TextAlign.center,
                          ).animate().slideY(begin: 0.3, duration: 500.ms, delay: 200.ms).fadeIn(duration: 500.ms),

                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            'يرجى التحقق من هويتك للمتابعة',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontFamily: 'Nunito',
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().slideY(begin: 0.3, duration: 500.ms, delay: 300.ms).fadeIn(duration: 500.ms),

                          const SizedBox(height: 48),

                          // Authentication Options Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Biometric Button
                                if (_isBiometricAvailable) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton.icon(
                                      onPressed: _isAuthenticating ? null : _authenticateWithBiometric,
                                      icon: _isAuthenticating
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Icon(Icons.fingerprint, size: 24),
                                      label: Text(
                                        _isAuthenticating ? 'جاري التحقق...' : 'فتح بالبصمة',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1F21A8),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 400.ms).fadeIn(duration: 400.ms),
                                  const SizedBox(height: 16),
                                ],

                                // PIN Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: OutlinedButton.icon(
                                    onPressed: _showPinDialog,
                                    icon: const Icon(Icons.lock_outline, size: 24),
                                    label: const Text(
                                      'فتح برمز PIN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF1F21A8), width: 2),
                                      foregroundColor: const Color(0xFF1F21A8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 500.ms).fadeIn(duration: 400.ms),
                              ],
                            ),
                          ).animate().slideY(begin: 0.3, duration: 600.ms, delay: 400.ms).fadeIn(duration: 600.ms),

                          const SizedBox(height: 24),

                          // Reset PIN Link
                          TextButton(
                            onPressed: _showResetPinDialog,
                            child: Text(
                              'نسيت رمز القفل؟',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontFamily: 'Nunito',
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PinVerificationDialog extends StatefulWidget {
  const _PinVerificationDialog();

  @override
  State<_PinVerificationDialog> createState() => _PinVerificationDialogState();
}

class _PinVerificationDialogState extends State<_PinVerificationDialog> {
  String _enteredPin = '';
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    // Note: BLoC events should NOT be added in dispose()
    // The BLoC will handle state management independently
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppLockBloc, AppLockState>(
      listener: (context, state) {
        if (state is AppUnlocked) {
          Navigator.of(context).pop(); // Close dialog first
          // Navigation to dashboard will be handled by the main AppLockScreen
        } else if (state is PinLockedOut) {
          final unlockTime = state.unlockTime;
          final now = DateTime.now();
          if (unlockTime.isAfter(now)) {
            final minutesRemaining = unlockTime.difference(now).inMinutes;
            EasyLoading.showError(
              'تم قفل PIN. يرجى المحاولة بعد $minutesRemaining دقيقة',
            );
            Navigator.of(context).pop(); // Close dialog
          }
          setState(() {
            _enteredPin = '';
            _isVerifying = false;
          });
        } else if (state is AppLockError) {
          // The bloc now handles failed attempts and lockout, so we just show the error
          EasyLoading.showError(state.message);
          setState(() {
            _enteredPin = '';
            _isVerifying = false;
          });
          // Check if error indicates lockout and close dialog
          if (state.message.contains('قفل') || state.message.contains('lockout') || state.message.contains('Locked') || state.message.contains('locked out')) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F21A8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF1F21A8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'أدخل رمز القفل',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F21A8),
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'أدخل رمز القفل المكون من 4 أرقام',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // PIN Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  Color indicatorColor;
                  if (index < _enteredPin.length) {
                    indicatorColor = const Color(0xFF1F21A8);
                  } else {
                    indicatorColor = Colors.grey.shade300;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: indicatorColor,
                      boxShadow: index < _enteredPin.length
                          ? [
                              BoxShadow(
                                color: indicatorColor.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Number Pad or Loading
              if (_isVerifying)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F21A8)),
                )
              else
                _buildNumberPad(),

              const SizedBox(height: 24),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 60),
              _buildNumberButton('0'),
              _buildDeleteButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _onNumberTap(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F21A8),
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: _onDelete,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.grey[600],
            size: 24,
          ),
        ),
      ),
    );
  }

  void _onNumberTap(String number) {
    if (_enteredPin.length < 4 && !_isVerifying) {
      setState(() {
        _enteredPin += number;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() {
      _isVerifying = true;
    });

    // Use BLoC for PIN verification instead of direct storage access
    context.read<AppLockBloc>().add(VerifyPinEvent(_enteredPin));
  }
}

class _ResetPinDialog extends StatefulWidget {
  const _ResetPinDialog();

  @override
  State<_ResetPinDialog> createState() => _ResetPinDialogState();
}

class _ResetPinDialogState extends State<_ResetPinDialog> {
  String _newPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isResetting = false;
  bool _biometricVerified = false;

  @override
  void initState() {
    super.initState();
    _authenticateWithBiometric();
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      final appLockBloc = context.read<AppLockBloc>();
      // Use the dedicated event for reset verification
      appLockBloc.add(VerifyBiometricForResetEvent());
    } catch (e) {
      if (mounted) {
        EasyLoading.showError('فشل التحقق من الهوية');
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppLockBloc, AppLockState>(
      listener: (context, state) {
        // Handle biometric verification for reset
        if (state is BiometricVerifiedForReset && !_biometricVerified) {
          setState(() {
            _biometricVerified = true;
          });
        } else if (state is PinResetSuccess) {
          // PIN reset successful
          EasyLoading.showSuccess(state.message);
          // Lock app after showing success (user needs to use new PIN)
          // Store references before async operation
          final appLockBloc = context.read<AppLockBloc>();
          final navigator = Navigator.of(context);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              appLockBloc.add(LockAppEvent());
              navigator.pop();
            }
          });
        } else if (state is AppLockError) {
          if (_biometricVerified) {
            // Error during PIN reset
            EasyLoading.showError(state.message);
            setState(() {
              _newPin = '';
              _confirmPin = '';
              _isConfirming = false;
              _isResetting = false;
            });
          } else {
            // Biometric verification failed
            EasyLoading.showError(state.message.isNotEmpty ? state.message : 'فشل التحقق من الهوية');
            Navigator.of(context).pop();
          }
        } else if (state is BiometricErrorState || state is BiometricNotAvailableState || state is BiometricNotEnrolledState) {
          EasyLoading.showError('يجب التحقق بالبصمة أولاً لإعادة تعيين رمز القفل');
          Navigator.of(context).pop();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F21A8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      color: Color(0xFF1F21A8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _biometricVerified ? 'إعادة تعيين رمز القفل' : 'التحقق من الهوية',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F21A8),
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _biometricVerified ? 'أدخل رمز القفل الجديد' : 'يرجى التحقق من الهوية للمتابعة',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (!_biometricVerified)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F21A8)),
                  ),
                )
              else ...[
                // PIN Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final pinToShow = _isConfirming ? _confirmPin : _newPin;
                    final indicatorColor = index < pinToShow.length ? const Color(0xFF1F21A8) : Colors.grey.shade300;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: indicatorColor,
                        boxShadow: index < pinToShow.length
                            ? [
                                BoxShadow(
                                  color: indicatorColor.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  _isConfirming ? 'تأكيد الرمز' : 'أدخل الرمز الجديد',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 32),

                // Number Pad or Loading
                if (_isResetting)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F21A8)),
                  )
                else
                  _buildNumberPad(),

                const SizedBox(height: 24),
              ],

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 60),
              _buildNumberButton('0'),
              _buildDeleteButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _onNumberTap(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F21A8),
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: _onDelete,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.grey[600],
            size: 24,
          ),
        ),
      ),
    );
  }

  void _onNumberTap(String number) {
    if (!_biometricVerified || _isResetting) return;

    setState(() {
      if (_isConfirming) {
        if (_confirmPin.length < 4) {
          _confirmPin += number;
          if (_confirmPin.length == 4) {
            _validateAndReset();
          }
        }
      } else {
        if (_newPin.length < 4) {
          _newPin += number;
          if (_newPin.length == 4) {
            _isConfirming = true;
          }
        }
      }
    });
  }

  void _onDelete() {
    if (!_biometricVerified || _isResetting) return;

    setState(() {
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_newPin.isNotEmpty) {
          _newPin = _newPin.substring(0, _newPin.length - 1);
        }
      }
    });
  }

  void _validateAndReset() {
    if (_newPin == _confirmPin) {
      setState(() {
        _isResetting = true;
      });

      // Reset PIN via BLoC
      context.read<AppLockBloc>().add(ResetPinEvent(_newPin));
    } else {
      EasyLoading.showError('الرمز غير متطابق. يرجى المحاولة مرة أخرى');
      setState(() {
        _newPin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
    }
  }
}
