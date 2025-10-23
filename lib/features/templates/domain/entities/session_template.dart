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

  /// Factory constructor with validation
  factory SessionTemplate.create({
    required String id,
    required String name,
    required List<int> weekdays,
    required String timeOfDay,
    required int durationMin,
    required bool hasBookletDefault,
    required List<String> studentIds,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('Template name cannot be empty');
    }
    if (durationMin <= 0) {
      throw ArgumentError('Duration must be positive');
    }
    if (weekdays.any((day) => day < 0 || day > 6)) {
      throw ArgumentError('Weekdays must be between 0-6');
    }
    if (!_isValidTimeFormat(timeOfDay)) {
      throw ArgumentError('Time must be in HH:mm format');
    }
    
    return SessionTemplate(
      id: id,
      name: name,
      weekdays: weekdays,
      timeOfDay: timeOfDay,
      durationMin: durationMin,
      hasBookletDefault: hasBookletDefault,
      studentIds: studentIds,
    );
  }

  /// Validate time format (HH:mm)
  static bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

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

  /// Check if template is valid
  bool get isValid => 
      name.isNotEmpty && 
      durationMin > 0 && 
      weekdays.every((day) => day >= 0 && day <= 6) &&
      _isValidTimeFormat(timeOfDay);

  /// Get formatted duration
  String get formattedDuration {
    if (durationMin < 60) {
      return '$durationMin دقيقة';
    } else {
      final hours = durationMin ~/ 60;
      final minutes = durationMin % 60;
      if (minutes == 0) {
        return '$hours ساعة';
      } else {
        return '$hours ساعة و $minutes دقيقة';
      }
    }
  }

  /// Get formatted weekdays
  List<String> get formattedWeekdays {
    const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return weekdays.map((day) => days[day % 7]).toList();
  }

  /// Check if template has students
  bool get hasStudents => studentIds.isNotEmpty;

  /// Get student count
  int get studentCount => studentIds.length;

  /// Check if template is for specific day
  bool isForDay(int day) => weekdays.contains(day);

  /// Get next occurrence of this template
  DateTime? getNextOccurrence() {
    final now = DateTime.now();
    final today = now.weekday % 7; // Convert to 0-6 format
    
    // Find next occurrence
    for (int i = 0; i < 7; i++) {
      final checkDay = (today + i) % 7;
      if (weekdays.contains(checkDay)) {
        final daysToAdd = i == 0 ? (weekdays.contains(today) ? 0 : 7) : i;
        final nextDate = now.add(Duration(days: daysToAdd));
        return DateTime(nextDate.year, nextDate.month, nextDate.day);
      }
    }
    return null;
  }
}

