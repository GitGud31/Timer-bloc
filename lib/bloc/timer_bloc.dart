import 'dart:async';

export 'timer_bloc.dart';
//export 'timer_event.dart';
//export 'timer_state.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:timer_bloc/util/ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final int _duration = 5;
  final Ticker _ticker;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker;

  @override
  TimerState get initialState => Ready(_duration);

  @override
  void onTransition(Transition<TimerEvent, TimerState> transition) {
    super.onTransition(transition);
    print(transition);
  }

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    if (event is Start) {
      yield* _mapStartToState(event);
    } else if (event is Tick) {
      yield* _mapTickToState(event);
    } else if (event is Pause) {
      yield* _mapPauseToState(event);
    } else if (event is Resume) {
      yield* _mapResumeToState(event);
    } else if (event is Reset) {
      yield* _mapResetToState(event);
    }
  }

  /* override the close method on our TimerBloc so that we can cancel 
  the _tickerSubscription when the TimerBloc is closed */
  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  //Start Handler
  Stream<TimerState> _mapStartToState(Start start) async* {
    /* If the TimerBloc receives a Start event, it pushes a Running state with the start duration */
    yield Running(start.duration);
    /* if there was already an open _tickerSubscription we need to cancel it to deallocate the memory. */
    _tickerSubscription?.cancel();
    /* listen to the _ticker.tick stream and on every tick we add a Tick event with the remaining duration. */
    _tickerSubscription = _ticker
        .tick(ticks: start.duration)
        .listen((duration) => add(Tick(duration: duration)));
  }

  //Running Handler
  Stream<TimerState> _mapTickToState(Tick tick) async* {
    yield tick.duration > 0 ? Running(tick.duration) : Finished();
  }

  //Pause Handler
  Stream<TimerState> _mapPauseToState(Pause pause) async* {
    /* if the state of our TimerBloc 
    is Running, then pause the _tickerSubscription 
    and push a Paused state with the current timer duration. */
    if (state is Running) {
      _tickerSubscription?.pause();
      yield Paused(state.duration);
    }
  }

  //ResumeHandler
  Stream<TimerState> _mapResumeToState(Resume resume) async* {
    /* If the TimerBloc has a state of Paused and it receives a Resume event, 
    then it resumes the _tickerSubscription and pushes a Running state with the current duration. */
    if (state is Paused) {
      _tickerSubscription?.resume();
      yield Running(state.duration);
    }
  }

  //Reset Handler
  Stream<TimerState> _mapResetToState(Reset reset) async* {
    /* If the TimerBloc receives a Reset event, it needs to cancel the current 
    _tickerSubscription so that it isn’t notified of any additional ticks and pushes 
    a Ready state with the original duration. */
    _tickerSubscription?.cancel();
    yield Ready(_duration);
  }
}
