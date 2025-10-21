import 'package:equatable/equatable.dart';

class YearReport extends Equatable {
  final String year;
  final int studentsCount;
  final int sessionsCount;
  final int bookletsCount;
  final double lessonsRevenue;
  final double bookletsRevenue;
  final double totalRevenue;

  const YearReport({
    required this.year,
    required this.studentsCount,
    required this.sessionsCount,
    required this.bookletsCount,
    required this.lessonsRevenue,
    required this.bookletsRevenue,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [
        year,
        studentsCount,
        sessionsCount,
        bookletsCount,
        lessonsRevenue,
        bookletsRevenue,
        totalRevenue,
      ];
}

