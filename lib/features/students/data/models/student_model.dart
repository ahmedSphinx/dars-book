import '../../domain/entities/student.dart';

class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    super.phone,
    required super.year,
    super.notes,
    super.isActive,
    super.customLessonPrice,
    super.customBookletPrice,
    super.aggregates,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json, String id) {
    return StudentModel(
      id: id,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      year: json['year'] as String,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      customLessonPrice: (json['customLessonPrice'] as num?)?.toDouble(),
      customBookletPrice: (json['customBookletPrice'] as num?)?.toDouble(),
      aggregates: json['aggregates'] != null
          ? StudentAggregatesModel.fromJson(
              json['aggregates'] as Map<String, dynamic>)
          : const StudentAggregates(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'year': year,
      'notes': notes,
      'isActive': isActive,
      'customLessonPrice': customLessonPrice,
      'customBookletPrice': customBookletPrice,
      'aggregates': (aggregates as StudentAggregatesModel).toJson(),
    };
  }

  factory StudentModel.fromEntity(Student student) {
    return StudentModel(
      id: student.id,
      name: student.name,
      phone: student.phone,
      year: student.year,
      notes: student.notes,
      isActive: student.isActive,
      customLessonPrice: student.customLessonPrice,
      customBookletPrice: student.customBookletPrice,
      aggregates: student.aggregates,
    );
  }
}

class StudentAggregatesModel extends StudentAggregates {
  const StudentAggregatesModel({
    super.sessionsCount,
    super.bookletsCount,
    super.totalCharges,
    super.totalPaid,
    super.remaining,
  });

  factory StudentAggregatesModel.fromJson(Map<String, dynamic> json) {
    return StudentAggregatesModel(
      sessionsCount: json['sessionsCount'] as int? ?? 0,
      bookletsCount: json['bookletsCount'] as int? ?? 0,
      totalCharges: (json['totalCharges'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionsCount': sessionsCount,
      'bookletsCount': bookletsCount,
      'totalCharges': totalCharges,
      'totalPaid': totalPaid,
      'remaining': remaining,
    };
  }
}

