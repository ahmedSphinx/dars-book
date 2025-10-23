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
    try {
      // Validate required fields
      if (!json.containsKey('dateTime')) {
        throw FormatException('Missing required field: dateTime');
      }
      if (!json.containsKey('hasBooklet')) {
        throw FormatException('Missing required field: hasBooklet');
      }

      DateTime dateTime;
      if (json['dateTime'] is Timestamp) {
        dateTime = (json['dateTime'] as Timestamp).toDate();
      } else {
        dateTime = DateTime.parse(json['dateTime'].toString());
      }

      final hasBooklet = json['hasBooklet'] as bool;
      final note = json['note'] as String?;

      return SessionModel(
        id: id,
        dateTime: dateTime,
        hasBooklet: hasBooklet,
        note: note,
        attendances: [], // Attendances are loaded separately
      );
    } catch (e) {
      throw FormatException('Invalid session data: $e');
    }
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
    try {
      // Validate required fields
      final requiredFields = [
        'studentName', 'present', 'lessonPriceSnap', 
        'bookletPriceSnap', 'sessionCharge', 'bookletCharge'
      ];
      
      for (final field in requiredFields) {
        if (!json.containsKey(field)) {
          throw FormatException('Missing required field: $field');
        }
      }

      final studentName = json['studentName'] as String;
      final present = json['present'] as bool;
      final lessonPriceSnap = (json['lessonPriceSnap'] as num).toDouble();
      final bookletPriceSnap = (json['bookletPriceSnap'] as num).toDouble();
      final sessionCharge = (json['sessionCharge'] as num).toDouble();
      final bookletCharge = (json['bookletCharge'] as num).toDouble();

      // Validate values
      if (studentName.isEmpty) {
        throw FormatException('Student name cannot be empty');
      }
      if (lessonPriceSnap < 0) {
        throw FormatException('Lesson price cannot be negative');
      }
      if (bookletPriceSnap < 0) {
        throw FormatException('Booklet price cannot be negative');
      }
      if (sessionCharge < 0) {
        throw FormatException('Session charge cannot be negative');
      }
      if (bookletCharge < 0) {
        throw FormatException('Booklet charge cannot be negative');
      }

      return AttendanceModel(
        studentId: studentId,
        studentName: studentName,
        present: present,
        lessonPriceSnap: lessonPriceSnap,
        bookletPriceSnap: bookletPriceSnap,
        sessionCharge: sessionCharge,
        bookletCharge: bookletCharge,
      );
    } catch (e) {
      throw FormatException('Invalid attendance data: $e');
    }
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

