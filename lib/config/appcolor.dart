import 'package:flutter/material.dart';

class AppColors {
  static const Color lightBackground = Colors.white;
  static const Color lightText = Colors.black;
  static const Color lightCard = Color(0xFFF5F5F5);
  static const Color lightPrimary = Colors.red;
  static const Color lightSoftContainer = Color.fromARGB(255, 222, 222, 222);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkText = Colors.white;
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkPrimary = Colors.red;
  static const Color darkSoftContainer = Color.fromARGB(255, 47, 47, 47);

  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color text(bool isDark) => isDark ? darkText : lightText;

  static Color card(bool isDark) => isDark ? darkCard : lightCard;

  static Color primary(bool isDark) => isDark ? darkPrimary : lightPrimary;

  static Color softcontainer(bool isDark) =>
      isDark ? darkSoftContainer : lightSoftContainer;
}
