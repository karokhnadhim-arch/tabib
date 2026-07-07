import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/queue_entry.dart';
import '../../../utils/queue_status_utils.dart';
import '../../providers/app_providers.dart';
import 'doctor_workspace_constants.dart';

/// Left panel — today's queue with active patients and collapsed completed list.
class DoctorQueuePanel extends StatefulWidget {
  const DoctorQueuePanel({
    super.key,
    required this.entries,
    required this.selectedId,
    required this.roomPatientId,
    required this.investigationProvider,
    required this.onSelect,
  });

  final List<QueueEntry> entries;
  final String? selectedId;
  final String? roomPatientId;
  final InvestigationRequestProvider investigationProvider;
  final ValueChanged<String> onSelect;

  @override
  State<DoctorQueuePanel> createState() => _DoctorQueuePanelState();
}

class _DoctorQueuePanelState extends State<DoctorQueuePanel> {
  bool _completedExpanded = false;

  List<QueueEntry> get _active => widget.entries
      .where(
        (e) =>
            e.status != QueueStatus.completed &&
            e.status != QueueStatus.cancelled,
      )
      .toList();

  List<QueueEntry> get _completed => widget.entries
      .where((e) => e.status == QueueStatus.completed)
      .toList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DoctorWorkspaceConstants.panelRadius),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.people_outline_rounded, color: scheme.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.todaysQueue,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                  ),
                ),
                _CountChip(label: '${_active.length}', emphasized: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.activeQueueSection,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              children: [
                if (_active.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.noPatientsInQueue,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  )
                else
                  ..._active.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _QueuePatientTile(
                        entry: entry,
                        isSelected: entry.id == widget.selectedId,
                        isInRoom: entry.id == widget.roomPatientId,
                        pendingInvestigationCount: widget.investigationProvider
                                .requestForQueueEntry(entry.id)
                                ?.pendingItems
                                .length ??
                            0,
                        onTap: () => widget.onSelect(entry.id),
                      ),
                    ),
                  ),
                if (_completed.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () =>
                        setState(() => _completedExpanded = !_completedExpanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _completedExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.completedToday,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          _CountChip(label: '${_completed.length}'),
                        ],
                      ),
                    ),
                  ),
                  if (_completedExpanded)
                    ..._completed.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _QueuePatientTile(
                          entry: entry,
                          isSelected: entry.id == widget.selectedId,
                          isInRoom: false,
                          pendingInvestigationCount: 0,
                          onTap: () => widget.onSelect(entry.id),
                          compact: true,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, this.emphasized = false});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: emphasized
            ? scheme.primaryContainer.withOpacity(0.65)
            : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: emphasized ? scheme.primary : scheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _QueuePatientTile extends StatelessWidget {
  const _QueuePatientTile({
    required this.entry,
    required this.isSelected,
    required this.isInRoom,
    required this.pendingInvestigationCount,
    required this.onTap,
    this.compact = false,
  });

  final QueueEntry entry;
  final bool isSelected;
  final bool isInRoom;
  final int pendingInvestigationCount;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isCompleted = entry.status == QueueStatus.completed;
    final isReturned = entry.status == QueueStatus.review;
    final statusColor = entry.status.color();

    final background = isSelected
        ? AppTheme.doctorColor.withOpacity(0.12)
        : isInRoom
            ? AppTheme.medicalGreen.withOpacity(0.08)
            : isReturned
                ? Colors.orange.shade50.withOpacity(0.7)
                : scheme.surfaceContainerLow;

    final borderColor = isSelected
        ? AppTheme.doctorColor
        : isInRoom
            ? AppTheme.medicalGreen.withOpacity(0.45)
            : scheme.outlineVariant.withOpacity(0.35);

    return Material(
      color: background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: isSelected ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: compact ? 8 : 12,
          ),
          child: Row(
            children: [
              _QueueNumberBadge(
                position: entry.position,
                isCompleted: isCompleted,
                compact: compact,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: compact ? 13 : 15,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? scheme.onSurfaceVariant
                                : scheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            entry.status.label(l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    if (pendingInvestigationCount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.investigationRequestCount(pendingInvestigationCount),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.medicalBlue,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isCompleted)
                Icon(Icons.check_circle_rounded,
                    color: AppTheme.medicalGreen.withOpacity(0.85), size: 20)
              else if (isInRoom)
                Icon(Icons.meeting_room_outlined,
                    color: AppTheme.medicalGreen, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueNumberBadge extends StatelessWidget {
  const _QueueNumberBadge({
    required this.position,
    required this.isCompleted,
    this.compact = false,
  });

  final int position;
  final bool isCompleted;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 36.0 : 44.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.medicalGreen.withOpacity(0.15)
            : AppTheme.doctorColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? Icon(Icons.check_rounded,
              color: AppTheme.medicalGreen, size: compact ? 18 : 22)
          : Text(
              '$position',
              style: TextStyle(
                color: AppTheme.doctorColor,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 14 : 16,
              ),
            ),
    );
  }
}
