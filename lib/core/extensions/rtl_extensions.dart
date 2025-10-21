import 'package:flutter/material.dart';

/// RTL-specific extensions and utilities
extension RTLExtensions on BuildContext {
  /// Check if current locale is RTL (Arabic)
  bool get isRTL {
    final locale = Localizations.localeOf(this);
    return locale.languageCode == 'ar';
  }
  
  /// Get appropriate text direction based on locale
  TextDirection get textDirection {
    return isRTL ? TextDirection.rtl : TextDirection.ltr;
  }
  
  /// Get appropriate alignment for RTL/LTR
  Alignment get startAlignment {
    return isRTL ? Alignment.centerRight : Alignment.centerLeft;
  }
  
  /// Get appropriate alignment for RTL/LTR
  Alignment get endAlignment {
    return isRTL ? Alignment.centerLeft : Alignment.centerRight;
  }
  
  /// Get appropriate edge insets for RTL/LTR
  EdgeInsets get startEdgeInsets {
    return isRTL ? const EdgeInsets.only(right: 16) : const EdgeInsets.only(left: 16);
  }
  
  /// Get appropriate edge insets for RTL/LTR
  EdgeInsets get endEdgeInsets {
    return isRTL ? const EdgeInsets.only(left: 16) : const EdgeInsets.only(right: 16);
  }
}

/// RTL-aware widget utilities
class RTLWidget extends StatelessWidget {
  final Widget child;
  final bool forceRTL;
  
  const RTLWidget({
    super.key,
    required this.child,
    this.forceRTL = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final isRTL = forceRTL || context.isRTL;
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: child,
    );
  }
}
