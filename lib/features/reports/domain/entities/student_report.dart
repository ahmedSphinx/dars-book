import 'package:equatable/equatable.dart';

class StudentReport extends Equatable {
  final String studentId;
  final String studentName;
  final int sessionsCount;
  final int bookletsCount;
  final double totalCharges;
  final double totalPaid;
  final double remaining;

  const StudentReport({
    required this.studentId,
    required this.studentName,
    required this.sessionsCount,
    required this.bookletsCount,
    required this.totalCharges,
    required this.totalPaid,
    required this.remaining,
  });

  @override
  List<Object?> get props => [
        studentId,
        studentName,
        sessionsCount,
        bookletsCount,
        totalCharges,
        totalPaid,
        remaining,
      ];
}

