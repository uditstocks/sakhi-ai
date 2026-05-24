import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sakhi_ai/screens/home_screen.dart';
import 'package:sakhi_ai/theme/sakhi_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SakhiApp());
}

class SakhiApp extends StatelessWidget {
  const SakhiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sakhi AI',
      debugShowCheckedModeBanner: false,
      theme: SakhiTheme.build(),
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
