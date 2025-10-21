import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/student_repository.dart';
import 'students_event.dart';
import 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final StudentRepository studentRepository;

  StudentsBloc({required this.studentRepository}) : super(const StudentsInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<LoadStudentsByYear>(_onLoadStudentsByYear);
    on<SearchStudents>(_onSearchStudents);
    on<AddStudent>(_onAddStudent);
    on<UpdateStudent>(_onUpdateStudent);
    on<DeleteStudent>(_onDeleteStudent);
    on<ToggleStudentActive>(_onToggleStudentActive);
    on<LoadOverdueStudents>(_onLoadOverdueStudents);
    on<LoadOnTimeStudents>(_onLoadOnTimeStudents);
  }

  Future<void> _onLoadStudents(
    LoadStudents event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());

    final result = await studentRepository.getStudents();

    result.fold(
      (failure) => emit(StudentsError(failure.message)),
      (students) => emit(StudentsLoaded(students)),
    );
  }

  Future<void> _onLoadStudentsByYear(
    LoadStudentsByYear event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());

    final result = await studentRepository.getStudentsByYear(event.year);

    result.fold(
      (failure) => emit(StudentsError(failure.message)),
      (students) => emit(StudentsLoaded(students)),
    );
  }

  Future<void> _onSearchStudents(
    SearchStudents event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());

    final result = await studentRepository.searchStudents(event.query);

    result.fold(
      (failure) => emit(StudentsError(failure.message)),
      (students) => emit(StudentsLoaded(students)),
    );
  }

  Future<void> _onAddStudent(
    AddStudent event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());

    final result = await studentRepository.addStudent(event.student);

    await result.fold(
      (failure) async => emit(StudentsError(failure.message)),
      (_) async {
        final studentsResult = await studentRepository.getStudents();
        studentsResult.fold(
          (failure) => emit(StudentsError(failure.message)),
          (students) => emit(StudentOperationSuccess(
            message: 'Student added successfully',
            students: students,
          )),
        );
      },
    );
  }

  Future<void> _onUpdateStudent(
    UpdateStudent event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());

    final result = await studentRepository.updateStudent(event.student);

    await result.fold(
      (failure) async => emit(StudentsError(failure.message)),
      (_) async {
        final studentsResult = await studentRepository.getStudents();
        studentsResult.fold(
          (failure) => emit(StudentsError(failure.message)),
          (students) => emit(StudentOperationSuccess(
            message: 'Student updated successfully',
            students: students,
          )),
        );
      },
    );
  }

  Future<void> _onDeleteStudent(
    DeleteStudent event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());

    final result = await studentRepository.deleteStudent(event.studentId);

    await result.fold(
      (failure) async => emit(StudentsError(failure.message)),
      (_) async {
        final studentsResult = await studentRepository.getStudents();
        studentsResult.fold(
          (failure) => emit(StudentsError(failure.message)),
          (students) => emit(StudentOperationSuccess(
            message: 'Student deleted successfully',
            students: students,
          )),
        );
      },
    );
  }

  Future<void> _onToggleStudentActive(
    ToggleStudentActive event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());

    final result = await studentRepository.toggleActiveStatus(event.studentId);

    await result.fold(
      (failure) async => emit(StudentsError(failure.message)),
      (_) async {
        final studentsResult = await studentRepository.getStudents();
        studentsResult.fold(
          (failure) => emit(StudentsError(failure.message)),
          (students) => emit(StudentOperationSuccess(
            message: 'Student status updated',
            students: students,
          )),
        );
      },
    );
  }

  Future<void> _onLoadOverdueStudents(
    LoadOverdueStudents event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());

    final result = await studentRepository.getOverdueStudents();

    result.fold(
      (failure) => emit(StudentsError(failure.message)),
      (students) => emit(StudentsLoaded(students)),
    );
  }

  Future<void> _onLoadOnTimeStudents(
    LoadOnTimeStudents event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());

    final result = await studentRepository.getOnTimeStudents();

    result.fold(
      (failure) => emit(StudentsError(failure.message)),
      (students) => emit(StudentsLoaded(students)),
    );
  }
}

