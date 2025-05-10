part of 'rider_bloc.dart';

abstract class RiderEvent extends Equatable {
  const RiderEvent();

  @override
  List<Object> get props => [];
}

class FetchRiderEvent extends RiderEvent {}

class SubmitGuessEvent extends RiderEvent {
  final String guess;

  const SubmitGuessEvent(this.guess);

  @override
  List<Object> get props => [guess];
}

class LoadCyclistsEvent extends RiderEvent {
  final List<String> cyclists;

  LoadCyclistsEvent(this.cyclists);

  @override
  List<Object> get props => [cyclists];
}