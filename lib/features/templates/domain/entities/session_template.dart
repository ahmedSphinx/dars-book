import 'package:equatable/equatable.dart';

class SessionTemplate extends Equatable {
  final String id;
  final String name;
  final List<int> weekdays; // 0-6 (Sunday-Saturday or Monday-Sunday based on locale)
  final String timeOfDay; // "HH:mm" format
  final int durationMin;
  final bool hasBookletDefault;
  final List<String> studentIds;

  const SessionTemplate({
    required this.id,
    required this.name,
    required this.weekdays,
    required this.timeOfDay,
    required this.durationMin,
    required this.hasBookletDefault,
    required this.studentIds,
  });

  SessionTemplate copyWith({
    String? id,
    String? name,
    List<int>? weekdays,
    String? timeOfDay,
    int? durationMin,
    bool? hasBookletDefault,
    List<String>? studentIds,
  }) {
    return SessionTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      weekdays: weekdays ?? this.weekdays,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      durationMin: durationMin ?? this.durationMin,
      hasBookletDefault: hasBookletDefault ?? this.hasBookletDefault,
      studentIds: studentIds ?? this.studentIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        weekdays,
        timeOfDay,
        durationMin,
        hasBookletDefault,
        studentIds,
      ];
}

