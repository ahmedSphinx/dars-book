import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final String year;
  final String? notes;
  final bool isActive;
  final double? customLessonPrice;
  final double? customBookletPrice;
  final StudentAggregates aggregates;

  const Student({
    required this.id,
    required this.name,
    this.phone,
    required this.year,
    this.notes,
    this.isActive = true,
    this.customLessonPrice,
    this.customBookletPrice,
    this.aggregates = const StudentAggregates(),
  });

  Student copyWith({
    String? id,
    String? name,
    String? phone,
    String? year,
    String? notes,
    bool? isActive,
    double? customLessonPrice,
    double? customBookletPrice,
    StudentAggregates? aggregates,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      year: year ?? this.year,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      customLessonPrice: customLessonPrice ?? this.customLessonPrice,
      customBookletPrice: customBookletPrice ?? this.customBookletPrice,
      aggregates: aggregates ?? this.aggregates,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        year,
        notes,
        isActive,
        customLessonPrice,
        customBookletPrice,
        aggregates,
      ];
}

class StudentAggregates extends Equatable {
  final int sessionsCount;
  final int bookletsCount;
  final double totalCharges;
  final double totalPaid;
  final double remaining;

  const StudentAggregates({
    this.sessionsCount = 0,
    this.bookletsCount = 0,
    this.totalCharges = 0.0,
    this.totalPaid = 0.0,
    this.remaining = 0.0,
  });

  StudentAggregates copyWith({
    int? sessionsCount,
    int? bookletsCount,
    double? totalCharges,
    double? totalPaid,
    double? remaining,
  }) {
    return StudentAggregates(
      sessionsCount: sessionsCount ?? this.sessionsCount,
      bookletsCount: bookletsCount ?? this.bookletsCount,
      totalCharges: totalCharges ?? this.totalCharges,
      totalPaid: totalPaid ?? this.totalPaid,
      remaining: remaining ?? this.remaining,
    );
  }

  @override
  List<Object?> get props => [
        sessionsCount,
        bookletsCount,
        totalCharges,
        totalPaid,
        remaining,
      ];
}

