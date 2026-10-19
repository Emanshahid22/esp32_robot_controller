import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esp32_robot_controller/providers/robot_providers.dart';

class RobotControlDeckScreen extends ConsumerStatefulWidget {
  const RobotControlDeckScreen({super.key});

  @override
  ConsumerState<RobotControlDeckScreen> createState() => _RobotControlDeckScreenState();
}

class _RobotControlDeckScreenState extends ConsumerState<RobotControlDeckScreen> {
  double _robotSpeed = 150; // Initial mock speed (0-255)
  String _lastCommandSent = "None";

  // Simulate sending a command to the ESP32 robot car
  void _sendControlCommand(String command) {
    setState(() {
      _lastCommandSent = command;
    });

    // Web Guard: Avoid calling mobile native platform channels during chrome previews
    if (kIsWeb) {
      debugPrint("MOCK BLUETOOTH COMMAND SENT: $command at speed ${_robotSpeed.toInt()}");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Robot Control Deck'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Live Telemetry Monitor Card
                Card(
                  color: const Color(0xFF161B22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF30363D), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Console Logging:", style: TextStyle(color: Colors.grey)),
                            Text(
                              kIsWeb ? "MOCK ACTIVE" : "LIVE LINK",
                              style: const TextStyle(color: Color(0xFF00BFA6), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Last Tx Stream Vector:", style: TextStyle(color: Colors.grey)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _lastCommandSent,
                                style: const TextStyle(
                                  color: Colors.amberAccent,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 2. Directional D-Pad Layout
                Center(
                  child: SizedBox(
                    width: 240,
                    height: 240,
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        const SizedBox.shrink(), // Top Left Empty
                        _buildDirectionButton(Icons.arrow_upward_rounded, "FORWARD"),
                        const SizedBox.shrink(), // Top Right Empty

                        _buildDirectionButton(Icons.arrow_back_rounded, "LEFT"),
                        
                        // Center STOP Button (FIXED ICON HERE)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.2),
                            foregroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Colors.redAccent, width: 1.5),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () => _sendControlCommand("STOP"),
                          child: const Icon(Icons.warning_amber_rounded, size: 28),
                        ),
                        _buildDirectionButton(Icons.arrow_forward_rounded, "RIGHT"),

                        const SizedBox.shrink(), // Bottom Left Empty
                        _buildDirectionButton(Icons.arrow_downward_rounded, "BACKWARD"),
                        const SizedBox.shrink(), // Bottom Right Empty
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 3. Hardware Speed Adjustment Slider (FIXED TEXT ALIGN HERE)
                const Text(
                  "Motor Drive Intensity (PWM)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                Row(
                  children: [
                    const Icon(Icons.speed_rounded, color: Colors.grey),
                    Expanded(
                      child: Slider(
                        value: _robotSpeed,
                        min: 0,
                        max: 255,
                        activeColor: const Color(0xFF00BFA6),
                        inactiveColor: const Color(0xFF30363D),
                        label: _robotSpeed.toInt().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _robotSpeed = value;
                          });
                        },
                      ),
                    ),
                    Text(
                      _robotSpeed.toInt().toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionButton(IconData icon, String cmdValue) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: const Color(0xFF00BFA6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF30363D), width: 1.5),
        ),
        padding: EdgeInsets.zero,
      ),
      onPressed: () => _sendControlCommand(cmdValue),
      child: Icon(icon, size: 32),
    );
  }
}