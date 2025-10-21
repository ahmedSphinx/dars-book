import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/session_template.dart';

abstract class TemplateRepository {
  /// Get all templates
  Future<Either<Failure, List<SessionTemplate>>> getTemplates();
  
  /// Get template by id
  Future<Either<Failure, SessionTemplate>> getTemplateById(String templateId);
  
  /// Create new template
  Future<Either<Failure, SessionTemplate>> createTemplate(SessionTemplate template);
  
  /// Update template
  Future<Either<Failure, SessionTemplate>> updateTemplate(SessionTemplate template);
  
  /// Delete template
  Future<Either<Failure, void>> deleteTemplate(String templateId);
}

