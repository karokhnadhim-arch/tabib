import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/advertisement.dart';
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
import '../../../services/recently_visited_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/provider_labels.dart';
import '../../../widgets/common_widgets.dart';
import '../../widgets/doctor_avatar.dart';
import '../../widgets/simple_queue_circles.dart';

/// Modern patient home dashboard with search, favorites, nearby, ads, and queues.
class PatientDashboardTab extends StatefulWidget {
  const PatientDashboardTab({
    super.key,
    required this.userName,
    required this.onQueuesTap,
    required this.onDoctorsTap,
    required this.onBusinessesTap,
  });

  final String userName;
  final VoidCallback onQueuesTap;
  final VoidCallback onDoctorsTap;
  final VoidCallback onBusinessesTap;

  @override
  State<PatientDashboardTab> createState() => _PatientDashboardTabState();
}

class _PatientDashboardTabState extends State<PatientDashboardTab>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  Position? _position;
  bool _locationLoading = false;
  late final AnimationController _pulseController;
  late final AnimationController _numberController;
  late final Animation<double> _numberScale;
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthService>();
      final profile = context.read<PatientProfileService>();
      await profile.bindUser(auth.patientId);
      context.read<RecentlyVisitedService>().bindUser(auth.patientId);
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
    _searchController.dispose();
    _pulseController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  List<Doctor> _providersWithDistance(List<Doctor> doctors) {
    if (_position == null) return doctors;
    final loc = LocationService();
    final withDist = doctors.map((d) {
      final lat = d.latitude ?? d.clinic.latitude;
      final lng = d.longitude ?? d.clinic.longitude;
      final km = loc.distanceKm(
        fromLat: _position!.latitude,
        fromLng: _position!.longitude,
        toLat: lat,
        toLng: lng,
      );
      return (doctor: d, km: km);
    }).toList()
      ..sort((a, b) => a.km.compareTo(b.km));
    return withDist.map((e) => e.doctor).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = context.watch<ClinicDataService>();
    final auth = context.watch<AuthService>();
    final queue = context.watch<QueueService>();
    final favorites = context.watch<FavoritesService>();
    final recent = context.watch<RecentlyVisitedService>();
    final ads = context.watch<AdvertisementService>().advertisements;
    final profile = context.watch<PatientProfileService>().profile;

    final activeQueues = queue.activeQueuesForPatient(auth.patientId);
    final primaryQueue =
        activeQueues.isNotEmpty ? activeQueues.first : null;
    _syncDoctorWatch(primaryQueue);

    final doctors = data.patientCatalogProviders(
      catalogMode: ProviderCatalogMode.doctors,
    );
    final businesses = data.patientCatalogProviders(
      catalogMode: ProviderCatalogMode.businesses,
    );
    final favoriteDoctors = favorites.favoriteDoctorIds
        .map(data.doctorById)
        .whereType<Doctor>()
        .toList();
    final favoriteBusinesses = favorites.favoriteBusinessIds
        .map(data.doctorById)
        .whereType<Doctor>()
        .toList();
    final recentDoctors = recent.recentDoctorIds
        .map(data.doctorById)
        .whereType<Doctor>()
        .take(6)
        .toList();
    final recentBusinesses = recent.recentBusinessIds
        .map(data.doctorById)
        .whereType<Doctor>()
        .take(6)
        .toList();

    final nearbyDoctors = _providersWithDistance(doctors).take(6).toList();
    final nearbyBusinesses =
        _providersWithDistance(businesses).take(6).toList();
    final recommendedDoctors = List<Doctor>.from(doctors)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final recommendedBusinesses = List<Doctor>.from(businesses)
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: MedicalGradientHeader(
            title: l10n.welcomeUser(widget.userName),
            subtitle: l10n.appSubtitle,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () => context.push('/notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                tooltip: l10n.patientProfile,
                onPressed: () => context.push('/profile'),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                tooltip: l10n.settings,
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: TextField(
              controller: _searchController,
              readOnly: true,
              onTap: () => context.push('/doctors'),
              decoration: InputDecoration(
                hintText: l10n.searchProvidersHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        if (activeQueues.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
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
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SectionHeader(title: l10n.browseHealthcare),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _QuickCatalogCard(
                      icon: Icons.medical_services_outlined,
                      title: l10n.doctorsSection,
                      color: AppTheme.medicalBlue,
                      onTap: widget.onDoctorsTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickCatalogCard(
                      icon: Icons.local_hospital_outlined,
                      title: l10n.clinicsHealthcareCenters,
                      color: AppTheme.medicalGreen,
                      onTap: widget.onBusinessesTap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SectionHeader(title: l10n.medicalSpecialties),
              const SizedBox(height: 8),
              SizedBox(
                height: 108,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: data.patientVisibleDoctorSpecialties.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final specialty =
                        data.patientVisibleDoctorSpecialties[index];
                    return _SpecialtyChipCard(specialtyId: specialty.id, specialtyName: specialty.name.localized(context), icon: SpecialtyIcon.forName(specialty.iconName));
                  },
                ),
              ),
              if (favoriteDoctors.isNotEmpty) ...[
                const SizedBox(height: 20),
                _ProviderCarousel(
                  title: l10n.favoriteDoctors,
                  providers: favoriteDoctors,
                ),
              ],
              if (favoriteBusinesses.isNotEmpty) ...[
                const SizedBox(height: 20),
                _ProviderCarousel(
                  title: l10n.favoriteBusinesses,
                  providers: favoriteBusinesses,
                ),
              ],
              if (recentDoctors.isNotEmpty || recentBusinesses.isNotEmpty) ...[
                const SizedBox(height: 20),
                SectionHeader(title: l10n.recentlyVisited),
                if (recentDoctors.isNotEmpty)
                  _ProviderCarousel(
                    title: l10n.doctorsSection,
                    providers: recentDoctors,
                    showBookAgain: true,
                  ),
                if (recentBusinesses.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ProviderCarousel(
                    title: l10n.clinicsHealthcareCenters,
                    providers: recentBusinesses,
                    showBookAgain: true,
                  ),
                ],
              ],
              const SizedBox(height: 20),
              SectionHeader(
                title: l10n.nearbyProviders,
                action: _position == null
                    ? TextButton(
                        onPressed:
                            _locationLoading ? null : _tryLoadLocation,
                        child: Text(l10n.enableLocation),
                      )
                    : null,
              ),
              if (_position == null && !_locationLoading)
                Text(
                  l10n.locationRequiredForNearby,
                  style: TextStyle(color: Colors.grey.shade600),
                )
              else if (_locationLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                if (nearbyDoctors.isNotEmpty)
                  _ProviderCarousel(
                    title: l10n.doctorsSection,
                    providers: nearbyDoctors,
                  ),
                if (nearbyBusinesses.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ProviderCarousel(
                    title: l10n.clinicsHealthcareCenters,
                    providers: nearbyBusinesses,
                  ),
                ],
              ],
              if (ads.isNotEmpty) ...[
                const SizedBox(height: 20),
                SectionHeader(title: l10n.advertisements),
                ...ads.take(3).map((ad) => _AdCard(ad: ad)),
              ],
              const SizedBox(height: 20),
              _ProviderCarousel(
                title: l10n.recommendedDoctors,
                providers: recommendedDoctors.take(8).toList(),
              ),
              const SizedBox(height: 16),
              _ProviderCarousel(
                title: l10n.recommendedBusinesses,
                providers: recommendedBusinesses.take(8).toList(),
              ),
              if (profile.city != null && profile.city!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${l10n.city}: ${profile.city}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _QuickCatalogCard extends StatelessWidget {
  const _QuickCatalogCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
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
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
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

class _SpecialtyChipCard extends StatelessWidget {
  const _SpecialtyChipCard({
    required this.specialtyId,
    required this.specialtyName,
    required this.icon,
  });

  final String specialtyId;
  final String specialtyName;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => context.push('/doctors?specialty=$specialtyId'),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 100,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppTheme.medicalBlue),
                const SizedBox(height: 6),
                Text(
                  specialtyName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderCarousel extends StatelessWidget {
  const _ProviderCarousel({
    required this.title,
    required this.providers,
    this.showBookAgain = false,
  });

  final String title;
  final List<Doctor> providers;
  final bool showBookAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (providers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: showBookAgain ? 148 : 120,
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
                width: 140,
                child: Card(
                  elevation: 0,
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
                            radius: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            doctor.name.localized(context),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (showBookAgain) ...[
                            const Spacer(),
                            TextButton(
                              onPressed: () => context.push(route),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                l10n.bookAgain,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
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

class _AdCard extends StatelessWidget {
  const _AdCard({required this.ad});

  final Advertisement ad;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ad.imageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                ad.imageUrl!,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (ad.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    ad.description,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
                if (ad.buttonLabel != null && ad.linkUrl != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FilledButton(
                      onPressed: () {
                        final uri = Uri.tryParse(ad.linkUrl!);
                        if (uri != null) launchUrl(uri);
                      },
                      child: Text(ad.buttonLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
