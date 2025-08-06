import 'package:flutter/material.dart';

class ScreenUtil {
  static late double _unitHeight;

  static void initialize(BuildContext context) {
    _unitHeight = MediaQuery.of(context).size.height / 1000;
  }

  static double get unitHeight => _unitHeight;



  
}
