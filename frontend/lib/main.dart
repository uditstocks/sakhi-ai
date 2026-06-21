/// main.dart — App entry point for Sakhi AI Flutter application.
///
/// Initializes Flutter bindings, configures system UI overlay,
/// and launches the SakhiApp MaterialApp with custom theme and home screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sakhi_ai/screens/home_screen.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';



void main() {
  // Initialize Flutter engine bindings
  WidgetsFlutterBinding.ensureInitialized();
  // Set transparent status bar with light icons for the dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SakhiApp());
}

/// Root widget of the Sakhi AI application.
/// Configures MaterialApp with custom theme, text scaling, and home screen.
class SakhiApp extends StatelessWidget {
  const SakhiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sakhi AI',
      debugShowCheckedModeBanner: false,
      theme: SakhiTheme.build(),
      // Clamp text scaling between 1.0 and 1.35 for accessibility
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.35,
            ),
          ),
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
