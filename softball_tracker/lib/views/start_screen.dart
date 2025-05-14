import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/setup_values.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
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
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    "Pitch Snitch")
              ],
            )
          ]),
              Image(height: 500, image: AssetImage('assets/images/softball.jpg')),
          SizedBox(
            width: 200,
            height: 70,
            child: FilledButton(
              onPressed: () {
                Navigator.pushNamed(context, '/setupScreen');
              },
              child: const Text(style: TextStyle(fontSize: 30), 'Start'),
            ),
          ),
          // SizedBox(
          //     width: 200,
          //     height: 70,
          //     child: OutlinedButton(
          //       onPressed: () {
          //         Navigator.pushNamed(context, '/settings');
          //       },
          //       child: const Text(style: TextStyle(fontSize: 30), 'Settings'),
          //     )),
          // SizedBox(
          //   width: 200,
          //   height: 70,
          //   child: OutlinedButton(
          //     onPressed: () {
          //       Provider.of<SetupValues>(context, listen: false).setHeights(12, 6, 6);
          //       Provider.of<SetupValues>(context, listen: false).setPoints([200,100], [300,100], [200,500]);
          //
          //       Navigator.pushNamed(context, '/camera');
          //     },
          //     child: const Text(style: TextStyle(fontSize: 30), 'Camera'),
          //   ),
          // ),
          // SizedBox(
          //   width: 200,
          //   height: 70,
          //   child: OutlinedButton(
          //     onPressed: () {
          //       Navigator.pushNamed(context, '/yolo_video_screen');
          //     },
          //     child: const Text(style: TextStyle(fontSize: 30), 'YOLO Video'),
          //   ),
          // ),
          // Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          //   OutlinedButton(
          //     onPressed: () {
          //       Navigator.pushNamed(context, '/instructions');
          //     },
          //     child: const Text(style: TextStyle(fontSize: 30), '?'),
          //   )
          // ])
        ]));
  }
}
