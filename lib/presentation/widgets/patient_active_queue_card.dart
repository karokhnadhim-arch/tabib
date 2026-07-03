import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/doctor.dart';
import '../../models/provider_catalog_mode.dart';
import '../../models/queue_entry.dart';
import '../../services/favorites_service.dart';
import '../../services/location_service.dart';
import '../../services/queue_service.dart';
import '../../utils/localization_utils.dart';
import '../../utils/provider_labels.dart';
import 'doctor_avatar.dart';
import 'patient_queue_utils.dart';

/// Premium Material 3 card for one active patient queue.
class PatientActiveQueueCard extends StatelessWidget {
  const PatientActiveQueueCard({
    super.key,
    required this.entry,
    required this.doctor,
    required this.queueService,
  });

  final QueueEntry entry;
  final Doctor? doctor;
  final QueueService queueService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentServing = queueService.currentServingNumber(entry) ?? 0;
    final waitMin = queueService.estimatedWaitMinutes(entry);
    final specialty = doctor == null
        ? ''
        : ProviderLabels.displayCategory(context, l10n, doctor!);
    final clinicName = doctor?.effectiveClinicName.localized(context);
    final status = _homeStatus(l10n, entry.status);
    final favorites = context.watch<FavoritesService>();
    final kind =
        doctor?.isBusiness == true ? FavoriteKind.business : FavoriteKind.doctor;
    final isFavorite =
        doctor != null && favorites.isFavorite(doctor!.id, kind);
    final progress = queueProgressRatio(currentServing, entry.position);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      shadowColor: Colors.black26,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                color: AppTheme.medicalBlue.withOpacity(0.04),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DoctorAvatar(
                      photoUrl: doctor?.photoUrl,
                      thumbnailUrl: doctor?.photoThumbnailUrl,
                      radius: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor?.name.localized(context) ?? l10n.doctor,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (specialty.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              specialty,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (clinicName != null && clinicName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              clinicName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (doctor != null)
                      IconButton(
                        tooltip: isFavorite
                            ? l10n.removeFromFavorites
                            : l10n.addToFavorites,
                        onPressed: () => favorites.toggle(doctor!.id, kind),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? Colors.red.shade400
                              : Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _StatusPill(label: status.label, color: status.color),
                        const Spacer(),
                        Text(
                          l10n.queueProgress,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricBadge(
                            icon: Icons.confirmation_number_outlined,
                            label: l10n.queueNumber,
                            value: '${entry.position}',
                            color: AppTheme.medicalBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricBadge(
                            icon: Icons.play_circle_outline,
                            label: l10n.currentServing,
                            value: '$currentServing',
                            color: AppTheme.medicalGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricBadge(
                            icon: Icons.hourglass_top_outlined,
                            label: l10n.waitTime,
                            value: l10n.minutesShort(waitMin),
                            color: Colors.orange.shade700,
                            compactValue: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TweenAnimationBuilder<double>(
                      key: ValueKey('$currentServing-${entry.position}'),
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: value.clamp(0.04, 1.0),
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              color: AppTheme.medicalGreen,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${l10n.currentServing}: $currentServing  ·  ${l10n.queueNumber}: ${entry.position}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          entry.effectiveQueueDate,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 18),
                        Icon(Icons.schedule_outlined,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          entry.effectiveSlotStart,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _QuickActions(
                      doctor: doctor,
                      entry: entry,
                      queueService: queueService,
                      canCancel: canCancelPatientQueue(entry),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () =>
                            context.push('/queue?entryId=${entry.id}'),
                        icon: const Icon(Icons.visibility_outlined, size: 20),
                        label: Text(l10n.viewDetails),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _HomeStatus _homeStatus(AppLocalizations l10n, QueueStatus status) {
    switch (status) {
      case QueueStatus.waiting:
      case QueueStatus.review:
      case QueueStatus.followUp:
        return _HomeStatus(l10n.queueStatusWaiting, AppTheme.medicalBlue);
      case QueueStatus.inProgress:
      case QueueStatus.examination:
      case QueueStatus.sentForTests:
        return _HomeStatus(l10n.queueStatusServing, AppTheme.medicalGreen);
      case QueueStatus.completed:
        return _HomeStatus(l10n.queueStatusFinished, AppTheme.medicalGreenLight);
      case QueueStatus.cancelled:
        return _HomeStatus(l10n.queueStatusCancelled, Colors.grey.shade600);
      case QueueStatus.absent:
        return _HomeStatus(l10n.queueStatusAbsent, Colors.red.shade600);
    }
  }
}

class _HomeStatus {
  const _HomeStatus(this.label, this.color);
  final String label;
  final Color color;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.compactValue = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool compactValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compactValue ? 15 : 20,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.doctor,
    required this.entry,
    required this.queueService,
    required this.canCancel,
  });

  final Doctor? doctor;
  final QueueEntry entry;
  final QueueService queueService;
  final bool canCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phone = doctor?.contactPhone ?? doctor?.clinic.phone;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (phone != null && phone.isNotEmpty)
          _ActionChip(
            icon: Icons.phone_outlined,
            label: l10n.callClinic,
            onTap: () => _callPhone(phone),
          ),
        if (doctor != null)
          _ActionChip(
            icon: Icons.map_outlined,
            label: l10n.openMap,
            onTap: () => _openMap(doctor!),
          ),
        if (doctor != null)
          _ActionChip(
            icon: Icons.person_outline,
            label: l10n.viewProfile,
            onTap: () => context.push(
              ProviderLabels.detailRoute(
                doctor!.isBusiness
                    ? ProviderCatalogMode.businesses
                    : ProviderCatalogMode.doctors,
                doctor!.id,
              ),
            ),
          ),
        if (canCancel)
          _ActionChip(
            icon: Icons.cancel_outlined,
            label: l10n.cancelQueue,
            color: Colors.red.shade600,
            onTap: () => _confirmCancel(context, l10n),
          ),
      ],
    );
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openMap(Doctor doctor) async {
    await LocationService().openCoordinatesInMaps(
      latitude: doctor.latitude ?? doctor.clinic.latitude,
      longitude: doctor.longitude ?? doctor.clinic.longitude,
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelQueue),
        content: Text(l10n.cancelQueueConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: Text(l10n.cancelQueue),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await queueService.cancelEntry(entry.id, entry.doctorId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.queueCancelled)),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.medicalBlue;
    return Material(
      color: c.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: c),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: c,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
