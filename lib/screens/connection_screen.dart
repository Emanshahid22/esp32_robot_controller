import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esp32_robot_controller/providers/robot_providers.dart';
import 'package:esp32_robot_controller/screens/robot_control_deck_screen.dart'; // Import the new screen

class ConnectionScreen extends ConsumerWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(bluetoothStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32 Robot Car'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 6,
              backgroundColor: connectionStatus == "Connected" 
                  ? Colors.green 
                  : (kIsWeb ? Colors.amber : Colors.red),
            ),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.directions_car_rounded,
                size: 80,
                color: Color(0xFF00BFA6),
              ),
              const SizedBox(height: 24),
              Text(
                connectionStatus,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA6),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Navigate straight to the controller interface screen for testing!
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RobotControlDeckScreen(),
                      ),
                    );
                  },
                  child: Text(
                    kIsWeb ? 'Enter UI Preview Deck' : 'Grant Permissions & Connect',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}