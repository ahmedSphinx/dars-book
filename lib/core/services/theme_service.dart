import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

/// Legacy theme service - DEPRECATED
/// This class is kept for backward compatibility but should not be used.
/// All new code should use FlexTheme from flex_theme.dart
@deprecated
class AppTheme {
  // 🌓 الوضع الفاتح
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColor.primaryColor,
      scaffoldBackgroundColor: AppColor.backgroundColor,
      fontFamily: 'Nunito', // Legacy font - replaced with Cairo in FlexTheme
      colorScheme: ColorScheme(
        primary: AppColor.primaryColor,
        secondary: Colors.green,
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColor.grayColor,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: textStyle(24.sp, FontWeight.bold, AppColor.black),
        displayMedium: textStyle(20.sp, FontWeight.bold, AppColor.black),
        displaySmall: textStyle(18.sp, FontWeight.w600, AppColor.black),
        headlineMedium: textStyle(16.sp, FontWeight.bold, AppColor.black),
        bodyLarge: textStyle(14.sp, FontWeight.normal, AppColor.black),
        bodyMedium: textStyle(12.sp, FontWeight.normal, AppColor.black),
      ),
      cardColor: AppColor.primaryColor,
      buttonTheme: ButtonThemeData(
        buttonColor: AppColor.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColor.primaryColor,
          textStyle: textStyle(16, FontWeight.bold, Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  // 🌙 الوضع الداكن
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColor.primaryColor,
      scaffoldBackgroundColor: AppColor.backgroundColor,
      fontFamily: 'Nunito', // Legacy font - replaced with Cairo in FlexTheme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: textStyle(24.sp, FontWeight.bold, Colors.white),
        displayMedium: textStyle(20.sp, FontWeight.bold, Colors.white),
        displaySmall: textStyle(18.sp, FontWeight.w600, Colors.white),
        headlineMedium: textStyle(16.sp, FontWeight.bold, Colors.white),
        bodyLarge: textStyle(14.sp, FontWeight.normal, Colors.white),
        bodyMedium: textStyle(12.sp, FontWeight.normal, Colors.grey),
      ),
      cardColor: Colors.grey[900],
      buttonTheme: ButtonThemeData(
        buttonColor: AppColor.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColor.primaryColor,
          textStyle: textStyle(16, FontWeight.bold, Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  // 🎨 دالة لإنشاء TextStyle بسهولة
  static TextStyle textStyle(double size, FontWeight weight, Color color) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }
}


