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

  /// Factory constructor with validation
  factory Price.create({
    required String year,
    required double lessonPrice,
    required double bookletPrice,
    DateTime? updatedAt,
  }) {
    if (year.isEmpty) {
      throw ArgumentError('Year cannot be empty');
    }
    if (lessonPrice < 0) {
      throw ArgumentError('Lesson price cannot be negative');
    }
    if (bookletPrice < 0) {
      throw ArgumentError('Booklet price cannot be negative');
    }
    
    return Price(
      year: year,
      lessonPrice: lessonPrice,
      bookletPrice: bookletPrice,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

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

  /// Get total price for a lesson and booklet
  double get totalPrice => lessonPrice + bookletPrice;

  /// Check if prices are valid (positive values)
  bool get isValid => lessonPrice > 0 && bookletPrice > 0;

  /// Get formatted lesson price
  String get formattedLessonPrice => '${lessonPrice.toStringAsFixed(2)} ج.م';

  /// Get formatted booklet price
  String get formattedBookletPrice => '${bookletPrice.toStringAsFixed(2)} ج.م';

  /// Get formatted total price
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(2)} ج.م';

  /// Check if this price is newer than another
  bool isNewerThan(Price other) => updatedAt.isAfter(other.updatedAt);

  /// Get price difference with another price
  PriceDifference getDifference(Price other) {
    return PriceDifference(
      lessonPriceDiff: lessonPrice - other.lessonPrice,
      bookletPriceDiff: bookletPrice - other.bookletPrice,
    );
  }
}

/// Represents the difference between two prices
class PriceDifference extends Equatable {
  final double lessonPriceDiff;
  final double bookletPriceDiff;

  const PriceDifference({
    required this.lessonPriceDiff,
    required this.bookletPriceDiff,
  });

  double get totalDiff => lessonPriceDiff + bookletPriceDiff;

  bool get hasIncrease => totalDiff > 0;
  bool get hasDecrease => totalDiff < 0;
  bool get isSame => totalDiff == 0;

  @override
  List<Object?> get props => [lessonPriceDiff, bookletPriceDiff];
}

