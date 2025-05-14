import 'dart:isolate';
import 'package:camera/camera.dart';

class ImageProcessingIsolate {
  late ReceivePort receivePort;
  Isolate? isolate;
  SendPort? isolateSendPort;

  ImageProcessingIsolate() {
    receivePort = ReceivePort();
  }

  //Initialize the isolate
  Future<void> initializeIsolate(Function listenOperation) async {
    isolate = await Isolate.spawn(isolateFunction, receivePort.sendPort);

    receivePort.listen((message) {
      if (message is SendPort) {
        // First message is the isolate's SendPort
        isolateSendPort = message;
      } else {
        //Do the intended listen message
        listenOperation(message);
      }
    });
  }

  //Send a CameraImage to the isolate for processing
  void sendImage(CameraImage image, bool runYOLO) {
    if (isolateSendPort == null) {
      print("Isolate not initialized yet.");
      return;
    }
    isolateSendPort!.send({'image': image, 'runYOLO': runYOLO});
  }

  //The isolate function to send to backend and return results
  static void isolateFunction(SendPort mainThreadSendPort) {
    int timeTaken1 = DateTime.now().millisecondsSinceEpoch;
    final ReceivePort isolateReceivePort = ReceivePort();
    //Send isolate's SendPort back
    mainThreadSendPort.send(isolateReceivePort.sendPort);

    isolateReceivePort.listen((message) async {
      if (message is! Map<String, dynamic>) return;

      CameraImage image = message['image'];
      bool runYOLO = message['runYOLO'];


      try {
        if (runYOLO) {
          print("Sending frame to YOLO");
          List<int> result = [1, 2, 3, 4, 5];
          //List<int> result = await OpenCVService.runYOLO(image);

          // Send the result back to the main thread
          mainThreadSendPort.send(result);
          int timeTaken2 = DateTime.now().millisecondsSinceEpoch;
          print("Results: ${result}");
          print("Took ${timeTaken2 - timeTaken1} seconds.");
        } else {
          print("Sending frame to KCF");

          //List<int> result = await OpenCVService.runTracker(image);
          List<int> result = [1, 2, 3, 4, 5];

          // Send the result back to the main thread
          mainThreadSendPort.send(result);
          int timeTaken2 = DateTime.now().millisecondsSinceEpoch;
          print("Results: ${result}");
          print("Took ${timeTaken2 - timeTaken1} seconds.");
        }
      } catch (e) {
        print("Error running OpenCV function: $e");
      }
    });
  }
}
