# Development Guide for Softball Tracker App

This guide provides an overview of the folder structure, the usage of the Ultralytics YOLO plugin, and the method channels used for communication between Flutter and native platforms (iOS and Android).

---

## **1. Folder Structure Overview**

### **Root Directory**
- **`.vscode/`**: Contains Visual Studio Code settings for the project.
- **`android/`**: Contains Android-specific files, including Gradle build scripts and native code.
- **`ios/`**: Contains iOS-specific files, including Xcode project files and native code.
- **`lib/`**: The main directory for Flutter/Dart code.
  - **`views/`**: Contains UI screens such as `yolo_screen.dart` and `setup_camera_capture_screen.dart`.
  - **`utils/`**: Utility functions and constants used across the app.
  - **`widgets/`**: Reusable Flutter widgets.
- **`assets/`**: Contains images, videos, and other static resources.
- **`ultralytics_yolo/`**: A custom Flutter plugin for YOLO-based object detection.
- **`test/`**: Contains unit and widget tests for the app.

---

## **2. Ultralytics YOLO Plugin**

The `ultralytics_yolo` plugin is a custom Flutter plugin used for YOLO-based object detection. It integrates with both Android and iOS platforms to provide real-time camera preview and object detection capabilities.

### **Key Components**
- **`ultralytics_yolo/lib/`**: Contains the Dart interface for the plugin.
  - **`ultralytics_yolo_platform_interface.dart`**: Defines the platform interface for the plugin.
  - **`ultralytics_yolo_platform_channel.dart`**: Implements the platform interface using method channels.
  - **`camera_preview/`**: Contains classes for managing the camera preview and bounding box overlays.
- **`ultralytics_yolo/android/`**: Contains Android-specific implementation.
  - **`MethodCallHandler.java`**: Handles method calls from Dart and communicates with the Android CameraX API and TensorFlow Lite.
- **`ultralytics_yolo/ios/`**: Contains iOS-specific implementation.
  - **`SwiftUltralyticsYoloPlugin.swift`**: Handles method calls from Dart and communicates with the iOS AVFoundation and CoreML frameworks.

---

## **3. Method Channels**

The plugin uses method channels to communicate between Flutter and the native platforms.

### **Android**
- **Method Channel**: `"ultralytics_yolo"`
  - **Implemented in**: [`UltralyticsYoloPlugin.java`](softball_tracker/ultralytics_yolo/android/src/main/java/com/ultralytics/ultralytics_yolo/UltralyticsYoloPlugin.java)
  - **Key Methods**:
    - `loadModel`: Loads the YOLO model for object detection.
    - `setConfidenceThreshold`: Sets the confidence threshold for detections.
    - `setIouThreshold`: Sets the Intersection over Union (IoU) threshold.
    - `startCamera`: Starts the camera preview.
    - `stopCamera`: Stops the camera preview.

### **iOS**
- **Method Channel**: `"ultralytics_yolo"`
  - **Implemented in**: [`SwiftUltralyticsYoloPlugin.swift`](softball_tracker/ultralytics_yolo/ios/Classes/SwiftUltralyticsYoloPlugin.swift)
  - **Key Methods**:
    - `loadModel`: Loads the YOLO model using CoreML.
    - `setConfidenceThreshold`: Sets the confidence threshold for detections.
    - `setIouThreshold`: Sets the IoU threshold.
    - `startCamera`: Starts the camera preview using AVFoundation.
    - `stopCamera`: Stops the camera preview.

---

## **4. Development Workflow**

### **Setting Up the Project**
1. Install Flutter and ensure it is properly configured (`flutter doctor`).
2. Run `flutter pub get` to fetch dependencies.
3. For iOS:
   - Navigate to the `ios/` directory and run `pod install`.
   - Open the `.xcworkspace` file in Xcode and configure signing.
4. For Android:
   - Ensure the `local.properties` file points to the correct Flutter SDK path.

### **Running the App**
- Use `flutter run` to start the app on a connected device or emulator.
- For iOS, ensure a physical device is connected and properly provisioned.

### **Testing**
- Write and run tests in the `test/` directory using `flutter test`.

---

## **5. Notes on YOLO Integration**

- The YOLO models are stored in the `assets/` directory and loaded dynamically at runtime.
- The plugin supports both CPU and GPU inference for better performance.
- Bounding boxes and detection results are rendered on the Flutter UI using custom painters.

---

## **6. Troubleshooting**

- **Camera Not Working**: Ensure camera permissions are granted in the device settings.
- **Model Loading Errors**: Verify the model file paths in the `assets/` directory.
- **iOS Build Issues**: Ensure CocoaPods dependencies are installed and Xcode signing is configured.

---

For further details, refer to the source code and comments in the respective files.