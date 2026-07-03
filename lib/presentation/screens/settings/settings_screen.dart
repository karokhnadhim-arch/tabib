import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/admin_routes.dart';
import '../../../core/constants/app_info.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/doctor.dart';
import '../../../models/user_account.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/favorites_service.dart';
import '../../../services/locale_service.dart';
import '../../../services/theme_service.dart';
import '../../../services/user_preferences_service.dart';
import '../../../utils/localization_utils.dart';
import '../../../core/utils/account_code_resolver.dart';
import '../../../presentation/widgets/account_code_badge.dart';
import '../../../utils/provider_labels.dart';
import '../../widgets/doctor_avatar.dart';
import '../../widgets/settings/settings_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindUserServices());
  }

  Future<void> _bindUserServices() async {
    final auth = context.read<AuthService>();
    final userId = auth.currentUser?.id;
    if (!mounted) return;
    await context.read<UserPreferencesService>().bindUser(userId);
    if (!mounted) return;
    await context.read<FavoritesService>().bindUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final locale = context.watch<LocaleService>();
    final themeService = context.watch<ThemeService>();
    final prefs = context.watch<UserPreferencesService>().preferences;
    final data = context.watch<ClinicDataService>();

    final doctor = auth.isClinicalProvider &&
            auth.currentUser?.doctorId != null
        ? data.doctorById(auth.currentUser!.doctorId!)
        : null;
    final isProvider = auth.isClinicalProvider && doctor != null;
    final isBusiness = doctor?.isBusiness == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: _accentForRole(auth),
      ),
      body: ResponsiveBody(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AccountHeader(auth: auth, doctor: doctor),
            const SizedBox(height: 8),
            SettingsSection(
              title: l10n.appearance,
              icon: Icons.palette_outlined,
              children: [
                SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: l10n.theme,
                  subtitle: _themeLabel(l10n, themeService.themeMode),
                  onTap: () => _showThemePicker(context, themeService, l10n),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.language,
                  title: l10n.language,
                  subtitle: _languageLabel(l10n, locale.locale),
                  onTap: () => _showLanguagePicker(context, locale, l10n),
                ),
              ],
            ),
            SettingsSection(
              title: l10n.accountSecurity,
              icon: Icons.lock_outline,
              children: [
                if (auth.canChangePassword)
                  SettingsTile(
                    icon: Icons.password_outlined,
                    title: l10n.changePassword,
                    subtitle: l10n.changePasswordHint,
                    onTap: () => context.push('/settings/password'),
                  )
                else
                  SettingsTile(
                    icon: Icons.password_outlined,
                    title: l10n.changePassword,
                    subtitle: l10n.passwordChangeUnavailable,
                    showChevron: false,
                  ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.info_outline,
                  title: l10n.accountInfoReadOnly,
                  subtitle: l10n.accountInfoReadOnlyHint,
                  showChevron: false,
                ),
              ],
            ),
            SettingsSection(
              title: l10n.notifications,
              icon: Icons.notifications_outlined,
              children: [
                SettingsSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: l10n.pushNotifications,
                  value: prefs.pushNotifications,
                  onChanged: (v) => context
                      .read<UserPreferencesService>()
                      .updateField((p) => p.copyWith(pushNotifications: v)),
                ),
                const SettingsDivider(),
                SettingsSwitchTile(
                  icon: Icons.queue_play_next,
                  title: l10n.queueNotifications,
                  value: prefs.queueNotifications,
                  onChanged: (v) => context
                      .read<UserPreferencesService>()
                      .updateField((p) => p.copyWith(queueNotifications: v)),
                ),
                const SettingsDivider(),
                SettingsSwitchTile(
                  icon: Icons.volume_up_outlined,
                  title: l10n.sound,
                  value: prefs.soundEnabled,
                  onChanged: (v) => context
                      .read<UserPreferencesService>()
                      .updateField((p) => p.copyWith(soundEnabled: v)),
                ),
                const SettingsDivider(),
                SettingsSwitchTile(
                  icon: Icons.vibration,
                  title: l10n.vibration,
                  value: prefs.vibrationEnabled,
                  onChanged: (v) => context
                      .read<UserPreferencesService>()
                      .updateField((p) => p.copyWith(vibrationEnabled: v)),
                ),
              ],
            ),
            if (auth.isPatient) ...[
              SettingsSection(
                title: l10n.patientPreferences,
                icon: Icons.person_outline,
                children: [
                  SettingsTile(
                    icon: Icons.account_circle_outlined,
                    title: l10n.patientProfile,
                    onTap: () => context.push('/profile'),
                  ),
                  const SettingsDivider(),
                  SettingsTile(
                    icon: Icons.favorite_outline,
                    title: l10n.favoriteDoctors,
                    onTap: () => context.push('/settings/favorites?kind=doctor'),
                  ),
                  const SettingsDivider(),
                  SettingsTile(
                    icon: Icons.storefront_outlined,
                    title: l10n.favoriteBusinesses,
                    onTap: () =>
                        context.push('/settings/favorites?kind=business'),
                  ),
                ],
              ),
            ],
            if (isProvider) ...[
              SettingsSection(
                title:
                    isBusiness ? l10n.businessSettings : l10n.doctorSettings,
                icon: Icons.medical_services_outlined,
                children: [
                  if (doctor != null &&
                      AccountCodeResolver.forDoctor(doctor) != null) ...[
                    SettingsAccountCodeTile(
                      title: l10n.accountCode,
                      code: AccountCodeResolver.forDoctor(doctor)!,
                      onCopy: () => AccountCodeBadge.copyToClipboard(
                        context,
                        AccountCodeResolver.forDoctor(doctor)!,
                      ),
                    ),
                    const SettingsDivider(),
                  ],
                  SettingsTile(
                    icon: Icons.edit_outlined,
                    title: ProviderLabels.editProfileTitle(l10n, doctor),
                    onTap: () => context.push('/doctor/profile'),
                  ),
                  const SettingsDivider(),
                  SettingsTile(
                    icon: Icons.calendar_month_outlined,
                    title: l10n.workingDaysAndHours,
                    onTap: () =>
                        context.push('/settings/provider?section=schedule'),
                  ),
                  const SettingsDivider(),
                  SettingsTile(
                    icon: Icons.queue_outlined,
                    title: l10n.queueSettings,
                    onTap: () =>
                        context.push('/settings/provider?section=queue'),
                  ),
                  const SettingsDivider(),
                  SettingsTile(
                    icon: Icons.visibility_outlined,
                    title: l10n.profileVisibility,
                    onTap: () =>
                        context.push('/settings/provider?section=visibility'),
                  ),
                  const SettingsDivider(),
                  SettingsTile(
                    icon: Icons.phone_outlined,
                    title: l10n.contactVisibility,
                    onTap: () =>
                        context.push('/settings/provider?section=contact'),
                  ),
                  const SettingsDivider(),
                  SettingsTile(
                    icon: Icons.chat_outlined,
                    title: l10n.whatsappVisibility,
                    onTap: () =>
                        context.push('/settings/provider?section=whatsapp'),
                  ),
                ],
              ),
            ],
            if (auth.isSecretary) ...[
              SettingsSection(
                title: l10n.secretarySettings,
                icon: Icons.support_agent_outlined,
                children: [
                  Builder(
                    builder: (context) {
                      final code = AccountCodeResolver.forSecretary(
                        auth.currentUser!,
                        data,
                      );
                      if (code == null) return const SizedBox.shrink();
                      return Column(
                        children: [
                          SettingsAccountCodeTile(
                            title: l10n.doctorAccountCode,
                            code: code,
                            onCopy: () =>
                                AccountCodeBadge.copyToClipboard(context, code),
                          ),
                          const SettingsDivider(),
                        ],
                      );
                    },
                  ),
                  SettingsSwitchTile(
                    icon: Icons.notifications_active_outlined,
                    title: l10n.queueNotifications,
                    value: prefs.secretaryQueueAlerts,
                    onChanged: (v) => context
                        .read<UserPreferencesService>()
                        .updateField(
                          (p) => p.copyWith(secretaryQueueAlerts: v),
                        ),
                  ),
                  const SettingsDivider(),
                  SettingsSwitchTile(
                    icon: Icons.refresh,
                    title: l10n.queueAutoRefresh,
                    subtitle: l10n.queueAutoRefreshHint,
                    value: prefs.secretaryAutoRefreshQueue,
                    onChanged: (v) => context
                        .read<UserPreferencesService>()
                        .updateField(
                          (p) => p.copyWith(secretaryAutoRefreshQueue: v),
                        ),
                  ),
                ],
              ),
            ],
            SettingsSection(
              title: l10n.privacySettings,
              icon: Icons.privacy_tip_outlined,
              children: [
                SettingsSwitchTile(
                  title: l10n.showInSearchResults,
                  subtitle: l10n.showInSearchResultsHint,
                  value: prefs.showProfileInSearch,
                  onChanged: (v) => context
                      .read<UserPreferencesService>()
                      .updateField((p) => p.copyWith(showProfileInSearch: v)),
                ),
                const SettingsDivider(),
                SettingsSwitchTile(
                  title: l10n.shareUsageAnalytics,
                  subtitle: l10n.shareUsageAnalyticsHint,
                  value: prefs.shareUsageAnalytics,
                  onChanged: (v) => context
                      .read<UserPreferencesService>()
                      .updateField((p) => p.copyWith(shareUsageAnalytics: v)),
                ),
              ],
            ),
            SettingsSection(
              title: l10n.supportAndLegal,
              icon: Icons.help_outline,
              children: [
                SettingsTile(
                  icon: Icons.info_outline,
                  title: l10n.about,
                  onTap: () => context.push('/settings/legal?doc=about'),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.support_agent_outlined,
                  title: l10n.helpAndSupport,
                  onTap: () => _openSupport(context),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: l10n.termsAndConditions,
                  onTap: () => context.push('/settings/legal?doc=terms'),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.shield_outlined,
                  title: l10n.privacyPolicy,
                  onTap: () => context.push('/settings/legal?doc=privacy'),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.verified_outlined,
                  title: l10n.appVersion,
                  subtitle: '${AppInfo.version} (${AppInfo.buildNumber})',
                  showChevron: false,
                ),
              ],
            ),
            if (auth.isSystemOwner)
              SettingsSection(
                title: l10n.systemOwnerDashboard,
                icon: Icons.admin_panel_settings_outlined,
                children: [
                  SettingsTile(
                    icon: Icons.dashboard_outlined,
                    title: l10n.dashboardOverview,
                    subtitle: l10n.systemOwnerDashboardHint,
                    onTap: () => context.go(AdminRoutes.ownerHome),
                  ),
                ],
              ),
            if (auth.canAccessAdminPanel && !auth.isSystemOwner)
              SettingsSection(
                title: l10n.adminControlPanel,
                icon: Icons.admin_panel_settings_outlined,
                children: [
                  SettingsTile(
                    icon: Icons.admin_panel_settings,
                    title: l10n.adminControlPanel,
                    subtitle: l10n.adminControlPanelHint,
                    onTap: () => context.push('/owner/console'),
                  ),
                ],
              ),
            FilledButton.icon(
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                context.go('/login');
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: const Icon(Icons.logout),
              label: Text(l10n.logout),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentForRole(AuthService auth) {
    if (auth.isSystemOwner) return AppTheme.primaryDark;
    if (auth.isClinicalProvider) return AppTheme.doctorColor;
    if (auth.isSecretary) return AppTheme.secretaryColor;
    return AppTheme.patientColor;
  }

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
        ThemeMode.light => l10n.themeLight,
        ThemeMode.dark => l10n.themeDark,
        ThemeMode.system => l10n.themeSystem,
      };

  String _languageLabel(AppLocalizations l10n, Locale locale) =>
      switch (locale.languageCode) {
        'ar' => l10n.langArabic,
        'en' => l10n.langEnglish,
        _ => l10n.langKurdish,
      };

  Future<void> _showThemePicker(
    BuildContext context,
    ThemeService themeService,
    AppLocalizations l10n,
  ) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode_outlined),
              title: Text(l10n.themeLight),
              onTap: () => Navigator.pop(context, ThemeMode.light),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: Text(l10n.themeDark),
              onTap: () => Navigator.pop(context, ThemeMode.dark),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto_outlined),
              title: Text(l10n.themeSystem),
              onTap: () => Navigator.pop(context, ThemeMode.system),
            ),
          ],
        ),
      ),
    );
    if (selected != null) await themeService.setThemeMode(selected);
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    LocaleService localeService,
    AppLocalizations l10n,
  ) async {
    final selected = await showModalBottomSheet<Locale>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.langKurdish),
              onTap: () => Navigator.pop(context, const Locale('ku')),
            ),
            ListTile(
              title: Text(l10n.langArabic),
              onTap: () => Navigator.pop(context, const Locale('ar')),
            ),
            ListTile(
              title: Text(l10n.langEnglish),
              onTap: () => Navigator.pop(context, const Locale('en')),
            ),
          ],
        ),
      ),
    );
    if (selected != null) await localeService.setLocale(selected);
  }

  Future<void> _openSupport(BuildContext context) async {
    final uri = Uri.parse('mailto:${AppInfo.supportEmail}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.auth, this.doctor});

  final AuthService auth;
  final Doctor? doctor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    final roleLabel = user.isSystemOwner
        ? l10n.systemOwner
        : switch (user.role) {
            UserRole.patient => l10n.patient,
            UserRole.secretary => l10n.secretary,
            UserRole.admin => l10n.roleAdmin,
            UserRole.doctor => doctor?.isBusiness == true
                ? l10n.accountTypeBusiness
                : l10n.doctor,
          };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (doctor != null)
              DoctorAvatar(
                photoUrl: doctor!.patientVisiblePhotoUrl,
                thumbnailUrl: doctor!.patientVisiblePhotoThumbnailUrl,
                radius: 28,
                fallback: const Icon(Icons.person, color: AppTheme.medicalBlue),
              )
            else
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.medicalBlue.withOpacity(0.12),
                child: const Icon(Icons.person, color: AppTheme.medicalBlue),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.localized(context),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roleLabel,
                    style: TextStyle(color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.email != null && user.email!.isNotEmpty)
                    Text(
                      user.email!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
