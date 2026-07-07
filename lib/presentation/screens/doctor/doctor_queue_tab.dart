import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/queue_entry.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/firebase_bootstrap.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../providers/app_providers.dart';
import 'doctor_consultation_session.dart';
import 'doctor_consultation_widgets.dart';
import 'doctor_consultation_workspace.dart';
import 'doctor_queue_panel.dart';
import 'doctor_today_queue.dart';
import 'doctor_visit_notes_store.dart';
import 'doctor_workspace_constants.dart';

/// Read-only today's queue with in-place consultation workspace (no navigation).
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
    final investigationProvider = context.watch<InvestigationRequestProvider>();

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
        final desktop = DoctorWorkspaceConstants.isDesktopConsultation(
          constraints.maxWidth,
        );

        final queuePanel = DoctorQueuePanel(
          entries: _todayQueue,
          selectedId: _selectedEntryId,
          roomPatientId: roomPatient?.id,
          investigationProvider: investigationProvider,
          onSelect: _selectPatient,
        );

        final consultationPanel = selected == null
            ? _SelectPatientPlaceholder(message: l10n.selectPatientFromQueue)
            : DoctorConsultationWorkspace(
                key: ValueKey(selected.id),
                entry: selected,
                doctorId: widget.doctorId,
                doctorName: doctorName,
                session: _session,
                expandedSections: desktop,
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isClinicalDesktop(context))
              _QueueHintBanner(message: l10n.doctorQueueViewOnlyHint),
            if (!isClinicalDesktop(context)) const SizedBox(height: 8),
            Expanded(
              child: desktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: DoctorWorkspaceConstants.queuePanelFlex,
                          child: queuePanel,
                        ),
                        const SizedBox(
                          width: DoctorWorkspaceConstants.panelGap,
                        ),
                        Expanded(
                          flex: DoctorWorkspaceConstants.consultationPanelFlex,
                          child: _ConsultationPanelShell(
                            title: l10n.consultationWorkspace,
                            child: consultationPanel,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (selected != null)
                          Flexible(
                            flex: 5,
                            child: _ConsultationPanelShell(
                              title: l10n.consultationWorkspace,
                              child: consultationPanel,
                            ),
                          ),
                        if (selected != null) const SizedBox(height: 8),
                        Expanded(
                          flex: selected == null ? 1 : 4,
                          child: queuePanel,
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Right-hand consultation column — fills available height on desktop.
class _ConsultationPanelShell extends StatelessWidget {
  const _ConsultationPanelShell({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DoctorWorkspacePanel(
      title: title,
      icon: Icons.medical_services_outlined,
      child: child,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, size: 48, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
