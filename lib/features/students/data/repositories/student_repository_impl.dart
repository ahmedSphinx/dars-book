import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  StudentRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _userId => firebaseAuth.currentUser?.uid ?? '';

  CollectionReference get _studentsCollection =>
      firestore.collection('teachers').doc(_userId).collection('students');

  @override
  Future<Either<Failure, List<Student>>> getStudents() async {
    try {
      final snapshot = await _studentsCollection.get();
      final students = snapshot.docs
          .map((doc) => StudentModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Student>> getStudentById(String studentId) async {
    try {
      final doc = await _studentsCollection.doc(studentId).get();
      if (!doc.exists) {
        return Left(ServerFailure('Student not found'));
      }
      final student = StudentModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
      return Right(student);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Student>> addStudent(Student student) async {
    try {
      final docRef = await _studentsCollection.add({
        'name': student.name,
        'phone': student.phone,
        'year': student.year,
        'notes': student.notes,
        'isActive': student.isActive,
        'customLessonPrice': student.customLessonPrice,
        'customBookletPrice': student.customBookletPrice,
        'aggregates': {
          'sessionsCount': 0,
          'bookletsCount': 0,
          'totalCharges': 0.0,
          'totalPaid': 0.0,
          'remaining': 0.0,
        },
        'ownerId': _userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final newStudent = student.copyWith(id: docRef.id);
      return Right(newStudent);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Student>> updateStudent(Student student) async {
    try {
      await _studentsCollection.doc(student.id).update({
        'name': student.name,
        'phone': student.phone,
        'year': student.year,
        'notes': student.notes,
        'isActive': student.isActive,
        'customLessonPrice': student.customLessonPrice,
        'customBookletPrice': student.customBookletPrice,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Right(student);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStudent(String studentId) async {
    try {
      await _studentsCollection.doc(studentId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Student>> toggleActiveStatus(String studentId) async {
    try {
      final doc = await _studentsCollection.doc(studentId).get();
      if (!doc.exists) {
        return Left(ServerFailure('Student not found'));
      }

      final student = StudentModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      final updatedStudent = student.copyWith(isActive: !student.isActive);

      await _studentsCollection.doc(studentId).update({
        'isActive': updatedStudent.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Right(updatedStudent);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getStudentsByYear(String year) async {
    try {
      final snapshot = await _studentsCollection
          .where('year', isEqualTo: year)
          .get();
      final students = snapshot.docs
          .map((doc) => StudentModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> searchStudents(String query) async {
    try {
      // Use Firestore query for better performance
      // This requires a composite index on 'name' field
      final snapshot = await _studentsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();
      
      final students = snapshot.docs
          .map((doc) => StudentModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .where((student) =>
              student.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return Right(students);
    } catch (e) {
      // Fallback to client-side filtering if Firestore query fails
      try {
        final snapshot = await _studentsCollection.get();
        final students = snapshot.docs
            .map((doc) => StudentModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .where((student) =>
                student.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return Right(students);
      } catch (fallbackError) {
        return Left(ServerFailure(fallbackError.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getOverdueStudents() async {
    try {
      final snapshot = await _studentsCollection
          .where('aggregates.remaining', isGreaterThan: 0)
          .get();
      final students = snapshot.docs
          .map((doc) => StudentModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getOnTimeStudents() async {
    try {
      final snapshot = await _studentsCollection
          .where('aggregates.remaining', isEqualTo: 0)
          .get();
      final students = snapshot.docs
          .map((doc) => StudentModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

