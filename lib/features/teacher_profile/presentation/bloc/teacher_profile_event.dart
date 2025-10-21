
// Events
import 'package:equatable/equatable.dart';

import '../../domain/entities/teacher.dart';

abstract class TeacherProfileEvent extends Equatable {
  const TeacherProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadTeacherProfile extends TeacherProfileEvent {
  final String uid;
  const LoadTeacherProfile(this.uid);
  @override
  List<Object?> get props => [uid];
}

class SaveTeacherProfile extends TeacherProfileEvent {
  final Teacher teacher;
  const SaveTeacherProfile(this.teacher);
  @override
  List<Object?> get props => [teacher];
}