import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/ultralytics_yolo_platform_interface.dart';

const String _viewType = 'ultralytics_yolo_camera_preview';

/// A widget that displays the camera preview and runs inference on the frames
/// using a Ultralytics YOLO model.
class UltralyticsYoloCameraPreview extends StatefulWidget {
  /// Constructor to create a [UltralyticsYoloCameraPreview].
  const UltralyticsYoloCameraPreview({
    required this.predictor,
    required this.controller,
    required this.onCameraCreated,
    this.boundingBoxesColorList = const [Colors.lightBlueAccent],
    this.classificationOverlay,
    this.loadingPlaceholder,
    this.orientation = CameraOrientation.portrait,
    super.key,
  });

  /// The predictor used to run inference on the camera frames.
  final Predictor? predictor;

  /// The list of colors used to draw the bounding boxes.
  final List<Color> boundingBoxesColorList;

  /// The classification overlay widget.
  final BaseClassificationOverlay? classificationOverlay;

  /// The controller for the camera preview.
  final UltralyticsYoloCameraController controller;

  /// The callback invoked when the camera is created.
  final VoidCallback onCameraCreated;

  /// The placeholder widget displayed while the predictor is loading.
  final Widget? loadingPlaceholder;

  /// Defines the orientation of the camera preview.
  final CameraOrientation orientation;

  @override
  State<UltralyticsYoloCameraPreview> createState() =>
      _UltralyticsYoloCameraPreviewState();
}

/// Enum for camera orientations.
enum CameraOrientation { portrait, landscape, auto }

class _UltralyticsYoloCameraPreviewState
    extends State<UltralyticsYoloCameraPreview> {
  final _ultralyticsYoloPlatform = UltralyticsYoloPlatform.instance;

  double _currentZoomFactor = 1;
  final double _zoomSensitivity = 0.05;
  final double _minZoomLevel = 1;
  final double _maxZoomLevel = 5;

  void _onPlatformViewCreated(_) {
    widget.onCameraCreated();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UltralyticsYoloCameraValue>(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        return Stack(
          children: [
            // Camera preview
            () {
              final creationParams = <String, dynamic>{
                'lensDirection': widget.controller.value.lensDirection,
                'format': widget.predictor?.model.format.name,
                'orientation': widget.orientation.toString().split('.').last,
              };

              switch (defaultTargetPlatform) {
                case TargetPlatform.android:
                  return AndroidView(
                    viewType: _viewType,
                    onPlatformViewCreated: _onPlatformViewCreated,
                    creationParams: creationParams,
                    creationParamsCodec: const StandardMessageCodec(),
                  );
                case TargetPlatform.iOS:
                  return UiKitView(
                    viewType: _viewType,
                    creationParams: creationParams,
                    onPlatformViewCreated: _onPlatformViewCreated,
                    creationParamsCodec: const StandardMessageCodec(),
                  );
                default:
                  return Container();
              }
            }(),

            // Results overlay
            () {
              if (widget.predictor == null) {
                return widget.loadingPlaceholder ?? Container();
              }

              switch (widget.predictor.runtimeType) {
                case ObjectDetector:
                  return StreamBuilder(
                    stream: (widget.predictor! as ObjectDetector)
                        .detectionResultStream,
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<List<DetectedObject?>?> snapshot,
                    ) {
                      if (snapshot.data == null) return Container();

                      return SizedBox.expand(
                        child: CustomPaint(
                          painter: ObjectDetectorPainter(
                            snapshot.data! as List<DetectedObject>,
                            widget.boundingBoxesColorList,
                            widget.controller.value.strokeWidth,
                          ),
                        ),
                      );
                    },
                  );
                case ImageClassifier:
                  return widget.classificationOverlay ??
                      StreamBuilder(
                        stream: (widget.predictor! as ImageClassifier)
                            .classificationResultStream,
                        builder: (context, snapshot) {
                          final classificationResults = snapshot.data;

                          if (classificationResults == null ||
                              classificationResults.isEmpty) {
                            return Container();
                          }

                          return ClassificationResultOverlay(
                            classificationResults: classificationResults,
                          );
                        },
                      );
                default:
                  return Container();
              }
            }(),

            // Zoom detector
            GestureDetector(
              onScaleUpdate: (details) {
                if (details.pointerCount == 2) {
                  var newZoomFactor = _currentZoomFactor * details.scale;

                  if (newZoomFactor < _currentZoomFactor) {
                    newZoomFactor = _currentZoomFactor -
                        (_zoomSensitivity *
                            (_currentZoomFactor - newZoomFactor));
                  } else {
                    newZoomFactor = _currentZoomFactor +
                        (_zoomSensitivity *
                            (newZoomFactor - _currentZoomFactor));
                  }

                  final clampedZoomFactor =
                      max(_minZoomLevel, min(_maxZoomLevel, newZoomFactor));

                  _ultralyticsYoloPlatform.setZoomRatio(clampedZoomFactor);
                  _currentZoomFactor = clampedZoomFactor;
                }
              },
              child: Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.transparent,
              ),
            ),
          ],
        );
      },
    );
  }
}
