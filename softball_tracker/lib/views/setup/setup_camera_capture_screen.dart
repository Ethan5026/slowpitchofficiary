import 'dart:async';
import 'dart:io';
import 'dart:io' as io;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:provider/provider.dart';
import 'package:ultralytics_yolo/camera_preview/ultralytics_yolo_camera_controller.dart';
import 'package:ultralytics_yolo/camera_preview/ultralytics_yolo_camera_preview.dart';
import 'package:ultralytics_yolo/predict/detect/detected_object.dart';
import 'package:ultralytics_yolo/predict/detect/object_detector.dart';
import 'package:ultralytics_yolo/yolo_model.dart';

import '../../utils/Times.dart';
import '../../utils/setup_values.dart';

class SetupCameraCaptureScreen extends StatefulWidget {
  const SetupCameraCaptureScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SetupCameraCaptureScreenState();
}

class _SetupCameraCaptureScreenState extends State<SetupCameraCaptureScreen> {
  bool started = false;
  int stage = -1;
  int countdown = -1;
  List<int> ballCoordinates = [-1, -1];
  final controller = UltralyticsYoloCameraController();
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    controller.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  void startCapture() {
    setState(() {
      started = true;
      stage = 0;
    });

    _runStage(0, () {
      List<int> homePlate = ballCoordinates;
      setState(() {
        stage = 1;
      });
      _runStage(1, () {
        List<int> referencePoint = ballCoordinates;
        setState(() {
          stage = 2;
        });
        _runStage(2, () {
          List<int> pitchersMound = ballCoordinates;

          Provider.of<SetupValues>(context, listen: false)
              .setPoints(homePlate, referencePoint, pitchersMound);

          setState(() {
            countdown = -1;
            stage = -1;
            started = false;
          });

          Navigator.pushReplacementNamed(context, '/camera');
        });
      });
    });
  }
  void _runStage(int stageIndex, VoidCallback onStageComplete) {
    int counter = 15;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        countdown = counter;
      });

      if (counter == 0) {
        timer.cancel();
        onStageComplete();
        //audioPlayer.play(AssetSource('sounds/camera_shutter.mp3'));
        //Future.delayed(const Duration(milliseconds: 1000), onStageComplete);
      } else {
        //audioPlayer.play(AssetSource('sounds/beep.mp3'));
        counter--;
      }
    });
  }

  Widget getCountdown() {
    if (countdown == -1) {
      return Container();
    }
    return Column(
        children:[
        Container(
        height: 400
    ),
    Transform.rotate(
    angle: 3.14159 / 2,
    child: Container(
      alignment: Alignment.center,
      child: Text(
          style: const TextStyle(
              fontSize: 150,
              color: Colors.black,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold),
          countdown.toString()),
    ))]);
  }

  Widget getTitle() {
    String title;
    if (stage == 0) {
      title = "Ball on Home Plate";
    } else if (stage == 1) {
      title = "Ball at Reference Height Above Home Plate";
    } else if (stage == 2) {
      title = "Ball on Pitchers Mound";
    } else {
      return Container();
    }

    return Column(
        children:[
          Container(
            height: 250
          ),
          Transform.rotate(
        angle: 3.14159 / 2,
        child: Container(
          height: 450,
        alignment: Alignment.topCenter,
        child: Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Container(
              width: 500,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [BoxShadow(color: Colors.black, blurRadius: 5)]),
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Text(title,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            fontFamily: 'arial',
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none)))))))]);
  }
  Future<ObjectDetector> _initObjectDetectorWithLocalModel() async {
    if (io.Platform.isAndroid) {
      //final modelPath = await _copy('assets/best_float16.tflite');
      final modelPath = await _copy('assets/best_float32.tflite');
      final metadataPath = await _copy('assets/metadata.yaml');

      final model = LocalYoloModel(
        id: '',
        task: Task.detect,
        format: Format.tflite,
        modelPath: modelPath,
        metadataPath: metadataPath,
      );
      return ObjectDetector(model: model);
    } else {
      // FOR IOS
      final modelPath = await _copy('assets/bestv2-img640.mlmodel');
      final model = LocalYoloModel(
        id: '',
        task: Task.detect,
        format: Format.coreml,
        modelPath: modelPath,
      );
      return ObjectDetector(model: model);
    }
  }
  Future<String> _copy(String assetPath) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(p.dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }
  @override
  Widget build(BuildContext context) {

    Widget ultralyticsCameraPreview = FutureBuilder<ObjectDetector>(
      future: _initObjectDetectorWithLocalModel(),
      builder: (context, snapshot) {
        ObjectDetector? predictor = snapshot.data;
        return predictor == null
            ? Container()
            : Stack(
          children: [
            UltralyticsYoloCameraPreview(
              controller: controller,
              predictor: predictor,
              onCameraCreated: () {
                predictor.setConfidenceThreshold(0.2);
                predictor.setNumItemsThreshold(1);
                predictor.setIouThreshold(0.6);
                predictor.loadModel(useGpu: true);
                setState(() => started = true);
                startCapture();
              },
              orientation: CameraOrientation.portrait,
            ),
            Positioned(
              left: ballCoordinates[0] - 5,
              top: ballCoordinates[1] - 5,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            StreamBuilder<double?>(
              stream: predictor.inferenceTime,
              builder: (context, snapshot) {
                final inferenceTime = snapshot.data;

                return StreamBuilder<double?>(
                  stream: predictor.fpsRate,
                  builder: (context, snapshot) {
                    final fpsRate = snapshot.data;
                    void onDetect(List<DetectedObject?>? detection) {
                      if (detection != null) {
                        if (detection[0] != null) {
                          print(
                              "Detected object at (${detection[0]!.boundingBox.center.dx}, ${detection[0]!.boundingBox.center.dy}), Confidence: ${detection[0]!.confidence}");
                          setState(() => ballCoordinates = [
                            detection[0]!.boundingBox.center.dx.toInt(),
                            detection[0]!.boundingBox.center.dy.toInt()
                          ]);
                        }
                      }
                    }

                    predictor.detectionResultStream.listen(onDetect);

                    //predictor.detectionResultStream.listen(onDetect);
                    return Times(
                      inferenceTime: inferenceTime,
                      fpsRate: fpsRate,
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
    return MaterialApp(
        home: Scaffold(
        body: Stack(children: [
          FutureBuilder<bool>(
            future: checkPerms(),
            builder: (context, snapshot) {
              final allPermissionsGranted = snapshot.data ?? false;

              return !allPermissionsGranted
                  ? const Center(
                child: Text("Error requesting permissions"),
              )
                  : ultralyticsCameraPreview;
            },
          ),ultralyticsCameraPreview,
      getCountdown(),
      getTitle(),
      ])));
  }
}
Future<bool> checkPerms() async {
  return true;
}