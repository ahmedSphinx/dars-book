import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final int studentsCount;
  final int sessionsCount;
  final double totalRevenue;
  final double lessonsRevenue;
  final double bookletsRevenue;
  final int overdueStudentsCount;
  final int onTimeStudentsCount;

  const DashboardSummary({
    required this.studentsCount,
    required this.sessionsCount,
    required this.totalRevenue,
    required this.lessonsRevenue,
    required this.bookletsRevenue,
    required this.overdueStudentsCount,
    required this.onTimeStudentsCount,
  });

  @override
  List<Object?> get props => [
        studentsCount,
        sessionsCount,
        totalRevenue,
        lessonsRevenue,
        bookletsRevenue,
        overdueStudentsCount,
        onTimeStudentsCount,
      ];
}

