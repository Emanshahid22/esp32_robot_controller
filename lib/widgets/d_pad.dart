import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/robot_protocol.dart';

/// The manual-drive control surface: four directional buttons that send
/// their command on press and 'S' (stop) on release, plus a dedicated
/// Stop button.
class DPad extends StatelessWidget {
  const DPad({
    super.key,
    required this.onDirectionDown,
    required this.onDirectionUp,
    required this.onStopPressed,
  });

  /// Called with 'F' / 'B' / 'L' / 'R' the instant a direction button is
  /// pressed.
  final void Function(String command) onDirectionDown;

  /// Called when a direction button is released or the press is cancelled
  /// (e.g. finger dragged off the button) — sends 'S'.
  final VoidCallback onDirectionUp;

  /// Called when the dedicated round Stop button is tapped.
  final VoidCallback onStopPressed;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(width: 12, height: 12);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DirectionButton(
          icon: Icons.keyboard_arrow_up,
          command: RobotCommand.forward,
          onDown: onDirectionDown,
          onUp: onDirectionUp,
        ),
        gap,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DirectionButton(
              icon: Icons.keyboard_arrow_left,
              command: RobotCommand.left,
              onDown: onDirectionDown,
              onUp: onDirectionUp,
            ),
            gap,
            _StopButton(onPressed: onStopPressed),
            gap,
            _DirectionButton(
              icon: Icons.keyboard_arrow_right,
              command: RobotCommand.right,
              onDown: onDirectionDown,
              onUp: onDirectionUp,
            ),
          ],
        ),
        gap,
        _DirectionButton(
          icon: Icons.keyboard_arrow_down,
          command: RobotCommand.backward,
          onDown: onDirectionDown,
          onUp: onDirectionUp,
        ),
      ],
    );
  }
}

class _DirectionButton extends StatefulWidget {
  const _DirectionButton({
    required this.icon,
    required this.command,
    required this.onDown,
    required this.onUp,
  });

  final IconData icon;
  final String command;
  final void Function(String command) onDown;
  final VoidCallback onUp;

  @override
  State<_DirectionButton> createState() => _DirectionButtonState();
}

class _DirectionButtonState extends State<_DirectionButton> {
  bool _pressed = false;

  void _handleDown() {
    setState(() => _pressed = true);
    HapticFeedback.lightImpact();
    widget.onDown(widget.command);
  }

  void _handleUp() {
    if (!_pressed) return;
    setState(() => _pressed = false);
    widget.onUp();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => _handleDown(),
      onTapUp: (_) => _handleUp(),
      onTapCancel: _handleUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: _pressed ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          boxShadow: _pressed
              ? const []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Icon(
          widget.icon,
          size: 36,
          color: _pressed ? scheme.onPrimary : scheme.onSurface,
        ),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.stop, size: 32, color: Colors.white),
      ),
    );
  }
}
