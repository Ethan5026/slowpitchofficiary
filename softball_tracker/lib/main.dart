import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:softball_tracker/setup.dart';
import 'package:softball_tracker/utils/RoutedPage.dart';
import 'package:softball_tracker/utils/constants.dart';
import 'package:softball_tracker/utils/review_arguments.dart';
import 'package:softball_tracker/utils/screen_orientation.dart';
import 'package:softball_tracker/utils/setup_values.dart';
import 'package:softball_tracker/views/yolo_screen.dart';
import 'package:softball_tracker/views/instructions_screen.dart';
import 'package:softball_tracker/views/past_pitches_screen.dart';
import 'package:softball_tracker/views/settings_screen.dart';
import 'package:softball_tracker/views/setup/setup_screen.dart';
import 'package:softball_tracker/views/start_screen.dart';
import 'package:softball_tracker/views/yolo_video_screen.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(    ChangeNotifierProvider(
    create: (_) => SetupValues(),
    child: MainApp(),
  ),
  );
}

RouteSettings rotationSettings(RouteSettings settings, rotation) {
  return RouteSettings(name: settings.name, arguments: rotation);
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final _observer = NavigationObserverWithOrientation();

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    if (settings.name == PAST_PITCHES_SCREEN) {
      return MaterialPageRoute(
          builder: (context) => const PastPitchesScreen(),
          settings: rotationSettings(settings, ScreenOrientation.portraitOnly));
    } else if (settings.name == SETTINGS_SCREEN) {
      return MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
          settings: rotationSettings(settings, ScreenOrientation.portraitOnly));
    } else if (settings.name == CAMERA_SCREEN) {
      // Lock CameraScreen to landscape-only
      return MaterialPageRoute(
          builder: (context) => YoloScreen(),
          settings: rotationSettings(settings, ScreenOrientation.portraitOnly));
    } else if (settings.name!.startsWith(SETUP_SCREEN)) {
      RoutedPage setupScreen = routeSetup(settings.name);
      return MaterialPageRoute(
          builder: (context) => setupScreen.widget,
          settings: rotationSettings(settings, setupScreen.rotationSettings));
    } else if (settings.name == INSTRUCTIONS_SCREEN){
      return MaterialPageRoute(
        builder: (context) => const InstructionsScreen(),
          settings: rotationSettings(settings, ScreenOrientation.portraitOnly)
      );
    } else if (settings.name == YOLO_VIDEO_SCREEN){
      return MaterialPageRoute(
        // might need to do => const YoloVideoScreen()
          builder: (context) => YoloVideoScreen(),
          settings: rotationSettings(settings, ScreenOrientation.portraitOnly));
    }
    else{
      return MaterialPageRoute(
          builder: (context) => const StartScreen(),
          settings: rotationSettings(settings, ScreenOrientation.portraitOnly));
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: _onGenerateRoute,
      navigatorObservers: [_observer],
    );
  }
}
