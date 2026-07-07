import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/patient_profile.dart';
import '../../../models/queue_entry.dart';
import '../../../services/patient_profile_service.dart';
import '../../providers/app_providers.dart';
import 'doctor_workspace_constants.dart';

/// Left panel — professional today's queue for the doctor workspace.
class DoctorQueuePanel extends StatefulWidget {
  const DoctorQueuePanel({
    super.key,
    required this.entries,
    required this.selectedId,
    required this.roomPatientId,
    required this.investigationProvider,
    required this.onSelect,
    this.showSummary = true,
  });

  final List<QueueEntry> entries;
  final String? selectedId;
  final String? roomPatientId;
  final InvestigationRequestProvider investigationProvider;
  final ValueChanged<String> onSelect;
  final bool showSummary;

  @override
  State<DoctorQueuePanel> createState() => _DoctorQueuePanelState();
}

class _DoctorQueuePanelState extends State<DoctorQueuePanel> {
  final _searchController = TextEditingController();
  final _profileCache = _QueueProfileCache();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _waitingCount => widget.entries
      .where((e) => e.status == QueueStatus.waiting)
      .length;

  int get _readyCount => widget.entries
      .where(
        (e) =>
            e.patientReady &&
            (e.status == QueueStatus.waiting ||
                e.status == QueueStatus.review),
      )
      .length;

  int get _examiningCount => widget.entries
      .where((e) => e.status == QueueStatus.inProgress)
      .length;

  List<QueueEntry> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.entries;
    return widget.entries.where((e) {
      if (e.patientName.toLowerCase().contains(q)) return true;
      if ('${e.position}'.contains(q)) return true;
      return false;
    }).toList();
  }

  List<QueueEntry> get _activeOrdered {
    final list = _filtered
        .where(
          (e) =>
              e.status != QueueStatus.completed &&
              e.status != QueueStatus.cancelled,
        )
        .toList();
    list.sort((a, b) => a.position.compareTo(b.position));
    return list;
  }

  List<QueueEntry> get _completedOrdered {
    final list =
        _filtered.where((e) => e.status == QueueStatus.completed).toList();
    list.sort((a, b) => a.position.compareTo(b.position));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final profileService = context.read<PatientProfileService>();
    final active = _activeOrdered;
    final completed = _completedOrdered;
    final itemCount = active.length + (completed.isEmpty ? 0 : completed.length + 1);

    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(DoctorWorkspaceConstants.panelRadius),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.groups_outlined, color: scheme.primary, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.todaysQueue,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                      ),
                    ),
                  ],
                ),
                if (widget.showSummary) ...[
                  const SizedBox(height: 10),
                  DoctorQueueSummaryPanel(
                    totalCount: widget.entries.length,
                    waitingCount: _waitingCount,
                    readyCount: _readyCount,
                    examiningCount: _examiningCount,
                    compact: true,
                  ),
                ],
                const SizedBox(height: 12),
                SearchBar(
                  controller: _searchController,
                  hintText: l10n.searchQueueHint,
                  leading: const Icon(Icons.search_rounded, size: 22),
                  onChanged: (value) => setState(() => _query = value),
                  trailing: _query.isEmpty
                      ? null
                      : [
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                        ],
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor:
                      WidgetStateProperty.all(scheme.surfaceContainerLow),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: scheme.outlineVariant.withOpacity(0.35),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: itemCount == 0
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.noSearchResults,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: itemCount,
                    cacheExtent: 480,
                    itemBuilder: (context, index) {
                      if (index < active.length) {
                        final entry = active[index];
                        return RepaintBoundary(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _QueuePatientCard(
                              entry: entry,
                              isSelected: entry.id == widget.selectedId,
                              isInRoom: entry.id == widget.roomPatientId,
                              pendingInvestigationCount: widget
                                      .investigationProvider
                                      .requestForQueueEntry(entry.id)
                                      ?.pendingItems
                                      .length ??
                                  0,
                              profileCache: _profileCache,
                              profileService: profileService,
                              onTap: () => widget.onSelect(entry.id),
                            ),
                          ),
                        );
                      }

                      final completedIndex = index - active.length;
                      if (completed.isEmpty) return const SizedBox.shrink();

                      if (completedIndex == 0) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                          child: Text(
                            l10n.completedToday,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        );
                      }

                      final entry = completed[completedIndex - 1];
                      return RepaintBoundary(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _QueuePatientCard(
                            entry: entry,
                            isSelected: entry.id == widget.selectedId,
                            isInRoom: false,
                            pendingInvestigationCount: 0,
                            profileCache: _profileCache,
                            profileService: profileService,
                            muted: true,
                            onTap: () => widget.onSelect(entry.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Today's queue stats — shown beside the patient list on desktop.
class DoctorQueueSummaryPanel extends StatelessWidget {
  const DoctorQueueSummaryPanel({
    super.key,
    required this.totalCount,
    required this.waitingCount,
    required this.readyCount,
    required this.examiningCount,
    this.compact = false,
    this.horizontal = false,
  });

  final int totalCount;
  final int waitingCount;
  final int readyCount;
  final int examiningCount;
  final bool compact;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final stats = [
      _SummaryStatRow(
        label: l10n.totalPatients,
        value: totalCount,
        icon: Icons.groups_outlined,
        color: scheme.primary,
      ),
      _SummaryStatRow(
        label: l10n.patientReady,
        value: readyCount,
        icon: Icons.front_hand_outlined,
        color: AppTheme.medicalGreen,
      ),
      _SummaryStatRow(
        label: l10n.waitingPatients,
        value: waitingCount,
        icon: Icons.hourglass_top_rounded,
        color: AppTheme.medicalBlue,
      ),
      _SummaryStatRow(
        label: l10n.queueStatusWithDoctor,
        value: examiningCount,
        icon: Icons.medical_services_outlined,
        color: AppTheme.doctorColor,
      ),
    ];

    if (horizontal) {
      return Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: stats[i]),
          ],
        ],
      );
    }

    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(DoctorWorkspaceConstants.panelRadius),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.insights_outlined, color: scheme.primary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.todaysQueue,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            stats[0],
            const SizedBox(height: 8),
            stats[1],
            const SizedBox(height: 8),
            stats[2],
            if (examiningCount > 0) ...[
              const SizedBox(height: 8),
              stats[3],
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryStatRow extends StatelessWidget {
  const _SummaryStatRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _QueuePatientCard extends StatefulWidget {
  const _QueuePatientCard({
    required this.entry,
    required this.isSelected,
    required this.isInRoom,
    required this.pendingInvestigationCount,
    required this.profileCache,
    required this.profileService,
    required this.onTap,
    this.muted = false,
  });

  final QueueEntry entry;
  final bool isSelected;
  final bool isInRoom;
  final int pendingInvestigationCount;
  final _QueueProfileCache profileCache;
  final PatientProfileService profileService;
  final VoidCallback onTap;
  final bool muted;

  @override
  State<_QueuePatientCard> createState() => _QueuePatientCardState();
}

class _QueuePatientCardState extends State<_QueuePatientCard> {
  PatientProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didUpdateWidget(covariant _QueuePatientCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.patientId != widget.entry.patientId) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    final profile = await widget.profileCache.load(
      widget.entry.patientId,
      widget.profileService,
    );
    if (mounted) setState(() => _profile = profile);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final entry = widget.entry;
    final isCompleted = entry.status == QueueStatus.completed;
    final status = _queueDisplayStatus(entry);
    final timeFmt = DateFormat.jm();
    final profile = _profile ?? const PatientProfile();
    final genderIcon = _genderIcon(profile.gender);
    final opacity = widget.muted ? 0.72 : 1.0;

    final background = widget.isSelected
        ? AppTheme.doctorColor.withOpacity(0.14 * opacity)
        : widget.isInRoom
            ? AppTheme.medicalGreen.withOpacity(0.1 * opacity)
            : scheme.surfaceContainerLow.withOpacity(opacity);

    final borderColor = widget.isSelected
        ? AppTheme.doctorColor
        : widget.isInRoom
            ? AppTheme.medicalGreen.withOpacity(0.5)
            : scheme.outlineVariant.withOpacity(0.35);

    return Opacity(
      opacity: opacity,
      child: Material(
        color: background,
        elevation: widget.isSelected ? 1 : 0,
        shadowColor: scheme.primary.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor,
            width: widget.isSelected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QueueNumberBadge(
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: widget.muted
                                  ? scheme.onSurfaceVariant
                                  : scheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _QueueMetaChip(
                            icon: genderIcon,
                            label: _genderLabel(profile.gender, l10n),
                            iconColor: scheme.primary,
                            textStyle:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: scheme.onSurfaceVariant,
                                    ),
                          ),
                          _QueueMetaChip(
                            icon: Icons.cake_outlined,
                            label: l10n.ageNotRecorded,
                            iconColor: scheme.onSurfaceVariant,
                            textStyle:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _StatusPill(
                            status: status,
                            entry: entry,
                            l10n: l10n,
                          ),
                          _QueueMetaChip(
                            icon: Icons.schedule_rounded,
                            label: timeFmt.format(entry.bookedAt.toLocal()),
                            iconColor: scheme.onSurfaceVariant,
                            iconSize: 15,
                            textStyle:
                                Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                      if (widget.pendingInvestigationCount > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          l10n.investigationRequestCount(
                            widget.pendingInvestigationCount,
                          ),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppTheme.medicalBlue,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _genderIcon(String? gender) {
    final g = (gender ?? '').trim().toLowerCase();
    if (g == 'male' || g == 'm' || g == 'ذكر' || g == 'نێر') {
      return Icons.male_rounded;
    }
    if (g == 'female' || g == 'f' || g == 'أنثى' || g == 'مێ') {
      return Icons.female_rounded;
    }
    return Icons.person_outline_rounded;
  }

  String _genderLabel(String? gender, AppLocalizations l10n) {
    final g = (gender ?? '').trim();
    return g.isEmpty ? l10n.notAvailable : g;
  }
}

enum _QueueDisplayStatus { waiting, inside, completed }

_QueueDisplayStatus _queueDisplayStatus(QueueEntry entry) {
  switch (entry.status) {
    case QueueStatus.completed:
      return _QueueDisplayStatus.completed;
    case QueueStatus.inProgress:
    case QueueStatus.examination:
    case QueueStatus.sentForTests:
      return _QueueDisplayStatus.inside;
    default:
      return _QueueDisplayStatus.waiting;
  }
}

extension _QueueDisplayStatusUi on _QueueDisplayStatus {
  String label(AppLocalizations l10n, {QueueEntry? entry}) {
    if (this == _QueueDisplayStatus.waiting &&
        entry != null &&
        entry.patientReady &&
        (entry.status == QueueStatus.waiting ||
            entry.status == QueueStatus.review)) {
      return l10n.patientReady;
    }
    switch (this) {
      case _QueueDisplayStatus.waiting:
        return l10n.queueStatusWaiting;
      case _QueueDisplayStatus.inside:
        return l10n.queueStatusInside;
      case _QueueDisplayStatus.completed:
        return l10n.queueStatusCompleted;
    }
  }

  Color color() {
    switch (this) {
      case _QueueDisplayStatus.waiting:
        return AppTheme.medicalBlue;
      case _QueueDisplayStatus.inside:
        return AppTheme.medicalGreen;
      case _QueueDisplayStatus.completed:
        return AppTheme.medicalGreenLight;
    }
  }
}

class _QueueMetaChip extends StatelessWidget {
  const _QueueMetaChip({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.iconSize = 16,
    this.textStyle,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final double iconSize;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: iconColor),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.status,
    required this.entry,
    required this.l10n,
  });

  final _QueueDisplayStatus status;
  final QueueEntry entry;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = status.color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label(l10n, entry: entry),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _QueueNumberBadge extends StatelessWidget {
  const _QueueNumberBadge({
    required this.position,
    required this.isCompleted,
  });

  final int position;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.medicalGreen.withOpacity(0.15)
            : AppTheme.doctorColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? const Icon(Icons.check_rounded, color: AppTheme.medicalGreen, size: 24)
          : Text(
              '$position',
              style: const TextStyle(
                color: AppTheme.doctorColor,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
    );
  }
}

class _QueueProfileCache {
  final Map<String, PatientProfile> _profiles = {};
  final Map<String, Future<PatientProfile>> _inFlight = {};

  Future<PatientProfile> load(
    String patientId,
    PatientProfileService service,
  ) {
    if (_profiles.containsKey(patientId)) {
      return Future.value(_profiles[patientId]);
    }
    return _inFlight.putIfAbsent(patientId, () async {
      final profile = await service.readProfileForUser(patientId);
      _profiles[patientId] = profile;
      _inFlight.remove(patientId);
      return profile;
    });
  }
}
