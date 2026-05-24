import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';

abstract final class SakhiTheme {
  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? SakhiColors.cream,
      height: height,
    );
  }

  static TextStyle hind({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.hind(
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? SakhiColors.cream,
      height: height,
    );
  }

  static ThemeData build() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SakhiColors.deepGreen,
      colorScheme: const ColorScheme.dark(
        primary: SakhiColors.gold,
        secondary: SakhiColors.cardGreen,
        surface: SakhiColors.deepGreen,
        error: SakhiColors.sosRed,
      ),
      textTheme: TextTheme(
        headlineLarge: poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: SakhiColors.gold,
        ),
        bodyLarge: poppins(fontSize: 18, color: SakhiColors.cream),
        bodyMedium: poppins(fontSize: 16, color: SakhiColors.creamMuted),
      ),
    );
  }
}
