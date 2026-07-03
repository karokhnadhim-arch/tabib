import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/queue_entry.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../widgets/patient_active_queue_card.dart';
import '../../widgets/patient_queue_utils.dart';

class MyQueuesScreen extends StatefulWidget {
  const MyQueuesScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<MyQueuesScreen> createState() => _MyQueuesScreenState();
}

class _MyQueuesScreenState extends State<MyQueuesScreen> {
  PatientQueueSort _sort = PatientQueueSort.nearestAppointment;
  final Set<String> _watchedDoctorIds = {};
  QueueService? _queueService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthService>();
      final queue = context.read<QueueService>();
      queue.watchPatientQueues(auth.patientId);
      _syncDoctorWatches(queue.activeQueuesForPatient(auth.patientId));
    });
  }

  void _syncDoctorWatches(List<QueueEntry> entries) {
    final queue = _queueService ??= context.read<QueueService>();
    final needed = entries.map((e) => e.doctorId).toSet();
    for (final id in _watchedDoctorIds.toList()) {
      if (!needed.contains(id)) {
        queue.stopWatchingDoctorQueue(id);
        _watchedDoctorIds.remove(id);
      }
    }
    for (final id in needed) {
      if (_watchedDoctorIds.add(id)) {
        queue.watchDoctorQueue(id);
      }
    }
  }

  @override
  void dispose() {
    final queue = _queueService;
    if (queue != null) {
      for (final id in _watchedDoctorIds) {
        queue.stopWatchingDoctorQueue(id);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final queue = context.watch<QueueService>();
    final data = context.watch<ClinicDataService>();
    final entries = sortPatientQueues(
      entries: queue.activeQueuesForPatient(auth.patientId),
      sort: _sort,
      queueService: queue,
    );
    _syncDoctorWatches(entries);

    final queueCards = [
      for (final entry in entries)
        PatientActiveQueueCard(
          entry: entry,
          doctor: data.doctorById(entry.doctorId),
          queueService: queue,
        ),
    ];

    if (widget.embedded) {
      return ScrollableResponsiveBody(
        child: entries.isEmpty
            ? _EmptyQueues(l10n: l10n)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ResponsiveHeaderRow(
                    title: Text(
                      l10n.myQueues,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SortBar(
                    sort: _sort,
                    onChanged: (s) => setState(() => _sort = s),
                  ),
                  const SizedBox(height: 8),
                  ...queueCards,
                ],
              ),
      );
    }

    final body = ResponsiveBody(
      child: entries.isEmpty
          ? _EmptyQueues(l10n: l10n)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SortBar(
                  sort: _sort,
                  onChanged: (s) => setState(() => _sort = s),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: queueCards,
                  ),
                ),
              ],
            ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myQueues),
        backgroundColor: AppTheme.patientColor,
      ),
      body: body,
    );
  }
}

class _SortBar extends StatelessWidget {
  const _SortBar({required this.sort, required this.onChanged});

  final PatientQueueSort sort;
  final ValueChanged<PatientQueueSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(l10n.sortClosestAppointment, PatientQueueSort.nearestAppointment),
          const SizedBox(width: 8),
          _chip(l10n.sortQueueProgress, PatientQueueSort.queueProgress),
          const SizedBox(width: 8),
          _chip(l10n.sortRecentlyJoined, PatientQueueSort.recentlyJoined),
        ],
      ),
    );
  }

  Widget _chip(String label, PatientQueueSort value) {
    return FilterChip(
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      selected: sort == value,
      onSelected: (_) => onChanged(value),
    );
  }
}

class _EmptyQueues extends StatelessWidget {
  const _EmptyQueues({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              l10n.noActiveQueue,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.bookQueueHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/doctors'),
              icon: const Icon(Icons.search),
              label: Text(l10n.searchDoctors),
            ),
          ],
        ),
      ),
    );
  }
}
