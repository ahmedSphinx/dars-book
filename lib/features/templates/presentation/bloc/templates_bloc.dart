import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/session_template.dart';
import '../../domain/repositories/template_repository.dart';

// Events
abstract class TemplatesEvent extends Equatable {
  const TemplatesEvent();

  @override
  List<Object?> get props => [];
}

class LoadTemplates extends TemplatesEvent {
  const LoadTemplates();
}

class CreateTemplate extends TemplatesEvent {
  final SessionTemplate template;

  const CreateTemplate(this.template);

  @override
  List<Object?> get props => [template];
}

class UpdateTemplate extends TemplatesEvent {
  final SessionTemplate template;

  const UpdateTemplate(this.template);

  @override
  List<Object?> get props => [template];
}

class DeleteTemplate extends TemplatesEvent {
  final String templateId;

  const DeleteTemplate(this.templateId);

  @override
  List<Object?> get props => [templateId];
}

// States
abstract class TemplatesState extends Equatable {
  const TemplatesState();

  @override
  List<Object?> get props => [];
}

class TemplatesInitial extends TemplatesState {
  const TemplatesInitial();
}

class TemplatesLoading extends TemplatesState {
  const TemplatesLoading();
}

class TemplatesLoaded extends TemplatesState {
  final List<SessionTemplate> templates;

  const TemplatesLoaded(this.templates);

  @override
  List<Object?> get props => [templates];
}

class TemplateOperationSuccess extends TemplatesState {
  final String message;

  const TemplateOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TemplatesError extends TemplatesState {
  final String message;

  const TemplatesError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class TemplatesBloc extends Bloc<TemplatesEvent, TemplatesState> {
  final TemplateRepository templateRepository;

  TemplatesBloc({required this.templateRepository}) : super(const TemplatesInitial()) {
    on<LoadTemplates>(_onLoadTemplates);
    on<CreateTemplate>(_onCreateTemplate);
    on<UpdateTemplate>(_onUpdateTemplate);
    on<DeleteTemplate>(_onDeleteTemplate);
  }

  Future<void> _onLoadTemplates(
    LoadTemplates event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(const TemplatesLoading());

    final result = await templateRepository.getTemplates();

    result.fold(
      (failure) => emit(TemplatesError(failure.message)),
      (templates) => emit(TemplatesLoaded(templates)),
    );
  }

  Future<void> _onCreateTemplate(
    CreateTemplate event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(const TemplatesLoading());

    final result = await templateRepository.createTemplate(event.template);

    result.fold(
      (failure) => emit(TemplatesError(failure.message)),
      (_) => emit(const TemplateOperationSuccess('Template created successfully')),
    );
  }

  Future<void> _onUpdateTemplate(
    UpdateTemplate event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(const TemplatesLoading());

    final result = await templateRepository.updateTemplate(event.template);

    result.fold(
      (failure) => emit(TemplatesError(failure.message)),
      (_) => emit(const TemplateOperationSuccess('Template updated successfully')),
    );
  }

  Future<void> _onDeleteTemplate(
    DeleteTemplate event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(const TemplatesLoading());

    final result = await templateRepository.deleteTemplate(event.templateId);

    result.fold(
      (failure) => emit(TemplatesError(failure.message)),
      (_) => emit(const TemplateOperationSuccess('Template deleted successfully')),
    );
  }
}

