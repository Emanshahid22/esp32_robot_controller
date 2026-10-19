import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';

// Provide the main Bluetooth instance safely
final bluetoothPluginProvider = Provider<BluetoothClassic>((ref) {
  return BluetoothClassic();
});

// Modern Riverpod Notifier for managing connection state strings
class BluetoothStateNotifier extends Notifier<String> {
  late final BluetoothClassic _plugin;

  @override
  String build() {
    _plugin = ref.watch(bluetoothPluginProvider);
    _initBluetoothStreams();
    
    // Default starting state based on platform
    return kIsWeb ? "UI Preview Mode (No Bluetooth)" : "Disconnected";
  }

  void _initBluetoothStreams() {
    // WEB GUARD: Skip mobile streams if running inside a web browser
    if (kIsWeb) return;

    // This section will only execute on a physical Android phone
    _plugin.onDeviceStatusChanged().listen((status) {
      switch (status) {
        case 0:
          state = "Disconnected";
          break;
        case 1:
          state = "Connecting...";
          break;
        case 2:
          state = "Connected";
          break;
        default:
          state = "Disconnected";
      }
    });
  }

  Future<void> connectToDevice(String address) async {
    if (kIsWeb) return; // Prevent connecting on web browser
    state = "Connecting...";
    try {
      await _plugin.connect(address, "00001101-0000-1000-8000-00805F9B34FB");
    } catch (e) {
      state = "Connection Failed";
    }
  }

  Future<void> disconnectDevice() async {
    if (kIsWeb) return;
    await _plugin.disconnect();
    state = "Disconnected";
  }
}

// Modern Riverpod NotifierProvider registration
final bluetoothStateProvider = NotifierProvider<BluetoothStateNotifier, String>(() {
  return BluetoothStateNotifier();
});