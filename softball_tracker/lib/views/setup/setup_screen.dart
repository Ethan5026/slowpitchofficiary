import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softball_tracker/utils/constants.dart';


class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SetupScreenState();

}

class _SetupScreenState extends State<SetupScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      return const Scaffold(
          body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(
              style: TextStyle(fontSize: 30),
              "This is the setup screen")]),
          ]
          )
      );
  }
}
