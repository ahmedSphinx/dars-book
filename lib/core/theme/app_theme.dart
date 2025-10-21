import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Legacy theme class - DEPRECATED
/// This class is kept for backward compatibility but should not be used.
/// All new code should use FlexTheme from flex_theme.dart
@deprecated
class AppTheme {
 static ThemeData get lightTheme => ThemeData(
   primaryColor: AppColor.primaryColor,
   scaffoldBackgroundColor: AppColor.backgroundColor,
   fontFamily: 'Nunito', // Legacy font - replaced with Cairo in FlexTheme
   brightness: Brightness.light,
   appBarTheme: const AppBarTheme(
     backgroundColor: AppColor.white,
     elevation: 0,
     centerTitle: true,
     iconTheme: IconThemeData(color: AppColor.black),
     titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.black),
   ),
 );


 static ThemeData get darkTheme => ThemeData(
   primaryColor: AppColor.primaryColor,
   scaffoldBackgroundColor: Colors.black,
   fontFamily: 'Nunito', // Legacy font - replaced with Cairo in FlexTheme
   brightness: Brightness.dark,
   appBarTheme: const AppBarTheme(
     backgroundColor: Colors.black,
     elevation: 0,
     centerTitle: true,
     iconTheme: IconThemeData(color: AppColor.white),
     titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.white),
   ),
 );
}
