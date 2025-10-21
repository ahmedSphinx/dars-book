import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.studentId,
    required super.amount,
    required super.method,
    super.note,
    required super.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json, String id) {
    return PaymentModel(
      id: id,
      studentId: json['studentId'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: _paymentMethodFromString(json['method'] as String),
      note: json['note'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'amount': amount,
      'method': _paymentMethodToString(method),
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static PaymentMethod _paymentMethodFromString(String method) {
    switch (method) {
      case 'cash':
        return PaymentMethod.cash;
      case 'transfer':
        return PaymentMethod.transfer;
      case 'wallet':
        return PaymentMethod.wallet;
      default:
        return PaymentMethod.cash;
    }
  }

  static String _paymentMethodToString(PaymentMethod method) {
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

