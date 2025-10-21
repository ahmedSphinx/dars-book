// States
import 'package:equatable/equatable.dart';

import '../../domain/entities/teacher.dart';

abstract class TeacherProfileState extends Equatable {
  const TeacherProfileState();
  @override
  List<Object?> get props => [];
}

class TeacherProfileInitial extends TeacherProfileState {
  const TeacherProfileInitial();
}

class TeacherProfileLoading extends TeacherProfileState {
  const TeacherProfileLoading();
}

class TeacherProfileLoaded extends TeacherProfileState {
  final Teacher? teacher;
  const TeacherProfileLoaded(this.teacher);
  @override
  List<Object?> get props => [teacher];
}

class TeacherProfileSaved extends TeacherProfileState {
  const TeacherProfileSaved();
}

class TeacherProfileError extends TeacherProfileState {
  final String message;
  const TeacherProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
