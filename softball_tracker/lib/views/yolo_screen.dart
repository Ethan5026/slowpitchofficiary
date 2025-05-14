import 'dart:io' as io;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo_model.dart';

import '../utils/Times.dart';
import '../utils/setup_values.dart';
import '../widgets/action_button_widget.dart';
import '../widgets/expandable_fab_widget.dart';

class YoloScreen extends StatefulWidget {
  const YoloScreen({super.key});

  @override
  State<YoloScreen> createState() => _YoloScreen();
}

class BoundingBoxPainter extends CustomPainter 
{
  final Rect boundingBox;
  final Color boxColor;

  BoundingBoxPainter(this.boundingBox, this.boxColor);

  @override
  void paint(Canvas canvas, Size size) 
  {
    final Paint boxPaint = Paint()
      ..color = boxColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(boundingBox, boxPaint);
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) 
  {
    return oldDelegate.boundingBox != boundingBox || oldDelegate.boxColor != boxColor;
  }
}

class _YoloScreen extends State<YoloScreen> {
  final controller = UltralyticsYoloCameraController();
  bool isRecording = false;
  bool showData = true;
  List<int> ballCoordinates = [-1, -1, -1];
  double dataWidgetHeight = 65;
  GlobalKey yoloPreviewKey = GlobalKey();
  ValueNotifier<List<List<int>>> ballTracker = ValueNotifier<List<List<int>>>([]);
  bool tracking = false;
  bool initBoundBox = false;
  late List<int>? moundCoords;
  late double moundCoordsX;
  late double moundCoordsY;
  late Rect boundingBox;
  double maxHeight = 0;
  DateTime? ballEnterTime;
  Color boxColor = Colors.red;
  Duration ballInsideDuration = Duration.zero;

  late final AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();

    // Initialize the audio player
    audioPlayer = AudioPlayer();

    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger re-layout
    });
    ballTracker.addListener(trackBall);
  }

  @override
  void dispose() {
    // Dispose the audio player
    controller.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  void triggerIllegal() async {
    await audioPlayer.play(AssetSource('sounds/Illegal.mp3'));
  }

  void updateBoundingBoxColor() 
  {
    if(ballCoordinates[0] > moundCoordsX && ballCoordinates[0] < (moundCoordsX + 250) && ballCoordinates[1] < moundCoordsY + 50 && ballCoordinates[1] > moundCoordsY - 50)
    {
      if(ballEnterTime == null)
      {
        ballEnterTime = DateTime.now();
        boxColor = Colors.yellow;
      }
      else
      {
        Duration timeInBoundingBox = DateTime.now().difference(ballEnterTime!);
        if(timeInBoundingBox.inSeconds > 2)
        {
          boxColor = Colors.green;
        }
      }
    }
    else 
    {
      if(boxColor == Colors.green)
      {
        tracking = true;
      }
      ballEnterTime = null;
      ballInsideDuration = Duration.zero;
      boxColor = Colors.red;
    }

    setState(() {});
  }

  trackBall() {
    if (tracking) {
      double lastHeight = 0;
      List<int> lastCoords = [0, 0];
      int downwardTrendCount = 0;

      for (var ballCoords in ballTracker.value) {
        double ballHeight = getHeight(ballCoords);

        if (ballHeight > lastHeight) {
          lastHeight = ballHeight;
          lastCoords = ballCoords;
          downwardTrendCount = 0; // Reset downward trend count
        } else {
          downwardTrendCount++;
          if (downwardTrendCount >= 3) {
            print("FINAL HEIGHT DETECTED: $lastHeight at $lastCoords");
            setState(() {
              maxHeight = lastHeight;
            });
            if (lastHeight > Provider.of<SetupValues>(context, listen: false).maxHeight! ||
                lastHeight < Provider.of<SetupValues>(context, listen: false).minHeight!) {
              print("ILLEGAL");
              triggerIllegal();
            } else {
              print("FAIR");
            }
            setState(() {
              tracking = false;
              ballTracker.value = [];
          });
            break;
          }
        }
      }
    }
  }

  double getHeight(coordinates) {
    if (coordinates[0] != -1 && coordinates[1] != -1) {
      //start height calculation
      
      int pixelHeight = ballCoordinates[0] - Provider.of<SetupValues>(context, listen: false).homePlate![0];
      double calculatedHeight = Provider.of<SetupValues>(context, listen: false).averagePixelLength! * pixelHeight;
      // print("COORDINATES: $coordinates");
      // print("Home Plate: ${Provider.of<SetupValues>(context, listen: false).homePlate}");
      // print("Reference Point: ${Provider.of<SetupValues>(context, listen: false).referencePoint}");
      // print("Pixel Height: $pixelHeight");
      // print("Calculated Height: $calculatedHeight");
      return calculatedHeight;
    }
    return -1;
  }

  Widget getData() {
    if (!showData) {
      return Container();
    }
    return Column(
      children: [
        Container(
        height:130
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.end,
    children:[
    Transform.rotate(
      angle: 3.14159 / 2,
    child: Container(
        width: 139,
        height: dataWidgetHeight,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 5)]),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Height: ${getHeight(ballCoordinates).toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal)),
                Text("Yolo: $ballCoordinates",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.normal)),
                Text("Max Height: ${maxHeight.toStringAsFixed(2)}",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.normal)),
            ]))))
    ])]);
  }

  @override
  Widget build(BuildContext context) {

    if(!initBoundBox)
    {
      moundCoords = Provider.of<SetupValues>(context, listen: false).pitchersMound!;
      moundCoordsX = moundCoords![0].toDouble();
      print("MOUND COORDS: $moundCoords");
      moundCoordsY = moundCoords![1].toDouble();
      boundingBox = Rect.fromLTRB(
        moundCoordsX, moundCoordsY - 50, moundCoordsX + 200, moundCoordsY + 50);

      initBoundBox = true;
    }

    updateBoundingBoxColor();

    Widget ultralyticsYoloCameraPreview = FutureBuilder<ObjectDetector>(
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
                    },
                    orientation: CameraOrientation.portrait,
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: true,
                      child: CustomPaint(
                        painter: BoundingBoxPainter(boundingBox, boxColor),
                      ),
                    ),
                  ),
                  Positioned(
                      left: ballCoordinates[0] - 5,
                      top:  ballCoordinates[1] - 5,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  Positioned(
                    left: (Provider.of<SetupValues>(context, listen: false).maxHeight! / Provider.of<SetupValues>(context, listen: false).averagePixelLength!) + Provider.of<SetupValues>(context, listen: false).homePlate![0],
                    top: 0,
                    bottom: 0,
                    child: Container(
                      height: 3,
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                    left: (Provider.of<SetupValues>(context, listen: false).minHeight! / Provider.of<SetupValues>(context, listen: false).averagePixelLength!) + Provider.of<SetupValues>(context, listen: false).homePlate![0],
                    top: 0,
                    bottom: 0,
                    child: Container(
                      height: 3,
                      color: Colors.black,
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
                                if(tracking) {
                                  ballTracker.value.add(ballCoordinates);
                                }
                                trackBall();
                              }
                            }
                          }

                          predictor.detectionResultStream.listen(onDetect);

                          //predictor.detectionResultStream.listen(onDetect);
                          return                          
                          Times(
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
            future: _checkPermissions(),
            builder: (context, snapshot) {
              final allPermissionsGranted = snapshot.data ?? false;

              return !allPermissionsGranted
                  ? const Center(
                      child: Text("Error requesting permissions"),
                    )
                  : ultralyticsYoloCameraPreview;
            },
          ),
          getData(),
        ]),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton:
              Row(
                children: [
        Transform.rotate(
            angle: 3.14159/2,
            child: ActionButton(
                  text: const Text("Data", style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    print("BARF");
                    if (showData) {
                      setState(() => showData = false);
                    } else {
                      setState(() => showData = true);
                    }
                  })
        ),
        Transform.rotate(
            angle: 3.14159/2,
            child: ActionButton(
                text: const Text("Home", style: TextStyle(fontSize: 18)),
                onPressed: () => Navigator.pushNamed(context, '/'),
              )
        )
            ])
        ),
      );
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

  Future<ImageClassifier> _initImageClassifierWithLocalModel() async {
    final modelPath = await _copy('assets/yolov8n-cls.mlmodel');
    final model = LocalYoloModel(
      id: '',
      task: Task.classify,
      format: Format.coreml,
      modelPath: modelPath,
    );

    return ImageClassifier(model: model);
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

  Future<bool> _checkPermissions() async {
    // List<Permission> permissions = [];

    // var cameraStatus = await Permission.camera.status;
    // if (!cameraStatus.isGranted) permissions.add(Permission.camera);

    // // var storageStatus = await Permission.photos.status;
    // // if (!storageStatus.isGranted) permissions.add(Permission.photos);

    // if (permissions.isEmpty) {
    //   return true;
    // } else {
    //   try {
    //     Map<Permission, PermissionStatus> statuses =
    //         await permissions.request();
    //     return statuses.values
    //         .every((status) => status == PermissionStatus.granted);
    //   } on Exception catch (_) {
    //     return false;
    //   }
    // }
    return true;
  }
}