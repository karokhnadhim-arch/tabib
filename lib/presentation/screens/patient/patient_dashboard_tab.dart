import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/doctor.dart';
import '../../../models/provider_catalog_mode.dart';
import '../../../models/queue_entry.dart';
import '../../../services/advertisement_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/favorites_service.dart';
import '../../../services/patient_profile_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/provider_labels.dart';
import '../../widgets/advertisement_carousel.dart';
import '../../widgets/doctor_avatar.dart';
import '../../widgets/simple_queue_circles.dart';

/// Clean patient home: ads carousel, search, catalog shortcuts, favorites, queues.
class PatientDashboardTab extends StatefulWidget {
  const PatientDashboardTab({
    super.key,
    required this.onQueuesTap,
    required this.onDoctorsTap,
    required this.onBusinessesTap,
  });

  final VoidCallback onQueuesTap;
  final VoidCallback onDoctorsTap;
  final VoidCallback onBusinessesTap;

  @override
  State<PatientDashboardTab> createState() => _PatientDashboardTabState();
}

class _PatientDashboardTabState extends State<PatientDashboardTab>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _numberController;
  late final Animation<double> _numberScale;
  String? _watchedDoctorId;
  String? _lastWatchedCity;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthService>();
      final profile = context.read<PatientProfileService>();
      await profile.bindUser(auth.patientId);
      if (!mounted) return;
      context
          .read<AdvertisementService>()
          .watchForCity(profile.profile.city);
    });
  }

  void _syncDoctorWatch(QueueEntry? entry) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final auth = context.watch<AuthService>();
    final queue = context.watch<QueueService>();
    final favorites = context.watch<FavoritesService>();
    final ads = context.watch<AdvertisementService>().advertisements;
    final patientCity = context.watch<PatientProfileService>().profile.city;

    if (patientCity != _lastWatchedCity) {
      _lastWatchedCity = patientCity;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AdvertisementService>().watchForCity(patientCity);
      });
    }

    final activeQueues = queue.activeQueuesForPatient(auth.patientId);
    final primaryQueue =
        activeQueues.isNotEmpty ? activeQueues.first : null;
    _syncDoctorWatch(primaryQueue);

    final favoriteDoctors = favorites.favoriteDoctorIds
        .map(data.doctorById)
        .whereType<Doctor>()
        .toList();
    final favoriteBusinesses = favorites.favoriteBusinessIds
        .map(data.doctorById)
        .whereType<Doctor>()
        .toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 0,
          backgroundColor: AppTheme.patientColor,
          foregroundColor: Colors.white,
          title: Text(
            l10n.appTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push('/notifications'),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: l10n.settings,
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        if (ads.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AdvertisementCarousel(advertisements: ads),
            ),
          )
        else if (patientCity == null || patientCity.trim().isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _CityHintCard(
                message: l10n.setCityForAds,
                actionLabel: l10n.patientProfile,
                onAction: () => context.push('/profile'),
              ),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, ads.isNotEmpty ? 20 : 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Material(
              color: Theme.of(context).cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: InkWell(
                onTap: () => context.push('/doctors'),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade500),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.searchProvidersHint,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: _CatalogTile(
                    icon: Icons.medical_services_outlined,
                    label: l10n.doctorsSection,
                    color: AppTheme.medicalBlue,
                    onTap: widget.onDoctorsTap,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CatalogTile(
                    icon: Icons.local_hospital_outlined,
                    label: l10n.clinicsHealthcareCenters,
                    color: AppTheme.medicalGreen,
                    onTap: widget.onBusinessesTap,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (activeQueues.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: SectionHeader(
                title: activeQueues.length > 1
                    ? l10n.activeQueues
                    : l10n.myQueue,
                action: TextButton(
                  onPressed: widget.onQueuesTap,
                  child: Text(l10n.viewAll),
                ),
              ),
            ),
          ),
          if (primaryQueue != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SimpleQueueCircles(
                  myNumber: primaryQueue.position,
                  currentNumber:
                      queue.currentServingNumber(primaryQueue) ?? 0,
                  peopleAhead: queue.peopleAhead(primaryQueue),
                  pulseController: _pulseController,
                  numberScaleAnimation: _numberScale,
                  onTap: widget.onQueuesTap,
                ),
              ),
            ),
        ],
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (favoriteDoctors.isNotEmpty) ...[
                _FavoritesRow(
                  title: l10n.favoriteDoctors,
                  providers: favoriteDoctors,
                ),
                const SizedBox(height: 20),
              ],
              if (favoriteBusinesses.isNotEmpty)
                _FavoritesRow(
                  title: l10n.favoriteBusinesses,
                  providers: favoriteBusinesses,
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _CityHintCard extends StatelessWidget {
  const _CityHintCard({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.medicalBlue.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.medicalBlue.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.campaign_outlined, color: AppTheme.medicalBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
              ),
            ),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesRow extends StatelessWidget {
  const _FavoritesRow({
    required this.title,
    required this.providers,
  });

  final String title;
  final List<Doctor> providers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: 8),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: providers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final doctor = providers[index];
              final route = ProviderLabels.detailRoute(
                doctor.isBusiness
                    ? ProviderCatalogMode.businesses
                    : ProviderCatalogMode.doctors,
                doctor.id,
              );
              return SizedBox(
                width: 108,
                child: Material(
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: InkWell(
                    onTap: () => context.push(route),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          DoctorAvatar(
                            photoUrl: doctor.photoUrl,
                            thumbnailUrl: doctor.photoThumbnailUrl,
                            radius: 26,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            doctor.name.localized(context),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
