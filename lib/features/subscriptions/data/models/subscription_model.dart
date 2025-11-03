import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/entities/subscription.dart';

class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.tier,
    required super.expiresAt,
    required super.isActive,
    super.graceDays,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    try {
      // Validate required fields
      if (json['tier'] == null) {
        throw FormatException('tier field is required');
      }
      if (json['expiresAt'] == null) {
        throw FormatException('expiresAt field is required');
      }

      // Validate tier value
      final tier = json['tier'] as String;
      if (!['free', 'premium', 'pro'].contains(tier.toLowerCase())) {
        throw FormatException('Invalid tier value: $tier');
      }

      // Parse expiresAt with error handling
      DateTime expiresAt;
      if (json['expiresAt'] is Timestamp) {
        expiresAt = (json['expiresAt'] as Timestamp).toDate();
      } else if (json['expiresAt'] is String) {
        expiresAt = DateTime.parse(json['expiresAt'] as String);
      } else {
        throw FormatException('Invalid expiresAt format');
      }

      return SubscriptionModel(
        tier: tier,
        expiresAt: expiresAt,
        isActive: json['isActive'] as bool? ?? false,
        graceDays: (json['graceDays'] as int?)?.clamp(0, 30) ?? 0, // Limit grace days to 30
      );
    } catch (e) {
      throw FormatException('Failed to parse subscription data: ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'tier': tier,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isActive': isActive,
      'graceDays': graceDays,
    };
  }
}
