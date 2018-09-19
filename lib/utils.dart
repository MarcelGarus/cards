import 'package:flutter/material.dart';


abstract class Utils {
  static ThemeData buildLightTheme() {
    return ThemeData(
      backgroundColor: Colors.white,
      primaryColor: Colors.amber,
      accentColor: Colors.amber,
      brightness: Brightness.light,
    );
  }
}
