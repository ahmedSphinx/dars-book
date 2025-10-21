import 'package:flutter/material.dart';

/// Legacy color constants - DEPRECATED
/// These colors are kept for backward compatibility but should not be used.
/// New code should use the FlexTheme color scheme which provides better accessibility.
@deprecated
class AppColor {
  static const Color primaryColor = Color(0xFF1F21A8); // Deep blue - matches FlexTheme primary
  static const Color backgroundColor = Color(0xFFF8FBFC); // Light gray background
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grayColor = Color(0xFF6B7280); // Professional gray
}
