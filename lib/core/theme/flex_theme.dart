import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors_new.dart';

/// Enhanced theme configuration using Flex Color Scheme
/// Provides professional, accessible colors with Cairo font integration
class FlexTheme {
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
        elevatedButtonSecondarySchemeColor: SchemeColor.primary,
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
        cardElevation: 1.0,
        dialogElevation: 3.0,
        timePickerDialogRadius: 16.0,
        snackBarElevation: 4.0,
        appBarScrolledUnderElevation: 1.0,
        drawerElevation: 2.0,
        bottomNavigationBarElevation: 1.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    ).copyWith(
      // Custom text theme with Cairo font variants
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: GoogleFonts.cairo(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          height: 1.12,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          height: 1.16,
          letterSpacing: 0,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          height: 1.22,
          letterSpacing: 0,
        ),
        headlineLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          height: 1.25,
          letterSpacing: 0,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          height: 1.29,
          letterSpacing: 0,
        ),
        headlineSmall: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.27,
          letterSpacing: 0,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.43,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0.4,
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.33,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.45,
          letterSpacing: 0.5,
        ),
      ),
      // Custom ElevatedButton theme with gray foreground
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.grey,
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
        elevatedButtonSecondarySchemeColor: SchemeColor.primary,
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
        cardElevation: 1.0,
        dialogElevation: 3.0,
        timePickerDialogRadius: 16.0,
        snackBarElevation: 4.0,
        appBarScrolledUnderElevation: 1.0,
        drawerElevation: 2.0,
        bottomNavigationBarElevation: 1.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    ).copyWith(
      // Custom text theme with Cairo font variants for dark theme
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
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
        elevatedButtonSecondarySchemeColor: SchemeColor.primary,
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
        cardElevation: 1.0,
        dialogElevation: 3.0,
        timePickerDialogRadius: 16.0,
        snackBarElevation: 4.0,
        appBarScrolledUnderElevation: 1.0,
        drawerElevation: 2.0,
        bottomNavigationBarElevation: 1.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    ).copyWith(
      // Custom text theme with Cairo font variants
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: GoogleFonts.cairo(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          height: 1.12,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          height: 1.16,
          letterSpacing: 0,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          height: 1.22,
          letterSpacing: 0,
        ),
        headlineLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          height: 1.25,
          letterSpacing: 0,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          height: 1.29,
          letterSpacing: 0,
        ),
        headlineSmall: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.27,
          letterSpacing: 0,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.43,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0.4,
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.33,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.45,
          letterSpacing: 0.5,
        ),
      ),
      // Custom ElevatedButton theme with gray foreground
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.grey,
        ),
      ),
    );
  }

  /// Get dark theme with RTL support
  static ThemeData _getDarkTheme({bool isRTL = true}) {
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
        elevatedButtonSecondarySchemeColor: SchemeColor.primary,
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
        cardElevation: 1.0,
        dialogElevation: 3.0,
        timePickerDialogRadius: 16.0,
        snackBarElevation: 4.0,
        appBarScrolledUnderElevation: 1.0,
        drawerElevation: 2.0,
        bottomNavigationBarElevation: 1.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    ).copyWith(
      // Custom text theme with Cairo font variants for dark theme
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      // Custom ElevatedButton theme with gray foreground
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.grey,
        ),
      ),
    );
  }
}
