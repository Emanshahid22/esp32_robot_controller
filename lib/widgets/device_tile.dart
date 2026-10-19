import 'package:flutter/material.dart';
import 'package:bluetooth_classic/models/device.dart';

/// A single row in the discovered/paired device list.
class DeviceTile extends StatelessWidget {
  const DeviceTile({
    super.key,
    required this.device,
    required this.onTap,
    this.highlighted = false,
  });

  final Device device;
  final VoidCallback onTap;

  /// Set when this device's name matches the robot's expected name
  /// ("ESP32_Robot_Car"), so it stands out in the list.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = (device.name?.isNotEmpty ?? false) ? device.name! : 'Unknown device';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: highlighted ? scheme.primaryContainer.withValues(alpha: 0.35) : null,
      child: ListTile(
        leading: Icon(
          Icons.directions_car_filled,
          color: highlighted ? scheme.primary : Colors.grey,
        ),
        title: Text(name),
        subtitle: Text(device.address),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
