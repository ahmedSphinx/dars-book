import '../../domain/entities/teacher.dart';

class TeacherModel extends Teacher {
  const TeacherModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.subject,
    required super.city,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json, String id) {
    return TeacherModel(
      id: id,
      name: (json['name'] as String?)?.trim() ?? '',
      phone: (json['phone'] as String?)?.trim() ?? '',
      subject: (json['subject'] as String?)?.trim() ?? '',
      city: (json['city'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'subject': subject,
      'city': city,
    };
  }
}



