part of 'cyclist_guess_bloc.dart';

abstract class CyclistGuessState extends Equatable {
  const CyclistGuessState();

  @override
  List<Object> get props => [];
}

class CyclistGuessInitial extends CyclistGuessState {}
class Loading extends CyclistGuessState {}
class Loaded extends CyclistGuessState {
  final Cyclist cyclist;

  const Loaded(this.cyclist);
}
class GuessCorrect extends CyclistGuessState {}
class GuessIncorrect extends CyclistGuessState {}
class ErrorState extends CyclistGuessState {
  final String message;

  const ErrorState(this.message);
}