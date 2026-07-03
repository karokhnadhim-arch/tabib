import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/provider_catalog_mode.dart';
import '../../../models/doctor.dart';
import '../../../models/queue_entry.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/provider_labels.dart';
import '../../../utils/queue_status_utils.dart';
import '../../widgets/doctor_avatar.dart';
import '../../widgets/simple_queue_circles.dart';

enum PatientQueueSort { closestAppointment, recentlyJoined, doctorName }

class MyQueuesScreen extends StatefulWidget {
  const MyQueuesScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<MyQueuesScreen> createState() => _MyQueuesScreenState();
}

class _MyQueuesScreenState extends State<MyQueuesScreen>
    with TickerProviderStateMixin {
  PatientQueueSort _sort = PatientQueueSort.closestAppointment;
  final Set<String> _watchedDoctorIds = {};
  late final AnimationController _pulseController;
  late final AnimationController _numberController;
  late final Animation<double> _numberScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _numberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _numberScale = CurvedAnimation(
      parent: _numberController,
      curve: Curves.elasticOut,
    );
    _numberController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthService>();
      final queue = context.read<QueueService>();
      queue.watchPatientQueues(auth.patientId);
      _syncDoctorWatches(queue.activeQueuesForPatient(auth.patientId));
    });
  }

  void _syncDoctorWatches(List<QueueEntry> entries) {
    final needed = entries.map((e) => e.doctorId).toSet();
    final queue = context.read<QueueService>();
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
    final queue = context.read<QueueService>();
    for (final id in _watchedDoctorIds) {
      queue.stopWatchingDoctorQueue(id);
    }
    _pulseController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  List<QueueEntry> _sortedEntries(
    BuildContext context,
    List<QueueEntry> entries,
    ClinicDataService data,
  ) {
    final list = List<QueueEntry>.from(entries);
    switch (_sort) {
      case PatientQueueSort.closestAppointment:
        list.sort((a, b) {
          final ad = '${a.effectiveQueueDate} ${a.effectiveSlotStart}';
          final bd = '${b.effectiveQueueDate} ${b.effectiveSlotStart}';
          return ad.compareTo(bd);
        });
      case PatientQueueSort.recentlyJoined:
        list.sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
      case PatientQueueSort.doctorName:
        list.sort((a, b) {
          final an = data.doctorById(a.doctorId)?.name.localized(context) ?? '';
          final bn = data.doctorById(b.doctorId)?.name.localized(context) ?? '';
          return an.compareTo(bn);
        });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final queue = context.watch<QueueService>();
    final data = context.watch<ClinicDataService>();
    final entries = _sortedEntries(
      context,
      queue.activeQueuesForPatient(auth.patientId),
      data,
    );
    _syncDoctorWatches(entries);

    final body = ResponsiveBody(
      child: entries.isEmpty
          ? _EmptyQueues(l10n: l10n)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.embedded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                    child: Text(
                      l10n.myQueues,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                _SortBar(
                  sort: _sort,
                  onChanged: (s) => setState(() => _sort = s),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final doctor = data.doctorById(entry.doctorId);
                      return _PatientQueueCard(
                        entry: entry,
                        doctor: doctor,
                        pulseController: _pulseController,
                        numberScaleAnimation: _numberScale,
                        onRefresh: () => queue.refreshPatientQueues(
                          auth.patientId,
                        ),
                        onCancel: () async {
                          await queue.cancelEntry(entry.id, entry.doctorId);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.queueCancelled)),
                          );
                        },
                        onOpenProfile: doctor == null
                            ? null
                            : () => context.push(
                                  ProviderLabels.detailRoute(
                                    doctor!.isBusiness
                                        ? ProviderCatalogMode.businesses
                                        : ProviderCatalogMode.doctors,
                                    doctor!.id,
                                  ),
                                ),
                        onOpenQueue: () => context.push(
                          '/queue?entryId=${entry.id}',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );

    if (widget.embedded) return body;

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
          _chip(
            context,
            l10n.sortClosestAppointment,
            PatientQueueSort.closestAppointment,
          ),
          const SizedBox(width: 8),
          _chip(
            context,
            l10n.sortRecentlyJoined,
            PatientQueueSort.recentlyJoined,
          ),
          const SizedBox(width: 8),
          _chip(context, l10n.sortDoctorName, PatientQueueSort.doctorName),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, PatientQueueSort value) {
    return FilterChip(
      label: Text(label),
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

class _PatientQueueCard extends StatelessWidget {
  const _PatientQueueCard({
    required this.entry,
    required this.doctor,
    required this.pulseController,
    required this.numberScaleAnimation,
    required this.onRefresh,
    required this.onCancel,
    required this.onOpenQueue,
    this.onOpenProfile,
  });

  final QueueEntry entry;
  final Doctor? doctor;
  final AnimationController pulseController;
  final Animation<double> numberScaleAnimation;
  final VoidCallback onRefresh;
  final VoidCallback onCancel;
  final VoidCallback onOpenQueue;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final queue = context.watch<QueueService>();
    final current = queue.currentServingNumber(entry) ?? 0;
    final waitMin = queue.estimatedWaitMinutes(entry);
    final providerName =
        doctor?.name.localized(context) ?? l10n.doctor;
    final specialty = doctor == null
        ? ''
        : ProviderLabels.displayCategory(context, l10n, doctor!);
    final clinicName = doctor?.effectiveClinicName.localized(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onOpenQueue,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  DoctorAvatar(
                    photoUrl: doctor?.photoUrl,
                    thumbnailUrl: doctor?.photoThumbnailUrl,
                    radius: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          providerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (specialty.isNotEmpty)
                          Text(
                            specialty,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        if (clinicName != null && clinicName.isNotEmpty)
                          Text(
                            clinicName,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: entry.status.color().withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      entry.status.label(l10n),
                      style: TextStyle(
                        color: entry.status.color(),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: SimpleQueueCircles(
                  myNumber: entry.position,
                  currentNumber: current,
                  peopleAhead: queue.peopleAhead(entry),
                  pulseController: pulseController,
                  numberScaleAnimation: numberScaleAnimation,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    l10n.minutesShort(waitMin),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const Spacer(),
                  Text(
                    '${entry.effectiveQueueDate} · ${entry.effectiveSlotStart}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    tooltip: l10n.refresh,
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                  ),
                  if (onOpenProfile != null)
                    IconButton(
                      tooltip: l10n.viewProfile,
                      onPressed: onOpenProfile,
                      icon: const Icon(Icons.person_outline),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: onCancel,
                    child: Text(
                      l10n.cancelQueue,
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
