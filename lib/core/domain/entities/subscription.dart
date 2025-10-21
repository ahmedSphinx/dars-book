import 'package:equatable/equatable.dart';

class Subscription extends Equatable {
  final String tier;
  final DateTime expiresAt;
  final bool isActive;
  final int graceDays;

  const Subscription({
    required this.tier,
    required this.expiresAt,
    required this.isActive,
    this.graceDays = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  int get remainingDays {
    final difference = expiresAt.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }

  Subscription copyWith({
    String? tier,
    DateTime? expiresAt,
    bool? isActive,
    int? graceDays,
  }) {
    return Subscription(
      tier: tier ?? this.tier,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      graceDays: graceDays ?? this.graceDays,
    );
  }

  @override
  List<Object?> get props => [tier, expiresAt, isActive, graceDays];
}

