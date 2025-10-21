import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/session.dart';

class SessionModel extends Session {
  const SessionModel({
    required super.id,
    required super.dateTime,
    required super.hasBooklet,
    super.note,
    super.attendances,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json, String id) {
    return SessionModel(
      id: id,
      dateTime: (json['dateTime'] as Timestamp).toDate(),
      hasBooklet: json['hasBooklet'] as bool,
      note: json['note'] as String?,
      attendances: [], // Attendances are loaded separately
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': Timestamp.fromDate(dateTime),
      'hasBooklet': hasBooklet,
      'note': note,
    };
  }
}

class AttendanceModel extends Attendance {
  const AttendanceModel({
    required super.studentId,
    required super.studentName,
    required super.present,
    required super.lessonPriceSnap,
    required super.bookletPriceSnap,
    required super.sessionCharge,
    required super.bookletCharge,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json, String studentId) {
    return AttendanceModel(
      studentId: studentId,
      studentName: json['studentName'] as String,
      present: json['present'] as bool,
      lessonPriceSnap: (json['lessonPriceSnap'] as num).toDouble(),
      bookletPriceSnap: (json['bookletPriceSnap'] as num).toDouble(),
      sessionCharge: (json['sessionCharge'] as num).toDouble(),
      bookletCharge: (json['bookletCharge'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'present': present,
      'lessonPriceSnap': lessonPriceSnap,
      'bookletPriceSnap': bookletPriceSnap,
      'sessionCharge': sessionCharge,
      'bookletCharge': bookletCharge,
    };
  }
}

