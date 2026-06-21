/// Sakhi AI theme configuration.
///
/// Provides centralized text styles using Poppins and Hind fonts (via
/// Google Fonts) and builds the app-wide [ThemeData] with a dark theme
/// featuring gold and green palette colors.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';

/// Utility class for Sakhi AI text styles and theme construction.
///
/// All methods are static. Use [poppins] and [hind] to create styled
/// [TextStyle] objects, or call [build] to generate the full [ThemeData].
abstract final class SakhiTheme {
  /// Returns a [TextStyle] using the Poppins font.
  ///
  /// Defaults to 16px, medium weight (w500), and cream color if not specified.
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

  /// Returns a [TextStyle] using the Hind font.
  ///
  /// Defaults to 16px, semi-bold weight (w600), and cream color if not
  /// specified. Hind is used primarily for Indic-language text rendering.
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

  /// Constructs the app-wide [ThemeData] for Sakhi AI.
  ///
  /// Uses Material 3, dark brightness, deep-green scaffold background,
  /// gold primary, and card-green secondary. Defines headline and body
  /// text styles using [poppins].
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
