import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class SetupValues extends ChangeNotifier {
  double? maxHeight;
  double? minHeight;
  double? refHeight;
  List<int>? homePlate;
  List<int>? referencePoint;
  List<int>? pitchersMound;
  double? averagePixelLength;

  void setPoints(List<int> homePlate, List<int> referencePoint, List<int> pitchersMound){
    this.homePlate = homePlate;
    this.referencePoint = referencePoint;
    this.pitchersMound = pitchersMound;
    this.averagePixelLength = refHeight! / (referencePoint[0] - homePlate[0]);
    notifyListeners();
  }
  void setHeights(double max, double min, double ref) {
    maxHeight = max;
    minHeight = min;
    refHeight = ref;

    notifyListeners();
  }
}
