import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/student.dart';

abstract class StudentRepository {
  /// Get all students
  Future<Either<Failure, List<Student>>> getStudents();
  
  /// Get student by id
  Future<Either<Failure, Student>> getStudentById(String studentId);
  
  /// Add new student
  Future<Either<Failure, Student>> addStudent(Student student);
  
  /// Update student
  Future<Either<Failure, Student>> updateStudent(Student student);
  
  /// Delete student
  Future<Either<Failure, void>> deleteStudent(String studentId);
  
  /// Toggle student active status
  Future<Either<Failure, Student>> toggleActiveStatus(String studentId);
  
  /// Get students by year
  Future<Either<Failure, List<Student>>> getStudentsByYear(String year);
  
  /// Search students by name
  Future<Either<Failure, List<Student>>> searchStudents(String query);
  
  /// Get overdue students (those with remaining balance)
  Future<Either<Failure, List<Student>>> getOverdueStudents();
  
  /// Get on-time students (those with no remaining balance)
  Future<Either<Failure, List<Student>>> getOnTimeStudents();
}

