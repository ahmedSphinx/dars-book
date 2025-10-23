import 'package:flutter/material.dart';

/// Comprehensive color system for the app
/// Provides consistent colors with proper contrast ratios and accessibility
class AppColors {
  // Private constructor to prevent instantiation
  const AppColors._();
  
  // Public constructor for extensions
  const AppColors();

  // Primary brand colors
  static const Color primary =
      Color(0xFF1F21A8); // Deep blue - main brand color
  static const Color primaryLight =
      Color(0xFF3B82F6); // Lighter blue for dark mode
  static const Color primaryDark =
      Color(0xFF1E3A8A); // Darker blue for containers
  static const Color primaryContainer =
      Color(0xFFE3E4FF); // Light blue container
  static const Color onPrimary = Color(0xFFFFFFFF); // White text on primary
  static const Color onPrimaryContainer =
      Color(0xFF1F21A8); // Dark text on primary container

  // Secondary colors
  static const Color secondary = Color(0xFF6B7280); // Professional gray
  static const Color secondaryLight =
      Color(0xFF9CA3AF); // Light gray for dark mode
  static const Color secondaryDark = Color(0xFF374151); // Dark gray
  static const Color secondaryContainer =
      Color(0xFFE5E7EB); // Light gray container
  static const Color onSecondary = Color(0xFFFFFFFF); // White text on secondary
  static const Color onSecondaryContainer =
      Color(0xFF6B7280); // Dark text on secondary container

  // Tertiary colors (success)
  static const Color tertiary = Color(0xFF059669); // Success green
  static const Color tertiaryLight =
      Color(0xFF10B981); // Light green for dark mode
  static const Color tertiaryDark = Color(0xFF065F46); // Dark green
  static const Color tertiaryContainer =
      Color(0xFFD1FAE5); // Light green container
  static const Color onTertiary = Color(0xFFFFFFFF); // White text on tertiary
  static const Color onTertiaryContainer =
      Color(0xFF059669); // Dark text on tertiary container

  // Error colors
  static const Color error = Color(0xFFDC2626); // Error red
  static const Color errorLight = Color(0xFFF87171); // Light red for dark mode
  static const Color errorDark = Color(0xFF991B1B); // Dark red
  static const Color errorContainer = Color(0xFFFEE2E2); // Light red container
  static const Color onError = Color(0xFFFFFFFF); // White text on error
  static const Color onErrorContainer =
      Color(0xFFDC2626); // Dark text on error container

  // Warning colors
  static const Color warning = Color(0xFFD97706); // Warning orange
  static const Color warningLight =
      Color(0xFFF59E0B); // Light orange for dark mode
  static const Color warningDark = Color(0xFF92400E); // Dark orange
  static const Color warningContainer =
      Color(0xFFFEF3C7); // Light orange container
  static const Color onWarning = Color(0xFFFFFFFF); // White text on warning
  static const Color onWarningContainer =
      Color(0xFFD97706); // Dark text on warning container

  // Info colors
  static const Color info = Color(0xFF0EA5E9); // Info blue
  static const Color infoLight = Color(0xFF38BDF8); // Light blue for dark mode
  static const Color infoDark = Color(0xFF0369A1); // Dark blue
  static const Color infoContainer = Color(0xFFE0F2FE); // Light blue container
  static const Color onInfo = Color(0xFFFFFFFF); // White text on info
  static const Color onInfoContainer =
      Color(0xFF0EA5E9); // Dark text on info container

  // Neutral colors
  static const Color surface = Color(0xFFFFFFFF); // White surface
  static const Color surfaceDim = Color(0xFFF8F9FA); // Dimmed surface
  static const Color surfaceBright = Color(0xFFFFFFFF); // Bright surface
  static const Color surfaceContainer = Color(0xFFF1F5F9); // Surface container
  static const Color surfaceContainerHigh =
      Color(0xFFE2E8F0); // High surface container
  static const Color surfaceContainerHighest =
      Color(0xFFCBD5E1); // Highest surface container
  static const Color onSurface = Color(0xFF1A1A1A); // Dark text on surface
  static const Color onSurfaceVariant =
      Color(0xFF6B7280); // Variant text on surface

  // Background colors
  static const Color background = Color(0xFFF8FBFC); // Light background
  static const Color backgroundDark = Color(0xFF0F172A); // Dark background
  static const Color onBackground =
      Color(0xFF1A1A1A); // Dark text on background
  static const Color onBackgroundDark =
      Color(0xFFF8F9FA); // Light text on dark background

  // Outline colors
  static const Color outline = Color(0xFFD1D5DB); // Light outline
  static const Color outlineVariant = Color(0xFFE5E7EB); // Variant outline
  static const Color outlineDark =
      Color(0xFF374151); // Dark outline for dark mode

  // Shadow colors
  static const Color shadow = Color(0xFF000000); // Black shadow
  static const Color shadowLight = Color(0x1A000000); // Light shadow
  static const Color shadowMedium = Color(0x33000000); // Medium shadow
  static const Color shadowDark = Color(0x4D000000); // Dark shadow

  // Scrim colors
  static const Color scrim = Color(0x80000000); // Semi-transparent black
  static const Color scrimLight = Color(0x40000000); // Light scrim
  static const Color scrimDark = Color(0xCC000000); // Dark scrim

  // Legacy colors for backward compatibility
  @deprecated
  static const Color primaryColor = primary;
  @deprecated
  static const Color backgroundColor = background;
  @deprecated
  static const Color white = surface;
  @deprecated
  static const Color black = onSurface;
  @deprecated
  static const Color grayColor = secondary;
}

/// Text colors
class AppTextColors {
  static const Color primary = Color(0xFF1A1A1A); // High contrast text
  static const Color secondary = Color(0xFF6B7280); // Medium contrast text
  static const Color tertiary = Color(0xFF9CA3AF); // Low contrast text
  static const Color disabled = Color(0xFFD1D5DB); // Disabled text
  static const Color inverse = Color(0xFFFFFFFF); // Inverse text (white)
  static const Color onPrimary = Color(0xFFFFFFFF); // Text on primary color
  static const Color onSecondary = Color(0xFFFFFFFF); // Text on secondary color
  static const Color onError = Color(0xFFFFFFFF); // Text on error color
  static const Color onSuccess = Color(0xFFFFFFFF); // Text on success color
  static const Color onWarning = Color(0xFFFFFFFF); // Text on warning color
  static const Color onInfo = Color(0xFFFFFFFF); // Text on info color
}

/// Status colors
class AppStatusColors {
  static const Color success = AppColors.tertiary;
  static const Color successLight = AppColors.tertiaryLight;
  static const Color successDark = AppColors.tertiaryDark;
  static const Color successContainer = AppColors.tertiaryContainer;
  static const Color onSuccess = AppColors.onTertiary;
  static const Color onSuccessContainer = AppColors.onTertiaryContainer;

  static const Color error = AppColors.error;
  static const Color errorLight = AppColors.errorLight;
  static const Color errorDark = AppColors.errorDark;
  static const Color errorContainer = AppColors.errorContainer;
  static const Color onError = AppColors.onError;
  static const Color onErrorContainer = AppColors.onErrorContainer;

  static const Color warning = AppColors.warning;
  static const Color warningLight = AppColors.warningLight;
  static const Color warningDark = AppColors.warningDark;
  static const Color warningContainer = AppColors.warningContainer;
  static const Color onWarning = AppColors.onWarning;
  static const Color onWarningContainer = AppColors.onWarningContainer;

  static const Color info = AppColors.info;
  static const Color infoLight = AppColors.infoLight;
  static const Color infoDark = AppColors.infoDark;
  static const Color infoContainer = AppColors.infoContainer;
  static const Color onInfo = AppColors.onInfo;
  static const Color onInfoContainer = AppColors.onInfoContainer;
}

/// Interactive colors
class AppInteractiveColors {
  static const Color hover = Color(0x0A1F21A8); // Hover state
  static const Color pressed = Color(0x141F21A8); // Pressed state
  static const Color focus = Color(0x1A1F21A8); // Focus state
  static const Color selected = Color(0x0D1F21A8); // Selected state
  static const Color disabled = Color(0xFFD1D5DB); // Disabled state
}

/// Chart colors for data visualization
class AppChartColors {
  static const Color primary = Color(0xFF1F21A8);
  static const Color secondary = Color(0xFF059669);
  static const Color tertiary = Color(0xFFD97706);
  static const Color quaternary = Color(0xFFDC2626);
  static const Color quinary = Color(0xFF0EA5E9);
  static const Color senary = Color(0xFF8B5CF6);
  static const Color septenary = Color(0xFFEC4899);
  static const Color octonary = Color(0xFF10B981);
}
