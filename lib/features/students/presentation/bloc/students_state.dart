import 'package:equatable/equatable.dart';
import '../../domain/entities/student.dart';

abstract class StudentsState extends Equatable {
  const StudentsState();

  @override
  List<Object?> get props => [];
}

class StudentsInitial extends StudentsState {
  const StudentsInitial();
}

class StudentsLoading extends StudentsState {
  const StudentsLoading();
}

class StudentsLoaded extends StudentsState {
  final List<Student> students;

  const StudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class StudentOperationSuccess extends StudentsState {
  final String message;
  final List<Student> students;

  const StudentOperationSuccess({
    required this.message,
    required this.students,
  });

  @override
  List<Object?> get props => [message, students];
}

class StudentsError extends StudentsState {
  final String message;

  const StudentsError(this.message);

  @override
  List<Object?> get props => [message];
}

