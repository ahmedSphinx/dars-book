import 'package:equatable/equatable.dart';

class Session extends Equatable {
  final String id;
  final DateTime dateTime;
  final bool hasBooklet;
  final String? note;
  final List<Attendance> attendances;

  const Session({
    required this.id,
    required this.dateTime,
    required this.hasBooklet,
    this.note,
    this.attendances = const [],
  });

  Session copyWith({
    String? id,
    DateTime? dateTime,
    bool? hasBooklet,
    String? note,
    List<Attendance>? attendances,
  }) {
    return Session(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      hasBooklet: hasBooklet ?? this.hasBooklet,
      note: note ?? this.note,
      attendances: attendances ?? this.attendances,
    );
  }

  @override
  List<Object?> get props => [id, dateTime, hasBooklet, note, attendances];
}

class Attendance extends Equatable {
  final String studentId;
  final String studentName;
  final bool present;
  final double lessonPriceSnap;
  final double bookletPriceSnap;
  final double sessionCharge;
  final double bookletCharge;

  const Attendance({
    required this.studentId,
    required this.studentName,
    required this.present,
    required this.lessonPriceSnap,
    required this.bookletPriceSnap,
    required this.sessionCharge,
    required this.bookletCharge,
  });

  double get totalCharge => sessionCharge + bookletCharge;

  Attendance copyWith({
    String? studentId,
    String? studentName,
    bool? present,
    double? lessonPriceSnap,
    double? bookletPriceSnap,
    double? sessionCharge,
    double? bookletCharge,
  }) {
    return Attendance(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      present: present ?? this.present,
      lessonPriceSnap: lessonPriceSnap ?? this.lessonPriceSnap,
      bookletPriceSnap: bookletPriceSnap ?? this.bookletPriceSnap,
      sessionCharge: sessionCharge ?? this.sessionCharge,
      bookletCharge: bookletCharge ?? this.bookletCharge,
    );
  }

  @override
  List<Object?> get props => [
        studentId,
        studentName,
        present,
        lessonPriceSnap,
        bookletPriceSnap,
        sessionCharge,
        bookletCharge,
      ];
}

