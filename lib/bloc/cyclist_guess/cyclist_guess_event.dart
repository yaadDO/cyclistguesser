part of 'cyclist_guess_bloc.dart';


abstract class CyclistGuessEvent extends Equatable {
  const CyclistGuessEvent();

  @override
  List<Object> get props => [];
}

class LoadRandomCyclist extends CyclistGuessEvent {}
class SubmitGuess extends CyclistGuessEvent {
  final String guess;

  const SubmitGuess(this.guess);
}
