import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeDataState extends ThemeState {
  final ThemeMode themeMode;

  const ThemeDataState(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class ThemeErrorState extends ThemeState {
  final String message;

  const ThemeErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
