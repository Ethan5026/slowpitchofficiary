# Flutter App Setup Guide

This guide walks you through installing Flutter, setting up Android and iOS environments, and running a Flutter app on **Android** (emulator or physical device) and **iOS** (physical device).

---

## **1. Install Flutter**

### **Windows**
1. Download Flutter from the official site: [Flutter SDK](https://flutter.dev/docs/get-started/install)
2. Extract the Flutter SDK to a preferred location (e.g., `C:\flutter` on Windows)
3. Add Flutter to the system path:
    - Windows: Add `C:\flutter\bin` to `Environment Variables`
4. Restart your terminal
5. Run the `flutter doctor` command in your terminal to ensure the installation is complete.
6. Download Android Studio from the official site: [Android Studio Download](https://https://developer.android.com/studio)
7. Install the Android Studio Dart and Flutter plugins from Settings --> Plugins
8. For Emulating: 
   - Set up a device in the Device Manager tab 
   - Edit the device and set `Graphics = Software`
   - Set up the camera environment by going into `Advanced Settings` and set `Front Camera = Emulated` and `Back Camera = Emulated`
9. For Physical Device:
   - Enable **Developer Mode** on your Android phone:
   - Go to **Settings > About phone**
   - Tap **Build number** **7 times** to enable Developer Mode
   - In **Developer Options**, enable **USB Debugging**
   - Connect your Android device via USB
   - Run:
       ```sh
       flutter devices
       ```
       Your device should appear in the list.

**Common Windows Issues:**
- If your device becomes unresponsive with errors about `*.lock files` delete all files ending in `.lock` in your Android Studio installation location within the `avd` directory
- When running the app, if the installation fails due to storage limitations, select to edit your emulated device and select the `Wipe Data` option to clear the device's app storage.
- If Android Studio is unable to run Dart, end all tasks in Task Manager using `dart`. Some programs can be left dangling.

### **macOS (for iOS & Android development)**
1. Install **Flutter** using Homebrew:
   ```sh
   brew install flutter
   ```
2. Ensure **Xcode** is installed via the App Store
3. Install CocoaPods for iOS dependencies:
   ```sh
   sudo gem install cocoapods
   ```

---

## **2. Verify Installation**
Run the following command to check if Flutter is set up correctly:
```sh
flutter doctor
```
If there are any missing dependencies, follow the instructions provided by `flutter doctor`.

---

## **3. Setup Flutter Project**

Navigate to your project directory and run:
```sh
flutter clean
flutter pub get
```
If `flutter pub get` fails, run it again:
```sh
flutter pub get
```

---


## **5. Setting Up iOS Development** (macOS only)

### **Using a Physical iOS Device**
1. Install **Xcode** from the App Store
2. Open **Xcode > Preferences > Accounts**
3. Sign in with your Apple ID (free account works, but requires manual app signing)
4. Connect your iPhone via USB
5. Trust the device when prompted
6. Run:
   ```sh
   flutter devices
   ```
   Your iPhone should appear in the list.
7. Open **ios/Runner.xcworkspace** in Xcode
8. Select your **development team** under **Signing & Capabilities**
9. Run the app in Xcode or via:
   ```sh
   flutter run
   ```

---

## **6. Running the Flutter App**

To start the app on an **Android emulator, physical Android device, or iOS device**, run:
```sh
flutter run
```
If running on iOS and encountering permission errors, try:
```sh
cd ios
pod install
cd ..
flutter run
```

---

## **Troubleshooting**
- **App not detecting device?**
    - Run `flutter devices` to confirm the device is recognized.
    - Ensure USB debugging (Android) or proper provisioning (iOS) is set up.
- **Errors during `flutter pub get`?**
    - Run `flutter clean` and try `flutter pub get` twice.
- **iOS Signing Issues?**
    - Ensure Xcode is signed with a valid development team in **Signing & Capabilities**.
- **Dependency Errors**
  - Run `flutter clean` and try `flutter pub get` twice.


---

Now you're ready to build your Flutter app! 🚀

