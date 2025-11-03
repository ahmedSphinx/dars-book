import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/app_logging_services.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    AppLogging.logInfo(
      '🔍 Bloc Created: ${bloc.runtimeType}',
      name: 'BlocObserver',
    );
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    AppLogging.logInfo(
      '🔁 Bloc Change: $change',
      name: bloc.runtimeType.toString(),
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    AppLogging.logError(
      '❌ Bloc Error: $error',
      name: bloc.runtimeType.toString(),
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    AppLogging.logInfo(
      '🛑 Bloc Closed: ${bloc.runtimeType}',
      name: 'BlocObserver',
    );
    super.onClose(bloc);
  }
}
