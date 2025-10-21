import 'package:equatable/equatable.dart';

class Teacher extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String subject;
  final String city;

  const Teacher({
    required this.id,
    required this.name,
    required this.phone,
    required this.subject,
    required this.city,
  });

  Teacher copyWith({
    String? id,
    String? name,
    String? phone,
    String? subject,
    String? city,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      subject: subject ?? this.subject,
      city: city ?? this.city,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, subject, city];
}



