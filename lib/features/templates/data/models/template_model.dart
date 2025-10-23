import '../../domain/entities/session_template.dart';

class SessionTemplateModel extends SessionTemplate {
  const SessionTemplateModel({
    required super.id,
    required super.name,
    required super.weekdays,
    required super.timeOfDay,
    required super.durationMin,
    required super.hasBookletDefault,
    required super.studentIds,
  });

  factory SessionTemplateModel.fromJson(Map<String, dynamic> json, String id) {
    try {
      // Validate required fields
      if (!json.containsKey('name') || !json.containsKey('weekdays') || 
          !json.containsKey('timeOfDay') || !json.containsKey('durationMin')) {
        throw FormatException('Missing required template fields');
      }

      final name = json['name'] as String;
      final weekdays = List<int>.from(json['weekdays'] as List);
      final timeOfDay = json['timeOfDay'] as String;
      final durationMin = json['durationMin'] as int;
      final hasBookletDefault = json['hasBookletDefault'] as bool? ?? false;
      final studentIds = List<String>.from(json['studentIds'] as List? ?? []);

      // Validate data
      if (name.isEmpty) {
        throw FormatException('Template name cannot be empty');
      }
      if (durationMin <= 0) {
        throw FormatException('Duration must be positive');
      }
      if (weekdays.any((day) => day < 0 || day > 6)) {
        throw FormatException('Weekdays must be between 0-6');
      }
      if (!_isValidTimeFormat(timeOfDay)) {
        throw FormatException('Time must be in HH:mm format');
      }

      return SessionTemplateModel(
        id: id,
        name: name,
        weekdays: weekdays,
        timeOfDay: timeOfDay,
        durationMin: durationMin,
        hasBookletDefault: hasBookletDefault,
        studentIds: studentIds,
      );
    } catch (e) {
      throw FormatException('Invalid template data: $e');
    }
  }

  /// Validate time format (HH:mm)
  static bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'weekdays': weekdays,
      'timeOfDay': timeOfDay,
      'durationMin': durationMin,
      'hasBookletDefault': hasBookletDefault,
      'studentIds': studentIds,
    };
  }
}

