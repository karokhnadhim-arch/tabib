import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom intent carrying a shortcut action index.
class ClinicalShortcutIntent extends Intent {
  const ClinicalShortcutIntent(this.index);
  final int index;
}

/// Keyboard shortcuts for clinical desktop workspaces.
abstract final class ClinicalShortcuts {
  static const searchIntent = ClinicalShortcutIntent(0);
  static const queueTabIntent = ClinicalShortcutIntent(1);
  static const registerTabIntent = ClinicalShortcutIntent(2);
  static const scheduleTabIntent = ClinicalShortcutIntent(3);
  static const recordsTabIntent = ClinicalShortcutIntent(4);

  static Map<ShortcutActivator, Intent> doctorMap() => {
        const SingleActivator(LogicalKeyboardKey.digit1, control: true):
            const ClinicalShortcutIntent(1),
        const SingleActivator(LogicalKeyboardKey.digit2, control: true):
            const ClinicalShortcutIntent(2),
        const SingleActivator(LogicalKeyboardKey.digit3, control: true):
            const ClinicalShortcutIntent(3),
        const SingleActivator(LogicalKeyboardKey.digit4, control: true):
            const ClinicalShortcutIntent(4),
      };

  static Map<ShortcutActivator, Intent> secretaryMap() => {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            searchIntent,
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            registerTabIntent,
        const SingleActivator(LogicalKeyboardKey.digit1, control: true):
            queueTabIntent,
        const SingleActivator(LogicalKeyboardKey.digit2, control: true):
            registerTabIntent,
        const SingleActivator(LogicalKeyboardKey.digit3, control: true):
            scheduleTabIntent,
      };
}

/// Wraps clinical content with desktop keyboard shortcuts.
class ClinicalShortcutScope extends StatelessWidget {
  const ClinicalShortcutScope({
    super.key,
    required this.shortcuts,
    required this.onAction,
    required this.child,
  });

  final Map<ShortcutActivator, Intent> shortcuts;
  final ValueChanged<int> onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: {
          ClinicalShortcutIntent: CallbackAction<ClinicalShortcutIntent>(
            onInvoke: (intent) {
              onAction(intent.index);
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}
