import 'package:flutter/material.dart';

abstract class Utils {
  static ThemeData mainTheme = ThemeData(
    primaryColor: Colors.black,
    accentColor: Colors.amber,
    iconTheme: IconThemeData(color: Colors.pink),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    backgroundColor: Colors.pink,
    //cursorColor: Colors.amber,
    cardColor: Colors.white,
    canvasColor: Colors.white,
  );
}
