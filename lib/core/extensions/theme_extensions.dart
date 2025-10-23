import 'package:flutter/material.dart';
import '../theme/app_colors_new.dart';
import '../theme/text_theme.dart';

/// Extension methods for easy access to app colors and text styles
extension AppThemeExtensions on BuildContext {
  /// Get the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Get the current text theme
 TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get app colors
  AppColors get appColors => AppColors();
  
  /// Get specialized text styles
  SpecializedTextStyles get specializedText => SpecializedTextStyles();
}

/// Extension methods for ColorScheme
extension ColorSchemeExtensions on ColorScheme {
  /// Get app-specific colors
  AppColors get app => AppColors();
  
  /// Get text colors
  AppTextColors get text => AppTextColors();
  
  /// Get status colors
  AppStatusColors get status => AppStatusColors();
  
  /// Get interactive colors
  AppInteractiveColors get interactive => AppInteractiveColors();
  
  /// Get chart colors
  AppChartColors get chart => AppChartColors();
}

/// Extension methods for TextTheme
extension TextThemeExtensions on TextTheme {
  /// Get specialized text styles
  SpecializedTextStyles get specialized => SpecializedTextStyles();
}

/// Helper class for common text style combinations
class AppTextStyles {
  // Display styles
  static TextStyle displayLarge(BuildContext context) => 
      Theme.of(context).textTheme.displayLarge!;
  
  static TextStyle displayMedium(BuildContext context) => 
      Theme.of(context).textTheme.displayMedium!;
  
  static TextStyle displaySmall(BuildContext context) => 
      Theme.of(context).textTheme.displaySmall!;

  // Headline styles
  static TextStyle headlineLarge(BuildContext context) => 
      Theme.of(context).textTheme.headlineLarge!;
  
  static TextStyle headlineMedium(BuildContext context) => 
      Theme.of(context).textTheme.headlineMedium!;
  
  static TextStyle headlineSmall(BuildContext context) => 
      Theme.of(context).textTheme.headlineSmall!;

  // Title styles
  static TextStyle titleLarge(BuildContext context) => 
      Theme.of(context).textTheme.titleLarge!;
  
  static TextStyle titleMedium(BuildContext context) => 
      Theme.of(context).textTheme.titleMedium!;
  
  static TextStyle titleSmall(BuildContext context) => 
      Theme.of(context).textTheme.titleSmall!;

  // Body styles
  static TextStyle bodyLarge(BuildContext context) => 
      Theme.of(context).textTheme.bodyLarge!;
  
  static TextStyle bodyMedium(BuildContext context) => 
      Theme.of(context).textTheme.bodyMedium!;
  
  static TextStyle bodySmall(BuildContext context) => 
      Theme.of(context).textTheme.bodySmall!;

  // Label styles
  static TextStyle labelLarge(BuildContext context) => 
      Theme.of(context).textTheme.labelLarge!;
  
  static TextStyle labelMedium(BuildContext context) => 
      Theme.of(context).textTheme.labelMedium!;
  
  static TextStyle labelSmall(BuildContext context) => 
      Theme.of(context).textTheme.labelSmall!;

  // Custom combinations
  static TextStyle primaryHeading(BuildContext context) => 
      Theme.of(context).textTheme.headlineLarge!.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      );
  
  static TextStyle secondaryHeading(BuildContext context) => 
      Theme.of(context).textTheme.headlineMedium!.copyWith(
        color: AppColors.secondary,
        fontWeight: FontWeight.w600,
      );
  
  static TextStyle cardTitle(BuildContext context) => 
      Theme.of(context).textTheme.titleLarge!.copyWith(
        color: AppTextColors.primary,
        fontWeight: FontWeight.w600,
      );
  
  static TextStyle cardSubtitle(BuildContext context) => 
      Theme.of(context).textTheme.titleMedium!.copyWith(
        color: AppTextColors.secondary,
        fontWeight: FontWeight.w500,
      );
  
  static TextStyle buttonText(BuildContext context) => 
      Theme.of(context).textTheme.labelLarge!.copyWith(
        color: AppColors.onPrimary,
        fontWeight: FontWeight.w600,
      );
  
  static TextStyle caption(BuildContext context) => 
      Theme.of(context).textTheme.bodySmall!.copyWith(
        color: AppTextColors.tertiary,
        fontWeight: FontWeight.w400,
      );
  
  static TextStyle errorText(BuildContext context) => 
      Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: AppColors.error,
        fontWeight: FontWeight.w500,
      );
  
  static TextStyle successText(BuildContext context) => 
      Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: AppColors.tertiary,
        fontWeight: FontWeight.w500,
      );
  
  static TextStyle warningText(BuildContext context) => 
      Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: AppColors.warning,
        fontWeight: FontWeight.w500,
      );
  
  static TextStyle infoText(BuildContext context) => 
      Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: AppColors.info,
        fontWeight: FontWeight.w500,
      );
}

/// Helper class for common color combinations
class AppColorSchemes {
  /// Get primary color scheme
  static ColorScheme primary(BuildContext context) => 
      Theme.of(context).colorScheme.copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
      );
  
  /// Get secondary color scheme
  static ColorScheme secondary(BuildContext context) => 
      Theme.of(context).colorScheme.copyWith(
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
      );
  
  /// Get success color scheme
  static ColorScheme success(BuildContext context) => 
      Theme.of(context).colorScheme.copyWith(
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
      );
  
  /// Get error color scheme
  static ColorScheme error(BuildContext context) => 
      Theme.of(context).colorScheme.copyWith(
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
      );
}