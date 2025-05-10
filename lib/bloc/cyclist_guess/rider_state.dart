import 'package:equatable/equatable.dart';

import '../../data/models/rider.dart';

abstract class RiderState extends Equatable {
  final int score;
  const RiderState({this.score = 0});

  @override
  List<Object> get props => [score];
}

class RiderInitial extends RiderState {
  const RiderInitial({super.score});
}

class RiderLoading extends RiderState {
  const RiderLoading({super.score});
}

class RiderLoaded extends RiderState {
  final Rider rider;
  const RiderLoaded(this.rider, {super.score});

  @override
  List<Object> get props => [rider, score];
}

class GuessChecked extends RiderState {
  final bool isCorrect;
  final Rider rider;
  const GuessChecked(this.isCorrect, this.rider, {super.score});

  @override
  List<Object> get props => [isCorrect, rider, score];
}

class RiderError extends RiderState {
  final String message;

  const RiderError(this.message, {super.score});

  @override
  List<Object> get props => [message, score];
}