import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your custom screen layout
import 'package:esp32_robot_controller/screens/connection_screen.dart';

void main() {
  // A quick check to log when running as a web/desktop UI mockup preview
  if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
    debugPrint("Running in UI Preview Mode — Bluetooth operations disabled.");
  }

  runApp(
    const ProviderScope(
      child: RobotControllerApp(),
    ),
  );
}

class RobotControllerApp extends StatelessWidget {
  const RobotControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Robot Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00BFA6),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E1116),
      ),
      home: const ConnectionScreen(),
    );
  }
}