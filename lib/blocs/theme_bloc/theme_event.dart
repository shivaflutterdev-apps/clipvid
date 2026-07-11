import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ThemeToggleEvent extends ThemeEvent {}

class ThemeSetDarkEvent extends ThemeEvent {}

class ThemeSetLightEvent extends ThemeEvent {}
