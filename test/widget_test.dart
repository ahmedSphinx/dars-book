// This is a basic Flutter widget test for DarsBook app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dars_book/core/theme/flex_theme.dart';
import 'package:dars_book/core/extensions/rtl_extensions.dart';

void main() {
  testWidgets('RTL theme test', (WidgetTester tester) async {
    // Test RTL theme creation
    final lightTheme = FlexTheme.getTheme(
      brightness: Brightness.light,
      locale: const Locale('ar', 'SA'),
    );
    
    final darkTheme = FlexTheme.getTheme(
      brightness: Brightness.dark,
      locale: const Locale('ar', 'SA'),
    );
    
    // Verify themes are created successfully
    expect(lightTheme, isNotNull);
    expect(darkTheme, isNotNull);
    
    // Test LTR theme creation
    final lightThemeLTR = FlexTheme.getTheme(
      brightness: Brightness.light,
      locale: const Locale('en', 'US'),
    );
    
    final darkThemeLTR = FlexTheme.getTheme(
      brightness: Brightness.dark,
      locale: const Locale('en', 'US'),
    );
    
    // Verify LTR themes are created successfully
    expect(lightThemeLTR, isNotNull);
    expect(darkThemeLTR, isNotNull);
  });
  
  testWidgets('RTL extensions test', (WidgetTester tester) async {
    // Test RTL extensions
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            // Test RTL context extensions
            final isRTL = context.isRTL;
            final textDirection = context.textDirection;
            final startAlignment = context.startAlignment;
            final endAlignment = context.endAlignment;
            
            expect(isRTL, isA<bool>());
            expect(textDirection, isA<TextDirection>());
            expect(startAlignment, isA<Alignment>());
            expect(endAlignment, isA<Alignment>());
            
            return const Text('Test');
          },
        ),
      ),
    );
  });
}
