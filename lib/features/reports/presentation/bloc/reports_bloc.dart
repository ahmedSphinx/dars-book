import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/student_report.dart';
import '../../domain/entities/year_report.dart';
import '../../domain/repositories/report_repository.dart';

// Events
abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardSummary extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadDashboardSummary({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadStudentReport extends ReportsEvent {
  final String studentId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadStudentReport({
    required this.studentId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [studentId, startDate, endDate];
}

class LoadYearReport extends ReportsEvent {
  final String year;
  final DateTime startDate;
  final DateTime endDate;

  const LoadYearReport({
    required this.year,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [year, startDate, endDate];
}

// States
abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class DashboardSummaryLoaded extends ReportsState {
  final DashboardSummary summary;

  const DashboardSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class StudentReportLoaded extends ReportsState {
  final StudentReport report;

  const StudentReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class YearReportLoaded extends ReportsState {
  final YearReport report;

  const YearReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportRepository reportRepository;

  ReportsBloc({required this.reportRepository}) : super(const ReportsInitial()) {
    on<LoadDashboardSummary>(_onLoadDashboardSummary);
    on<LoadStudentReport>(_onLoadStudentReport);
    on<LoadYearReport>(_onLoadYearReport);
  }

  Future<void> _onLoadDashboardSummary(
    LoadDashboardSummary event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    final result = await reportRepository.getDashboardSummary(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (summary) => emit(DashboardSummaryLoaded(summary)),
    );
  }

  Future<void> _onLoadStudentReport(
    LoadStudentReport event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    final result = await reportRepository.getStudentReport(
      studentId: event.studentId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (report) => emit(StudentReportLoaded(report)),
    );
  }

  Future<void> _onLoadYearReport(
    LoadYearReport event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    final result = await reportRepository.getYearReport(
      year: event.year,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (report) => emit(YearReportLoaded(report)),
    );
  }
}

