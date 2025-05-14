import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:softball_tracker/utils/screen_orientation.dart';
import 'package:video_player/video_player.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo_model.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class YoloVideoScreen extends StatefulWidget {
  const YoloVideoScreen({super.key});

  @override
  _YoloVideoScreen createState() => _YoloVideoScreen();
}

class _YoloVideoScreen extends State<YoloVideoScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  final GlobalKey _videoKey = GlobalKey(); // For capturing frames
  List<DetectedObject> _detections = [];
  bool _isProcessing = false;
  late ObjectDetector _predictor;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _controller = VideoPlayerController.asset('assets/videos/field_vid_30fps.MOV');

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {}); // Update UI once initialized
      _initObjectDetector();
      _startFrameExtraction(); // Start processing frames
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Load YOLO model
  Future<void> _initObjectDetector() async {
    final modelPath = await _copy('assets/best-yolo11s.mlmodel');
    final model = LocalYoloModel(
      id: '',
      task: Task.detect,
      format: Format.coreml,
      modelPath: modelPath,
    );
    _predictor = ObjectDetector(model: model);
    _predictor.setConfidenceThreshold(1);
    _predictor.setIouThreshold(.5);
    _predictor.setNumItemsThreshold(1);
    _predictor.loadModel(useGpu: true);
  }

  /// Starts extracting frames periodically
  void _startFrameExtraction() {
    Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (!_controller.value.isPlaying || _isProcessing) return;

      _isProcessing = true;
      final framePath = await _captureFrame();
      if (framePath != null) {
        _processFrame(framePath);
      }
      _isProcessing = false;
    });
  }

  /// Extract a frame using RenderRepaintBoundary
  Future<String?> _captureFrame() async {
    try {
      RenderRepaintBoundary? boundary = _videoKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        print("Failed to capture frame: boundary is null");
        return null;
      }

      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        Uint8List imageBytes = byteData.buffer.asUint8List();
        String tempDir = (await getTemporaryDirectory()).path;
        String filePath =
            '$tempDir/frame_${DateTime.now().millisecondsSinceEpoch}.png';

        io.File file = io.File(filePath);
        await file.writeAsBytes(imageBytes);
        return file.path;
      }
    } catch (e) {
      print("Error capturing frame: $e");
    }
    return null;
  }

  /// Runs YOLO detection on a frame
  void _processFrame(String framePath) async {
    try {
      final List<DetectedObject?>? rawResult =
          await _predictor.detect(imagePath: framePath);

      print("Raw result from detection:");

      print(rawResult);

      if (rawResult == null || rawResult.isEmpty) {
        print("No objects detected.");
        setState(() {
          _detections = [];
        });
        return;
      }

      setState(() {
        _detections = rawResult.whereType<DetectedObject>().toList();
      });

      print("Detections found: ${_detections.length}");
    } catch (e, stacktrace) {
      print("Error processing frame: $e");
      print(stacktrace);
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YOLO Video Player'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;
          double videoAspectRatio = _controller.value.aspectRatio;
          print("Video aspect ratio: $videoAspectRatio");
          print("Screen width: $screenWidth, height: $screenHeight");

          double videoWidth, videoHeight;

          if (MediaQuery.of(context).orientation == Orientation.portrait) {
            // Standard portrait mode sizing
            videoWidth = screenWidth;
            videoHeight = screenWidth / videoAspectRatio;

            if (videoHeight > screenHeight) {
              videoHeight = screenHeight;
              videoWidth = screenHeight * videoAspectRatio;
            }
          } else {
            // Landscape mode: ensure video does not exceed screen height
            videoHeight = screenHeight;
            videoWidth = videoHeight * videoAspectRatio;

            if (videoWidth > screenWidth) {
              videoWidth = screenWidth;
              videoHeight = screenWidth / videoAspectRatio;
            }
          }

          List<Widget> overlays = _detections.map((detection) {
            final double dx = detection.boundingBox.center.dx;
            final double dy = detection.boundingBox.center.dy;

            return Positioned(
              left: dx, 
              top: dy, 
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }).toList();

          print("Final Video width: $videoWidth, height: $videoHeight");

          return Center(
            child: Stack(
              children: [
                RepaintBoundary(
                  key: _videoKey,
                  child: SizedBox(
                    width: videoWidth,
                    height: videoHeight,
                    child: VideoPlayer(_controller),
                  ),
                ),
                ...overlays, // Add the overlays to the stack
              ],
              
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
              _startFrameExtraction();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  /// Copy model file for YOLO
  Future<String> _copy(String assetPath) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  Future<ObjectDetector> _initObjectDetectorWithLocalModel() async {
    final modelPath = await _copy('assets/best.mlmodel');
    final model = LocalYoloModel(
      id: '',
      task: Task.detect,
      format: Format.coreml,
      modelPath: modelPath,
    );

    return ObjectDetector(model: model);
  }
}
