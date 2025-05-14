import 'package:bulleted_list/bulleted_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softball_tracker/widgets/expandable_stepper.dart';

import '../../utils/expansion_tile.dart';

class SetupCameraInstructionsScreen extends StatefulWidget {
  const SetupCameraInstructionsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SetupCameraInstructionsScreenState();
}

class _SetupCameraInstructionsScreenState
    extends State<SetupCameraInstructionsScreen> {
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
    List<ExpansionTileContent> expansionStepper = [];
    ExpansionTileContent expandedStep1 = ExpansionTileContent(
        const Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              "Step 1:"),
          Text(
              style: TextStyle(
                fontSize: 20,
              ),
              "  Place The Camera")
        ]),
        Container(),
        const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              const Text(
                  style: TextStyle(fontSize: 20),
                  "Place your camera following the specifications below:"),
              const BulletedList(
                  bulletColor: Colors.deepPurple,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold),
                  listItems: [
                    "Must have the home plate and pitcher's mound in camera view.",
                    "Home plate and pitcher's mound must be horizontally aligned.",
                    "Must be equidistant from the home plate and the pitcher's mound.",
                    "Must be protected from potential damages beyond the foul line."
                  ]),
              const Image(image: AssetImage('assets/images/camera_placement.png')),
              const Text(
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  "You should not move the camera mount's position once calibrated."
                  " Moving the camera will compromise the accuracy."),
            ]));

    ExpansionTileContent expandedStep2 = ExpansionTileContent(
        const Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              "Step 2:"),
          Text(
              style: TextStyle(
                fontSize: 20,
              ),
              "  Capture The Field")
        ]),
        Container(),
        const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              Text(
                  style: TextStyle(fontSize: 20),
                  "You will mark three points of the field with the softball"),
              BulletedList(
                  bulletColor: Colors.deepPurple,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold),
                  listItems: [
                    "The softball should be placed on home plate",
                    "The softball should be held at the reference height above home plate",
                    "The softball should be placed on the pitchers mound.",
                  ]),

              Text(
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  "Each capture will be taken with a 15 second countdown. "
                  "Move the softball during the countdown process.")
            ]));


    return Scaffold(
        appBar: AppBar(
          title: const Text("Setup Camera Instructions"),
        ),
        body: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 20,
                      children: [
                        const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                                  "Our Accuracy Relies On A Proper Setup")
                            ]),
                        ExpandableStepper(tiles: [expandedStep1, expandedStep2], exitFunction: () {
                          Navigator.pushNamed(context,
                              '/setupScreen/setupValues');
                        })
                      ])
                ])));
  }
}
