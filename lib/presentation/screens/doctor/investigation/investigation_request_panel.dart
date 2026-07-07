import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/investigation_request_item.dart';
import '../doctor_consultation_widgets.dart';
import 'doctor_investigation_composer.dart';

/// Opens investigation selection in a right drawer (desktop) or full sheet (mobile).
Future<bool> showInvestigationRequestPanel({
  required BuildContext context,
  required List<InvestigationRequestItem> initialItems,
  required Future<void> Function(List<InvestigationRequestItem> items) onSave,
  bool readOnly = false,
  void Function(List<InvestigationRequestItem> items)? onPrint,
}) async {
  final panel = _InvestigationRequestPanel(
    initialItems: initialItems,
    readOnly: readOnly,
    onSave: onSave,
    onPrint: onPrint,
  );

  if (isClinicalDesktop(context)) {
    return await showGeneralDialog<bool>(
          context: context,
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
          transitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (context, _, __) => Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Material(
              elevation: 12,
              shadowColor: Colors.black26,
              clipBehavior: Clip.antiAlias,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: SizedBox(
                width: 440,
                height: MediaQuery.sizeOf(context).height,
                child: panel,
              ),
            ),
          ),
          transitionBuilder: (context, animation, _, child) {
            final offset = Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));
            return SlideTransition(position: offset, child: child);
          },
        ) ??
        false;
  }

  return await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        builder: (ctx) => SizedBox(
          height: MediaQuery.sizeOf(ctx).height * 0.94,
          child: panel,
        ),
      ) ??
      false;
}

class _InvestigationRequestPanel extends StatefulWidget {
  const _InvestigationRequestPanel({
    required this.initialItems,
    required this.onSave,
    required this.readOnly,
    this.onPrint,
  });

  final List<InvestigationRequestItem> initialItems;
  final Future<void> Function(List<InvestigationRequestItem> items) onSave;
  final bool readOnly;
  final void Function(List<InvestigationRequestItem> items)? onPrint;

  @override
  State<_InvestigationRequestPanel> createState() =>
      _InvestigationRequestPanelState();
}

class _InvestigationRequestPanelState extends State<_InvestigationRequestPanel> {
  late List<InvestigationRequestItem> _draft;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _draft = List<InvestigationRequestItem>.from(widget.initialItems);
  }

  Future<void> _handleSave() async {
    if (widget.readOnly || _saving) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(_draft);
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
          child: Row(
            children: [
              Icon(Icons.biotech_outlined, color: scheme.primary, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.requestInvestigation,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                    ),
                    if (_draft.isNotEmpty)
                      Text(
                        l10n.investigationRequestCount(_draft.length),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
              if (widget.onPrint != null && _draft.isNotEmpty)
                IconButton(
                  tooltip: l10n.printInvestigationRequest,
                  icon: const Icon(Icons.print_outlined),
                  onPressed: () => widget.onPrint!(_draft),
                ),
              IconButton(
                tooltip: l10n.cancelLabel,
                icon: const Icon(Icons.close_rounded),
                onPressed: _handleCancel,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: scheme.outlineVariant.withOpacity(0.4)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: DoctorInvestigationComposer(
              items: _draft,
              readOnly: widget.readOnly,
              onItemsChanged: (items) => setState(() => _draft = items),
            ),
          ),
        ),
        Divider(height: 1, color: scheme.outlineVariant.withOpacity(0.4)),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                TextButton(
                  onPressed: _saving ? null : _handleCancel,
                  child: Text(l10n.cancelLabel),
                ),
                const Spacer(),
                if (!widget.readOnly)
                  FilledButton.icon(
                    onPressed: _saving ? null : _handleSave,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded, size: 20),
                    label: Text(l10n.save),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.doctorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  FilledButton(
                    onPressed: _handleCancel,
                    child: Text(l10n.cancelLabel),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact action button with investigation count badge for the consultation workspace.
class InvestigationRequestActionButton extends StatelessWidget {
  const InvestigationRequestActionButton({
    super.key,
    required this.count,
    required this.onPressed,
    this.enabled = true,
  });

  final int count;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = count > 0
        ? l10n.investigationRequestCount(count)
        : l10n.requestInvestigation;

    final button = FilledButton.tonalIcon(
      onPressed: enabled ? onPressed : null,
      icon: const Icon(Icons.biotech_outlined, size: 22),
      label: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: DoctorConsultationTokens.cardRadius,
        ),
      ),
    );

    if (count <= 0) return button;

    return Badge(
      label: Text('$count'),
      backgroundColor: AppTheme.doctorColor,
      textColor: Colors.white,
      offset: const Offset(-4, -6),
      child: button,
    );
  }
}
