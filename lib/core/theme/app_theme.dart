import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = _build(Brightness.light);
  static ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness b) => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: b,
        appBarTheme: const AppBarTheme(centerTitle: false),
      );
}