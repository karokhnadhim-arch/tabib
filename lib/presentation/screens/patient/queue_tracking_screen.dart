import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/queue_entry.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/queue_alert_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../services/smart_notification_service.dart';
import '../../../services/queue_service.dart';
import '../../../services/offline/connectivity_service.dart';
import '../../../services/offline/offline_queue_cache_service.dart';
import '../../widgets/offline_indicator_banner.dart';
import '../../widgets/premium_queue_dashboard.dart';


class QueueTrackingScreen extends StatefulWidget {
  const QueueTrackingScreen({
    super.key,
    this.embedded = false,
    this.entryId,
  });

  final bool embedded;
  final String? entryId;

  @override
  State<QueueTrackingScreen> createState() => _QueueTrackingScreenState();
}

class _QueueTrackingScreenState extends State<QueueTrackingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _numberController;
  late final Animation<double> _numberScale;
  late QueueAlertService _alertService;
  int? _lastPosition;
  String? _watchedDoctorId;

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
    _alertService = QueueAlertService();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _alertService = QueueAlertService(
        smartNotifications: context.read<SmartNotificationService>(),
      );
      _startWatching();
    });
  }

  void _startWatching() {
    final auth = context.read<AuthService>();
    final queue = context.read<QueueService>();
    queue.watchPatientQueues(auth.patientId);
    final entry = widget.entryId != null
        ? queue.queueEntryById(auth.patientId, widget.entryId!)
        : queue.activeEntryForPatient(auth.patientId);
    _syncDoctorQueueWatch(entry);
  }

  void _syncDoctorQueueWatch(QueueEntry? entry) {
    final doctorId = entry?.doctorId;
    if (doctorId == null || doctorId.isEmpty) {
      if (_watchedDoctorId != null) {
        context.read<QueueService>().stopWatchingDoctorQueue(_watchedDoctorId);
        _watchedDoctorId = null;
      }
      return;
    }
    if (_watchedDoctorId == doctorId) return;
    if (_watchedDoctorId != null) {
      context.read<QueueService>().stopWatchingDoctorQueue(_watchedDoctorId);
    }
    _watchedDoctorId = doctorId;
    context.read<QueueService>().watchDoctorQueue(doctorId);
  }

  @override
  void dispose() {
    if (_watchedDoctorId != null) {
      context.read<QueueService>().stopWatchingDoctorQueue(_watchedDoctorId);
    }
    _pulseController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _handleAlerts({
    required QueueEntry entry,
    required int ahead,
    required AuthService auth,
  }) {
    final l10n = AppLocalizations.of(context);
    final data = context.read<ClinicDataService>();
    final doctor = data.doctorById(entry.doctorId);
    final doctorName = doctor?.name.localized(context) ?? entry.doctorId;
    _alertService.handleQueueUpdate(
      entry: entry,
      peopleAhead: ahead,
      l10n: l10n,
      notifications: context.read<NotificationProvider>(),
      patientUserId: auth.patientId,
      doctorName: doctorName,
    );

    if (_lastPosition != null && _lastPosition != entry.position) {
      _numberController
        ..reset()
        ..forward();
    }
    _lastPosition = entry.position;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final queue = context.watch<QueueService>();
    final data = context.watch<ClinicDataService>();
    final offlineQueue = context.watch<OfflineQueueCacheService>();
    final connectivity = context.watch<ConnectivityService>();
    QueueEntry? entry = widget.entryId != null
        ? queue.queueEntryById(auth.patientId, widget.entryId!)
        : queue.activeEntryForPatient(auth.patientId);
    if (entry == null && connectivity.isOffline) {
      final cached = offlineQueue.cachedPatientQueues(auth.patientId);
      if (widget.entryId != null) {
        for (final e in cached) {
          if (e.id == widget.entryId) {
            entry = e;
            break;
          }
        }
      } else if (cached.isNotEmpty) {
        entry = cached.first;
      }
    }
    _syncDoctorQueueWatch(entry);

    if (entry != null) {
      final activeEntry = entry!;
      final ahead = queue.peopleAhead(activeEntry);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _handleAlerts(entry: activeEntry, ahead: ahead, auth: auth);
      });
    } else {
      _alertService.reset();
      _lastPosition = null;
    }

    if (entry == null) {
      final emptyBody = SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.medicalBlue.withOpacity(0.08),
              ),
              child: Icon(Icons.event_busy,
                  size: 72, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
            Text(l10n.noActiveQueue,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.bookQueueHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => context.go('/doctors'),
              icon: const Icon(Icons.search),
              label: Text(l10n.searchDoctors),
            ),
          ],
        ),
      );

      if (widget.embedded) {
        return emptyBody;
      }

      return Scaffold(
        backgroundColor: AppTheme.medicalWhite,
        appBar: AppBar(
          title: Text(l10n.queueTracking),
          backgroundColor: AppTheme.patientColor,
        ),
        body: emptyBody,
      );
    }

    final activeEntry = entry!;

    final doctor = data.doctorById(activeEntry.doctorId);
    final ahead = queue.peopleAhead(activeEntry);
    final current = queue.currentServingNumber(activeEntry) ?? 0;
    final waitMin = queue.estimatedWaitMinutes(activeEntry);

    final queueBody = ResponsiveBody(
      child: Column(
        children: [
          if (connectivity.isOffline)
            const OfflineIndicatorBanner(compact: true),
          if (widget.embedded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.myQueue,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PremiumQueueDashboard(
                entry: activeEntry,
                doctor: doctor,
                currentNumber: current,
                peopleAhead: ahead,
                waitMinutes: waitMin,
                pulseController: _pulseController,
                numberScaleAnimation: _numberScale,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ResponsiveActionButtons(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.push(
                      '/chat?clinicId=${doctor?.clinicId ?? 'clinic_erbil_1'}',
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(l10n.chatWithClinic),
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      await queue.cancelEntry(activeEntry.id, activeEntry.doctorId);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.queueCancelled)),
                      );
                      if (!widget.embedded) context.go('/home');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                    ),
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(l10n.cancelQueue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) return queueBody;

    return Scaffold(
      backgroundColor: AppTheme.medicalWhite,
      appBar: AppBar(
        title: Text(l10n.queueTracking),
        backgroundColor: AppTheme.patientColor,
        elevation: 0,
      ),
      body: queueBody,
    );
  }
}
