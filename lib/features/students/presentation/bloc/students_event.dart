import 'package:equatable/equatable.dart';
import '../../domain/entities/student.dart';

abstract class StudentsEvent extends Equatable {
  const StudentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudents extends StudentsEvent {
  const LoadStudents();
}

class LoadStudentsByYear extends StudentsEvent {
  final String year;

  const LoadStudentsByYear(this.year);

  @override
  List<Object?> get props => [year];
}

class SearchStudents extends StudentsEvent {
  final String query;

  const SearchStudents(this.query);

  @override
  List<Object?> get props => [query];
}

class AddStudent extends StudentsEvent {
  final Student student;

  const AddStudent(this.student);

  @override
  List<Object?> get props => [student];
}

class UpdateStudent extends StudentsEvent {
  final Student student;

  const UpdateStudent(this.student);

  @override
  List<Object?> get props => [student];
}

class DeleteStudent extends StudentsEvent {
  final String studentId;

  const DeleteStudent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class ToggleStudentActive extends StudentsEvent {
  final String studentId;

  const ToggleStudentActive(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LoadOverdueStudents extends StudentsEvent {
  const LoadOverdueStudents();
}

class LoadOnTimeStudents extends StudentsEvent {
  const LoadOnTimeStudents();
}

