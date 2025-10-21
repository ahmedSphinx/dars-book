import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/session.dart';

abstract class SessionRepository {
  /// Create new session
  Future<Either<Failure, Session>> createSession(Session session);
  
  /// Get session by id
  Future<Either<Failure, Session>> getSessionById(String sessionId);
  
  /// Get all sessions
  Future<Either<Failure, List<Session>>> getSessions();
  
  /// Get sessions by date range
  Future<Either<Failure, List<Session>>> getSessionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// Get sessions by student
  Future<Either<Failure, List<Session>>> getSessionsByStudent(String studentId);
  
  /// Update session attendance
  Future<Either<Failure, Session>> updateAttendance({
    required String sessionId,
    required List<Attendance> attendances,
  });
  
  /// Delete session
  Future<Either<Failure, void>> deleteSession(String sessionId);
}

