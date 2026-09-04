import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do_list_app/core/constants/appcolor.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary(false),
    scaffoldBackgroundColor: AppColors.background(false),
    cardColor: AppColors.card(false),
    textTheme: GoogleFonts.notoSansKhmerTextTheme().apply(
      bodyColor: AppColors.text(false),
      displayColor: AppColors.text(false),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary(true),
    scaffoldBackgroundColor: AppColors.background(true),
    cardColor: AppColors.card(true),
    textTheme: GoogleFonts.notoSansKhmerTextTheme().apply(
      bodyColor: AppColors.text(true),
      displayColor: AppColors.text(true),
    ),
  );
}
