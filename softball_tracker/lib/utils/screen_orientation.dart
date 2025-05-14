import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:softball_tracker/utils/screen_orientation.dart';

enum ScreenOrientation { portraitOnly, landscapeOnly, rotating }

void _setOrientation(ScreenOrientation orientation) {
  List<DeviceOrientation> orientations;
  switch (orientation) {
    case ScreenOrientation.portraitOnly:
      orientations = [
        DeviceOrientation.portraitUp,
      ];
      break;
    case ScreenOrientation.landscapeOnly:
      orientations = [
        // DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ];
      break;
    case ScreenOrientation.rotating:
      orientations = [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ];
      break;
  }
  SystemChrome.setPreferredOrientations(orientations);
}

class NavigationObserverWithOrientation extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.settings.arguments is ScreenOrientation) {
      _setOrientation(previousRoute!.settings.arguments as ScreenOrientation);
    } else {
      _setOrientation(ScreenOrientation.portraitOnly);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print(route.settings.arguments);
    if (route.settings.arguments is ScreenOrientation) {
      _setOrientation(route.settings.arguments as ScreenOrientation);
    } else {
      _setOrientation(ScreenOrientation.portraitOnly);
    }
  }
}
