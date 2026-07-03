import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/doctor.dart';
import '../../../models/provider_catalog_mode.dart';
import '../../../models/queue_entry.dart';
import '../../../services/advertisement_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/favorites_service.dart';
import '../../../services/locale_service.dart';
import '../../../services/patient_profile_service.dart';
import '../../../services/queue_service.dart';
import '../../../services/recently_visited_service.dart';
import '../../../services/theme_service.dart';
import '../../../utils/image_upload_utils.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/patient_photo_utils.dart';
import '../../../utils/provider_labels.dart';
import '../../../utils/queue_status_utils.dart';
import '../../providers/app_providers.dart';
import '../../widgets/advertisement_carousel.dart';
import '../../widgets/doctor_avatar.dart';
import '../../widgets/patient_queue_utils.dart';
import '../../widgets/settings/settings_widgets.dart';

/// Premium Material 3 patient profile hub — header, stats, queues, favorites.
class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  String? _gender;
  bool _saving = false;
  final Set<String> _watchedDoctorIds = {};
  QueueService? _queueService;

  static const _sectionSpacing = 20.0;
  static const _contentPadding = 16.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthService>();
    final patientId = auth.patientId;
    if (patientId.isEmpty) return;

    _queueService = context.read<QueueService>();
    _queueService!.watchPatientQueues(patientId);
    context.read<AppointmentProvider>().watchPatient(patientId);
    await context.read<FavoritesService>().bindUser(patientId);
    await context.read<RecentlyVisitedService>().bindUser(patientId);

    final city = context.read<PatientProfileService>().profile.city;
    if (city != null && city.trim().isNotEmpty) {
      context.read<AdvertisementService>().watchForCity(city.trim());
    }

    _syncDoctorWatches(
      context.read<QueueService>().activeQueuesForPatient(patientId),
    );
    _load();
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

  void _load() {
    final auth = context.read<AuthService>();
    final profile = context.read<PatientProfileService>();
    final user = auth.currentUser;
    _nameController.text = user?.name.localized(context) ?? '';
    _phoneController.text = user?.phone ?? '';
    _emailController.text = user?.email ?? '';
    _cityController.text = profile.profile.city ?? '';
    _gender = profile.profile.gender;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final id in _watchedDoctorIds) {
      _queueService?.stopWatchingDoctorQueue(id);
    }
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    final auth = context.read<AuthService>();
    final profileService = context.read<PatientProfileService>();

    final err = await auth.updatePatientAccount(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;
    if (err != null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage(l10n, err))),
      );
      return;
    }

    await profileService.updateProfile(
      profileService.profile.copyWith(
        city: _cityController.text.trim(),
        gender: _gender,
      ),
    );
    context.read<AdvertisementService>().watchForCity(
          _cityController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.profileSaved)),
    );
  }

  Future<void> _pickPhoto() async {
    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context);
    final result = await pickPatientProfilePhoto(
      context,
      patientId: auth.patientId,
    );
    if (!mounted || result.isCancelled) return;
    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.uploadFailed)),
      );
      return;
    }
    final urls = result.urls!;
    await context.read<PatientProfileService>().updateField(
          (p) => p.copyWith(
            photoUrl: urls.fullUrl,
            photoThumbnailUrl: urls.thumbnailUrl,
          ),
        );
  }

  void _openEditSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => _EditProfileSheet(
        nameController: _nameController,
        phoneController: _phoneController,
        emailController: _emailController,
        cityController: _cityController,
        gender: _gender,
        saving: _saving,
        onGenderChanged: (v) => setState(() => _gender = v),
        onSave: () async {
          await _save();
          if (ctx.mounted) Navigator.pop(ctx);
        },
        onPickPhoto: _pickPhoto,
      ),
    );
  }

  String _errorMessage(AppLocalizations l10n, String code) {
    switch (code) {
      case 'invalid_phone':
        return l10n.invalidPhone;
      case 'invalid_name':
        return l10n.invalidName;
      default:
        return l10n.saveFailed;
    }
  }

  String _genderLabel(AppLocalizations l10n, String? gender) {
    switch (gender) {
      case 'male':
        return l10n.male;
      case 'female':
        return l10n.female;
      default:
        return l10n.notSpecified;
    }
  }

  String? _memberSinceLabel(
    AppLocalizations l10n,
    List<QueueEntry> queues,
  ) {
    if (queues.isEmpty) return null;
    final earliest = queues
        .map((e) => e.bookedAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    return DateFormat.yMMMd().format(earliest);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profile = context.watch<PatientProfileService>().profile;
    final locale = context.watch<LocaleService>();
    final themeService = context.watch<ThemeService>();
    final auth = context.watch<AuthService>();
    final queue = context.watch<QueueService>();
    final data = context.watch<ClinicDataService>();
    final favorites = context.watch<FavoritesService>();
    final recentlyVisited = context.watch<RecentlyVisitedService>();
    final appointments = context.watch<AppointmentProvider>();
    final ads = context.watch<AdvertisementService>().advertisements;

    final patientId = auth.patientId;
    final activeQueues = queue.activeQueuesForPatient(patientId);
    _syncDoctorWatches(activeQueues);

    final photoProvider = tabibImageProvider(
      profile.photoUrl,
      thumbnailUrl: profile.photoThumbnailUrl,
      preferThumbnail: kIsWeb,
    );

    final displayName =
        auth.currentUser?.name.localized(context) ?? l10n.patientName;
    final city = profile.city?.trim();
    final memberSince = _memberSinceLabel(l10n, activeQueues);

    final upcomingCount = appointments.appointments
        .where(
          (a) =>
              a.dateTime.isAfter(DateTime.now()) &&
              (a.isPending || a.isAccepted),
        )
        .length;

    final visitedCount = recentlyVisited.recentDoctorIds.length +
        recentlyVisited.recentBusinessIds.length;

    final favoriteDoctors = favorites.favoriteDoctorIds
        .map(data.doctorById)
        .whereType<Doctor>()
        .toList();

    final scrollBody = SafeArea(
      top: !widget.embedded,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth.clamp(0.0, 960.0);
          return SingleChildScrollView(
            primary: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProfileCoverHeader(
                    photoProvider: photoProvider,
                    displayName: displayName,
                    city: city,
                    memberSince: memberSince,
                    memberSinceLabel: l10n.memberSince,
                    notSpecified: l10n.notSpecified,
                    editLabel: l10n.editProfile,
                    uploadLabel: l10n.uploadPhoto,
                    onEdit: _openEditSheet,
                    onPickPhoto: _pickPhoto,
                  ),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        _contentPadding,
                        _sectionSpacing,
                        _contentPadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionTitle(title: l10n.profileStatistics),
                          const SizedBox(height: 12),
                          _StatisticsGrid(
                            activeQueues: activeQueues.length,
                            completedVisits: visitedCount,
                            favoriteDoctors: favorites.favoriteDoctorIds.length,
                            upcomingAppointments: upcomingCount,
                            labels: _StatLabels(
                              activeQueues: l10n.activeQueues,
                              completedVisits: l10n.completedVisits,
                              favoriteDoctors: l10n.favoriteDoctors,
                              upcomingAppointments: l10n.upcomingAppointments,
                            ),
                          ),
                          if (ads.isNotEmpty) ...[
                            const SizedBox(height: _sectionSpacing),
                            AdvertisementCarousel(
                              advertisements: ads,
                              height: 148,
                            ),
                          ],
                          const SizedBox(height: _sectionSpacing),
                          _SectionTitle(title: l10n.accountDetails),
                          const SizedBox(height: 12),
                          _AccountDetailsCard(
                            rows: [
                              _DetailRow(
                                icon: Icons.person_outline,
                                label: l10n.patientName,
                                value: displayName,
                              ),
                              _DetailRow(
                                icon: Icons.phone_outlined,
                                label: l10n.mobile,
                                value: auth.currentUser?.phone?.isNotEmpty == true
                                    ? auth.currentUser!.phone!
                                    : l10n.notSpecified,
                              ),
                              _DetailRow(
                                icon: Icons.email_outlined,
                                label: l10n.emailOptional,
                                value: auth.currentUser?.email?.isNotEmpty == true
                                    ? auth.currentUser!.email!
                                    : l10n.notSpecified,
                              ),
                              _DetailRow(
                                icon: Icons.wc_outlined,
                                label: l10n.genderOptional,
                                value: _genderLabel(l10n, profile.gender),
                              ),
                              _DetailRow(
                                icon: Icons.cake_outlined,
                                label: l10n.birthDate,
                                value: l10n.notSpecified,
                              ),
                              _DetailRow(
                                icon: Icons.bloodtype_outlined,
                                label: l10n.bloodType,
                                value: l10n.notSpecified,
                              ),
                              _DetailRow(
                                icon: Icons.emergency_outlined,
                                label: l10n.emergencyContact,
                                value: l10n.notSpecified,
                              ),
                            ],
                          ),
                          const SizedBox(height: _sectionSpacing),
                          _SectionTitle(
                            title: l10n.myQueues,
                            trailing: IconButton(
                              tooltip: l10n.refresh,
                              onPressed: patientId.isEmpty
                                  ? null
                                  : () {
                                      queue.refreshPatientQueues(patientId);
                                      for (final e in activeQueues) {
                                        queue.watchDoctorQueue(e.doctorId);
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.refresh),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.refresh_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (activeQueues.isEmpty)
                            _EmptyHintCard(
                              message: l10n.noActiveQueuesOnProfile,
                              icon: Icons.event_busy_outlined,
                            )
                          else
                            ...activeQueues.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ProfileQueueCard(
                                  entry: entry,
                                  doctor: data.doctorById(entry.doctorId),
                                  queueService: queue,
                                ),
                              ),
                            ),
                          if (ads.length > 1) ...[
                            const SizedBox(height: _sectionSpacing),
                            AdvertisementCarousel(
                              advertisements: ads,
                              height: 132,
                            ),
                          ],
                          const SizedBox(height: _sectionSpacing),
                          _SectionTitle(title: l10n.favoriteDoctors),
                          const SizedBox(height: 12),
                          if (favoriteDoctors.isEmpty)
                            _EmptyHintCard(
                              message: l10n.noFavoriteDoctorsYet,
                              icon: Icons.favorite_border,
                            )
                          else
                            _FavoriteDoctorsStrip(doctors: favoriteDoctors),
                          const SizedBox(height: _sectionSpacing),
                          _SectionTitle(title: l10n.appearanceAndPrivacy),
                          const SizedBox(height: 12),
                          SettingsSection(
                            title: l10n.appearance,
                            icon: Icons.palette_outlined,
                            children: [
                              SettingsTile(
                                icon: Icons.dark_mode_outlined,
                                title: l10n.theme,
                                subtitle: _themeLabel(l10n, themeService.themeMode),
                                onTap: () =>
                                    _showThemePicker(themeService, l10n),
                              ),
                              const SettingsDivider(),
                              SettingsTile(
                                icon: Icons.language,
                                title: l10n.language,
                                subtitle: _languageLabel(l10n, locale.locale),
                                onTap: () =>
                                    _showLanguagePicker(locale, l10n),
                              ),
                            ],
                          ),
                          SettingsSection(
                            title: l10n.privacySettings,
                            icon: Icons.shield_outlined,
                            children: [
                              SettingsSwitchTile(
                                icon: Icons.photo_outlined,
                                title: l10n.showProfilePhoto,
                                value: profile.showProfilePhoto,
                                onChanged: (v) => context
                                    .read<PatientProfileService>()
                                    .updateField(
                                      (p) => p.copyWith(showProfilePhoto: v),
                                    ),
                              ),
                              SettingsSwitchTile(
                                icon: Icons.phone_android_outlined,
                                title: l10n.showPhoneNumber,
                                value: profile.showPhoneNumber,
                                onChanged: (v) => context
                                    .read<PatientProfileService>()
                                    .updateField(
                                      (p) => p.copyWith(showPhoneNumber: v),
                                    ),
                              ),
                              SettingsSwitchTile(
                                icon: Icons.visibility_outlined,
                                title: l10n.profileVisibleToVisitedOnly,
                                value: profile.visibleToVisitedOnly,
                                onChanged: (v) => context
                                    .read<PatientProfileService>()
                                    .updateField(
                                      (p) =>
                                          p.copyWith(visibleToVisitedOnly: v),
                                    ),
                              ),
                            ],
                          ),
                          if (auth.canChangePassword) ...[
                            SettingsSection(
                              title: l10n.accountSecurity,
                              icon: Icons.lock_outline,
                              children: [
                                SettingsTile(
                                  icon: Icons.vpn_key_outlined,
                                  title: l10n.changePassword,
                                  onTap: () =>
                                      context.push('/settings/password'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (widget.embedded) return scrollBody;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: scrollBody,
    );
  }

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return l10n.themeDark;
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.system:
        return l10n.themeSystem;
    }
  }

  String _languageLabel(AppLocalizations l10n, Locale locale) {
    switch (locale.languageCode) {
      case 'ku':
        return l10n.langKurdish;
      case 'ar':
        return l10n.langArabic;
      default:
        return l10n.langEnglish;
    }
  }

  Future<void> _showThemePicker(
    ThemeService themeService,
    AppLocalizations l10n,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.themeSystem),
              onTap: () {
                themeService.setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(l10n.themeLight),
              onTap: () {
                themeService.setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(l10n.themeDark),
              onTap: () {
                themeService.setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLanguagePicker(
    LocaleService localeService,
    AppLocalizations l10n,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.langKurdish),
              onTap: () {
                localeService.setLocale(const Locale('ku'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(l10n.langArabic),
              onTap: () {
                localeService.setLocale(const Locale('ar'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(l10n.langEnglish),
              onTap: () {
                localeService.setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Web-safe bounded images (prevents intrinsic-size overflow on Chrome)
// ---------------------------------------------------------------------------

class _BoundedFillImage extends StatelessWidget {
  const _BoundedFillImage({required this.provider});

  final ImageProvider provider;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox.expand(
        child: Image(
          image: provider,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _BoundedCircleImage extends StatelessWidget {
  const _BoundedCircleImage({
    required this.provider,
    required this.size,
    this.fallbackIconSize,
  });

  final ImageProvider provider;
  final double size;
  final double? fallbackIconSize;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cache = (size * dpr).round().clamp(48, 512);

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image(
          image: ResizeImage(provider, width: cache, height: cache),
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => ColoredBox(
            color: AppTheme.medicalBlue.withOpacity(0.12),
            child: Icon(
              Icons.person,
              size: fallbackIconSize ?? size * 0.46,
              color: AppTheme.medicalBlue.withOpacity(0.55),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cover header (Facebook-style overlapping avatar)
// ---------------------------------------------------------------------------

class _ProfileCoverHeader extends StatelessWidget {
  const _ProfileCoverHeader({
    required this.photoProvider,
    required this.displayName,
    required this.city,
    required this.memberSince,
    required this.memberSinceLabel,
    required this.notSpecified,
    required this.editLabel,
    required this.uploadLabel,
    required this.onEdit,
    required this.onPickPhoto,
  });

  final ImageProvider? photoProvider;
  final String displayName;
  final String? city;
  final String? memberSince;
  final String memberSinceLabel;
  final String notSpecified;
  final String editLabel;
  final String uploadLabel;
  final VoidCallback onEdit;
  final VoidCallback onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final avatarRadius =
            (maxWidth * 0.13).clamp(44.0, screenSizeOf(context) == ScreenSize.mobile ? 54.0 : 60.0);
        final coverHeight = (avatarRadius * 2.35).clamp(120.0, 176.0);
        final cameraSize = (avatarRadius * 0.36).clamp(30.0, 38.0);
        final avatarDiameter = avatarRadius * 2;
        final frameSize = avatarDiameter + cameraSize * 0.22;
        final avatarTop = coverHeight - avatarRadius;
        final headerBlockHeight = avatarTop + frameSize + 8;
        final ring = Border.all(color: theme.colorScheme.surface, width: 4);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: headerBlockHeight,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: coverHeight,
                    child: _CoverBackground(photoProvider: photoProvider),
                  ),
                  Positioned(
                    top: avatarTop,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _OverlappingAvatar(
                        radius: avatarRadius,
                        ring: ring,
                        photoProvider: photoProvider,
                        uploadLabel: uploadLabel,
                        onPickPhoto: onPickPhoto,
                        cameraSize: cameraSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _MetaChip(
                        icon: Icons.location_city_outlined,
                        label: city?.isNotEmpty == true
                            ? city!
                            : notSpecified,
                        maxWidth: maxWidth * 0.42,
                      ),
                      _MetaChip(
                        icon: Icons.calendar_month_outlined,
                        label: memberSince != null
                            ? '$memberSinceLabel $memberSince'
                            : '$memberSinceLabel $notSpecified',
                        maxWidth: maxWidth * 0.52,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(
                        editLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.patientColor,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
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

class _CoverBackground extends StatelessWidget {
  const _CoverBackground({required this.photoProvider});

  final ImageProvider? photoProvider;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.medicalBlue,
            Color(0xFF2E7D8A),
            AppTheme.medicalGreen,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photoProvider != null)
            Opacity(
              opacity: 0.22,
              child: _BoundedFillImage(provider: photoProvider!),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.05),
                  Colors.black.withOpacity(0.28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlappingAvatar extends StatelessWidget {
  const _OverlappingAvatar({
    required this.radius,
    required this.ring,
    required this.photoProvider,
    required this.uploadLabel,
    required this.onPickPhoto,
    required this.cameraSize,
  });

  final double radius;
  final BoxBorder ring;
  final ImageProvider? photoProvider;
  final String uploadLabel;
  final VoidCallback onPickPhoto;
  final double cameraSize;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final frameSide = size + cameraSize * 0.22;

    return SizedBox(
      width: frameSide,
      height: frameSide,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, border: ring),
            child: photoProvider != null
                ? _BoundedCircleImage(
                    provider: photoProvider!,
                    size: size,
                    fallbackIconSize: radius * 0.92,
                  )
                : ClipOval(
                    child: ColoredBox(
                      color: AppTheme.medicalBlue.withOpacity(0.12),
                      child: Icon(
                        Icons.person,
                        size: radius * 0.92,
                        color: AppTheme.medicalBlue.withOpacity(0.55),
                      ),
                    ),
                  ),
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: Material(
              elevation: 2,
              color: AppTheme.patientColor,
              shape: const CircleBorder(),
              child: SizedBox(
                width: cameraSize,
                height: cameraSize,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: uploadLabel,
                  onPressed: onPickPhoto,
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: cameraSize * 0.46,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.maxWidth,
  });

  final IconData icon;
  final String label;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Statistics & details
// ---------------------------------------------------------------------------

class _StatLabels {
  const _StatLabels({
    required this.activeQueues,
    required this.completedVisits,
    required this.favoriteDoctors,
    required this.upcomingAppointments,
  });

  final String activeQueues;
  final String completedVisits;
  final String favoriteDoctors;
  final String upcomingAppointments;
}

class _StatisticsGrid extends StatelessWidget {
  const _StatisticsGrid({
    required this.activeQueues,
    required this.completedVisits,
    required this.favoriteDoctors,
    required this.upcomingAppointments,
    required this.labels,
  });

  final int activeQueues;
  final int completedVisits;
  final int favoriteDoctors;
  final int upcomingAppointments;
  final _StatLabels labels;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        icon: Icons.queue_play_next_rounded,
        label: labels.activeQueues,
        value: '$activeQueues',
        color: AppTheme.medicalBlue,
      ),
      _StatCard(
        icon: Icons.check_circle_outline_rounded,
        label: labels.completedVisits,
        value: '$completedVisits',
        color: AppTheme.medicalGreen,
      ),
      _StatCard(
        icon: Icons.favorite_outline_rounded,
        label: labels.favoriteDoctors,
        value: '$favoriteDoctors',
        color: Colors.pink.shade400,
      ),
      _StatCard(
        icon: Icons.event_available_outlined,
        label: labels.upcomingAppointments,
        value: '$upcomingAppointments',
        color: Colors.orange.shade700,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 560;
        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 12),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 12),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard({required this.rows});

  final List<_DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              ListTile(
                leading: Icon(rows[i].icon, color: AppTheme.medicalBlue),
                title: Text(
                  rows[i].label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                subtitle: Text(
                  rows[i].value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              if (i < rows.length - 1)
                const Divider(height: 1, indent: 56, endIndent: 16),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Queues, favorites, helpers
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _EmptyHintCard extends StatelessWidget {
  const _EmptyHintCard({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade500, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileQueueCard extends StatelessWidget {
  const _ProfileQueueCard({
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
    final status = _queueStatusLabel(l10n, entry.status);
    final statusColor = entry.status.color();
    final canCancel = canCancelPatientQueue(entry);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorAvatar(
                  photoUrl: doctor?.photoUrl,
                  thumbnailUrl: doctor?.photoThumbnailUrl,
                  radius: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor?.name.localized(context) ?? l10n.doctor,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (specialty.isNotEmpty)
                        Text(
                          specialty,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 400;
                final metrics = [
                  _QueueMetric(
                    icon: Icons.confirmation_number_outlined,
                    label: l10n.queueNumber,
                    value: '${entry.position}',
                  ),
                  _QueueMetric(
                    icon: Icons.play_circle_outline,
                    label: l10n.currentServing,
                    value: '$currentServing',
                  ),
                  _QueueMetric(
                    icon: Icons.hourglass_top_outlined,
                    label: l10n.waitTime,
                    value: l10n.minutesShort(waitMin),
                  ),
                ];

                if (narrow) {
                  return Column(
                    children: [
                      for (var i = 0; i < metrics.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        metrics[i],
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    for (var i = 0; i < metrics.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(child: metrics[i]),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    queueService.watchDoctorQueue(entry.doctorId);
                    queueService.refreshPatientQueues(entry.patientId);
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.refresh),
                ),
                if (canCancel)
                  FilledButton.icon(
                    onPressed: () => _confirmCancel(context, l10n),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: Text(l10n.cancelQueue),
                  ),
                TextButton.icon(
                  onPressed: () =>
                      context.push('/queue?entryId=${entry.id}'),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: Text(l10n.viewDetails),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _queueStatusLabel(AppLocalizations l10n, QueueStatus status) {
    switch (status) {
      case QueueStatus.waiting:
      case QueueStatus.review:
      case QueueStatus.followUp:
        return l10n.queueStatusWaiting;
      case QueueStatus.inProgress:
      case QueueStatus.examination:
      case QueueStatus.sentForTests:
        return l10n.queueStatusServing;
      case QueueStatus.completed:
        return l10n.queueStatusFinished;
      case QueueStatus.cancelled:
        return l10n.queueStatusCancelled;
      case QueueStatus.absent:
        return l10n.queueStatusAbsent;
    }
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

class _QueueMetric extends StatelessWidget {
  const _QueueMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.medicalBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.medicalBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteDoctorsStrip extends StatelessWidget {
  const _FavoriteDoctorsStrip({required this.doctors});

  final List<Doctor> doctors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          final route = ProviderLabels.detailRoute(
            doctor.isBusiness
                ? ProviderCatalogMode.businesses
                : ProviderCatalogMode.doctors,
            doctor.id,
          );
          return SizedBox(
            width: 108,
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: InkWell(
                onTap: () => context.push(route),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DoctorAvatar(
                        photoUrl: doctor.photoUrl,
                        thumbnailUrl: doctor.photoThumbnailUrl,
                        radius: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        doctor.name.localized(context),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
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
    );
  }
}

// ---------------------------------------------------------------------------
// Edit profile bottom sheet
// ---------------------------------------------------------------------------

class _EditProfileSheet extends StatelessWidget {
  const _EditProfileSheet({
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.cityController,
    required this.gender,
    required this.saving,
    required this.onGenderChanged,
    required this.onSave,
    required this.onPickPhoto,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController cityController;
  final String? gender;
  final bool saving;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onSave;
  final VoidCallback onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.editProfile,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onPickPhoto,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(l10n.uploadPhoto),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.patientName,
                prefixIcon: const Icon(Icons.person_outline),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
                prefixIcon: const Icon(Icons.phone_outlined),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.emailOptional,
                prefixIcon: const Icon(Icons.email_outlined),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: l10n.city,
                prefixIcon: const Icon(Icons.location_city_outlined),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              value: gender?.isEmpty == true ? null : gender,
              decoration: InputDecoration(
                labelText: l10n.genderOptional,
                prefixIcon: const Icon(Icons.wc_outlined),
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.notSpecified, overflow: TextOverflow.ellipsis),
                ),
                DropdownMenuItem(
                  value: 'male',
                  child: Text(l10n.male, overflow: TextOverflow.ellipsis),
                ),
                DropdownMenuItem(
                  value: 'female',
                  child: Text(l10n.female, overflow: TextOverflow.ellipsis),
                ),
              ],
              onChanged: onGenderChanged,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: saving ? null : onSave,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.patientColor,
                minimumSize: const Size.fromHeight(48),
              ),
              child: saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
