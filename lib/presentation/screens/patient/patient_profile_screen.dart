import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/advertisement_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/locale_service.dart';
import '../../../services/patient_profile_service.dart';
import '../../../services/theme_service.dart';
import '../../../utils/image_upload_utils.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/patient_photo_utils.dart';
import '../../widgets/settings/settings_widgets.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = context.watch<PatientProfileService>().profile;
    final locale = context.watch<LocaleService>();
    final themeService = context.watch<ThemeService>();
    final auth = context.watch<AuthService>();

    final photoProvider = tabibImageProvider(
      profile.photoUrl,
      thumbnailUrl: profile.photoThumbnailUrl,
      preferThumbnail: false,
    );

    final body = ScrollableResponsiveBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.embedded) ...[
            ResponsiveHeaderRow(
              title: Text(
                l10n.patientProfile,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              trailing: [
                _ProfileSaveButton(
                  saving: _saving,
                  onSave: _save,
                  l10n: l10n,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          _ProfilePhotoSection(
            photoProvider: photoProvider,
            onPickPhoto: _pickPhoto,
            uploadLabel: l10n.uploadPhoto,
          ),
          const SizedBox(height: 24),
          ResponsiveColumns(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.patientName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ResponsiveColumns(
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.emailOptional,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: l10n.city,
                  prefixIcon: const Icon(Icons.location_city_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            isExpanded: true,
            value: _gender?.isEmpty == true ? null : _gender,
            decoration: InputDecoration(
              labelText: l10n.genderOptional,
              prefixIcon: const Icon(Icons.wc_outlined),
            ),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(
                  l10n.notSpecified,
                  overflow: TextOverflow.ellipsis,
                ),
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
            onChanged: (v) => setState(() => _gender = v),
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: l10n.appearance,
            icon: Icons.palette_outlined,
            children: [
              SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: l10n.theme,
                subtitle: _themeLabel(l10n, themeService.themeMode),
                onTap: () => _showThemePicker(themeService, l10n),
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.language,
                title: l10n.language,
                subtitle: _languageLabel(l10n, locale.locale),
                onTap: () => _showLanguagePicker(locale, l10n),
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
                    .updateField((p) => p.copyWith(showProfilePhoto: v)),
              ),
              SettingsSwitchTile(
                icon: Icons.phone_android_outlined,
                title: l10n.showPhoneNumber,
                value: profile.showPhoneNumber,
                onChanged: (v) => context
                    .read<PatientProfileService>()
                    .updateField((p) => p.copyWith(showPhoneNumber: v)),
              ),
              SettingsSwitchTile(
                icon: Icons.visibility_outlined,
                title: l10n.profileVisibleToVisitedOnly,
                value: profile.visibleToVisitedOnly,
                onChanged: (v) => context
                    .read<PatientProfileService>()
                    .updateField((p) => p.copyWith(visibleToVisitedOnly: v)),
              ),
            ],
          ),
          if (auth.canChangePassword) ...[
            const SizedBox(height: 8),
            SettingsSection(
              title: l10n.accountSecurity,
              icon: Icons.lock_outline,
              children: [
                SettingsTile(
                  icon: Icons.vpn_key_outlined,
                  title: l10n.changePassword,
                  onTap: () => context.push('/settings/password'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.patientProfile),
        backgroundColor: AppTheme.patientColor,
        actions: [
          _ProfileSaveButton(
            saving: _saving,
            onSave: _save,
            l10n: l10n,
            compact: true,
          ),
        ],
      ),
      body: body,
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

class _ProfileSaveButton extends StatelessWidget {
  const _ProfileSaveButton({
    required this.saving,
    required this.onSave,
    required this.l10n,
    this.compact = false,
  });

  final bool saving;
  final VoidCallback onSave;
  final AppLocalizations l10n;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (saving) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final useIcon =
        compact || MediaQuery.sizeOf(context).width < 400;

    if (useIcon) {
      return IconButton(
        onPressed: onSave,
        tooltip: l10n.save,
        icon: const Icon(Icons.check),
      );
    }

    return TextButton(
      onPressed: onSave,
      child: Text(l10n.save, overflow: TextOverflow.ellipsis),
    );
  }
}

class _ProfilePhotoSection extends StatelessWidget {
  const _ProfilePhotoSection({
    required this.photoProvider,
    required this.onPickPhoto,
    required this.uploadLabel,
  });

  final ImageProvider? photoProvider;
  final VoidCallback onPickPhoto;
  final String uploadLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final photoSize = (constraints.maxWidth * 0.34).clamp(80.0, 112.0);
        final cameraSize = (photoSize * 0.34).clamp(32.0, 40.0);
        final stackSize = photoSize + cameraSize * 0.3;

        return Center(
          child: SizedBox(
            width: stackSize,
            height: stackSize,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: SizedBox(
                    width: photoSize,
                    height: photoSize,
                    child: ClipOval(
                      child: photoProvider != null
                          ? Image(
                              image: photoProvider!,
                              fit: BoxFit.cover,
                              width: photoSize,
                              height: photoSize,
                            )
                          : ColoredBox(
                              color: AppTheme.medicalBlue.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                size: photoSize * 0.5,
                                color: AppTheme.medicalBlue.withOpacity(0.5),
                              ),
                            ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: AppTheme.medicalBlue,
                    shape: const CircleBorder(),
                    child: SizedBox(
                      width: cameraSize,
                      height: cameraSize,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: cameraSize * 0.48,
                        ),
                        onPressed: onPickPhoto,
                        tooltip: uploadLabel,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
