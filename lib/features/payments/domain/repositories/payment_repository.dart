import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment.dart';

abstract class PaymentRepository {
  /// Add new payment
  Future<Either<Failure, Payment>> addPayment(Payment payment);
  
  /// Get payments by student
  Future<Either<Failure, List<Payment>>> getPaymentsByStudent(String studentId);
  
  /// Get all payments
  Future<Either<Failure, List<Payment>>> getPayments();
  
  /// Get payments by date range
  Future<Either<Failure, List<Payment>>> getPaymentsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// Delete payment
  Future<Either<Failure, void>> deletePayment(String paymentId);
}

