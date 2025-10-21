import '../../domain/entities/price.dart';

class PriceModel extends Price {
  const PriceModel({
    required super.year,
    required super.lessonPrice,
    required super.bookletPrice,
    required super.updatedAt,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json, String year) {
    return PriceModel(
      year: year,
      lessonPrice: (json['lessonPrice'] as num).toDouble(),
      bookletPrice: (json['bookletPrice'] as num).toDouble(),
      updatedAt: (json['updatedAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonPrice': lessonPrice,
      'bookletPrice': bookletPrice,
      'updatedAt': updatedAt,
    };
  }
}

