// camera_preview_widget.dart
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../utils/RotatedCameraController.dart';

class CameraPreviewWidget extends StatefulWidget {
  final void Function(CameraController)? onControllerCreated;

  const CameraPreviewWidget({super.key, this.onControllerCreated});

  @override
  State<CameraPreviewWidget> createState() => CameraPreviewWidgetState();
}

class CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  late CameraController controller;
  late List<CameraDescription> cameras;
  String? _videoPath;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Starts/stops and saves camera recording to cache
  Future<void> toggleCameraRecord() async {
    if (!controller.value.isInitialized) {
      print("Camera is not initialized");
      return;
    }

    if (!_isRecording) {
      // Start recording
      try {
        final tempDir = await getTemporaryDirectory();
        _videoPath = path.join(
          tempDir.path,
          'video_${DateTime
              .now()
              .millisecondsSinceEpoch}.mp4',
        );
        await controller.startVideoRecording();
        print("Recording started");
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        print("Error starting video recording: $e");
        await controller.stopVideoRecording();
      }
    } else {
      // Stop recording
      try {
        final XFile videoFile = await controller.stopVideoRecording();
        if (_videoPath != null) {
          await videoFile.saveTo(_videoPath!);
          print("Recording stopped, saved to $_videoPath");
        }
        setState(() {
          _isRecording = false;
        });
      } catch (e) {
        print("Error stopping video recording: $e");
      }
    }
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    print(cameras);
    final CameraDescription camera =
    cameras.length > 1 ? cameras[0] : cameras.first;
    controller = CameraController(camera, ResolutionPreset.max);

    try {
      await controller.initialize();
      if (widget.onControllerCreated != null) {
        widget.onControllerCreated!(controller);
      }
      await controller.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
    } catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {}); // Rebuild widget to show camera preview.
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final deviceSize = MediaQuery
        .of(context)
        .size;


    return Stack(
      children: [
        // Wrap Camera Preview in a container to separate it from overlay
        Center(
          child: OverflowBox(
            maxWidth: deviceSize.width,
            maxHeight: deviceSize.height,
            child: CameraPreview(controller),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: LineOverlayPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class LineOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.4) // Light gray for grid lines
      ..strokeWidth = 1;

    double gridSpacing = 520.0 / 12.0; // Adjust as needed for spacing
    // Draw vertical grid lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(727, y), gridPaint);
    }

    // Draw vertical grid lines
    for (double x = 109; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


