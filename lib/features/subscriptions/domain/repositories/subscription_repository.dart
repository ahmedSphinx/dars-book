import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/entities/subscription.dart';

abstract class SubscriptionRepository {
  /// Get current subscription status
  Future<Either<Failure, Subscription?>> getSubscriptionStatus();
  
  /// Redeem voucher code
  Future<Either<Failure, Subscription>> redeemVoucher(String voucherCode);
  
  /// Stream of subscription changes
  Stream<Subscription?> watchSubscription();
}

