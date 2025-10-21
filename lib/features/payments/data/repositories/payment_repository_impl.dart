import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  PaymentRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _userId => firebaseAuth.currentUser?.uid ?? '';

  CollectionReference get _paymentsCollection =>
      firestore.collection('teachers').doc(_userId).collection('payments');

  @override
  Future<Either<Failure, Payment>> addPayment(Payment payment) async {
    try {
      final docRef = await _paymentsCollection.add({
        'studentId': payment.studentId,
        'amount': payment.amount,
        'method': _paymentMethodToString(payment.method),
        'note': payment.note,
        'createdAt': FieldValue.serverTimestamp(),
        'ownerId': _userId,
      });

      return Right(payment.copyWith(id: docRef.id));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Payment>>> getPaymentsByStudent(String studentId) async {
    try {
      final snapshot = await _paymentsCollection
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();

      final payments = snapshot.docs
          .map((doc) => PaymentModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();

      return Right(payments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Payment>>> getPayments() async {
    try {
      final snapshot = await _paymentsCollection
          .orderBy('createdAt', descending: true)
          .get();

      final payments = snapshot.docs
          .map((doc) => PaymentModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();

      return Right(payments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Payment>>> getPaymentsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _paymentsCollection
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      final payments = snapshot.docs
          .map((doc) => PaymentModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();

      return Right(payments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePayment(String paymentId) async {
    try {
      await _paymentsCollection.doc(paymentId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _paymentMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.transfer:
        return 'transfer';
      case PaymentMethod.wallet:
        return 'wallet';
    }
  }
}

