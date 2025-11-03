
import 'package:flutter/foundation.dart';

class AppLogging {
  static const String _reset = '\x1B[0m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';

  static void logInfo(Object message, {String? name}) {
    if (kDebugMode) {
      print('$_green[INFO] ${name ?? 'AppInfo'}: $message$_reset');
    }
  }

  static void logWarning(String message, {String? name, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('$_yellow[WARNING] ${name ?? 'AppWarning'}: $message$_reset');
      if (error != null) print('$_yellow  Error: $error$_reset');
      if (stackTrace != null) print('$_yellow  StackTrace: $stackTrace$_reset');
    }
  }

  static void logError(String message, {String? name, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('$_red[ERROR] ${name ?? 'AppError'}: $message$_reset');
      if (error != null) print('$_red  Error: $error$_reset');
      if (stackTrace != null) print('$_red  StackTrace: $stackTrace$_reset');

    } else {
    }
  }
}
