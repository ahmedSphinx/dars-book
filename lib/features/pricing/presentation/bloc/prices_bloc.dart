import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/price.dart';
import '../../domain/repositories/price_repository.dart';

// Events
abstract class PricesEvent extends Equatable {
  const PricesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrices extends PricesEvent {
  const LoadPrices();
}

class LoadPriceByYear extends PricesEvent {
  final String year;

  const LoadPriceByYear(this.year);

  @override
  List<Object?> get props => [year];
}

class SetYearPrice extends PricesEvent {
  final Price price;

  const SetYearPrice(this.price);

  @override
  List<Object?> get props => [price];
}

class SetStudentCustomPrice extends PricesEvent {
  final String studentId;
  final double? lessonPrice;
  final double? bookletPrice;

  const SetStudentCustomPrice({
    required this.studentId,
    this.lessonPrice,
    this.bookletPrice,
  });

  @override
  List<Object?> get props => [studentId, lessonPrice, bookletPrice];
}

class ClearStudentCustomPrice extends PricesEvent {
  final String studentId;

  const ClearStudentCustomPrice(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

// States
abstract class PricesState extends Equatable {
  const PricesState();

  @override
  List<Object?> get props => [];
}

class PricesInitial extends PricesState {
  const PricesInitial();
}

class PricesLoading extends PricesState {
  const PricesLoading();
}

class PricesLoaded extends PricesState {
  final List<Price> prices;

  const PricesLoaded(this.prices);

  @override
  List<Object?> get props => [prices];
}

class PriceOperationSuccess extends PricesState {
  final String message;

  const PriceOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PricesError extends PricesState {
  final String message;

  const PricesError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PricesBloc extends Bloc<PricesEvent, PricesState> {
  final PriceRepository priceRepository;

  PricesBloc({required this.priceRepository}) : super(const PricesInitial()) {
    on<LoadPrices>(_onLoadPrices);
    on<LoadPriceByYear>(_onLoadPriceByYear);
    on<SetYearPrice>(_onSetYearPrice);
    on<SetStudentCustomPrice>(_onSetStudentCustomPrice);
    on<ClearStudentCustomPrice>(_onClearStudentCustomPrice);
  }

  Future<void> _onLoadPrices(
    LoadPrices event,
    Emitter<PricesState> emit,
  ) async {
    emit(const PricesLoading());

    final result = await priceRepository.getAllPrices();

    result.fold(
      (failure) => emit(PricesError(failure.message)),
      (prices) => emit(PricesLoaded(prices)),
    );
  }

  Future<void> _onLoadPriceByYear(
    LoadPriceByYear event,
    Emitter<PricesState> emit,
  ) async {
    emit(const PricesLoading());

    final result = await priceRepository.getPriceByYear(event.year);

    result.fold(
      (failure) => emit(PricesError(failure.message)),
      (price) => emit(PricesLoaded([price])),
    );
  }

  Future<void> _onSetYearPrice(
    SetYearPrice event,
    Emitter<PricesState> emit,
  ) async {
    emit(const PricesLoading());

    final result = await priceRepository.setYearPrice(event.price);

    result.fold(
      (failure) => emit(PricesError(failure.message)),
      (_) {
        emit(const PriceOperationSuccess('تم تحديث الأسعار بنجاح'));
        // Refresh prices after successful update
        add(const LoadPrices());
      },
    );
  }

  Future<void> _onSetStudentCustomPrice(
    SetStudentCustomPrice event,
    Emitter<PricesState> emit,
  ) async {
    emit(const PricesLoading());

    final result = await priceRepository.setStudentCustomPrice(
      studentId: event.studentId,
      lessonPrice: event.lessonPrice,
      bookletPrice: event.bookletPrice,
    );

    result.fold(
      (failure) => emit(PricesError(failure.message)),
      (_) => emit(const PriceOperationSuccess('تم تعيين السعر المخصص بنجاح')),
    );
  }

  Future<void> _onClearStudentCustomPrice(
    ClearStudentCustomPrice event,
    Emitter<PricesState> emit,
  ) async {
    emit(const PricesLoading());

    final result = await priceRepository.clearStudentCustomPrice(event.studentId);

    result.fold(
      (failure) => emit(PricesError(failure.message)),
      (_) => emit(const PriceOperationSuccess('تم مسح السعر المخصص بنجاح')),
    );
  }
}

