import 'package:flutter/cupertino.dart';
import 'package:softball_tracker/utils/screen_orientation.dart';

class RoutedPage {
  Widget widget;
  ScreenOrientation rotationSettings;
  RoutedPage(this.widget, this.rotationSettings);
}
