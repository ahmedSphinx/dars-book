import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/student_report.dart';
import '../../domain/entities/year_report.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseFunctions functions;

  ReportRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.functions,
  });

  String get _userId => firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get students count
      final studentsSnapshot = await firestore
          .collection('teachers')
          .doc(_userId)
          .collection('students')
          .where('isActive', isEqualTo: true)
          .get();

      final studentsCount = studentsSnapshot.size;

      // Get sessions in period
      final sessionsSnapshot = await firestore
          .collection('teachers')
          .doc(_userId)
          .collection('sessions')
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final sessionsCount = sessionsSnapshot.size;

      // Calculate revenue from sessions
      double lessonsRevenue = 0.0;
      double bookletsRevenue = 0.0;

      for (final sessionDoc in sessionsSnapshot.docs) {
        final attendancesSnapshot = await sessionDoc.reference
            .collection('attendances')
            .get();

        for (final attendanceDoc in attendancesSnapshot.docs) {
          final data = attendanceDoc.data();
          if (data['present'] == true) {
            lessonsRevenue += (data['sessionCharge'] as num?)?.toDouble() ?? 0.0;
            bookletsRevenue += (data['bookletCharge'] as num?)?.toDouble() ?? 0.0;
          }
        }
      }

      // Get overdue and on-time students
      final overdueStudents = studentsSnapshot.docs
          .where((doc) {
            final data = doc.data();
            final aggregates = data['aggregates'] as Map<String, dynamic>?;
            final remaining = (aggregates?['remaining'] as num?)?.toDouble() ?? 0.0;
            return remaining > 0;
          })
          .length;

      final onTimeStudents = studentsCount - overdueStudents;

      final summary = DashboardSummary(
        studentsCount: studentsCount,
        sessionsCount: sessionsCount,
        totalRevenue: lessonsRevenue + bookletsRevenue,
        lessonsRevenue: lessonsRevenue,
        bookletsRevenue: bookletsRevenue,
        overdueStudentsCount: overdueStudents,
        onTimeStudentsCount: onTimeStudents,
      );

      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentReport>> getStudentReport({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get student
      final studentDoc = await firestore
          .collection('teachers')
          .doc(_userId)
          .collection('students')
          .doc(studentId)
          .get();

      if (!studentDoc.exists) {
        return Left(ServerFailure('Student not found'));
      }

      final studentData = studentDoc.data()!;
      final aggregates = studentData['aggregates'] as Map<String, dynamic>? ?? {};

      final report = StudentReport(
        studentId: studentId,
        studentName: studentData['name'] as String,
        sessionsCount: aggregates['sessionsCount'] as int? ?? 0,
        bookletsCount: aggregates['bookletsCount'] as int? ?? 0,
        totalCharges: (aggregates['totalCharges'] as num?)?.toDouble() ?? 0.0,
        totalPaid: (aggregates['totalPaid'] as num?)?.toDouble() ?? 0.0,
        remaining: (aggregates['remaining'] as num?)?.toDouble() ?? 0.0,
      );

      return Right(report);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, YearReport>> getYearReport({
    required String year,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get students by year
      final studentsSnapshot = await firestore
          .collection('teachers')
          .doc(_userId)
          .collection('students')
          .where('year', isEqualTo: year)
          .get();

      final studentsCount = studentsSnapshot.size;
      final studentIds = studentsSnapshot.docs.map((doc) => doc.id).toList();

      // Get sessions with students from this year
      final sessionsSnapshot = await firestore
          .collection('teachers')
          .doc(_userId)
          .collection('sessions')
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      int sessionsCount = 0;
      int bookletsCount = 0;
      double lessonsRevenue = 0.0;
      double bookletsRevenue = 0.0;

      for (final sessionDoc in sessionsSnapshot.docs) {
        final sessionData = sessionDoc.data();
        final hasBooklet = sessionData['hasBooklet'] as bool? ?? false;

        final attendancesSnapshot = await sessionDoc.reference
            .collection('attendances')
            .get();

        for (final attendanceDoc in attendancesSnapshot.docs) {
          if (studentIds.contains(attendanceDoc.id)) {
            final data = attendanceDoc.data();
            if (data['present'] == true) {
              sessionsCount++;
              lessonsRevenue += (data['sessionCharge'] as num?)?.toDouble() ?? 0.0;
              
              if (hasBooklet) {
                bookletsCount++;
                bookletsRevenue += (data['bookletCharge'] as num?)?.toDouble() ?? 0.0;
              }
            }
          }
        }
      }

      final report = YearReport(
        year: year,
        studentsCount: studentsCount,
        sessionsCount: sessionsCount,
        bookletsCount: bookletsCount,
        lessonsRevenue: lessonsRevenue,
        bookletsRevenue: bookletsRevenue,
        totalRevenue: lessonsRevenue + bookletsRevenue,
      );

      return Right(report);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudentReport>>> getTodayCollections() async {
    try {
      final studentsSnapshot = await firestore
          .collection('teachers')
          .doc(_userId)
          .collection('students')
          .where('aggregates.remaining', isGreaterThan: 0)
          .where('isActive', isEqualTo: true)
          .get();

      final reports = studentsSnapshot.docs.map((doc) {
        final data = doc.data();
        final aggregates = data['aggregates'] as Map<String, dynamic>? ?? {};

        return StudentReport(
          studentId: doc.id,
          studentName: data['name'] as String,
          sessionsCount: aggregates['sessionsCount'] as int? ?? 0,
          bookletsCount: aggregates['bookletsCount'] as int? ?? 0,
          totalCharges: (aggregates['totalCharges'] as num?)?.toDouble() ?? 0.0,
          totalPaid: (aggregates['totalPaid'] as num?)?.toDouble() ?? 0.0,
          remaining: (aggregates['remaining'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      return Right(reports);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

