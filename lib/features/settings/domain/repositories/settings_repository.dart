import 'package:flutter/material.dart';

abstract class SettingsRepository {
  /// Get theme mode
  ThemeMode getThemeMode();

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode);

  /// Get language
  String getLanguage();

  /// Set language
  Future<void> setLanguage(String languageCode);

  /// Get animations enabled status
  bool getAnimationsEnabled();

  /// Set animations enabled status
  Future<void> setAnimationsEnabled(bool enabled);

  /// Get haptics enabled status
  bool getHapticsEnabled();

  /// Set haptics enabled status
  Future<void> setHapticsEnabled(bool enabled);

  /// Get biometric enabled status
  bool getBiometricEnabled();

  /// Set biometric enabled status
  Future<void> setBiometricEnabled(bool enabled);

  /// Get PIN enabled status
  bool getPinEnabled();

  /// Set PIN enabled status
  Future<void> setPinEnabled(bool enabled);

  /// Get PIN (synchronous - returns null, use getPinAsync instead)
  String? getPin();

  /// Get PIN asynchronously from secure storage
  Future<String?> getPinAsync();

  /// Verify PIN against stored hash (secure method)
  Future<bool> verifyPin(String pin);

  /// Set PIN
  Future<void> setPin(String pin);

  /// Clear PIN
  Future<void> clearPin();
}
