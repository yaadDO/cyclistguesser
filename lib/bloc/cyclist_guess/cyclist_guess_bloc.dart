import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/cyclist.dart';
import '../../data/repositories/cyclist_repository.dart';
part 'cyclist_guess_event.dart';
part 'cyclist_guess_state.dart';

class CyclistGuessBloc extends Bloc<CyclistGuessEvent, CyclistGuessState> {
  final CyclistRepository repository;

  CyclistGuessBloc({required this.repository}) : super(CyclistGuessInitial()) {
    on<LoadRandomCyclist>(_onLoadRandomCyclist);
    on<SubmitGuess>(_onSubmitGuess);
  }

  Future<void> _onLoadRandomCyclist(
      LoadRandomCyclist event,
      Emitter<CyclistGuessState> emit,
      ) async {
    emit(Loading());
    try {
      final cyclist = await repository.fetchRandomCyclist();
      emit(Loaded(cyclist));
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  void _onSubmitGuess(
      SubmitGuess event,
      Emitter<CyclistGuessState> emit,
      ) {
    final currentState = state;
    if (currentState is Loaded) {
      if (event.guess.toLowerCase() == currentState.cyclist.name.toLowerCase()) {
        emit(GuessCorrect());
      } else {
        emit(GuessIncorrect());
      }
    }
  }
}