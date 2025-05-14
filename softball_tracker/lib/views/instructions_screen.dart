import 'package:bulleted_list/bulleted_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:softball_tracker/utils/constants.dart';


class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _InstructionsScreenState();

}

class _InstructionsScreenState extends State<InstructionsScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Instructions"),
      ),
        body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),
            Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    style: TextStyle(fontSize: 40, color: Colors.deepPurple, fontWeight: FontWeight.bold),

                    "Our Accuracy Relies On A Proper Setup")]),
            Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),
            ExpansionTile(
                title: Text(
                    style: TextStyle(fontSize: 30,),
                    "How it works:"),
                subtitle: Text(
                    style: TextStyle(fontSize: 23,),
                    "The Math Behind the Madness"),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 30,
                    children: [
                      Text(
                        style: TextStyle(fontSize: 20),
                      "First you must identify the home plate and pitcher's "
                          "mound from your camera to identify the ground below the pitch."
                      ),
                      Text(
                          style: TextStyle(fontSize: 20),
                          "Secondly we use an identified known height above both the home plate and pitcher's "
                              "mound. We now know the amount of pixels per feet."
                      ),
                      Text(
                          style: TextStyle(fontSize: 20),
                          "Using YOLO and OpenCV's KCF tracking algorithm, we then can identify a softball from the camera feed, "
                             "calculate its distance from the ground in pixels, and convert to its height in feet."
                      ),
                    ]
                  ),
                ]
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),

            Text(
                    style: TextStyle(fontSize: 30,),
                    "What you need"),
                  BulletedList(listItems: [
                    Text(
                        style: TextStyle(fontSize: 20),
                        "A pole of a known height in feet."
                    ),
                    Text(
                        style: TextStyle(fontSize: 20),
                        "A camera mount."
                    ),
                    Text(
                        style: TextStyle(fontSize: 20),
                        "Open sideline location on the field equally between the home plate "
                            "and the pitcher's mound"
                    ),
                  ])
                ]
      )

    )
    );
  }
}
