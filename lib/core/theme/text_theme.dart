import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Comprehensive text theme system for the app
/// Provides consistent typography with proper Arabic support
class AppTextTheme {
  // Font families
  static const String _primaryFontFamily = 'Cairo';
  static const String _secondaryFontFamily = 'Tajawal';
  static const String _monospaceFontFamily = 'JetBrains Mono';

  // Font weights
  static const FontWeight _light = FontWeight.w300;
  static const FontWeight _regular = FontWeight.w400;
  static const FontWeight _medium = FontWeight.w500;
  static const FontWeight _semiBold = FontWeight.w600;
  static const FontWeight _bold = FontWeight.w700;
  static const FontWeight _extraBold = FontWeight.w800;

  /// Get the primary text theme for light mode
  static TextTheme get lightTextTheme {
    return GoogleFonts.cairoTextTheme().copyWith(
      // Display styles - for large headlines
      displayLarge: GoogleFonts.cairo(
        fontSize: 57,
        fontWeight: _bold,
        height: 1.12,
        letterSpacing: -0.25,
        color: const Color(0xFF1A1A1A), // Dark gray for high contrast
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 45,
        fontWeight: _bold,
        height: 1.16,
        letterSpacing: 0,
        color: const Color(0xFF1A1A1A),
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 36,
        fontWeight: _semiBold,
        height: 1.22,
        letterSpacing: 0,
        color: const Color(0xFF1A1A1A),
      ),

      // Headline styles - for section headers
      headlineLarge: GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: _semiBold,
        height: 1.25,
        letterSpacing: 0,
        color: const Color(0xFF1F21A8), // Primary brand color
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: _semiBold,
        height: 1.29,
        letterSpacing: 0,
        color: const Color(0xFF1F21A8),
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: _semiBold,
        height: 1.33,
        letterSpacing: 0,
        color: const Color(0xFF1F21A8),
      ),

      // Title styles - for card headers and important text
      titleLarge: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: _semiBold,
        height: 1.27,
        letterSpacing: 0,
        color: const Color(0xFF2D2D2D), // Slightly lighter than display
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: _medium,
        height: 1.5,
        letterSpacing: 0.15,
        color: const Color(0xFF2D2D2D),
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: _medium,
        height: 1.43,
        letterSpacing: 0.1,
        color: const Color(0xFF2D2D2D),
      ),

      // Body styles - for main content
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: _regular,
        height: 1.5,
        letterSpacing: 0.5,
        color: const Color(0xFF404040), // Medium gray for readability
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: _regular,
        height: 1.43,
        letterSpacing: 0.25,
        color: const Color(0xFF404040),
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: _regular,
        height: 1.33,
        letterSpacing: 0.4,
        color: const Color(0xFF6B7280), // Lighter gray for secondary text
      ),

      // Label styles - for buttons and form labels
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: _medium,
        height: 1.43,
        letterSpacing: 0.1,
        color: const Color(0xFF1F21A8), // Primary color for labels
      ),
      labelMedium: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: _medium,
        height: 1.33,
        letterSpacing: 0.5,
        color: const Color(0xFF1F21A8),
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: _medium,
        height: 1.45,
        letterSpacing: 0.5,
        color: const Color(0xFF6B7280), // Lighter for small labels
      ),
    );
  }

  /// Get the primary text theme for dark mode
  static TextTheme get darkTextTheme {
    return GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).copyWith(
      // Display styles - for large headlines
      displayLarge: GoogleFonts.cairo(
        fontSize: 57,
        fontWeight: _bold,
        height: 1.12,
        letterSpacing: -0.25,
        color: const Color(0xFFF8F9FA), // Light gray for dark mode
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 45,
        fontWeight: _bold,
        height: 1.16,
        letterSpacing: 0,
        color: const Color(0xFFF8F9FA),
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 36,
        fontWeight: _semiBold,
        height: 1.22,
        letterSpacing: 0,
        color: const Color(0xFFF8F9FA),
      ),

      // Headline styles - for section headers
      headlineLarge: GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: _semiBold,
        height: 1.25,
        letterSpacing: 0,
        color: const Color(0xFF3B82F6), // Lighter blue for dark mode
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: _semiBold,
        height: 1.29,
        letterSpacing: 0,
        color: const Color(0xFF3B82F6),
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: _semiBold,
        height: 1.33,
        letterSpacing: 0,
        color: const Color(0xFF3B82F6),
      ),

      // Title styles - for card headers and important text
      titleLarge: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: _semiBold,
        height: 1.27,
        letterSpacing: 0,
        color: const Color(0xFFE5E7EB), // Light gray for dark mode
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: _medium,
        height: 1.5,
        letterSpacing: 0.15,
        color: const Color(0xFFE5E7EB),
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: _medium,
        height: 1.43,
        letterSpacing: 0.1,
        color: const Color(0xFFE5E7EB),
      ),

      // Body styles - for main content
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: _regular,
        height: 1.5,
        letterSpacing: 0.5,
        color: const Color(0xFFD1D5DB), // Medium light gray for readability
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: _regular,
        height: 1.43,
        letterSpacing: 0.25,
        color: const Color(0xFFD1D5DB),
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: _regular,
        height: 1.33,
        letterSpacing: 0.4,
        color: const Color(0xFF9CA3AF), // Lighter gray for secondary text
      ),

      // Label styles - for buttons and form labels
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: _medium,
        height: 1.43,
        letterSpacing: 0.1,
        color: const Color(0xFF3B82F6), // Primary color for labels
      ),
      labelMedium: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: _medium,
        height: 1.33,
        letterSpacing: 0.5,
        color: const Color(0xFF3B82F6),
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: _medium,
        height: 1.45,
        letterSpacing: 0.5,
        color: const Color(0xFF9CA3AF), // Lighter for small labels
      ),
    );
  }

  /// Get specialized text styles for specific use cases
  static SpecializedTextStyles get specialized => SpecializedTextStyles();
}

/// Specialized text styles for specific use cases
class SpecializedTextStyles {
  // Font weights
  static const FontWeight _light = FontWeight.w300;
  static const FontWeight _regular = FontWeight.w400;
  static const FontWeight _medium = FontWeight.w500;
  static const FontWeight _semiBold = FontWeight.w600;
  static const FontWeight _bold = FontWeight.w700;
  static const FontWeight _extraBold = FontWeight.w800;

  // Success text styles
  static TextStyle successLarge(BuildContext context) => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: _medium,
    color: const Color(0xFF059669), // Success green
  );

    static TextStyle successMedium(BuildContext context) => GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: _medium,
      color: const Color(0xFF059669),
    );

    static TextStyle successSmall(BuildContext context) => GoogleFonts.cairo(
      fontSize: 12,
      fontWeight: _regular,
      color: const Color(0xFF059669),
    );

    // Error text styles
    static TextStyle errorLarge(BuildContext context) => GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: _medium,
      color: const Color(0xFFDC2626), // Error red
    );

    static TextStyle errorMedium(BuildContext context) => GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: _medium,
      color: const Color(0xFFDC2626),
    );

    static TextStyle errorSmall(BuildContext context) => GoogleFonts.cairo(
      fontSize: 12,
      fontWeight: _regular,
      color: const Color(0xFFDC2626),
    );

    // Warning text styles
    static TextStyle warningLarge(BuildContext context) => GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: _medium,
      color: const Color(0xFFD97706), // Warning orange
    );

    static TextStyle warningMedium(BuildContext context) => GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: _medium,
      color: const Color(0xFFD97706),
    );

    static TextStyle warningSmall(BuildContext context) => GoogleFonts.cairo(
      fontSize: 12,
      fontWeight: _regular,
      color: const Color(0xFFD97706),
    );

    // Info text styles
    static TextStyle infoLarge(BuildContext context) => GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: _medium,
      color: const Color(0xFF0EA5E9), // Info blue
    );

    static TextStyle infoMedium(BuildContext context) => GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: _medium,
      color: const Color(0xFF0EA5E9),
    );

    static TextStyle infoSmall(BuildContext context) => GoogleFonts.cairo(
      fontSize: 12,
      fontWeight: _regular,
      color: const Color(0xFF0EA5E9),
    );

    // Price text styles
    static TextStyle priceLarge(BuildContext context) => GoogleFonts.cairo(
      fontSize: 18,
      fontWeight: _bold,
      color: const Color(0xFF059669), // Success green for prices
    );

    static TextStyle priceMedium(BuildContext context) => GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: _semiBold,
      color: const Color(0xFF059669),
    );

    static TextStyle priceSmall(BuildContext context) => GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: _medium,
      color: const Color(0xFF059669),
    );

    // Monospace text styles (for codes, IDs, etc.)
    static TextStyle codeLarge(BuildContext context) => GoogleFonts.jetBrainsMono(
      fontSize: 16,
      fontWeight: _medium,
      color: const Color(0xFF6B7280),
    );

    static TextStyle codeMedium(BuildContext context) => GoogleFonts.jetBrainsMono(
      fontSize: 14,
      fontWeight: _medium,
      color: const Color(0xFF6B7280),
    );

    static TextStyle codeSmall(BuildContext context) => GoogleFonts.jetBrainsMono(
      fontSize: 12,
      fontWeight: _regular,
      color: const Color(0xFF6B7280),
    );

    // Secondary font family styles (Tajawal for variety)
    static TextStyle secondaryLarge(BuildContext context) => GoogleFonts.tajawal(
      fontSize: 16,
      fontWeight: _medium,
      color: const Color(0xFF404040),
    );

    static TextStyle secondaryMedium(BuildContext context) => GoogleFonts.tajawal(
      fontSize: 14,
      fontWeight: _medium,
      color: const Color(0xFF404040),
    );

    static TextStyle secondarySmall(BuildContext context) => GoogleFonts.tajawal(
      fontSize: 12,
      fontWeight: _regular,
      color: const Color(0xFF6B7280),
    );
  }

/// Font type enumeration
enum FontType {
  primary,
  secondary,
  monospace,
}
