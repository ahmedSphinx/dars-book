import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../../students/domain/repositories/student_repository.dart';

// Events
abstract class PaymentsEvent extends Equatable {
  const PaymentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPayments extends PaymentsEvent {
  const LoadPayments();
}

class LoadPaymentsByStudent extends PaymentsEvent {
  final String studentId;

  const LoadPaymentsByStudent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class AddPayment extends PaymentsEvent {
  final Payment payment;

  const AddPayment(this.payment);

  @override
  List<Object?> get props => [payment];
}

class DeletePayment extends PaymentsEvent {
  final String paymentId;

  const DeletePayment(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

// States
abstract class PaymentsState extends Equatable {
  const PaymentsState();

  @override
  List<Object?> get props => [];
}

class PaymentsInitial extends PaymentsState {
  const PaymentsInitial();
}

class PaymentsLoading extends PaymentsState {
  const PaymentsLoading();
}

class PaymentsLoaded extends PaymentsState {
  final List<Payment> payments;

  const PaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

class PaymentOperationSuccess extends PaymentsState {
  final String message;

  const PaymentOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentsError extends PaymentsState {
  final String message;

  const PaymentsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final PaymentRepository paymentRepository;
  final StudentRepository studentRepository;

  PaymentsBloc({
    required this.paymentRepository,
    required this.studentRepository,
  }) : super(const PaymentsInitial()) {
    on<LoadPayments>(_onLoadPayments);
    on<LoadPaymentsByStudent>(_onLoadPaymentsByStudent);
    on<AddPayment>(_onAddPayment);
    on<DeletePayment>(_onDeletePayment);
  }

  Future<void> _onLoadPayments(
    LoadPayments event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(const PaymentsLoading());

    final result = await paymentRepository.getPayments();

    result.fold(
      (failure) => emit(PaymentsError(failure.message)),
      (payments) => emit(PaymentsLoaded(payments)),
    );
  }

  Future<void> _onLoadPaymentsByStudent(
    LoadPaymentsByStudent event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(const PaymentsLoading());

    final result = await paymentRepository.getPaymentsByStudent(event.studentId);

    result.fold(
      (failure) => emit(PaymentsError(failure.message)),
      (payments) => emit(PaymentsLoaded(payments)),
    );
  }

  Future<void> _onAddPayment(
    AddPayment event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(const PaymentsLoading());

    final result = await paymentRepository.addPayment(event.payment);

    result.fold(
      (failure) => emit(PaymentsError(failure.message)),
      (_) => emit(const PaymentOperationSuccess('Payment added successfully')),
    );
  }

  Future<void> _onDeletePayment(
    DeletePayment event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(const PaymentsLoading());

    final result = await paymentRepository.deletePayment(event.paymentId);

    result.fold(
      (failure) => emit(PaymentsError(failure.message)),
      (_) => emit(const PaymentOperationSuccess('Payment deleted successfully')),
    );
  }
}

