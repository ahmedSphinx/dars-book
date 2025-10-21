import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/domain/entities/subscription.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../models/subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseFunctions functions;

  SubscriptionRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.functions,
  });

  String get _userId => firebaseAuth.currentUser?.uid ?? '';

  DocumentReference get _teacherDoc =>
      firestore.collection('teachers').doc(_userId);

  @override
  Future<Either<Failure, Subscription?>> getSubscriptionStatus() async {
    try {
      final doc = await _teacherDoc.get();
      if (!doc.exists) {
        return const Right(null);
      }

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || data['subscription'] == null) {
        return const Right(null);
      }

      final subscription = SubscriptionModel.fromJson(
        data['subscription'] as Map<String, dynamic>,
      );

      return Right(subscription);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subscription>> redeemVoucher(String voucherCode) async {
    try {
      final callable = functions.httpsCallable('redeemVoucher');
      final result = await callable.call({'code': voucherCode});

      final subscriptionData = result.data as Map<String, dynamic>;
      final subscription = SubscriptionModel(
        tier: subscriptionData['tier'] as String,
        expiresAt: DateTime.parse(subscriptionData['expiresAt'] as String),
        isActive: subscriptionData['isActive'] as bool,
        graceDays: subscriptionData['graceDays'] as int? ?? 0,
      );

      return Right(subscription);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to redeem voucher'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Subscription?> watchSubscription() {
    return _teacherDoc.snapshots().map((doc) {
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || data['subscription'] == null) return null;

      return SubscriptionModel.fromJson(
        data['subscription'] as Map<String, dynamic>,
      );
    });
  }
}

