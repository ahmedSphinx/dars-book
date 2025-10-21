import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../models/teacher_model.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  TeacherRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<Either<Failure, bool>> isProfileComplete(String uid) async {
    try {
      final doc = await firestore.collection('teachers').doc(uid).get();
      if (!doc.exists) return const Right(false);
      final data = doc.data() as Map<String, dynamic>;
      final complete = (data['name'] ?? '').toString().isNotEmpty &&
          (data['phone'] ?? '').toString().isNotEmpty &&
          (data['subject'] ?? '').toString().isNotEmpty &&
          (data['city'] ?? '').toString().isNotEmpty;
      return Right(complete);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Teacher?>> getTeacher(String uid) async {
    try {
      final doc = await firestore.collection('teachers').doc(uid).get();
      if (!doc.exists) return const Right(null);
      final teacher = TeacherModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      return Right(teacher);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveTeacher(Teacher teacher) async {
    try {
      final uid = teacher.id.isNotEmpty ? teacher.id : (firebaseAuth.currentUser?.uid ?? '');
      if (uid.isEmpty) {
        return Left(ServerFailure('No authenticated user'));
      }
      await firestore.collection('teachers').doc(uid).set(
        TeacherModel(
          id: uid,
          name: teacher.name,
          phone: teacher.phone,
          subject: teacher.subject,
          city: teacher.city,
        ).toJson()
          ..addAll({
            'ownerId': uid,
            'updatedAt': FieldValue.serverTimestamp(),
          }),
        SetOptions(merge: true),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}



