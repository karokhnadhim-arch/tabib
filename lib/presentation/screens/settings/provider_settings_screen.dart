import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/doctor.dart';
import '../../../models/doctor_profile_visibility.dart';
import '../../../models/doctor_working_schedule.dart';
import '../../../services/auth_service.dart';
import '../../../services/clinic_data_service.dart';
import '../../../services/user_preferences_service.dart';
import '../../widgets/doctor_schedule_editor.dart';
import '../../widgets/settings/settings_widgets.dart';

class ProviderSettingsScreen extends StatefulWidget {
  const ProviderSettingsScreen({super.key, this.initialSection});

  final String? initialSection;

  @override
  State<ProviderSettingsScreen> createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  Doctor? _doctor;
  DoctorWorkingSchedule _schedule = DoctorWorkingSchedule(days: []);
  DoctorProfileVisibility _visibility = const DoctorProfileVisibility();
  bool _loading = true;
  bool _saving = false;
  String? _watchedDoctorId;
  final _scrollController = ScrollController();
  final _scheduleKey = GlobalKey();
  final _visibilityKey = GlobalKey();
  final _contactKey = GlobalKey();
  final _whatsappKey = GlobalKey();
  final _queueKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      _scrollToSection();
    });
  }

  Future<void> _load() async {
    final auth = context.read<AuthService>();
    final data = context.read<ClinicDataService>();
    final doctorId = auth.currentUser?.doctorId;
    if (doctorId == null || doctorId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final doctor = await data.fetchDoctorById(doctorId, forceRefresh: true);
    if (!mounted) return;
    setState(() {
      _doctor = doctor;
      _schedule = doctor?.effectiveWorkingSchedule ?? DoctorWorkingSchedule(days: []);
      _visibility = doctor?.profileVisibility ?? const DoctorProfileVisibility();
      _loading = false;
    });
    data.watchDoctorProfile(doctorId, (updated) {
      if (!mounted || updated == null) return;
      setState(() {
        _doctor = updated;
        _schedule = updated.effectiveWorkingSchedule;
        _visibility = updated.profileVisibility;
      });
    });
    _watchedDoctorId = doctorId;
  }

  void _scrollToSection() {
    final section = widget.initialSection;
    if (section == null) return;
    final key = switch (section) {
      'schedule' => _scheduleKey,
      'visibility' => _visibilityKey,
      'contact' => _contactKey,
      'whatsapp' => _whatsappKey,
      'queue' => _queueKey,
      _ => null,
    };
    if (key == null) return;
    Future.delayed(const Duration(milliseconds: 350), () {
      final ctx = key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    if (_watchedDoctorId != null) {
      context
          .read<ClinicDataService>()
          .stopWatchingDoctorProfile(_watchedDoctorId!);
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final doctor = _doctor;
    if (doctor == null) return;
    setState(() => _saving = true);
    final updated = doctor.copyWith(
      workingSchedule: _schedule.days,
      workingDays: _schedule.openWeekdays,
      profileVisibility: _visibility,
    );
    await context.read<ClinicDataService>().saveDoctor(updated);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _doctor = updated;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).savedSuccessfully)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = context.watch<UserPreferencesService>().preferences;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.providerSettings),
          backgroundColor: AppTheme.doctorColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_doctor == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.providerSettings)),
        body: Center(child: Text(l10n.noDoctorsFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.providerSettings),
        backgroundColor: AppTheme.doctorColor,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
      body: ResponsiveBody(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            SettingsSection(
              key: _scheduleKey,
              title: l10n.workingDaysAndHours,
              icon: Icons.calendar_month_outlined,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: DoctorScheduleEditor(
                    schedule: _schedule,
                    onChanged: (s) => setState(() => _schedule = s),
                  ),
                ),
              ],
            ),
            SettingsSection(
              key: _queueKey,
              title: l10n.queueSettings,
              icon: Icons.queue_outlined,
              children: [
                SettingsSwitchTile(
                  title: l10n.queueNotifications,
                  subtitle: l10n.queueNotificationsProviderHint,
                  value: prefs.queueNotifications,
                  onChanged: (v) => context
                      .read<UserPreferencesService>()
                      .updateField((p) => p.copyWith(queueNotifications: v)),
                ),
              ],
            ),
            SettingsSection(
              key: _visibilityKey,
              title: l10n.profileVisibility,
              icon: Icons.visibility_outlined,
              children: [
                _visibilitySwitch(l10n.showToPatients, l10n.bio, _visibility.showBio,
                    (v) => _visibility = _visibility.copyWith(showBio: v)),
                const SettingsDivider(),
                _visibilitySwitch(l10n.showToPatients, l10n.profilePhoto,
                    _visibility.showProfilePhoto,
                    (v) => _visibility = _visibility.copyWith(showProfilePhoto: v)),
                const SettingsDivider(),
                _visibilitySwitch(l10n.showToPatients, l10n.degrees,
                    _visibility.showDegrees,
                    (v) => _visibility = _visibility.copyWith(showDegrees: v)),
                const SettingsDivider(),
                _visibilitySwitch(l10n.showToPatients, l10n.experience,
                    _visibility.showExperience,
                    (v) => _visibility = _visibility.copyWith(showExperience: v)),
              ],
            ),
            SettingsSection(
              key: _contactKey,
              title: l10n.contactVisibility,
              icon: Icons.phone_outlined,
              children: [
                _visibilitySwitch(l10n.showToPatients, l10n.phone,
                    _visibility.showPhoneNumber,
                    (v) => _visibility = _visibility.copyWith(showPhoneNumber: v)),
                const SettingsDivider(),
                _visibilitySwitch(l10n.showToPatients, l10n.email,
                    _visibility.showEmail,
                    (v) => _visibility = _visibility.copyWith(showEmail: v)),
              ],
            ),
            SettingsSection(
              key: _whatsappKey,
              title: l10n.whatsappVisibility,
              icon: Icons.chat_outlined,
              children: [
                _visibilitySwitch(l10n.showToPatients, l10n.whatsappNumber,
                    _visibility.showWhatsapp,
                    (v) => _visibility = _visibility.copyWith(showWhatsapp: v)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _visibilitySwitch(
    String prefix,
    String field,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        '$prefix: $field',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      value: value,
      activeColor: AppTheme.medicalGreen,
      onChanged: (v) => setState(() => onChanged(v)),
    );
  }
}
