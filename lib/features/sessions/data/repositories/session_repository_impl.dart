import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';
import '../models/session_model.dart';

class SessionRepositoryImpl implements SessionRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  SessionRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _userId => firebaseAuth.currentUser?.uid ?? '';

  CollectionReference get _sessionsCollection =>
      firestore.collection('teachers').doc(_userId).collection('sessions');

  @override
  Future<Either<Failure, Session>> createSession(Session session) async {
    try {
      // Validate input
      if (_userId.isEmpty) {
        return Left(ServerFailure('User not authenticated'));
      }
      if (session.dateTime.isAfter(DateTime.now().add(const Duration(days: 365)))) {
        return Left(ServerFailure('Session date cannot be more than 1 year in the future'));
      }
      if (session.dateTime.isBefore(DateTime.now().subtract(const Duration(days: 365)))) {
        return Left(ServerFailure('Session date cannot be more than 1 year in the past'));
      }

      final docRef = await _sessionsCollection.add({
        'dateTime': Timestamp.fromDate(session.dateTime),
        'hasBooklet': session.hasBooklet,
        'note': session.note,
        'ownerId': _userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add attendances as subcollection
      final batch = firestore.batch();
      for (final attendance in session.attendances) {
        final attendanceRef = docRef.collection('attendances').doc(attendance.studentId);
        batch.set(attendanceRef, {
          'studentName': attendance.studentName,
          'present': attendance.present,
          'lessonPriceSnap': attendance.lessonPriceSnap,
          'bookletPriceSnap': attendance.bookletPriceSnap,
          'sessionCharge': attendance.sessionCharge,
          'bookletCharge': attendance.bookletCharge,
          'ownerId': _userId,
        });
      }
      await batch.commit();

      return Right(session.copyWith(id: docRef.id));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Session>> getSessionById(String sessionId) async {
    try {
      // Validate input
      if (sessionId.isEmpty) {
        return Left(ServerFailure('Session ID cannot be empty'));
      }
      if (_userId.isEmpty) {
        return Left(ServerFailure('User not authenticated'));
      }

      final doc = await _sessionsCollection.doc(sessionId).get();
      if (!doc.exists) {
        return Left(ServerFailure('Session not found'));
      }

      final session = SessionModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      // Load attendances
      final attendancesSnapshot = await doc.reference.collection('attendances').get();
      final attendances = attendancesSnapshot.docs
          .map((doc) => AttendanceModel.fromJson(
                doc.data(),
                doc.id,
              ))
          .toList();

      return Right(session.copyWith(attendances: attendances));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Session>>> getSessions() async {
    try {
      final snapshot = await _sessionsCollection
          .orderBy('dateTime', descending: true)
          .get();

      final sessions = <Session>[];
      for (final doc in snapshot.docs) {
        final session = SessionModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        final attendancesSnapshot = await doc.reference.collection('attendances').get();
        final attendances = attendancesSnapshot.docs
            .map((doc) => AttendanceModel.fromJson(
                  doc.data(),
                  doc.id,
                ))
            .toList();

        sessions.add(session.copyWith(attendances: attendances));
      }

      return Right(sessions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Session>>> getSessionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _sessionsCollection
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('dateTime', descending: true)
          .get();

      final sessions = <Session>[];
      for (final doc in snapshot.docs) {
        final session = SessionModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        final attendancesSnapshot = await doc.reference.collection('attendances').get();
        final attendances = attendancesSnapshot.docs
            .map((doc) => AttendanceModel.fromJson(
                  doc.data(),
                  doc.id,
                ))
            .toList();

        sessions.add(session.copyWith(attendances: attendances));
      }

      return Right(sessions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Session>>> getSessionsByStudent(String studentId) async {
    try {
      final snapshot = await _sessionsCollection
          .orderBy('dateTime', descending: true)
          .get();

      final sessions = <Session>[];
      for (final doc in snapshot.docs) {
        final attendanceDoc = await doc.reference
            .collection('attendances')
            .doc(studentId)
            .get();

        if (attendanceDoc.exists) {
          final session = SessionModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );

          final attendance = AttendanceModel.fromJson(
            attendanceDoc.data()!,
            attendanceDoc.id,
          );

          sessions.add(session.copyWith(attendances: [attendance]));
        }
      }

      return Right(sessions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Session>> updateAttendance({
    required String sessionId,
    required List<Attendance> attendances,
  }) async {
    try {
      final batch = firestore.batch();
      final sessionRef = _sessionsCollection.doc(sessionId);

      for (final attendance in attendances) {
        final attendanceRef = sessionRef.collection('attendances').doc(attendance.studentId);
        batch.set(attendanceRef, {
          'studentName': attendance.studentName,
          'present': attendance.present,
          'lessonPriceSnap': attendance.lessonPriceSnap,
          'bookletPriceSnap': attendance.bookletPriceSnap,
          'sessionCharge': attendance.sessionCharge,
          'bookletCharge': attendance.bookletCharge,
          'ownerId': _userId,
        });
      }

      await batch.commit();

      // Fetch updated session
      return getSessionById(sessionId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      // Delete attendances first
      final attendancesSnapshot = await _sessionsCollection
          .doc(sessionId)
          .collection('attendances')
          .get();

      final batch = firestore.batch();
      for (final doc in attendancesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete session
      batch.delete(_sessionsCollection.doc(sessionId));

      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

