import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';

// States
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionState {
  final Subscription? subscription;

  const SubscriptionLoaded(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionRedeemed extends SubscriptionState {
  final Subscription subscription;

  const SubscriptionRedeemed(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

// Events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscription extends SubscriptionEvent {
  const LoadSubscription();
}

class RedeemSubscriptionVoucher extends SubscriptionEvent {
  final String voucherCode;
  const RedeemSubscriptionVoucher(this.voucherCode);

  @override
  List<Object?> get props => [voucherCode];
}

class WatchSubscriptionStarted extends SubscriptionEvent {
  const WatchSubscriptionStarted();
}

// Bloc
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository subscriptionRepository;

  SubscriptionBloc({required this.subscriptionRepository}) : super(const SubscriptionInitial()) {
    on<LoadSubscription>(_onLoadSubscription);
    on<RedeemSubscriptionVoucher>(_onRedeemVoucher);
    on<WatchSubscriptionStarted>(_onWatchSubscriptionStarted);
  }

  Future<void> _onLoadSubscription(
    LoadSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    final result = await subscriptionRepository.getSubscriptionStatus();
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscription) => emit(SubscriptionLoaded(subscription)),
    );
  }

  Future<void> _onRedeemVoucher(
    RedeemSubscriptionVoucher event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    final result = await subscriptionRepository.redeemVoucher(event.voucherCode);
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscription) => emit(SubscriptionRedeemed(subscription)),
    );
  }

  Future<void> _onWatchSubscriptionStarted(
    WatchSubscriptionStarted event,
    Emitter<SubscriptionState> emit,
  ) async {
    await emit.forEach<Subscription?>(
      subscriptionRepository.watchSubscription(),
      onData: (subscription) => SubscriptionLoaded(subscription),
      onError: (_, __) => const SubscriptionError('Failed to watch subscription'),
    );
  }
}



