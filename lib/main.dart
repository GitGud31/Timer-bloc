import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer_bloc/bloc/timer_bloc.dart';
import 'package:timer_bloc/ui/wave.dart';
import 'package:timer_bloc/util/ticker.dart';

void main() => runApp(MyApp());

/* MyApp is a StatelessWidget which will manage initializing 
and closing an instance of TimerBloc. In addition, 
it’s using the BlocProvider widget in order to make our 
TimerBloc instance available to the widgets in our subtree*/
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => TimerBloc(ticker: Ticker()),
        /* Timer widget will be responsible for displaying 
        the remaining time along with the proper buttons 
        which will enable users to start, pause, 
        and reset the timer. */
        child: Timer(),
      ),
      theme: ThemeData(
        primaryColor: Colors.indigo,
        accentColor: Color.fromRGBO(72, 74, 126, 1),
        brightness: Brightness.dark,
      ),
      title: 'Timer BLoC',
    );
  }
}

class Timer extends StatelessWidget {
  static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );

  /* BlocProvider to access the instance of our TimerBloc 
  and using a BlocBuilder widget in order to rebuild 
  the UI every time we get a new TimerState */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blue[50],
        title: Text(
          'Timer BLoC',
          style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Wave(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 100.0),
                child: Center(
                  child: BlocBuilder<TimerBloc, TimerState>(
                      builder: (context, state) {
                    final String minutesStr = ((state.duration / 60) % 60)
                        .floor()
                        .toString()
                        .padLeft(2, '0');
                    final String secondsStr = (state.duration % 60)
                        .floor()
                        .toString()
                        .padLeft(2, '0');
                    return Text(
                      '$minutesStr:$secondsStr',
                      style: Timer.timerTextStyle,
                    );
                  }),
                ),
              ),

              /* Another BlocBuilder which will render the Actions widget; 
              Using flutter_bloc feature to control how frequently 
              the Actions widget is rebuilt  */

              /*fine-grained control over when the builder function is called 
              Use the provided OPTIONAL 'condition' to BlocBuilder.
              The condition takes the previous bloc state and 
              current bloc state and returns a boolean. 
              If condition returns true, builder will be called with 
              state and the widget will rebuild. If condition returns 
              false, builder will not be called with state and no rebuild will occur.*/

              BlocBuilder<TimerBloc, TimerState>(
                condition: (previousState, state) =>
                    state.runtimeType != previousState.runtimeType,
                builder: (context, state) => Actions(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* The Actions widget is just another StatelessWidget which 
uses BlocProvider to access the TimerBloc instance and then 
returns different FloatingActionButtons based on the current 
state of the TimerBloc. Each of the FloatingActionButtons 
adds an event in its onPressed callback to notify the 
TimerBloc. */

class Actions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _mapToActionButtons(
        timerBloc: BlocProvider.of<TimerBloc>(context),
      ),
    );
  }

  List<Widget> _mapToActionButtons({TimerBloc timerBloc}) {
    final TimerState currentState = timerBloc.state;
    if (currentState is Ready) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () => timerBloc.add(
            Start(duration: currentState.duration),
          ),
        ),
      ];
    }
    if (currentState is Running) {
      return [
        FloatingActionButton(
            child: Icon(Icons.pause), onPressed: () => timerBloc.add(Pause())),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(Reset()),
        ),
      ];
    }
    if (currentState is Paused) {
      return [
        FloatingActionButton(
            child: Icon(Icons.play_arrow),
            onPressed: () => timerBloc.add(Resume())),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(Reset()),
        ),
      ];
    }
    if (currentState is Finished) {
      return [
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(Reset()),
        ),
      ];
    }
    return [];
  }
}
