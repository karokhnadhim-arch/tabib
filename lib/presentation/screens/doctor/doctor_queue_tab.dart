import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/queue_entry.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/queue_status_utils.dart';
import 'doctor_queue_patient_panel.dart';
import 'doctor_today_queue.dart';
import 'doctor_visit_notes_store.dart';

/// Read-only today's queue with selectable patient workspace for the doctor.
class DoctorQueueTab extends StatefulWidget {
  const DoctorQueueTab({super.key, required this.doctorId});

  final String doctorId;

  @override
  State<DoctorQueueTab> createState() => _DoctorQueueTabState();
}

class _DoctorQueueTabState extends State<DoctorQueueTab> {
  final _notesStore = DoctorVisitNotesStore();
  final _aggregator = DoctorTodayQueueAggregator();
  String? _selectedEntryId;
  Stream<List<QueueEntry>>? _todayStream;
  StreamSubscription<List<QueueEntry>>? _streamSub;
  List<QueueEntry> _todayQueue = const [];
  bool _streamReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attachStream());
  }

  void _attachStream() {
    final queueService = context.read<QueueService>();
    final secretaryStream = Stream<List<QueueEntry>>.multi((multi) {
      void emit() => multi.add(queueService.secretaryQueueForDoctor(widget.doctorId));
      emit();
      void listener() => emit();
      queueService.addListener(listener);
      multi.onCancel = () => queueService.removeListener(listener);
    });

    _todayStream = _aggregator.watchTodayQueue(
      secretaryStream: secretaryStream,
      doctorId: widget.doctorId,
    );

    _streamSub = _todayStream!.listen(
      (entries) {
        if (!mounted) return;
        setState(() {
          _todayQueue = entries;
          _streamReady = true;
          _selectedEntryId = _resolveSelection(entries, _selectedEntryId);
        });
      },
      onError: (_) {
        if (!mounted) return;
        final fallback = doctorTodayQueueFromService(
          secretaryQueue: queueService.secretaryQueueForDoctor(widget.doctorId),
          activeQueue: queueService.queueForDoctor(widget.doctorId),
        );
        setState(() {
          _todayQueue = fallback;
          _streamReady = true;
          _selectedEntryId = _resolveSelection(fallback, _selectedEntryId);
        });
      },
    );
  }

  String? _resolveSelection(List<QueueEntry> entries, String? currentId) {
    if (entries.isEmpty) return null;
    if (currentId != null && entries.any((e) => e.id == currentId)) {
      return currentId;
    }
    for (final e in entries) {
      if (e.status == QueueStatus.inProgress) return e.id;
    }
    for (final e in entries) {
      if (e.status == QueueStatus.waiting) return e.id;
    }
    return entries.first.id;
  }

  QueueEntry? get _selectedEntry {
    final id = _selectedEntryId;
    if (id == null) return null;
    for (final e in _todayQueue) {
      if (e.id == id) return e;
    }
    return null;
  }

  QueueEntry? get _roomPatient {
    for (final e in _todayQueue) {
      if (e.status == QueueStatus.inProgress) return e;
    }
    return null;
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _notesStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final doctor = data.doctorById(widget.doctorId);
    final doctorName = doctor?.name.localized(context) ?? widget.doctorId;
    final selected = _selectedEntry;
    final roomPatient = _roomPatient;

    if (!_streamReady) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_todayQueue.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.noPatientsInQueue,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 880;
        final list = _QueueList(
          entries: _todayQueue,
          selectedId: _selectedEntryId,
          roomPatientId: roomPatient?.id,
          onSelect: (id) => setState(() => _selectedEntryId = id),
        );

        final panel = selected == null
            ? _SelectPatientPlaceholder(message: l10n.selectPatientFromQueue)
            : DoctorQueuePatientPanel(
                key: ValueKey(selected.id),
                entry: selected,
                doctorId: widget.doctorId,
                doctorName: doctorName,
                notesStore: _notesStore,
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QueueHintBanner(message: l10n.doctorQueueViewOnlyHint),
            const SizedBox(height: 12),
            Text(
              l10n.todaysQueue,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 5, child: list),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 7,
                          child: SingleChildScrollView(child: panel),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (selected != null) ...[
                          panel,
                          const SizedBox(height: 12),
                        ],
                        Expanded(child: list),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _QueueHintBanner extends StatelessWidget {
  const _QueueHintBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: scheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectPatientPlaceholder extends StatelessWidget {
  const _SelectPatientPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(Icons.touch_app_outlined, size: 40, color: scheme.primary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueList extends StatelessWidget {
  const _QueueList({
    required this.entries,
    required this.selectedId,
    required this.roomPatientId,
    required this.onSelect,
  });

  final List<QueueEntry> entries;
  final String? selectedId;
  final String? roomPatientId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _QueueListTile(
          entry: entry,
          isSelected: entry.id == selectedId,
          isInRoom: entry.id == roomPatientId,
          onTap: () => onSelect(entry.id),
        );
      },
    );
  }
}

class _QueueListTile extends StatelessWidget {
  const _QueueListTile({
    required this.entry,
    required this.isSelected,
    required this.isInRoom,
    required this.onTap,
  });

  final QueueEntry entry;
  final bool isSelected;
  final bool isInRoom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isCompleted = entry.status == QueueStatus.completed;
    final statusColor = entry.status.color();

    Color? background;
    BorderSide border;
    if (isSelected) {
      background = AppTheme.doctorColor.withOpacity(0.12);
      border = BorderSide(color: AppTheme.doctorColor, width: 2);
    } else if (isInRoom) {
      background = AppTheme.medicalGreen.withOpacity(0.08);
      border = BorderSide(color: AppTheme.medicalGreen.withOpacity(0.55));
    } else if (isCompleted) {
      background = scheme.surfaceContainerHighest.withOpacity(0.55);
      border = BorderSide(color: scheme.outlineVariant.withOpacity(0.35));
    } else {
      background = scheme.surface;
      border = BorderSide(color: scheme.outlineVariant.withOpacity(0.45));
    }

    return Material(
      color: background,
      elevation: isSelected ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              _PositionBadge(
                position: entry.position,
                isCompleted: isCompleted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.patientName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.status.label(l10n),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle, color: AppTheme.medicalGreen)
              else if (isInRoom)
                Icon(Icons.meeting_room_outlined, color: AppTheme.medicalGreen, size: 22)
              else if (isSelected)
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _PositionBadge extends StatelessWidget {
  const _PositionBadge({
    required this.position,
    required this.isCompleted,
  });

  final int position;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.medicalGreen.withOpacity(0.15)
            : AppTheme.doctorColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? const Icon(Icons.check_rounded, color: AppTheme.medicalGreen, size: 22)
          : Text(
              '$position',
              style: TextStyle(
                color: isCompleted ? AppTheme.medicalGreen : AppTheme.doctorColor,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
    );
  }
}
