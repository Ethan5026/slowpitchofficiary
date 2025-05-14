import 'package:flutter/material.dart';
import 'package:softball_tracker/utils/constants.dart';

class RecordPhaseIndicator extends StatefulWidget {
  const RecordPhaseIndicator({super.key});

  @override
  State<StatefulWidget> createState() => RecordPhaseIndicatorState();
}

class RecordPhaseIndicatorState extends State<RecordPhaseIndicator> {
  late RecordingPhase _currentPhase = RecordingPhase.waiting;

  @override
  void initState() {
    super.initState();
  }

  void nextState() {
    final phase;
    if (_currentPhase == RecordingPhase.waiting) {
      phase = RecordingPhase.recording;
    }
    // else if (_currentPhase == RecordingPhase.recording) {
    //   phase = RecordingPhase.stopped;
    // }
    else {
      phase = RecordingPhase.waiting;
    }
    setState(() {
      _currentPhase = phase;
    });
  }

  Widget indicatorWidgetBuilder() {
    return Container(
        decoration: BoxDecoration(
            color: _currentPhase == RecordingPhase.waiting
                ? Colors.green[300]
                : Colors.red[300],
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 5)]),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Text(
                _currentPhase == RecordingPhase.waiting
                    ? "Waiting"
                    : "Recording",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.normal))));
  }

  @override
  Widget build(BuildContext context) {
    return indicatorWidgetBuilder();
  }
}
