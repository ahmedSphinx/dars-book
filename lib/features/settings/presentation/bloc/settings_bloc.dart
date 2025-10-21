import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/settings_repository.dart';



abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class SetThemeModeEvent extends SettingsEvent {
  final ThemeMode mode;

  const SetThemeModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SetLanguageEvent extends SettingsEvent {
  final String languageCode;

  const SetLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class SetAnimationsEnabledEvent extends SettingsEvent {
  final bool enabled;

  const SetAnimationsEnabledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SetHapticsEnabledEvent extends SettingsEvent {
  final bool enabled;

  const SetHapticsEnabledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SetBiometricEnabledEvent extends SettingsEvent {
  final bool enabled;

  const SetBiometricEnabledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SetPinEnabledEvent extends SettingsEvent {
  final bool enabled;

  const SetPinEnabledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SetPinEvent extends SettingsEvent {
  final String pin;

  const SetPinEvent(this.pin);

  @override
  List<Object?> get props => [pin];
}

class ClearPinEvent extends SettingsEvent {}

// States
class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final String language;
  final bool animationsEnabled;
  final bool hapticsEnabled;
  final bool biometricEnabled;
  final bool pinEnabled;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.language = 'ar',
    this.animationsEnabled = true,
    this.hapticsEnabled = true,
    this.biometricEnabled = false,
    this.pinEnabled = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? animationsEnabled,
    bool? hapticsEnabled,
    bool? biometricEnabled,
    bool? pinEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      pinEnabled: pinEnabled ?? this.pinEnabled,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        language,
        animationsEnabled,
        hapticsEnabled,
        biometricEnabled,
        pinEnabled,
      ];
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc({required this.settingsRepository}) : super(const SettingsState()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<SetThemeModeEvent>(_onSetThemeMode);
    on<SetLanguageEvent>(_onSetLanguage);
    on<SetAnimationsEnabledEvent>(_onSetAnimationsEnabled);
    on<SetHapticsEnabledEvent>(_onSetHapticsEnabled);
    on<SetBiometricEnabledEvent>(_onSetBiometricEnabled);
    on<SetPinEnabledEvent>(_onSetPinEnabled);
    on<SetPinEvent>(_onSetPin);
    on<ClearPinEvent>(_onClearPin);

    add(LoadSettingsEvent());
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsState(
      themeMode: settingsRepository.getThemeMode(),
      language: settingsRepository.getLanguage(),
      animationsEnabled: settingsRepository.getAnimationsEnabled(),
      hapticsEnabled: settingsRepository.getHapticsEnabled(),
      biometricEnabled: settingsRepository.getBiometricEnabled(),
      pinEnabled: settingsRepository.getPinEnabled(),
    ));
  }

  Future<void> _onSetThemeMode(
    SetThemeModeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await settingsRepository.setThemeMode(event.mode);
    emit(state.copyWith(themeMode: event.mode));
  }

  Future<void> _onSetLanguage(
    SetLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await settingsRepository.setLanguage(event.languageCode);
    emit(state.copyWith(language: event.languageCode));
  }

  Future<void> _onSetAnimationsEnabled(
    SetAnimationsEnabledEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await settingsRepository.setAnimationsEnabled(event.enabled);
    emit(state.copyWith(animationsEnabled: event.enabled));
  }

  Future<void> _onSetHapticsEnabled(
    SetHapticsEnabledEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await settingsRepository.setHapticsEnabled(event.enabled);
    emit(state.copyWith(hapticsEnabled: event.enabled));
  }

  Future<void> _onSetBiometricEnabled(
    SetBiometricEnabledEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await settingsRepository.setBiometricEnabled(event.enabled);
    emit(state.copyWith(biometricEnabled: event.enabled));
  }

  Future<void> _onSetPinEnabled(
    SetPinEnabledEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await settingsRepository.setPinEnabled(event.enabled);
    emit(state.copyWith(pinEnabled: event.enabled));
  }

  Future<void> _onSetPin(
    SetPinEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await settingsRepository.setPin(event.pin);
    await settingsRepository.setPinEnabled(true);
    emit(state.copyWith(pinEnabled: true));
  }

  Future<void> _onClearPin(
    ClearPinEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await settingsRepository.clearPin();
    await settingsRepository.setPinEnabled(false);
    emit(state.copyWith(pinEnabled: false));
  }
}

