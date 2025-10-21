import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_summary.dart';
import '../entities/student_report.dart';
import '../entities/year_report.dart';

abstract class ReportRepository {
  /// Get dashboard summary
  Future<Either<Failure, DashboardSummary>> getDashboardSummary({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// Get student report
  Future<Either<Failure, StudentReport>> getStudentReport({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// Get year report
  Future<Either<Failure, YearReport>> getYearReport({
    required String year,
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// Get today's collections (students with due amounts)
  Future<Either<Failure, List<StudentReport>>> getTodayCollections();
}

