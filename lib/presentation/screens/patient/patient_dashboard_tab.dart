import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
import '../../../services/location_service.dart';
import '../../../services/patient_profile_service.dart';
import '../../../services/queue_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/provider_labels.dart';
import '../../widgets/advertisement_carousel.dart';
import '../../widgets/doctor_avatar.dart';
import '../../widgets/patient_active_queue_card.dart';
import '../../widgets/patient_queue_utils.dart';

/// Premium patient home: ads, search, queue cards, favorites, nearby, recommended.
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

class _PatientDashboardTabState extends State<PatientDashboardTab> {
  final Set<String> _watchedDoctorIds = {};
  String? _lastWatchedCity;
  Position? _position;
  bool _locationLoading = false;
  QueueService? _queueService;
  PatientQueueSort _queueSort = PatientQueueSort.nearestAppointment;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthService>();
      final profile = context.read<PatientProfileService>();
      await profile.bindUser(auth.patientId);
      if (!mounted) return;
      context
          .read<AdvertisementService>()
          .watchForCity(profile.profile.city);
      await _tryLoadLocation();
    });
  }

  Future<void> _tryLoadLocation() async {
    setState(() => _locationLoading = true);
    final pos = await LocationService().getCurrentPosition();
    if (mounted) {
      setState(() {
        _position = pos;
        _locationLoading = false;
      });
    }
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

  List<Doctor> _sortedByDistance(List<Doctor> providers) {
    if (_position == null) return providers;
    final loc = LocationService();
    final withDist = providers.map((d) {
      final lat = d.latitude ?? d.clinic.latitude;
      final lng = d.longitude ?? d.clinic.longitude;
      return (
        doctor: d,
        km: loc.distanceKm(
          fromLat: _position!.latitude,
          fromLng: _position!.longitude,
          toLat: lat,
          toLng: lng,
        ),
      );
    }).toList()
      ..sort((a, b) => a.km.compareTo(b.km));
    return withDist.map((e) => e.doctor).toList();
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

    final activeQueues = sortPatientQueues(
      entries: queue.activeQueuesForPatient(auth.patientId),
      sort: _queueSort,
      queueService: queue,
    );
    _syncDoctorWatches(activeQueues);

    final favoriteDoctors = favorites.favoriteDoctorIds
        .map(data.doctorById)
        .whereType<Doctor>()
        .toList();
    final favoriteBusinesses = favorites.favoriteBusinessIds
        .map(data.doctorById)
        .whereType<Doctor>()
        .toList();

    final doctors = data.patientCatalogProviders(
      catalogMode: ProviderCatalogMode.doctors,
    );
    final businesses = data.patientCatalogProviders(
      catalogMode: ProviderCatalogMode.businesses,
    );
    final nearbyBusinesses = _sortedByDistance(businesses).take(8).toList();
    final recommendedDoctors = List<Doctor>.from(doctors)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final recommendedBusinesses = List<Doctor>.from(businesses)
      ..sort((a, b) => b.rating.compareTo(a.rating));

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
              padding: const EdgeInsets.only(top: 12),
              child: AdvertisementCarousel(advertisements: ads),
            ),
          )
        else if (patientCity == null || patientCity.trim().isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _CityHintCard(
                message: l10n.setCityForAds,
                actionLabel: l10n.patientProfile,
                onAction: () => context.push('/profile'),
              ),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, ads.isNotEmpty ? 16 : 12, 16, 0),
          sliver: SliverToBoxAdapter(child: _SearchBar(l10n: l10n)),
        ),
        if (activeQueues.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: SectionHeader(
                title: activeQueues.length > 1
                    ? l10n.activeQueues
                    : l10n.myQueue,
                action: activeQueues.length > 1
                    ? TextButton(
                        onPressed: widget.onQueuesTap,
                        child: Text(l10n.viewAll),
                      )
                    : null,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: _QueueSortBar(
                sort: _queueSort,
                onChanged: (s) => setState(() => _queueSort = s),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => PatientActiveQueueCard(
                  entry: activeQueues[index],
                  doctor: data.doctorById(activeQueues[index].doctorId),
                  queueService: queue,
                ),
                childCount: activeQueues.length,
              ),
            ),
          ),
        ],
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (favoriteDoctors.isNotEmpty)
                _ProviderRow(
                  title: l10n.favoriteDoctors,
                  providers: favoriteDoctors,
                ),
              if (favoriteDoctors.isNotEmpty) const SizedBox(height: 20),
              if (favoriteBusinesses.isNotEmpty)
                _ProviderRow(
                  title: l10n.favoriteBusinesses,
                  providers: favoriteBusinesses,
                ),
              if (favoriteBusinesses.isNotEmpty) const SizedBox(height: 20),
              _NearbySection(
                l10n: l10n,
                loading: _locationLoading,
                hasLocation: _position != null,
                providers: nearbyBusinesses,
                onEnableLocation: _tryLoadLocation,
              ),
              const SizedBox(height: 20),
              _ProviderRow(
                title: l10n.recommendedDoctors,
                providers: recommendedDoctors.take(8).toList(),
              ),
              const SizedBox(height: 20),
              _ProviderRow(
                title: l10n.recommendedHealthcareCenters,
                providers: recommendedBusinesses.take(8).toList(),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _QueueSortBar extends StatelessWidget {
  const _QueueSortBar({required this.sort, required this.onChanged});

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
      label: Text(label),
      selected: sort == value,
      onSelected: (_) => onChanged(value),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.l10n});

  final AppLocalizations l10n;

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
        onTap: () => context.push('/doctors'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey.shade500),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.searchProvidersHint,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
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
            const Icon(Icons.campaign_outlined, color: AppTheme.medicalBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 13)),
            ),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _NearbySection extends StatelessWidget {
  const _NearbySection({
    required this.l10n,
    required this.loading,
    required this.hasLocation,
    required this.providers,
    required this.onEnableLocation,
  });

  final AppLocalizations l10n;
  final bool loading;
  final bool hasLocation;
  final List<Doctor> providers;
  final VoidCallback onEnableLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.nearbyHealthcareCenters,
          action: !hasLocation
              ? TextButton(
                  onPressed: loading ? null : onEnableLocation,
                  child: Text(l10n.enableLocation),
                )
              : null,
        ),
        const SizedBox(height: 8),
        if (!hasLocation && !loading)
          Text(
            l10n.locationRequiredForNearby,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          )
        else if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (providers.isEmpty)
          Text(
            l10n.noNearbyProviders,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          )
        else
          _ProviderRow(title: '', providers: providers, hideTitle: true),
      ],
    );
  }
}

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({
    required this.title,
    required this.providers,
    this.hideTitle = false,
  });

  final String title;
  final List<Doctor> providers;
  final bool hideTitle;

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!hideTitle && title.isNotEmpty) SectionHeader(title: title),
        if (!hideTitle && title.isNotEmpty) const SizedBox(height: 8),
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
