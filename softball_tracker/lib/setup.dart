import 'package:flutter/material.dart';
import 'package:softball_tracker/utils/RoutedPage.dart';
import 'package:softball_tracker/utils/constants.dart';
import 'package:softball_tracker/utils/screen_orientation.dart';
import 'package:softball_tracker/views/setup/setup_camera_capture_screen.dart';
import 'package:softball_tracker/views/setup/setup_camera_instructions.dart';
import 'package:softball_tracker/views/instructions_screen.dart';
import 'package:softball_tracker/views/setup/setup_screen.dart';
import 'package:softball_tracker/views/setup/setup_values_screen.dart';

RoutedPage routeSetup(String? route){
  if(route == SETUP_SCREEN){
    return RoutedPage(
        const SetupCameraInstructionsScreen(),
        ScreenOrientation.portraitOnly);
  }
  else if(route == SETUP_VALUES){
    return RoutedPage(
        const SetupValuesScreen(),
        ScreenOrientation.portraitOnly);
  }
  else if(route == CAMERA_INSTRUCTIONS){
    return RoutedPage(
        SetupCameraInstructionsScreen(),
        ScreenOrientation.portraitOnly);
  }
  else if(route == CAMERA_CALIBRATION_CAPTURE){
    return RoutedPage(
        SetupCameraCaptureScreen(),
        ScreenOrientation.portraitOnly);
  }
  else{
    return RoutedPage(
      const SetupScreen(),
      ScreenOrientation.portraitOnly);
  }
}