import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/system_monitoring.dart';
import '../../../../services/system_activity_feed_service.dart';
import '../../../../services/system_monitoring_service.dart';
import 'monitoring_view_models.dart';
import 'system_health_widgets.dart';

class OwnerLiveStatisticsSection extends StatelessWidget {
  const OwnerLiveStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.select<SystemMonitoringService, LiveStatisticsViewModel?>(
      (m) {
        final snapshot = m.snapshot;
        if (snapshot == null) return null;
        return LiveStatisticsViewModel.from(
          snapshot,
          isRefreshing: m.isRefreshingPhase2,
        );
      },
    );

    if (vm == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.liveStatistics,
          icon: Icons.analytics_outlined,
          trailing: vm.isRefreshing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
        Text(
          l10n.monitoringPhase2Hint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        _StatGroup(
          title: l10n.usersSection,
          icon: Icons.people_outline,
          items: [
            _StatItem(l10n.totalUsers, vm.totalUsers, Icons.group_outlined, scheme.primary),
            _StatItem(l10n.onlineUsers, vm.onlineUsers, Icons.wifi_tethering, AppTheme.medicalGreen),
            _StatItem(l10n.activeToday, vm.activeToday, Icons.today_outlined, scheme.tertiary),
            _StatItem(
              l10n.newRegistrationsToday,
              vm.newRegistrationsToday,
              Icons.person_add_alt_1_outlined,
              Colors.teal,
            ),
          ],
        ),
        _StatGroup(
          title: l10n.doctorsSection,
          icon: Icons.medical_services_outlined,
          items: [
            _StatItem(l10n.totalDoctors, vm.totalDoctors, Icons.badge_outlined, scheme.primary),
            _StatItem(l10n.onlineDoctors, vm.onlineDoctors, Icons.circle, AppTheme.medicalGreen),
            _StatItem(l10n.activeDoctors, vm.activeDoctors, Icons.verified_outlined, Colors.blue),
            _StatItem(l10n.suspendedDoctors, vm.suspendedDoctors, Icons.block, scheme.error),
            _StatItem(l10n.expiredPackages, vm.expiredPackages, Icons.event_busy_outlined, Colors.orange),
          ],
        ),
        _StatGroup(
          title: l10n.secretariesSection,
          icon: Icons.support_agent_outlined,
          items: [
            _StatItem(l10n.totalSecretaries, vm.totalSecretaries, Icons.groups_2_outlined, scheme.primary),
            _StatItem(l10n.onlineSecretaries, vm.onlineSecretaries, Icons.circle, AppTheme.medicalGreen),
            _StatItem(
              l10n.secretariesWithoutDoctor,
              vm.secretariesWithoutDoctor,
              Icons.link_off_outlined,
              Colors.deepOrange,
            ),
            _StatItem(
              l10n.recentSecretaries,
              vm.recentSecretaries,
              Icons.fiber_new_outlined,
              scheme.tertiary,
            ),
          ],
        ),
        _StatGroup(
          title: l10n.patientsSection,
          icon: Icons.favorite_outline,
          items: [
            _StatItem(l10n.totalPatients, vm.totalPatients, Icons.people_alt_outlined, scheme.primary),
            _StatItem(l10n.onlinePatients, vm.onlinePatients, Icons.circle, AppTheme.medicalGreen),
            _StatItem(
              l10n.newPatientsToday,
              vm.newPatientsToday,
              Icons.person_add_outlined,
              Colors.teal,
            ),
          ],
        ),
        _StatGroup(
          title: l10n.businessesSection,
          icon: Icons.storefront_outlined,
          items: [
            _StatItem(l10n.totalBusinesses, vm.totalBusinesses, Icons.business_outlined, scheme.primary),
            _StatItem(l10n.clinicsStat, vm.clinics, Icons.local_hospital_outlined, Colors.blue),
            _StatItem(l10n.beautyCenters, vm.beautyCenters, Icons.spa_outlined, Colors.pink),
            _StatItem(l10n.laboratories, vm.laboratories, Icons.biotech_outlined, Colors.indigo),
            _StatItem(l10n.pharmacies, vm.pharmacies, Icons.medication_outlined, Colors.green),
            _StatItem(l10n.otherHealthcare, vm.otherHealthcare, Icons.health_and_safety_outlined, Colors.brown),
          ],
        ),
        _StatGroup(
          title: l10n.queuesSection,
          icon: Icons.queue_outlined,
          items: [
            _StatItem(l10n.activeQueues, vm.activeQueues, Icons.pending_actions, scheme.primary),
            _StatItem(l10n.waitingPatients, vm.waitingPatients, Icons.hourglass_top, Colors.orange),
            _StatItem(
              l10n.completedQueuesToday,
              vm.completedQueuesToday,
              Icons.check_circle_outline,
              AppTheme.medicalGreen,
            ),
            _StatItem(
              l10n.cancelledQueuesToday,
              vm.cancelledQueuesToday,
              Icons.cancel_outlined,
              scheme.error,
            ),
            _StatItem(
              l10n.avgWaitingTime,
              l10n.waitingMinutesLabel(vm.avgWaitingMinutes),
              Icons.timer_outlined,
              scheme.tertiary,
            ),
          ],
        ),
        _StatGroup(
          title: l10n.appointmentsSection,
          icon: Icons.calendar_month_outlined,
          items: [
            _StatItem(l10n.todaysAppointments, vm.todaysAppointments, Icons.event_available, scheme.primary),
            _StatItem(l10n.upcomingAppointments, vm.upcomingAppointments, Icons.upcoming_outlined, Colors.blue),
            _StatItem(l10n.missedAppointments, vm.missedAppointments, Icons.event_busy, Colors.orange),
            _StatItem(l10n.cancelledAppointments, vm.cancelledAppointments, Icons.event_busy_outlined, scheme.error),
          ],
        ),
      ],
    );
  }
}

class _StatItem {
  const _StatItem(this.label, this.value, this.icon, this.color);

  final String label;
  final Object value;
  final IconData icon;
  final Color color;
}

class _StatGroup extends StatelessWidget {
  const _StatGroup({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(title: title, icon: icon),
        MonitoringMetricGrid(
          items: items
              .map(
                (item) => (
                  label: item.label,
                  value: '${item.value}',
                  icon: item.icon,
                  color: item.color,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class OwnerActivityFeedSection extends StatelessWidget {
  const OwnerActivityFeedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feed = context.watch<SystemActivityFeedService>();
    final filter = feed.filter;
    final entries = feed.filteredEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonitoringSectionHeader(
          title: l10n.liveActivityFeed,
          icon: Icons.timeline_outlined,
          trailing: feed.isRefreshing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: ActivityFeedFilter.values.map((f) {
            final selected = filter == f;
            return FilterChip(
              label: Text(_filterLabel(l10n, f)),
              selected: selected,
              onSelected: (_) => feed.setFilter(f),
              showCheckmark: false,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        LiveActivityTimeline(
          entries: entries,
          emptyLabel: l10n.noActivityEvents,
          eventLabel: (type) => _eventLabel(l10n, type),
        ),
      ],
    );
  }

  String _filterLabel(AppLocalizations l10n, ActivityFeedFilter filter) =>
      switch (filter) {
        ActivityFeedFilter.today => l10n.filterToday,
        ActivityFeedFilter.lastHour => l10n.activityFilterLastHour,
        ActivityFeedFilter.all => l10n.activityFilterAll,
      };

  String _eventLabel(AppLocalizations l10n, ActivityEventType type) =>
      switch (type) {
        ActivityEventType.doctorCreated => l10n.activityEventDoctorCreated,
        ActivityEventType.doctorUpdated => l10n.activityEventDoctorUpdated,
        ActivityEventType.secretaryAdded => l10n.activityEventSecretaryAdded,
        ActivityEventType.patientRegistered => l10n.activityEventPatientRegistered,
        ActivityEventType.businessCreated => l10n.activityEventBusinessCreated,
        ActivityEventType.queueJoined => l10n.activityEventQueueJoined,
        ActivityEventType.queueCancelled => l10n.activityEventQueueCancelled,
        ActivityEventType.appointmentBooked => l10n.activityEventAppointmentBooked,
        ActivityEventType.appointmentCancelled => l10n.activityEventAppointmentCancelled,
        ActivityEventType.advertisementCreated => l10n.activityEventAdvertisementCreated,
        ActivityEventType.packageActivated => l10n.activityEventPackageActivated,
        ActivityEventType.packageRenewed => l10n.activityEventPackageRenewed,
        ActivityEventType.login => l10n.activityEventLogin,
        ActivityEventType.logout => l10n.activityEventLogout,
      };
}
