import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class Wave extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: CustomConfig(
        durations: [19440, 10800, 6000],
        heightPercentages: [0.03, 0.04, 0.02],
        gradientBegin: Alignment.bottomCenter,
        gradientEnd: Alignment.topCenter,
        gradients: [
          [
            Color.fromRGBO(58, 203, 232, 1),
            Color.fromRGBO(58, 203, 232, 1),
            Color.fromRGBO(58, 203, 232, 0.7)
          ],
          [
            Color.fromRGBO(58, 203, 232, 1),
            Color.fromRGBO(58, 232, 81, 1),
            Color.fromRGBO(58, 203, 232, 0.7)
          ],
          [
            Color.fromRGBO(230, 184, 60, 1),
            Color.fromRGBO(212, 52, 44, 1),
            Color.fromRGBO(172, 182, 219, 0.7)
          ],
        ],
      ),
      size: Size(double.infinity, double.infinity),
      waveAmplitude: 25,
      backgroundColor: Colors.blue[50],
    );
  }
}
