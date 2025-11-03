import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../domain/repositories/settings_repository.dart';
import '../../../../core/utils/app_shared_preferences.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final FlutterSecureStorage secureStorage;
  final AppPreferences _prefs = AppPreferences();

  SettingsRepositoryImpl({required this.secureStorage});

  static const String _themeModeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _animationsKey = 'animations_enabled';
  static const String _hapticsKey = 'haptics_enabled';
  static const String _biometricKey = 'biometric_enabled';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _pinKey = 'app_pin';

  @override
  ThemeMode getThemeMode() {
    final themeString = _prefs.getData(_themeModeKey) as String?;
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      default:
        modeString = 'system';
    }
    await _prefs.setData(_themeModeKey, modeString);
  }

  @override
  String getLanguage() {
    return _prefs.getData(_languageKey) as String? ?? 'ar';
  }

  @override
  Future<void> setLanguage(String languageCode) async {
    await _prefs.setData(_languageKey, languageCode);
  }

  @override
  bool getAnimationsEnabled() {
    return _prefs.getData(_animationsKey) as bool? ?? true;
  }

  @override
  Future<void> setAnimationsEnabled(bool enabled) async {
    await _prefs.setData(_animationsKey, enabled);
  }

  @override
  bool getHapticsEnabled() {
    return _prefs.getData(_hapticsKey) as bool? ?? true;
  }

  @override
  Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs.setData(_hapticsKey, enabled);
  }

  @override
  bool getBiometricEnabled() {
    return _prefs.getData(_biometricKey) as bool? ?? false;
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setData(_biometricKey, enabled);
  }

  @override
  bool getPinEnabled() {
    return _prefs.getData(_pinEnabledKey) as bool? ?? false;
  }

  @override
  Future<void> setPinEnabled(bool enabled) async {
    await _prefs.setData(_pinEnabledKey, enabled);
  }

  @override
  String? getPin() {
    // PIN is stored in secure storage for security
    // This is a synchronous getter, so we'll need to handle this differently
    // For now, return null and use async methods in the cubit
    return null;
  }

  /// Hash PIN before storage for security
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify PIN against stored hash
  @override
  Future<bool> verifyPin(String pin) async {
    final storedHash = await secureStorage.read(key: _pinKey);
    if (storedHash == null) return false;

    final inputHash = _hashPin(pin);
    return storedHash == inputHash;
  }

  @override
  Future<void> setPin(String pin) async {
    // Validate PIN format before hashing
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw ArgumentError('PIN must be 4 digits');
    }

    // Store hashed PIN instead of plain text
    final hashedPin = _hashPin(pin);
    await secureStorage.write(key: _pinKey, value: hashedPin);
  }

  @override
  Future<void> clearPin() async {
    await secureStorage.delete(key: _pinKey);
  }

  @override
  Future<String?> getPinAsync() async {
    // Return null for security - PIN should never be retrieved
    // Use verifyPin method instead
    return null;
  }
}
