import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cyclistguesser/bloc/cyclist_guess/rider_state.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/rider.dart';
import '../../data/repositories/api_service.dart';
part 'rider_event.dart';


class RiderBloc extends Bloc<RiderEvent, RiderState> {
  final ApiService apiService;

  RiderBloc({required this.apiService}) : super(RiderInitial()) {
    on<FetchRiderEvent>(_onFetchRider);
    on<SubmitGuessEvent>(_onSubmitGuess);
  }

  Future<void> _onFetchRider(
      FetchRiderEvent event,
      Emitter<RiderState> emit,
      ) async {
    emit(RiderLoading(score: state.score));
    try {
      final rider = await apiService.fetchRandomRider();
      emit(RiderLoaded(rider, score: state.score));
    } catch (e) {
      emit(RiderError(e.toString(), score: state.score));
    }
  }

  void _onSubmitGuess(SubmitGuessEvent event, Emitter<RiderState> emit) {
    if (state is! RiderLoaded) return;

    final currentState = state as RiderLoaded;
    final isCorrect = event.guess.trim().toLowerCase() ==
        currentState.rider.name.trim().toLowerCase();

    final newScore = isCorrect ? currentState.score + 1 : currentState.score;

    emit(GuessChecked(isCorrect, currentState.rider, score: newScore));

    if (isCorrect) {
      Future.delayed(const Duration(seconds: 5), () {
        add(FetchRiderEvent());
      });
    }
  }
}