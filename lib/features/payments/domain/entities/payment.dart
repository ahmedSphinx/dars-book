import 'package:equatable/equatable.dart';

enum PaymentMethod {
  cash,
  transfer,
  wallet,
}

class Payment extends Equatable {
  final String id;
  final String studentId;
  final double amount;
  final PaymentMethod method;
  final String? note;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.method,
    this.note,
    required this.createdAt,
  });

  Payment copyWith({
    String? id,
    String? studentId,
    double? amount,
    PaymentMethod? method,
    String? note,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, studentId, amount, method, note, createdAt];
}

