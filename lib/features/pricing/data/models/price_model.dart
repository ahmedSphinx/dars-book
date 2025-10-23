import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/price.dart';

class PriceModel extends Price {
  const PriceModel({
    required super.year,
    required super.lessonPrice,
    required super.bookletPrice,
    required super.updatedAt,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json, String year) {
    try {
      // Validate required fields
      if (!json.containsKey('lessonPrice') || !json.containsKey('bookletPrice')) {
        throw FormatException('Missing required price fields');
      }

      final lessonPrice = (json['lessonPrice'] as num).toDouble();
      final bookletPrice = (json['bookletPrice'] as num).toDouble();
      
      // Validate price values
      if (lessonPrice < 0 || bookletPrice < 0) {
        throw FormatException('Prices cannot be negative');
      }

      DateTime updatedAt;
      if (json['updatedAt'] != null) {
        if (json['updatedAt'] is Timestamp) {
          updatedAt = (json['updatedAt'] as Timestamp).toDate();
        } else {
          updatedAt = DateTime.parse(json['updatedAt'].toString());
        }
      } else {
        updatedAt = DateTime.now();
      }

      return PriceModel(
        year: year,
        lessonPrice: lessonPrice,
        bookletPrice: bookletPrice,
        updatedAt: updatedAt,
      );
    } catch (e) {
      throw FormatException('Invalid price data: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonPrice': lessonPrice,
      'bookletPrice': bookletPrice,
      'updatedAt': updatedAt,
    };
  }
}

