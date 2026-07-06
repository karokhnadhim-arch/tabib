import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/queue_entry.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/queue_status_utils.dart';
import '../../providers/app_providers.dart';
import '../../widgets/doctor_patient_summary_panel.dart';
import '../../../services/firebase_bootstrap.dart';
import 'doctor_consultation_session.dart';
import 'doctor_consultation_workspace.dart';
import 'doctor_today_queue.dart';
import 'doctor_visit_notes_store.dart';

/// Read-only today's queue with consultation workspace for the doctor.
class DoctorQueueTab extends StatefulWidget {
  const DoctorQueueTab({super.key, required this.doctorId});

  final String doctorId;

  @override
  State<DoctorQueueTab> createState() => _DoctorQueueTabState();
}

class _DoctorQueueTabState extends State<DoctorQueueTab> {
  final _notesStore = DoctorVisitNotesStore();
  late final DoctorConsultationSession _session =
      DoctorConsultationSession(_notesStore);
  final _aggregator = DoctorTodayQueueAggregator(
    firestore: FirebaseBootstrap.initialized
        ? FirebaseFirestore.instance
        : null,
  );
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
    context.read<InvestigationRequestProvider>().watchDoctor(widget.doctorId);
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

  Future<void> _selectPatient(String entryId) async {
    final fromKey = _selectedEntryId == null
        ? null
        : DoctorVisitNotesStore.storageKey(
            doctorId: widget.doctorId,
            queueEntryId: _selectedEntryId!,
          );
    final toKey = DoctorVisitNotesStore.storageKey(
      doctorId: widget.doctorId,
      queueEntryId: entryId,
    );
    await _session.switchPatient(fromKey: fromKey, toKey: toKey);
    if (mounted) setState(() => _selectedEntryId = entryId);
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
    _session.dispose();
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
        final threePane = constraints.maxWidth >= AppConstants.threePaneBreakpoint;
        final wide = constraints.maxWidth >= 880;
        final list = _QueueList(
          entries: _todayQueue,
          selectedId: _selectedEntryId,
          roomPatientId: roomPatient?.id,
          investigationProvider: context.watch<InvestigationRequestProvider>(),
          onSelect: _selectPatient,
        );

        final workspace = selected == null
            ? _SelectPatientPlaceholder(message: l10n.selectPatientFromQueue)
            : DoctorConsultationWorkspace(
                key: ValueKey(selected.id),
                entry: selected,
                doctorId: widget.doctorId,
                doctorName: doctorName,
                session: _session,
                hidePatientSummary: threePane,
              );

        final summaryPanel = selected == null
            ? const SizedBox.shrink()
            : DoctorPatientSummaryPanel(
                entry: selected,
                doctorId: widget.doctorId,
                doctorName: doctorName,
                notesStore: _notesStore,
                storageKey: DoctorVisitNotesStore.storageKey(
                  doctorId: widget.doctorId,
                  queueEntryId: selected.id,
                ),
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isClinicalDesktop(context))
              _QueueHintBanner(message: l10n.doctorQueueViewOnlyHint),
            if (!isClinicalDesktop(context)) const SizedBox(height: 12),
            if (!isClinicalDesktop(context))
              Text(
                l10n.todaysQueue,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            if (!isClinicalDesktop(context)) const SizedBox(height: 10),
            Expanded(
              child: threePane
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: 280, child: list),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: workspace,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(width: 300, child: summaryPanel),
                      ],
                    )
                  : wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 4, child: list),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 6,
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: workspace,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Flexible(
                              flex: selected == null ? 0 : 5,
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: workspace,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(flex: 4, child: list),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: scheme.primary, size: 18),
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
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.45)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_outlined, size: 36, color: scheme.primary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _QueueList extends StatelessWidget {
  const _QueueList({
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
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
      cacheExtent: 320,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return RepaintBoundary(
          child: Padding(
            padding: EdgeInsets.only(bottom: index < entries.length - 1 ? 8 : 0),
            child: _QueueListTile(
              entry: entry,
              isSelected: entry.id == selectedId,
              isInRoom: entry.id == roomPatientId,
              pendingInvestigationCount: investigationProvider
                      .requestForQueueEntry(entry.id)
                      ?.pendingItems
                      .length ??
                  0,
              onTap: () => onSelect(entry.id),
            ),
          ),
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
    required this.pendingInvestigationCount,
    required this.onTap,
  });

  final QueueEntry entry;
  final bool isSelected;
  final bool isInRoom;
  final int pendingInvestigationCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isCompleted = entry.status == QueueStatus.completed;
    final isReturned = entry.status == QueueStatus.review;
    final statusColor = entry.status.color();

    final background = isSelected
        ? AppTheme.doctorColor.withOpacity(0.1)
        : isInRoom
            ? AppTheme.medicalGreen.withOpacity(0.07)
            : isReturned
                ? Colors.orange.shade50.withOpacity(0.65)
            : isCompleted
                ? scheme.surfaceContainerHighest.withOpacity(0.5)
                : scheme.surface;

    final borderColor = isSelected
        ? AppTheme.doctorColor
        : isInRoom
            ? AppTheme.medicalGreen.withOpacity(0.5)
            : isReturned
                ? Colors.orange.shade400
            : scheme.outlineVariant.withOpacity(0.4);

    return Material(
      color: background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: isSelected ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _PositionBadge(
                position: entry.position,
                isCompleted: isCompleted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                    ),
                    Text(
                      entry.status.label(l10n),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                    if (pendingInvestigationCount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.investigationRequestCount(pendingInvestigationCount),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.medicalBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle, color: AppTheme.medicalGreen, size: 20)
              else if (isReturned)
                Icon(Icons.replay_rounded, color: Colors.orange.shade700, size: 20)
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.medicalGreen.withOpacity(0.15)
            : AppTheme.doctorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? const Icon(Icons.check_rounded, color: AppTheme.medicalGreen, size: 20)
          : Text(
              '$position',
              style: const TextStyle(
                color: AppTheme.doctorColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
    );
  }
}
