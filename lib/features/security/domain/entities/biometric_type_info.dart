import 'package:local_auth/local_auth.dart';

/// Information about available biometric types
class BiometricTypeInfo {
  final List<BiometricType> availableTypes;
  final bool hasFingerprint;
  final bool hasFace;
  final bool hasIris;
  final String primaryType;
  final String displayName;

  const BiometricTypeInfo({
    required this.availableTypes,
    required this.hasFingerprint,
    required this.hasFace,
    required this.hasIris,
    required this.primaryType,
    required this.displayName,
  });

  /// Create from available biometric types
  factory BiometricTypeInfo.fromTypes(List<BiometricType> types) {
    final hasFingerprint = types.contains(BiometricType.fingerprint);
    final hasFace = types.contains(BiometricType.face);
    final hasIris = types.contains(BiometricType.iris);

    String primaryType;
    String displayName;

    if (hasFace) {
      primaryType = 'face';
      displayName = 'Face ID';
    } else if (hasFingerprint) {
      primaryType = 'fingerprint';
      displayName = 'Fingerprint';
    } else if (hasIris) {
      primaryType = 'iris';
      displayName = 'Iris';
    } else {
      primaryType = 'unknown';
      displayName = 'Biometric';
    }

    return BiometricTypeInfo(
      availableTypes: types,
      hasFingerprint: hasFingerprint,
      hasFace: hasFace,
      hasIris: hasIris,
      primaryType: primaryType,
      displayName: displayName,
    );
  }

  /// Get appropriate icon for the biometric type
  String get iconName {
    if (hasFace) return 'face_id';
    if (hasFingerprint) return 'fingerprint';
    if (hasIris) return 'visibility';
    return 'security';
  }

  /// Get localized display name
  String getLocalizedDisplayName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        if (hasFace) return 'Face ID';
        if (hasFingerprint) return 'البصمة';
        if (hasIris) return 'قزحية العين';
        return 'التحقق البيومتري';
      case 'en':
      default:
        return displayName;
    }
  }

  /// Get authentication reason text
  String getAuthReason(String languageCode) {
    switch (languageCode) {
      case 'ar':
        if (hasFace) return 'يرجى استخدام Face ID للتحقق من هويتك';
        if (hasFingerprint) return 'يرجى استخدام البصمة للتحقق من هويتك';
        if (hasIris) return 'يرجى استخدام قزحية العين للتحقق من هويتك';
        return 'يرجى التحقق من هويتك لفتح التطبيق';
      case 'en':
      default:
        if (hasFace) return 'Please use Face ID to authenticate';
        if (hasFingerprint) return 'Please use your fingerprint to authenticate';
        if (hasIris) return 'Please use your iris to authenticate';
        return 'Please authenticate to unlock the app';
    }
  }

  /// Check if any biometric type is available
  bool get hasAnyBiometric => availableTypes.isNotEmpty;

  /// Get all available types as string list
  List<String> get typeNames {
    return availableTypes.map((type) {
      switch (type) {
        case BiometricType.fingerprint:
          return 'fingerprint';
        case BiometricType.face:
          return 'face';
        case BiometricType.iris:
          return 'iris';
        case BiometricType.strong:
          return 'strong';
        case BiometricType.weak:
          return 'weak';
      }
    }).toList();
  }
}
