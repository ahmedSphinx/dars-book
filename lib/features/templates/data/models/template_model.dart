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
    return SessionTemplateModel(
      id: id,
      name: json['name'] as String,
      weekdays: List<int>.from(json['weekdays'] as List),
      timeOfDay: json['timeOfDay'] as String,
      durationMin: json['durationMin'] as int,
      hasBookletDefault: json['hasBookletDefault'] as bool,
      studentIds: List<String>.from(json['studentIds'] as List),
    );
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

