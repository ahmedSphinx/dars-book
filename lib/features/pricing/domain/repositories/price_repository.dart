import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/price.dart';

abstract class PriceRepository {
  /// Get all year prices
  Future<Either<Failure, List<Price>>> getAllPrices();
  
  /// Get price by year
  Future<Either<Failure, Price>> getPriceByYear(String year);
  
  /// Set or update year price
  Future<Either<Failure, Price>> setYearPrice(Price price);
  
  /// Set custom price for student
  Future<Either<Failure, void>> setStudentCustomPrice({
    required String studentId,
    double? lessonPrice,
    double? bookletPrice,
  });
  
  /// Clear custom price for student
  Future<Either<Failure, void>> clearStudentCustomPrice(String studentId);
}

