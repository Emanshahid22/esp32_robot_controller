# ESP32 Robot Controller (Flutter)

A Flutter app that connects to an ESP32 running `BluetoothSerial` (Classic
Bluetooth / SPP) and drives a 4WD robot car. Built against the spec: scan →
pick "ESP32_Robot_Car" → connect → pick a mode → drive.

## Why Flutter + `bluetooth_classic`, and why Android-only

**Classic Bluetooth (SPP/RFCOMM) cannot reach iOS.** iOS has no public API
for Bluetooth Classic — the only path in is the `ExternalAccessory`
framework, which requires the accessory to be Apple **MFi-certified**. A
bare ESP32 running `BluetoothSerial` is not, and never will be, MFi
certified. This isn't a package limitation — it's an iOS platform
restriction, so no Flutter, React Native, or App Inventor app can get
around it for this hardware. That's why this app targets **Android only**,
which fully satisfies your spec.

If you do need iOS support down the line, the practical fix is on the
firmware side, not the app side: switch the ESP32 to **Wi-Fi (a WebSocket
or TCP socket server)** instead of Classic Bluetooth. That protocol is
fully cross-platform and the Flutter side becomes a `web_socket_channel`
connection instead of a Bluetooth one — same UI, different transport.
Bluetooth **Low Energy** (BLE) is the other cross-platform option, but
would mean rewriting the ESP32 sketch around `BLEDevice`/`NimBLE-Arduino`
instead of `BluetoothSerial`.

I chose `bluetooth_classic` over the older, more commonly-referenced
`flutter_bluetooth_serial` because the latter is unmaintained and breaks on
modern Android Gradle/AndroidX and Android 12+'s permission model.
`bluetooth_classic` is small, actively maintained, and handles the new
runtime permissions cleanly.

## Project structure

```
lib/
├── main.dart                       # App entry point, theme, ProviderScope
├── core/
│   ├── robot_protocol.dart         # Single-char command constants + RobotMode enum
│   └── bluetooth_repository.dart   # Wraps the bluetooth_classic plugin
├── providers/
│   └── robot_providers.dart        # Riverpod providers + RobotController
├── screens/
│   ├── connection_screen.dart      # Scan / list / connect / status
│   └── control_screen.dart         # Mode selector + D-pad
└── widgets/
    ├── connection_status_badge.dart
    ├── device_tile.dart
    ├── mode_selector.dart
    └── d_pad.dart
```

`bluetooth_repository.dart` is the only file that talks to the native
plugin directly — everything else goes through Riverpod providers, so
swapping the Bluetooth package later only touches one file.

## Setup

1. **Create a Flutter project** (if you don't already have one) and copy
   this `lib/` folder and `pubspec.yaml` into it:
   ```bash
   flutter create --org com.yourname esp32_robot_controller
   cd esp32_robot_controller
   # now copy this project's lib/ and pubspec.yaml over the generated ones
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
   This pulls in:
   - `flutter_riverpod` — state management
   - `bluetooth_classic` — Bluetooth Classic (SPP) for Android
   - `cupertino_icons` — default Flutter icon set

3. **Android permissions** — merge the `<uses-permission>` block from
   `android_manifest_reference/AndroidManifest.xml` (included in this
   download) into your `android/app/src/main/AndroidManifest.xml`, just
   above the `<application>` tag. The reference file includes:
   - `BLUETOOTH` / `BLUETOOTH_ADMIN` (Android ≤ 11)
   - `BLUETOOTH_SCAN` / `BLUETOOTH_CONNECT` (Android 12+)
   - `ACCESS_FINE_LOCATION` (Android ≤ 11 — required by the OS to discover
     nearby devices on older versions)

4. **Minimum SDK version** — `bluetooth_classic` needs a reasonably recent
   Android API level. In `android/app/build.gradle`, make sure:
   ```gradle
   defaultConfig {
       minSdkVersion 23
   }
   ```

5. **Pair the robot first.** Classic Bluetooth on Android generally
   requires the device be *bonded* before an RFCOMM/SPP connection will
   succeed reliably. Go to your phone's system **Settings → Bluetooth**,
   pair with `ESP32_Robot_Car` (no PIN needed for the default
   `BluetoothSerial` setup), then open the app — it'll show up under
   "Paired Devices" immediately, highlighted.

6. **Run it:**
   ```bash
   flutter run
   ```

## How it maps to your spec

| Requirement | Implementation |
|---|---|
| Scan button | `FilledButton` on the connection screen, toggles `startScan()`/`stopScan()` |
| Discovered device list | "Paired Devices" + "Nearby Devices" sections, tap to connect |
| Connected/Disconnected indicator | `ConnectionStatusBadge` — green/orange/red pill in the AppBar |
| Manual Mode → `'M'` | `ModeSelector` chip → `RobotController.setMode(RobotMode.manual)` |
| Line Follower → `'W'` | Same pattern, `RobotMode.lineFollower` |
| Obstacle Avoidance → `'U'` | Same pattern, `RobotMode.obstacleAvoidance` |
| D-pad only active in Manual | `ControlScreen` shows `DPad` only when `mode == RobotMode.manual` |
| Forward/Back/Left/Right: press → char, release → `'S'` | `_DirectionButton` uses `onTapDown`/`onTapUp`/`onTapCancel` |
| Stop button → `'S'` | Dedicated round button in the center of the D-pad |

## Production-hardening notes

- **Auto-navigation on connect/disconnect**: the app pushes the control
  screen the instant `connectionState` reports `connected`, and pops back
  automatically if the link drops mid-drive — so a dropped connection
  can't leave you stuck on a dead control screen.
- **Permission flow**: permissions are requested on first launch; if
  denied, the connection screen shows a retry prompt instead of silently
  failing.
- **Haptics**: direction and stop buttons fire light/medium haptic
  feedback on press, which makes the D-pad feel much more responsive on a
  touchscreen with no physical buttons.
- **Write errors are swallowed, not surfaced as crashes** — if a single
  `write()` call fails because the link just dropped, the connection-state
  stream (driven by the plugin's native disconnect callback) is what
  actually tells the UI to bail out, rather than every individual write
  needing its own error UI.

### Things worth adding if you keep building this out

- **Command throttling**: if you later add a joystick/slider instead of
  discrete buttons, debounce writes (e.g. 50–100 ms) so you don't flood the
  SPP link.
- **Reconnect-on-drop**: currently a dropped connection sends you back to
  the connection screen; you could add an auto-reconnect-to-last-device
  option using `getPairedDevices()` + `connect()` on disconnect.
- **Telemetry display**: `incomingDataProvider` is already wired up to
  the plugin's `onDeviceDataReceived()` stream — if your sketch ever
  writes ultrasonic distance or IR sensor state back over serial, you can
  display it with one `Consumer` widget; nothing else needs to change.

## Expected ESP32-side protocol (for reference)

This app assumes your existing sketch (the one already broadcasting
`"ESP32_Robot_Car"` via `BluetoothSerial`) reads single ASCII characters
from the serial buffer and reacts to:

| Char | Meaning |
|---|---|
| `M` | Enter Manual mode |
| `W` | Enter Line Follower mode |
| `U` | Enter Obstacle Avoidance mode |
| `F` | Drive forward |
| `B` | Drive backward |
| `L` | Turn left |
| `R` | Turn right |
| `S` | Stop |

If your sketch's `Serial.read()` loop expects anything other than bare
single characters (e.g. a trailing newline), let me know and I'll adjust
`BluetoothRepository.sendCommand` accordingly — right now it sends the raw
character with no terminator.
