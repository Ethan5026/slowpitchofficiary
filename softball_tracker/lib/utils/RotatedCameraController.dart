import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class RotatedCameraController extends CameraController {
  RotatedCameraController(CameraDescription camera, ResolutionPreset resolutionPreset)
      : super(camera, resolutionPreset);

  @override
  Future<XFile> takePicture() async {
    final XFile originalFile = await super.takePicture();

    if (Platform.isAndroid) {
      // Read the image bytes
      Uint8List imageBytes = await originalFile.readAsBytes();

      // Decode image using the `image` package
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception("Failed to decode image");
      }

      // Rotate the image 90 degrees
      img.Image rotatedImage = img.copyRotate(image, angle: 180);

      // Get the temp directory to save the rotated image
      final Directory tempDir = await getTemporaryDirectory();
      final String rotatedPath = '${tempDir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Encode and save the rotated image
      await File(rotatedPath).writeAsBytes(img.encodeJpg(rotatedImage));

      return XFile(rotatedPath);
    }

    return originalFile; // Return the original file if not on Android
  }
}
