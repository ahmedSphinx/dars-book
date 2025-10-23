import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';
import '../../../students/domain/repositories/student_repository.dart';
import '../../../pricing/domain/repositories/price_repository.dart';

// Events
abstract class SessionsEvent extends Equatable {
  const SessionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSessions extends SessionsEvent {
  const LoadSessions();
}

class LoadSessionsByDateRange extends SessionsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadSessionsByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class CreateSession extends SessionsEvent {
  final Session session;

  const CreateSession(this.session);

  @override
  List<Object?> get props => [session];
}

class UpdateSessionAttendance extends SessionsEvent {
  final String sessionId;
  final List<Attendance> attendances;

  const UpdateSessionAttendance({
    required this.sessionId,
    required this.attendances,
  });

  @override
  List<Object?> get props => [sessionId, attendances];
}

class DeleteSession extends SessionsEvent {
  final String sessionId;

  const DeleteSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

// States
abstract class SessionsState extends Equatable {
  const SessionsState();

  @override
  List<Object?> get props => [];
}

class SessionsInitial extends SessionsState {
  const SessionsInitial();
}

class SessionsLoading extends SessionsState {
  const SessionsLoading();
}

class SessionsLoaded extends SessionsState {
  final List<Session> sessions;

  const SessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class SessionOperationSuccess extends SessionsState {
  final String message;

  const SessionOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SessionsError extends SessionsState {
  final String message;

  const SessionsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class SessionsBloc extends Bloc<SessionsEvent, SessionsState> {
  final SessionRepository sessionRepository;
  final StudentRepository studentRepository;
  final PriceRepository priceRepository;

  SessionsBloc({
    required this.sessionRepository,
    required this.studentRepository,
    required this.priceRepository,
  }) : super(const SessionsInitial()) {
    on<LoadSessions>(_onLoadSessions);
    on<LoadSessionsByDateRange>(_onLoadSessionsByDateRange);
    on<CreateSession>(_onCreateSession);
    on<UpdateSessionAttendance>(_onUpdateSessionAttendance);
    on<DeleteSession>(_onDeleteSession);
  }

  Future<void> _onLoadSessions(
    LoadSessions event,
    Emitter<SessionsState> emit,
  ) async {
    emit(const SessionsLoading());

    final result = await sessionRepository.getSessions();

    result.fold(
      (failure) => emit(SessionsError(failure.message)),
      (sessions) => emit(SessionsLoaded(sessions)),
    );
  }

  Future<void> _onLoadSessionsByDateRange(
    LoadSessionsByDateRange event,
    Emitter<SessionsState> emit,
  ) async {
    emit(const SessionsLoading());

    final result = await sessionRepository.getSessionsByDateRange(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(SessionsError(failure.message)),
      (sessions) => emit(SessionsLoaded(sessions)),
    );
  }

  Future<void> _onCreateSession(
    CreateSession event,
    Emitter<SessionsState> emit,
  ) async {
    emit(const SessionsLoading());

    final result = await sessionRepository.createSession(event.session);

    result.fold(
      (failure) => emit(SessionsError(failure.message)),
      (_) {
        emit(const SessionOperationSuccess('تم إنشاء الحصة بنجاح'));
        // Refresh sessions after successful creation
        add(const LoadSessions());
      },
    );
  }

  Future<void> _onUpdateSessionAttendance(
    UpdateSessionAttendance event,
    Emitter<SessionsState> emit,
  ) async {
    emit(const SessionsLoading());

    final result = await sessionRepository.updateAttendance(
      sessionId: event.sessionId,
      attendances: event.attendances,
    );

    result.fold(
      (failure) => emit(SessionsError(failure.message)),
      (_) {
        emit(const SessionOperationSuccess('تم تحديث الحضور بنجاح'));
        // Refresh sessions after successful update
        add(const LoadSessions());
      },
    );
  }

  Future<void> _onDeleteSession(
    DeleteSession event,
    Emitter<SessionsState> emit,
  ) async {
    emit(const SessionsLoading());

    final result = await sessionRepository.deleteSession(event.sessionId);

    result.fold(
      (failure) => emit(SessionsError(failure.message)),
      (_) {
        emit(const SessionOperationSuccess('تم حذف الحصة بنجاح'));
        // Refresh sessions after successful deletion
        add(const LoadSessions());
      },
    );
  }
}

