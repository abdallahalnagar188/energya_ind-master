import 'package:flutter/material.dart';

class MaterialController with ChangeNotifier {
  int materialStep = 0;
  changeEditMaterialStep(int i) {
    materialStep = i;
    notifyListeners();
  }
}
