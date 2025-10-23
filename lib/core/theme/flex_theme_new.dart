import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors_new.dart';
import 'text_theme.dart';

/// Enhanced theme configuration using Flex Color Scheme
/// Provides professional, accessible colors with comprehensive text theming
class FlexThemeNew {
  // Define a professional color scheme suitable for educational apps
  static const FlexSchemeColor _scheme = FlexSchemeColor(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryContainer,
    secondary: AppColors.secondary,
    secondaryContainer: AppColors.secondaryContainer,
    tertiary: AppColors.tertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    error: AppColors.error,
    errorContainer: AppColors.errorContainer,
  );

  // Dark theme color scheme
  static const FlexSchemeColor _darkScheme = FlexSchemeColor(
    primary: AppColors.primaryLight,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondaryLight,
    secondaryContainer: AppColors.secondaryDark,
    tertiary: AppColors.tertiaryLight,
    tertiaryContainer: AppColors.tertiaryDark,
    error: AppColors.errorLight,
    errorContainer: AppColors.errorDark,
  );

  /// Light theme configuration
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: FlexScheme.custom,
      colors: _scheme,
      fontFamily: GoogleFonts.cairo().fontFamily,
      useMaterial3: true,
      appBarStyle: FlexAppBarStyle.primary,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 20,
      subThemesData: FlexSubThemesData(
        blendOnLevel: 20,
        blendOnColors: false,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        adaptiveRemoveElevationTint: FlexAdaptive.all(),
        elevatedButtonSchemeColor: SchemeColor.primary,
        elevatedButtonSecondarySchemeColor: SchemeColor.secondary,
        outlinedButtonOutlineSchemeColor: SchemeColor.primary,
        toggleButtonsSchemeColor: SchemeColor.primary,
        switchSchemeColor: SchemeColor.primary,
        checkboxSchemeColor: SchemeColor.primary,
        radioSchemeColor: SchemeColor.primary,
        sliderBaseSchemeColor: SchemeColor.primary,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBorderType: FlexInputBorderType.underline,
        inputDecoratorUnfocusedBorderIsColored: false,
        fabSchemeColor: SchemeColor.primary,
        chipSchemeColor: SchemeColor.primary,
        popupMenuSchemeColor: SchemeColor.primary,
        cardElevation: 2.0,
        dialogElevation: 4.0,
        timePickerDialogRadius: 16.0,
        snackBarElevation: 6.0,
        appBarScrolledUnderElevation: 2.0,
        drawerElevation: 3.0,
        bottomNavigationBarElevation: 2.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    ).copyWith(
      // Use the new comprehensive text theme
      textTheme: AppTextTheme.lightTextTheme,
      // Enhanced button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.onPrimary,
          backgroundColor: AppColors.primary,
          elevation: 2,
          shadowColor: AppColors.shadowLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Enhanced input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTextTheme.lightTextTheme.labelMedium,
        hintStyle: AppTextTheme.lightTextTheme.bodyMedium?.copyWith(
          color: AppTextColors.tertiary,
        ),
      ),
      // Enhanced card theme
      cardTheme:   CardThemeData(
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: AppColors.surface,
        margin: EdgeInsets.all(8),
      ),
      // Enhanced app bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        centerTitle: true,
        titleTextStyle: AppTextTheme.lightTextTheme.titleLarge?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.onPrimary,
          size: 24,
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.custom,
      colors: _darkScheme,
      fontFamily: GoogleFonts.cairo().fontFamily,
      useMaterial3: true,
      appBarStyle: FlexAppBarStyle.primary,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 15,
      subThemesData: FlexSubThemesData(
        blendOnLevel: 30,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        adaptiveRemoveElevationTint: FlexAdaptive.all(),
        elevatedButtonSchemeColor: SchemeColor.primary,
        elevatedButtonSecondarySchemeColor: SchemeColor.secondary,
        outlinedButtonOutlineSchemeColor: SchemeColor.primary,
        toggleButtonsSchemeColor: SchemeColor.primary,
        switchSchemeColor: SchemeColor.primary,
        checkboxSchemeColor: SchemeColor.primary,
        radioSchemeColor: SchemeColor.primary,
        sliderBaseSchemeColor: SchemeColor.primary,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBorderType: FlexInputBorderType.underline,
        inputDecoratorUnfocusedBorderIsColored: false,
        fabSchemeColor: SchemeColor.primary,
        chipSchemeColor: SchemeColor.primary,
        popupMenuSchemeColor: SchemeColor.primary,
        cardElevation: 2.0,
        dialogElevation: 4.0,
        timePickerDialogRadius: 16.0,
        snackBarElevation: 6.0,
        appBarScrolledUnderElevation: 2.0,
        drawerElevation: 3.0,
        bottomNavigationBarElevation: 2.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    ).copyWith(
      // Use the new comprehensive text theme for dark mode
      textTheme: AppTextTheme.darkTextTheme,
      // Enhanced button themes for dark mode
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.onPrimary,
          backgroundColor: AppColors.primaryLight,
          elevation: 2,
          shadowColor: AppColors.shadowLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Enhanced input decoration theme for dark mode
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorLight),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
        ),
        labelStyle: AppTextTheme.darkTextTheme.labelMedium,
        hintStyle: AppTextTheme.darkTextTheme.bodyMedium?.copyWith(
          color: AppTextColors.tertiary,
        ),
      ),
      // Enhanced card theme for dark mode
      cardTheme: const CardThemeData(
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: AppColors.surfaceContainerHighest,
        margin: EdgeInsets.all(8),
      ),
      // Enhanced app bar theme for dark mode
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        centerTitle: true,
        titleTextStyle: AppTextTheme.darkTextTheme.titleLarge?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.onPrimary,
          size: 24,
        ),
      ),
    );
  }

  /// Get theme based on brightness and locale
  static ThemeData getTheme({
    required Brightness brightness,
    Locale? locale,
  }) {
    final isRTL = locale?.languageCode == 'ar';
    return brightness == Brightness.light
        ? _getLightTheme(isRTL: isRTL)
        : _getDarkTheme(isRTL: isRTL);
  }

  /// Get light theme with RTL support
  static ThemeData _getLightTheme({bool isRTL = true}) {
    return lightTheme;
  }

  /// Get dark theme with RTL support
  static ThemeData _getDarkTheme({bool isRTL = true}) {
    return darkTheme;
  }
}
