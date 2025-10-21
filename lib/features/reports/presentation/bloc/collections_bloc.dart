import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/student_report.dart';
import '../../domain/repositories/report_repository.dart';

// Events
abstract class CollectionsEvent extends Equatable {
  const CollectionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodayCollections extends CollectionsEvent {
  const LoadTodayCollections();
}

// States
abstract class CollectionsState extends Equatable {
  const CollectionsState();

  @override
  List<Object?> get props => [];
}

class CollectionsInitial extends CollectionsState {
  const CollectionsInitial();
}

class CollectionsLoading extends CollectionsState {
  const CollectionsLoading();
}

class CollectionsLoaded extends CollectionsState {
  final List<StudentReport> collections;

  const CollectionsLoaded(this.collections);

  @override
  List<Object?> get props => [collections];
}

class CollectionsError extends CollectionsState {
  final String message;

  const CollectionsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final ReportRepository reportRepository;

  CollectionsBloc({required this.reportRepository}) : super(const CollectionsInitial()) {
    on<LoadTodayCollections>(_onLoadTodayCollections);
  }

  Future<void> _onLoadTodayCollections(
    LoadTodayCollections event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(const CollectionsLoading());

    final result = await reportRepository.getTodayCollections();

    result.fold(
      (failure) => emit(CollectionsError(failure.message)),
      (collections) => emit(CollectionsLoaded(collections)),
    );
  }
}

