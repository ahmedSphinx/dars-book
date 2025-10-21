import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/teacher.dart';

abstract class TeacherRepository {
  Future<Either<Failure, bool>> isProfileComplete(String uid);
  Future<Either<Failure, Teacher?>> getTeacher(String uid);
  Future<Either<Failure, void>> saveTeacher(Teacher teacher);
}



