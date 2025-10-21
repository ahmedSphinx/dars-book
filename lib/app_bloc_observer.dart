import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    dev.log(
      '🔍 Bloc Created: ${bloc.runtimeType}',
      name: 'BlocObserver',
    );
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    dev.log(
      '🔁 Bloc Change: $change',
      name: bloc.runtimeType.toString(),
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    dev.log(
      '❌ Bloc Error: $error',
      name: bloc.runtimeType.toString(),
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    dev.log(
      '🛑 Bloc Closed: ${bloc.runtimeType}',
      name: 'BlocObserver',
    );
    super.onClose(bloc);
  }
}
