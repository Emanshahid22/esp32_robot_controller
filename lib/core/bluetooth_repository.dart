import 'dart:async';
import 'dart:typed_data';

import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';

/// Well-known Serial Port Profile UUID. This is the UUID the ESP32's
/// BluetoothSerial library registers by default, so it's what we ask for
/// when opening the RFCOMM connection.
const String sppUuid = '00001101-0000-1000-8000-00805f9b34fb';

/// Connection lifecycle as understood by this app.
///
/// The native plugin only ever reports `connected` / `disconnected` via
/// [BluetoothClassic.onDeviceStatusChanged]; we track the in-between
/// `connecting` state ourselves so the UI can show an honest "Connecting…"
/// indicator instead of jumping straight from red to green.
enum BtConnectionState { disconnected, connecting, connected }

/// Thin wrapper around the `bluetooth_classic` plugin.
///
/// Keeping all direct plugin calls behind this class means the rest of the
/// app (providers, screens, widgets) never has to know that the underlying
/// API is method-channel based — it just sees clean Dart streams and
/// futures. If you ever swap Bluetooth packages, this is the only file that
/// needs to change.
class BluetoothRepository {
  BluetoothRepository() {
    _statusSub = _plugin.onDeviceStatusChanged().listen((status) {
      final isConnected = status == Device.connected;
      _connectionStateController.add(
        isConnected
            ? BtConnectionState.connected
            : BtConnectionState.disconnected,
      );
    });

    _dataSub = _plugin.onDeviceDataReceived().listen((Uint8List bytes) {
      _incomingDataController.add(String.fromCharCodes(bytes));
    });
  }

  final BluetoothClassic _plugin = BluetoothClassic();

  StreamSubscription<int>? _statusSub;
  StreamSubscription<Uint8List>? _dataSub;
  StreamSubscription<Device>? _discoverySub;

  final _connectionStateController =
      StreamController<BtConnectionState>.broadcast();
  final _incomingDataController = StreamController<String>.broadcast();
  final _discoveredDevicesController = StreamController<Device>.broadcast();

  /// Connection state changes (disconnected / connecting / connected).
  Stream<BtConnectionState> get connectionState =>
      _connectionStateController.stream;

  /// Raw text received back from the robot over the serial link (useful for
  /// debugging — e.g. printing ultrasonic distance or line-sensor state
  /// from the firmware, if you choose to send any back).
  Stream<String> get incomingData => _incomingDataController.stream;

  /// Devices discovered while a scan is active.
  Stream<Device> get discoveredDevices => _discoveredDevicesController.stream;

  /// Requests the Bluetooth + location runtime permissions the plugin
  /// needs. Safe to call multiple times.
  Future<bool> requestPermissions() async {
    try {
      await _plugin.initPermissions();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Device>> getPairedDevices() => _plugin.getPairedDevices();

  Future<void> startScan() async {
    await _discoverySub?.cancel();
    _discoverySub = _plugin.onDeviceDiscovered().listen(
      (device) => _discoveredDevicesController.add(device),
    );
    await _plugin.startScan();
  }

  Future<void> stopScan() async {
    await _plugin.stopScan();
    await _discoverySub?.cancel();
    _discoverySub = null;
  }

  Future<void> connect(Device device) async {
    _connectionStateController.add(BtConnectionState.connecting);
    try {
      await _plugin.connect(device.address, sppUuid);
    } catch (e) {
      _connectionStateController.add(BtConnectionState.disconnected);
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      await _plugin.disconnect();
    } finally {
      _connectionStateController.add(BtConnectionState.disconnected);
    }
  }

  /// Sends a single command string (e.g. `'F'`, `'S'`, `'M'`) down the
  /// serial link. Matches the single-character protocol the Arduino sketch
  /// expects.
  Future<void> sendCommand(String command) => _plugin.write(command);

  void dispose() {
    _statusSub?.cancel();
    _dataSub?.cancel();
    _discoverySub?.cancel();
    _connectionStateController.close();
    _incomingDataController.close();
    _discoveredDevicesController.close();
  }
}
