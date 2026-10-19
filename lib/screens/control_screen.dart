import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/bluetooth_repository.dart';
import '../core/robot_protocol.dart';
import '../providers/robot_providers.dart';
import '../widgets/connection_status_badge.dart';
import '../widgets/d_pad.dart';
import '../widgets/mode_selector.dart';

/// Main driving screen: mode selector up top, manual D-pad (only shown in
/// Manual mode) filling the rest of the screen.
class ControlScreen extends ConsumerWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState =
        ref.watch(connectionStateProvider).value ?? BtConnectionState.disconnected;
    final mode = ref.watch(selectedModeProvider);
    final controller = ref.watch(robotControllerProvider);

    // If the link drops while we're on this screen, fall back to the
    // connection screen automatically.
    ref.listen<AsyncValue<BtConnectionState>>(connectionStateProvider, (
      previous,
      next,
    ) {
      if (next.value == BtConnectionState.disconnected &&
          Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drive Controls'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: ConnectionStatusBadge(state: connectionState)),
          ),
          IconButton(
            tooltip: 'Disconnect',
            icon: const Icon(Icons.link_off),
            onPressed: () async {
              await controller.stop();
              await ref.read(bluetoothRepositoryProvider).disconnect();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ModeSelector(selectedMode: mode, onModeSelected: controller.setMode),
            const Divider(height: 32),
            Expanded(
              child: mode == RobotMode.manual
                  ? Center(
                      child: DPad(
                        onDirectionDown: controller.drive,
                        onDirectionUp: controller.stop,
                        onStopPressed: controller.stop,
                      ),
                    )
                  : _InactiveModeNotice(mode: mode),
            ),
          ],
        ),
      ),
    );
  }
}

class _InactiveModeNotice extends StatelessWidget {
  const _InactiveModeNotice({required this.mode});
  final RobotMode mode;

  @override
  Widget build(BuildContext context) {
    final message = mode == RobotMode.none
        ? 'Select a mode above to begin.'
        : '${mode.label} is now active on the robot.\n'
              'Switch to Manual to use the D-pad.';
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.grey),
        ),
      ),
    );
  }
}
