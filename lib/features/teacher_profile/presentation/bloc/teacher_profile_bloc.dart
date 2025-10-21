import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/repositories/teacher_repository.dart';
import 'teacher_profile_event.dart';
import 'teacher_profile_state.dart';




// Bloc
class TeacherProfileBloc extends Bloc<TeacherProfileEvent, TeacherProfileState> {
  final TeacherRepository teacherRepository;

  TeacherProfileBloc({required this.teacherRepository}) : super(const TeacherProfileInitial()) {
    on<LoadTeacherProfile>(_onLoad);
    on<SaveTeacherProfile>(_onSave);
  }

  Future<void> _onLoad(
    LoadTeacherProfile event,
    Emitter<TeacherProfileState> emit,
  ) async {
    emit(const TeacherProfileLoading());
    final result = await teacherRepository.getTeacher(event.uid);
    result.fold(
      (failure) => emit(TeacherProfileError(failure.message)),
      (teacher) => emit(TeacherProfileLoaded(teacher)),
    );
  }

  Future<void> _onSave(
    SaveTeacherProfile event,
    Emitter<TeacherProfileState> emit,
  ) async {
    emit(const TeacherProfileLoading());
    final result = await teacherRepository.saveTeacher(event.teacher);
    result.fold(
      (failure) => emit(TeacherProfileError(failure.message)),
      (_) => emit(const TeacherProfileSaved()),
    );
  }
}


