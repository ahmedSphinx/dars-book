import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/session_template.dart';
import '../../domain/repositories/template_repository.dart';
import '../models/template_model.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  TemplateRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _userId => firebaseAuth.currentUser?.uid ?? '';

  CollectionReference get _templatesCollection =>
      firestore.collection('teachers').doc(_userId).collection('session_templates');

  @override
  Future<Either<Failure, List<SessionTemplate>>> getTemplates() async {
    try {
      final snapshot = await _templatesCollection.get();
      final templates = snapshot.docs
          .map((doc) => SessionTemplateModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
      return Right(templates);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SessionTemplate>> getTemplateById(String templateId) async {
    try {
      final doc = await _templatesCollection.doc(templateId).get();
      if (!doc.exists) {
        return Left(ServerFailure('Template not found'));
      }
      final template = SessionTemplateModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
      return Right(template);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SessionTemplate>> createTemplate(SessionTemplate template) async {
    try {
      // Validate input
      if (template.name.isEmpty) {
        return Left(ServerFailure('Template name cannot be empty'));
      }
      if (template.durationMin <= 0) {
        return Left(ServerFailure('Duration must be positive'));
      }
      if (template.weekdays.any((day) => day < 0 || day > 6)) {
        return Left(ServerFailure('Weekdays must be between 0-6'));
      }
      if (_userId.isEmpty) {
        return Left(ServerFailure('User not authenticated'));
      }

      final docRef = await _templatesCollection.add({
        'name': template.name,
        'weekdays': template.weekdays,
        'timeOfDay': template.timeOfDay,
        'durationMin': template.durationMin,
        'hasBookletDefault': template.hasBookletDefault,
        'studentIds': template.studentIds,
        'ownerId': _userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return Right(template.copyWith(id: docRef.id));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SessionTemplate>> updateTemplate(SessionTemplate template) async {
    try {
      // Validate input
      if (template.id.isEmpty) {
        return Left(ServerFailure('Template ID cannot be empty'));
      }
      if (template.name.isEmpty) {
        return Left(ServerFailure('Template name cannot be empty'));
      }
      if (template.durationMin <= 0) {
        return Left(ServerFailure('Duration must be positive'));
      }
      if (template.weekdays.any((day) => day < 0 || day > 6)) {
        return Left(ServerFailure('Weekdays must be between 0-6'));
      }
      if (_userId.isEmpty) {
        return Left(ServerFailure('User not authenticated'));
      }

      await _templatesCollection.doc(template.id).update({
        'name': template.name,
        'weekdays': template.weekdays,
        'timeOfDay': template.timeOfDay,
        'durationMin': template.durationMin,
        'hasBookletDefault': template.hasBookletDefault,
        'studentIds': template.studentIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Right(template);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTemplate(String templateId) async {
    try {
      // Validate input
      if (templateId.isEmpty) {
        return Left(ServerFailure('Template ID cannot be empty'));
      }
      if (_userId.isEmpty) {
        return Left(ServerFailure('User not authenticated'));
      }

      await _templatesCollection.doc(templateId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

