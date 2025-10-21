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
    return SubscriptionModel(
      tier: json['tier'] as String? ?? 'free',
      expiresAt: (json['expiresAt'] as Timestamp).toDate(),
      isActive: json['isActive'] as bool? ?? false,
      graceDays: json['graceDays'] as int? ?? 0,
    );
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

