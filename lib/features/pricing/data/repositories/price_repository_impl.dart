import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/price.dart';
import '../../domain/repositories/price_repository.dart';
import '../models/price_model.dart';

class PriceRepositoryImpl implements PriceRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  PriceRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _userId => firebaseAuth.currentUser?.uid ?? '';

  CollectionReference get _pricesCollection =>
      firestore.collection('teachers').doc(_userId).collection('prices');

  CollectionReference get _studentsCollection =>
      firestore.collection('teachers').doc(_userId).collection('students');

  @override
  Future<Either<Failure, List<Price>>> getAllPrices() async {
    try {
      final snapshot = await _pricesCollection.get();
      final prices = snapshot.docs
          .map((doc) => PriceModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
      return Right(prices);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Price>> getPriceByYear(String year) async {
    try {
      final doc = await _pricesCollection.doc(year).get();
      if (!doc.exists) {
        return Left(ServerFailure('Price not found for year $year'));
      }
      final price = PriceModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
      return Right(price);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Price>> setYearPrice(Price price) async {
    try {
      await _pricesCollection.doc(price.year).set({
        'lessonPrice': price.lessonPrice,
        'bookletPrice': price.bookletPrice,
        'updatedAt': FieldValue.serverTimestamp(),
        'ownerId': _userId,
      });
      return Right(price.copyWith(updatedAt: DateTime.now()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setStudentCustomPrice({
    required String studentId,
    double? lessonPrice,
    double? bookletPrice,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (lessonPrice != null) {
        updateData['customLessonPrice'] = lessonPrice;
      }
      if (bookletPrice != null) {
        updateData['customBookletPrice'] = bookletPrice;
      }

      await _studentsCollection.doc(studentId).update(updateData);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearStudentCustomPrice(String studentId) async {
    try {
      await _studentsCollection.doc(studentId).update({
        'customLessonPrice': FieldValue.delete(),
        'customBookletPrice': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

