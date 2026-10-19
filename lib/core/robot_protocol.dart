/// Single-character serial commands understood by the ESP32 firmware
/// (the Arduino sketch running on BluetoothSerial).
class RobotCommand {
  RobotCommand._();

  static const String forward = 'F';
  static const String backward = 'B';
  static const String left = 'L';
  static const String right = 'R';
  static const String stop = 'S';

  static const String manualMode = 'M';
  static const String lineFollowerMode = 'W';
  static const String obstacleAvoidanceMode = 'U';
}

/// The robot's current high-level operating mode, mirrored on-device.
enum RobotMode { none, manual, lineFollower, obstacleAvoidance }

extension RobotModeX on RobotMode {
  /// The single-character command sent to switch the robot into this mode.
  /// `null` for [RobotMode.none], which is a local-only "nothing selected
  /// yet" state with no on-wire equivalent.
  String? get command {
    switch (this) {
      case RobotMode.manual:
        return RobotCommand.manualMode;
      case RobotMode.lineFollower:
        return RobotCommand.lineFollowerMode;
      case RobotMode.obstacleAvoidance:
        return RobotCommand.obstacleAvoidanceMode;
      case RobotMode.none:
        return null;
    }
  }

  String get label {
    switch (this) {
      case RobotMode.manual:
        return 'Manual';
      case RobotMode.lineFollower:
        return 'Line Follower';
      case RobotMode.obstacleAvoidance:
        return 'Obstacle Avoidance';
      case RobotMode.none:
        return 'None';
    }
  }
}
