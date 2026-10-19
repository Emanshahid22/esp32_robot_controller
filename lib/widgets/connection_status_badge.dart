import 'package:flutter/material.dart';

import '../core/bluetooth_repository.dart';

/// Small pill showing "Connected" (green) / "Connecting…" (orange) /
/// "Disconnected" (red), as required by the connection screen spec.
class ConnectionStatusBadge extends StatelessWidget {
  const ConnectionStatusBadge({super.key, required this.state});

  final BtConnectionState state;

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (state) {
      BtConnectionState.connected => (Colors.green, 'Connected'),
      BtConnectionState.connecting => (Colors.orange, 'Connecting…'),
      BtConnectionState.disconnected => (Colors.red, 'Disconnected'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
