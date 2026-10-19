import 'package:flutter/material.dart';

import '../core/robot_protocol.dart';

/// The three mode buttons: Manual ('M'), Line Follower ('W'), and
/// Obstacle Avoidance ('U').
class ModeSelector extends StatelessWidget {
  const ModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
  });

  final RobotMode selectedMode;
  final void Function(RobotMode mode) onModeSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _ModeChip(
            label: 'Manual',
            icon: Icons.gamepad,
            selected: selectedMode == RobotMode.manual,
            onTap: () => onModeSelected(RobotMode.manual),
          ),
          _ModeChip(
            label: 'Line Follower',
            icon: Icons.timeline,
            selected: selectedMode == RobotMode.lineFollower,
            onTap: () => onModeSelected(RobotMode.lineFollower),
          ),
          _ModeChip(
            label: 'Obstacle Avoidance',
            icon: Icons.sensors,
            selected: selectedMode == RobotMode.obstacleAvoidance,
            onTap: () => onModeSelected(RobotMode.obstacleAvoidance),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: scheme.primary,
      labelStyle: TextStyle(
        color: selected ? scheme.onPrimary : scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
