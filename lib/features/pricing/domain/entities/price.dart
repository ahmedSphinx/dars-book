import 'package:equatable/equatable.dart';

class Price extends Equatable {
  final String year;
  final double lessonPrice;
  final double bookletPrice;
  final DateTime updatedAt;

  const Price({
    required this.year,
    required this.lessonPrice,
    required this.bookletPrice,
    required this.updatedAt,
  });

  Price copyWith({
    String? year,
    double? lessonPrice,
    double? bookletPrice,
    DateTime? updatedAt,
  }) {
    return Price(
      year: year ?? this.year,
      lessonPrice: lessonPrice ?? this.lessonPrice,
      bookletPrice: bookletPrice ?? this.bookletPrice,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [year, lessonPrice, bookletPrice, updatedAt];
}

