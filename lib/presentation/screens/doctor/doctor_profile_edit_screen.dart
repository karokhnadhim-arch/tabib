import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';



import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';

import '../../../models/doctor.dart';
import '../../../models/doctor_profile_visibility.dart';
import '../../../models/doctor_working_schedule.dart';

import '../../../models/localized_text.dart';

import '../../../models/specialty.dart';

import '../../../services/auth_service.dart';

import '../../../services/clinic_data_service.dart';

import '../../../services/location_service.dart';

import '../../../utils/localization_utils.dart';

import '../../../presentation/widgets/doctor_avatar.dart';
import '../../../presentation/widgets/doctor_schedule_editor.dart';
import '../../../presentation/widgets/tabib_image.dart';
import '../../../services/image_storage_service.dart';
import '../../../utils/doctor_photo_utils.dart';
import '../../../widgets/auth/auth_text_field.dart';



class DoctorProfileEditScreen extends StatefulWidget {

  const DoctorProfileEditScreen({super.key});



  @override

  State<DoctorProfileEditScreen> createState() =>

      _DoctorProfileEditScreenState();

}



class _DoctorProfileEditScreenState extends State<DoctorProfileEditScreen> {

  final _formKey = GlobalKey<FormState>();

  final _locationService = LocationService();



  final _nameKuController = TextEditingController();

  final _nameArController = TextEditingController();

  final _nameEnController = TextEditingController();

  final _photoUrlController = TextEditingController();

  final _bioKuController = TextEditingController();

  final _bioArController = TextEditingController();

  final _bioEnController = TextEditingController();

  final _degreeKuController = TextEditingController();

  final _degreeArController = TextEditingController();

  final _degreeEnController = TextEditingController();

  final _experienceController = TextEditingController();

  final _clinicNameKuController = TextEditingController();

  final _clinicNameArController = TextEditingController();

  final _clinicNameEnController = TextEditingController();

  final _addrKuController = TextEditingController();

  final _addrArController = TextEditingController();

  final _addrEnController = TextEditingController();

  final _latController = TextEditingController();

  final _lngController = TextEditingController();

  final _hoursKuController = TextEditingController();

  final _hoursArController = TextEditingController();

  final _hoursEnController = TextEditingController();

  final _phoneController = TextEditingController();

  final _whatsappController = TextEditingController();

  final _emailController = TextEditingController();

  final _languagesController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final _clinicPhotosController = TextEditingController();

  String? _photoThumbnailUrl;
  List<String> _clinicPhotos = [];
  List<String> _clinicPhotoThumbnails = [];
  String? _specialtyId;
  DoctorWorkingSchedule _schedule = DoctorWorkingSchedule.empty();
  bool _isAvailableToday = true;
  bool _loading = false;
  bool _locating = false;
  bool _pickingPhoto = false;
  bool _pickingClinicPhoto = false;
  bool _loadFailed = false;
  Doctor? _doctor;
  DoctorProfileVisibility _visibility = const DoctorProfileVisibility();

  @override

  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDoctor());

  }



  Future<void> _loadDoctor() async {

    if (_doctor != null || _loadFailed) return;

    final auth = context.read<AuthService>();

    final doctorId = auth.currentUser?.doctorId;

    if (doctorId == null) {

      if (mounted) setState(() => _loadFailed = true);

      return;

    }



    final data = context.read<ClinicDataService>();

    var loaded = data.doctorById(doctorId);

    loaded ??= await data.backend.getDoctor(doctorId);



    if (!mounted) return;

    if (loaded != null) {

      _populateFromDoctor(loaded);

    } else {

      setState(() => _loadFailed = true);

    }

  }



  void _populateFromDoctor(Doctor doctor) {

    setState(() {

      _doctor = doctor;

      _specialtyId = doctor.specialtyId;

      _nameKuController.text = doctor.name.ku;

      _nameArController.text = doctor.name.ar;

      _nameEnController.text = doctor.name.en;

      _photoUrlController.text = doctor.photoUrl ?? '';
      _photoThumbnailUrl = doctor.photoThumbnailUrl;

      _bioKuController.text = doctor.bio.ku;

      _bioArController.text = doctor.bio.ar;

      _bioEnController.text = doctor.bio.en;

      _degreeKuController.text = doctor.academicDegree?.ku ?? '';

      _degreeArController.text = doctor.academicDegree?.ar ?? '';

      _degreeEnController.text = doctor.academicDegree?.en ?? '';

      _experienceController.text = doctor.experienceYears.toString();

      _clinicNameKuController.text = doctor.effectiveClinicName.ku;

      _clinicNameArController.text = doctor.effectiveClinicName.ar;

      _clinicNameEnController.text = doctor.effectiveClinicName.en;

      _addrKuController.text = doctor.effectiveAddress.ku;

      _addrArController.text = doctor.effectiveAddress.ar;

      _addrEnController.text = doctor.effectiveAddress.en;

      _latController.text = doctor.latitude?.toString() ?? '';

      _lngController.text = doctor.longitude?.toString() ?? '';

      _hoursKuController.text = doctor.workingHours?.ku ?? '';

      _hoursArController.text = doctor.workingHours?.ar ?? '';

      _hoursEnController.text = doctor.workingHours?.en ?? '';

      _phoneController.text = doctor.contactPhone ?? '';

      _whatsappController.text = doctor.whatsappNumber ?? '';

      _emailController.text = doctor.contactEmail ?? '';

      _languagesController.text =

          doctor.languagesSpoken?.join(', ') ?? '';

      _consultationFeeController.text = doctor.consultationFee != null
          ? doctor.consultationFee!.toStringAsFixed(0)
          : '';

      _clinicPhotos = List<String>.from(doctor.clinicPhotos ?? []);
      _clinicPhotoThumbnails =
          List<String>.from(doctor.clinicPhotoThumbnails ?? []);
      _syncClinicPhotoThumbnails();

      _visibility = doctor.profileVisibility;

      _schedule = doctor.effectiveWorkingSchedule;

      _isAvailableToday = doctor.isAvailableToday;

    });

  }



  @override

  void dispose() {

    _nameKuController.dispose();

    _nameArController.dispose();

    _nameEnController.dispose();

    _photoUrlController.dispose();

    _bioKuController.dispose();

    _bioArController.dispose();

    _bioEnController.dispose();

    _degreeKuController.dispose();

    _degreeArController.dispose();

    _degreeEnController.dispose();

    _experienceController.dispose();

    _clinicNameKuController.dispose();

    _clinicNameArController.dispose();

    _clinicNameEnController.dispose();

    _addrKuController.dispose();

    _addrArController.dispose();

    _addrEnController.dispose();

    _latController.dispose();

    _lngController.dispose();

    _hoursKuController.dispose();

    _hoursArController.dispose();

    _hoursEnController.dispose();

    _phoneController.dispose();

    _whatsappController.dispose();

    _emailController.dispose();

    _languagesController.dispose();
    _consultationFeeController.dispose();
    _clinicPhotosController.dispose();

    super.dispose();

  }



  Future<void> _pickPhoto() async {
    setState(() => _pickingPhoto = true);
    final imageStorage = context.read<ImageStorageService>();
    final doctorId = _doctor?.id ?? context.read<AuthService>().currentUser?.doctorId;
    final result = await pickDoctorPhotoDataUrl(
      context,
      imageStorage: imageStorage,
      doctorId: doctorId,
    );
    if (!mounted) return;
    setState(() => _pickingPhoto = false);
    if (result.isSuccess) {
      _photoUrlController.text = result.dataUrl!;
      _photoThumbnailUrl = result.thumbnailDataUrl;
      setState(() {});
    } else if (result.errorCode == 'too_large') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).photoTooLarge)),
      );
    } else if (result.errorCode != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).photoProcessingFailed),
        ),
      );
    }
  }

  void _removePhoto() {
    _photoUrlController.clear();
    _photoThumbnailUrl = null;
    setState(() {});
  }

  Future<void> _pickClinicPhoto() async {
    setState(() => _pickingClinicPhoto = true);
    final imageStorage = context.read<ImageStorageService>();
    final clinicId = _doctor?.clinicId;
    final result = await pickClinicPhotoDataUrl(
      imageStorage: imageStorage,
      clinicId: clinicId,
    );
    if (!mounted) return;
    setState(() => _pickingClinicPhoto = false);
    if (result.isSuccess) {
      setState(() {
        _clinicPhotos.add(result.dataUrl!);
        _clinicPhotoThumbnails.add(result.thumbnailDataUrl!);
      });
    } else if (result.errorCode == 'too_large') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).photoTooLarge)),
      );
    } else if (result.errorCode != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).photoProcessingFailed),
        ),
      );
    }
  }

  void _removeClinicPhoto(int index) {
    setState(() {
      _clinicPhotos.removeAt(index);
      if (index < _clinicPhotoThumbnails.length) {
        _clinicPhotoThumbnails.removeAt(index);
      }
      _syncClinicPhotoThumbnails();
    });
  }

  void _addClinicPhotoUrl() {
    final url = _clinicPhotosController.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _clinicPhotos.add(url);
      _clinicPhotoThumbnails.add(url);
      _clinicPhotosController.clear();
    });
  }

  void _syncClinicPhotoThumbnails() {
    while (_clinicPhotoThumbnails.length < _clinicPhotos.length) {
      _clinicPhotoThumbnails.add(_clinicPhotos[_clinicPhotoThumbnails.length]);
    }
    if (_clinicPhotoThumbnails.length > _clinicPhotos.length) {
      _clinicPhotoThumbnails.removeRange(
        _clinicPhotos.length,
        _clinicPhotoThumbnails.length,
      );
    }
  }

  Future<void> _useCurrentLocation() async {

    setState(() => _locating = true);

    final pos = await _locationService.getCurrentPosition();

    if (!mounted) return;

    setState(() => _locating = false);

    if (pos != null) {

      _latController.text = pos.latitude.toStringAsFixed(6);

      _lngController.text = pos.longitude.toStringAsFixed(6);

    }

  }



  List<String> _parseLanguages(String raw) {
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  bool _hasLocalizedText(String ku, String ar, String en) =>
      ku.trim().isNotEmpty || ar.trim().isNotEmpty || en.trim().isNotEmpty;

  String? _localizedFieldValidator(String ku, String ar, String en) {
    if (!_hasLocalizedText(ku, ar, en)) {
      return AppLocalizations.of(context).fieldRequired;
    }
    return null;
  }

  Widget _showToPatientsSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required AppLocalizations l10n,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        l10n.showToPatients,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      value: value,
      activeColor: AppTheme.doctorColor,
      onChanged: onChanged,
    );
  }

  LocalizedText? _localizedOrNull(

    String ku,

    String ar,

    String en,

  ) {

    if (ku.isEmpty && ar.isEmpty && en.isEmpty) return null;

    return LocalizedText(ku: ku, ar: ar, en: en);

  }

  String _scheduleErrorMessage(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'schedulePeriodInvalid':
        return l10n.schedulePeriodInvalid;
      case 'schedulePeriodOverlap':
        return l10n.schedulePeriodOverlap;
      case 'scheduleOpenDayNeedsPeriod':
        return l10n.scheduleOpenDayNeedsPeriod;
      default:
        return l10n.fieldRequired;
    }
  }



  Future<void> _save() async {

    if (!_formKey.currentState!.validate()) return;

    final doctor = _doctor;

    if (doctor == null || _specialtyId == null) return;



    setState(() => _loading = true);



    final data = context.read<ClinicDataService>();

    Specialty specialty = doctor.specialty;

    for (final s in data.specialties) {

      if (s.id == _specialtyId) {

        specialty = s;

        break;

      }

    }



    final experience = int.tryParse(_experienceController.text.trim());
    final languages = _parseLanguages(_languagesController.text);
    final clinicPhotos = _clinicPhotos;
    final clinicPhotoThumbnails = _clinicPhotoThumbnails;
    final consultationFee =
        double.tryParse(_consultationFeeController.text.trim());
    final sortedDays = _schedule.openWeekdays;
    final scheduleErrorKey = _schedule.validationErrorKey();
    if (scheduleErrorKey != null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_scheduleErrorMessage(context, scheduleErrorKey))),
      );
      return;
    }

    final clinicNameKu = _clinicNameKuController.text.trim();
    final clinicNameAr = _clinicNameArController.text.trim();
    final clinicNameEn = _clinicNameEnController.text.trim();
    final addrKu = _addrKuController.text.trim();
    final addrAr = _addrArController.text.trim();
    final addrEn = _addrEnController.text.trim();

    if (!_hasLocalizedText(clinicNameKu, clinicNameAr, clinicNameEn) ||
        !_hasLocalizedText(addrKu, addrAr, addrEn)) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).fieldRequired)),
      );
      return;
    }

    final photo = _photoUrlController.text.trim();

    final updated = doctor.copyWith(

      name: LocalizedText(

        ku: _nameKuController.text.trim(),

        ar: _nameArController.text.trim(),

        en: _nameEnController.text.trim(),

      ),

      specialtyId: _specialtyId!,

      specialty: specialty,

      photoUrl: photo.isEmpty ? null : photo,

      photoThumbnailUrl: photo.isEmpty ? null : _photoThumbnailUrl,

      clearPhotos: photo.isEmpty,

      bio: LocalizedText(

        ku: _bioKuController.text.trim(),

        ar: _bioArController.text.trim(),

        en: _bioEnController.text.trim(),

      ),

      academicDegree: _localizedOrNull(

        _degreeKuController.text.trim(),

        _degreeArController.text.trim(),

        _degreeEnController.text.trim(),

      ),

      experienceYears: experience ?? 0,

      clinicName: LocalizedText(
        ku: clinicNameKu,
        ar: clinicNameAr,
        en: clinicNameEn,
      ),

      clinicAddress: LocalizedText(
        ku: addrKu,
        ar: addrAr,
        en: addrEn,
      ),

      latitude: double.tryParse(_latController.text),

      longitude: double.tryParse(_lngController.text),

      workingDays: sortedDays.isEmpty ? null : sortedDays,

      workingSchedule: _schedule.days,

      workingHours: null,

      contactPhone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),

      whatsappNumber: _whatsappController.text.trim().isEmpty

          ? null

          : _whatsappController.text.trim(),

      contactEmail: _emailController.text.trim().isEmpty

          ? null

          : _emailController.text.trim(),

      languagesSpoken: languages.isEmpty ? null : languages,

      consultationFee: consultationFee,

      clinicPhotos: clinicPhotos.isEmpty ? null : clinicPhotos,

      clinicPhotoThumbnails:
          clinicPhotos.isEmpty ? null : clinicPhotoThumbnails,

      profileVisibility: _visibility,

      isAvailableToday: _isAvailableToday,

    );



    await data.backend.upsertDoctor(updated);



    if (!mounted) return;

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(content: Text(AppLocalizations.of(context).savedSuccessfully)),

    );

    context.pop();

  }



  @override

  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);

    final data = context.watch<ClinicDataService>();

    final auth = context.watch<AuthService>();

    final doctorId = auth.currentUser?.doctorId;



    if (_doctor == null && doctorId != null && !_loadFailed) {

      final loaded = data.doctorById(doctorId);

      if (loaded != null) {

        WidgetsBinding.instance.addPostFrameCallback((_) {

          if (mounted && _doctor == null) _populateFromDoctor(loaded);

        });

      }

    }



    if (_doctor == null) {

      return Scaffold(

        appBar: AppBar(

          title: Text(l10n.editProfile),

          backgroundColor: AppTheme.doctorColor,

        ),

        body: Center(

          child: _loadFailed || doctorId == null

              ? Column(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    Text(l10n.errorGeneric),

                    if (doctorId != null) ...[

                      const SizedBox(height: 12),

                      OutlinedButton(

                        onPressed: () {

                          setState(() => _loadFailed = false);

                          _loadDoctor();

                        },

                        child: Text(l10n.retry),

                      ),

                    ],

                  ],

                )

              : const CircularProgressIndicator(color: AppTheme.doctorColor),

        ),

      );

    }



    if (auth.currentUser?.doctorId != _doctor!.id) {

      return Scaffold(

        appBar: AppBar(title: Text(l10n.editProfile)),

        body: Center(child: Text(l10n.errorGeneric)),

      );

    }



    return Scaffold(

      backgroundColor: AppTheme.medicalWhite,

      appBar: AppBar(

        title: Text(l10n.editProfile),

        backgroundColor: AppTheme.doctorColor,

      ),

      body: ScrollableResponsiveBody(
        child: Form(

          key: _formKey,

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [

              _ProfileSectionCard(

                title: l10n.personalInfo,

                icon: Icons.person_outline,

                children: [

                  Center(
                    child: DoctorAvatar(
                      photoUrl: _photoUrlController.text.isEmpty
                          ? null
                          : _photoUrlController.text,
                      thumbnailUrl: _photoThumbnailUrl,
                      radius: 52,
                      backgroundColor: AppTheme.doctorColor.withOpacity(0.15),
                      fallback: Icon(
                        Icons.person,
                        size: 52,
                        color: AppTheme.doctorColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.photoUploadHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final uploadButton = OutlinedButton.icon(
                        onPressed: _pickingPhoto ? null : _pickPhoto,
                        icon: _pickingPhoto
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload_outlined),
                        label: Text(l10n.uploadPhoto),
                      );
                      final removeButton = TextButton(
                        onPressed: _photoUrlController.text.isEmpty
                            ? null
                            : _removePhoto,
                        child: Text(l10n.removePhoto),
                      );

                      if (constraints.maxWidth < 360) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            uploadButton,
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: removeButton,
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: uploadButton),
                          const SizedBox(width: 8),
                          removeButton,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _photoUrlController,
                    label: l10n.orPastePhotoUrl,
                    prefixIcon: Icons.link,
                    onChanged: (_) => setState(() {}),
                  ),
                  _showToPatientsSwitch(
                    l10n: l10n,
                    value: _visibility.showProfilePhoto,
                    onChanged: (v) => setState(
                      () => _visibility =
                          _visibility.copyWith(showProfilePhoto: v),
                    ),
                  ),

                  const SizedBox(height: 12),

                  AuthTextField(

                    controller: _nameKuController,

                    label: l10n.nameKu,

                    prefixIcon: Icons.badge_outlined,

                    validator: (v) =>

                        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,

                  ),

                  const SizedBox(height: 8),

                  AuthTextField(

                    controller: _nameArController,

                    label: l10n.nameAr,

                    prefixIcon: Icons.badge_outlined,

                  ),

                  const SizedBox(height: 8),

                  AuthTextField(

                    controller: _nameEnController,

                    label: l10n.nameEn,

                    prefixIcon: Icons.badge_outlined,

                  ),

                  const SizedBox(height: 12),

                  AuthTextField(

                    controller: _bioKuController,

                    label: l10n.bioKu,

                    prefixIcon: Icons.info_outline,

                    maxLines: 3,

                  ),

                  const SizedBox(height: 8),

                  AuthTextField(

                    controller: _bioArController,

                    label: l10n.bioAr,

                    prefixIcon: Icons.info_outline,

                    maxLines: 3,

                  ),

                  const SizedBox(height: 8),

                  AuthTextField(
                    controller: _bioEnController,
                    label: l10n.bioEn,
                    prefixIcon: Icons.info_outline,
                    maxLines: 3,
                  ),
                  _showToPatientsSwitch(
                    l10n: l10n,
                    value: _visibility.showBio,
                    onChanged: (v) => setState(
                      () => _visibility = _visibility.copyWith(showBio: v),
                    ),
                  ),

                ],

              ),

              const SizedBox(height: 16),

              _ProfileSectionCard(

                title: l10n.professionalInfo,

                icon: Icons.medical_services_outlined,

                children: [

                  DropdownButtonFormField<String>(

                    value: _specialtyId,

                    decoration: InputDecoration(

                      labelText: l10n.specialty,

                      prefixIcon: const Icon(Icons.medical_services_outlined),

                    ),

                    items: data.specialties

                        .map(

                          (s) => DropdownMenuItem(

                            value: s.id,

                            child: Text(s.name.localized(context)),

                          ),

                        )

                        .toList(),

                    onChanged: (v) => setState(() => _specialtyId = v),

                  ),

                  const SizedBox(height: 12),

                  AuthTextField(

                    controller: _degreeKuController,

                    label: l10n.academicDegreeKu,

                    prefixIcon: Icons.school_outlined,

                  ),

                  const SizedBox(height: 8),

                  AuthTextField(

                    controller: _degreeArController,

                    label: l10n.academicDegreeAr,

                    prefixIcon: Icons.school_outlined,

                  ),

                  const SizedBox(height: 8),

                  AuthTextField(
                    controller: _degreeEnController,
                    label: l10n.academicDegreeEn,
                    prefixIcon: Icons.school_outlined,
                  ),
                  _showToPatientsSwitch(
                    l10n: l10n,
                    value: _visibility.showDegrees,
                    onChanged: (v) => setState(
                      () => _visibility = _visibility.copyWith(showDegrees: v),
                    ),
                  ),

                  const SizedBox(height: 12),

                  AuthTextField(
                    controller: _experienceController,
                    label: l10n.experienceYears,
                    prefixIcon: Icons.timeline,
                    keyboardType: TextInputType.number,
                  ),
                  _showToPatientsSwitch(
                    l10n: l10n,
                    value: _visibility.showExperience,
                    onChanged: (v) => setState(
                      () =>
                          _visibility = _visibility.copyWith(showExperience: v),
                    ),
                  ),

                  const SizedBox(height: 12),

                  AuthTextField(
                    controller: _consultationFeeController,
                    label: l10n.consultationFee,
                    prefixIcon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  _showToPatientsSwitch(
                    l10n: l10n,
                    value: _visibility.showConsultationFee,
                    onChanged: (v) => setState(
                      () => _visibility =
                          _visibility.copyWith(showConsultationFee: v),
                    ),
                  ),

                  const SizedBox(height: 12),

                  AuthTextField(

                    controller: _languagesController,

                    label: l10n.languagesSpoken,

                    hint: l10n.languagesHint,

                    prefixIcon: Icons.translate,

                  ),

                  const SizedBox(height: 8),

                  SwitchListTile(

                    contentPadding: EdgeInsets.zero,

                    title: Text(l10n.availableTodayToggle),

                    subtitle: Text(

                      _isAvailableToday

                          ? l10n.availableToday

                          : l10n.unavailable,

                    ),

                    value: _isAvailableToday,

                    activeColor: AppTheme.medicalGreen,

                    onChanged: (v) => setState(() => _isAvailableToday = v),

                  ),

                ],

              ),

              const SizedBox(height: 16),

              _ProfileSectionCard(

                title: l10n.clinicInfo,

                icon: Icons.local_hospital_outlined,

                children: [

                  AuthTextField(
                    controller: _clinicNameKuController,
                    label: l10n.clinicNameKu,
                    prefixIcon: Icons.business_outlined,
                    validator: (v) => _localizedFieldValidator(
                      v ?? '',
                      _clinicNameArController.text,
                      _clinicNameEnController.text,
                    ),
                  ),

                  const SizedBox(height: 8),

                  AuthTextField(

                    controller: _clinicNameArController,

                    label: l10n.clinicNameAr,

                    prefixIcon: Icons.business_outlined,

                  ),

                  const SizedBox(height: 8),

                  AuthTextField(

                    controller: _clinicNameEnController,

                    label: l10n.clinicNameEn,

                    prefixIcon: Icons.business_outlined,

                  ),

                  const SizedBox(height: 12),

                  AuthTextField(
                    controller: _addrKuController,
                    label: l10n.addressKu,
                    prefixIcon: Icons.location_on_outlined,
                    validator: (v) => _localizedFieldValidator(
                      v ?? '',
                      _addrArController.text,
                      _addrEnController.text,
                    ),
                  ),

                  const SizedBox(height: 8),

                  AuthTextField(

                    controller: _addrArController,

                    label: l10n.addressAr,

                    prefixIcon: Icons.location_on_outlined,

                  ),

                  const SizedBox(height: 8),

                  AuthTextField(

                    controller: _addrEnController,

                    label: l10n.addressEn,

                    prefixIcon: Icons.location_on_outlined,

                  ),

                  const SizedBox(height: 12),

                  Text(

                    l10n.clinicLocationGps,

                    style: const TextStyle(fontWeight: FontWeight.w600),

                  ),

                  const SizedBox(height: 8),

                  Row(

                    children: [

                      Expanded(

                        child: AuthTextField(

                          controller: _latController,

                          label: l10n.latitude,

                          keyboardType: const TextInputType.numberWithOptions(

                            decimal: true,

                            signed: true,

                          ),

                        ),

                      ),

                      const SizedBox(width: 12),

                      Expanded(

                        child: AuthTextField(

                          controller: _lngController,

                          label: l10n.longitude,

                          keyboardType: const TextInputType.numberWithOptions(

                            decimal: true,

                            signed: true,

                          ),

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: 8),

                  OutlinedButton.icon(

                    onPressed: _locating ? null : _useCurrentLocation,

                    icon: _locating

                        ? const SizedBox(

                            width: 18,

                            height: 18,

                            child: CircularProgressIndicator(strokeWidth: 2),

                          )

                        : const Icon(Icons.my_location),

                    label: Text(l10n.useCurrentLocation),

                  ),
                  _showToPatientsSwitch(
                    l10n: l10n,
                    value: _visibility.showGpsLocation,
                    onChanged: (v) => setState(
                      () => _visibility =
                          _visibility.copyWith(showGpsLocation: v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickingClinicPhoto ? null : _pickClinicPhoto,
                    icon: _pickingClinicPhoto
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(l10n.addClinicPhoto),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.clinicPhotoUploadHint,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  if (_clinicPhotos.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 112,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _clinicPhotos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final thumb = index < _clinicPhotoThumbnails.length
                              ? _clinicPhotoThumbnails[index]
                              : _clinicPhotos[index];
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              TabibImage(
                                imageUrl: _clinicPhotos[index],
                                thumbnailUrl: thumb,
                                width: 148,
                                height: 112,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              PositionedDirectional(
                                top: -8,
                                end: -8,
                                child: IconButton.filledTonal(
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.shade50,
                                    foregroundColor: Colors.red.shade700,
                                    minimumSize: const Size(32, 32),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () => _removeClinicPhoto(index),
                                  icon: const Icon(Icons.close, size: 16),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _clinicPhotosController,
                    label: l10n.orPastePhotoUrl,
                    hint: l10n.clinicPhotosHint,
                    prefixIcon: Icons.link,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: _addClinicPhotoUrl,
                      icon: const Icon(Icons.add_link),
                      label: Text(l10n.addClinicPhotoUrl),
                    ),
                  ),
                  _showToPatientsSwitch(
                    l10n: l10n,
                    value: _visibility.showClinicPhotos,
                    onChanged: (v) => setState(
                      () => _visibility =
                          _visibility.copyWith(showClinicPhotos: v),
                    ),
                  ),

                ],

              ),

              const SizedBox(height: 16),

              _ProfileSectionCard(

                title: l10n.editWorkingSchedule,

                icon: Icons.schedule,

                children: [

                  Text(

                    l10n.scheduleInfo,

                    style: TextStyle(color: Colors.grey.shade600),

                  ),

                  const SizedBox(height: 12),

                  DoctorScheduleEditor(

                    schedule: _schedule,

                    onChanged: (updated) => setState(() => _schedule = updated),

                  ),

                ],

              ),

              const SizedBox(height: 16),

              _ProfileSectionCard(

                title: l10n.contactInfo,

                icon: Icons.contact_phone_outlined,

                children: [

                  AuthTextField(

                    controller: _phoneController,

                    label: l10n.phone,

                    prefixIcon: Icons.phone_outlined,

                    keyboardType: TextInputType.phone,

                  ),

                  const SizedBox(height: 8),

                  AuthTextField(
                    controller: _whatsappController,
                    label: l10n.whatsappNumber,
                    prefixIcon: Icons.chat_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  _showToPatientsSwitch(
                    l10n: l10n,
                    value: _visibility.showPhoneNumber,
                    onChanged: (v) => setState(
                      () => _visibility =
                          _visibility.copyWith(showPhoneNumber: v),
                    ),
                  ),
                  _showToPatientsSwitch(
                    l10n: l10n,
                    value: _visibility.showWhatsapp,
                    onChanged: (v) => setState(
                      () => _visibility = _visibility.copyWith(showWhatsapp: v),
                    ),
                  ),

                  const SizedBox(height: 8),

                  AuthTextField(

                    controller: _emailController,

                    label: l10n.email,

                    prefixIcon: Icons.email_outlined,

                    keyboardType: TextInputType.emailAddress,

                  ),

                ],

              ),

              const SizedBox(height: 24),

              FilledButton(

                onPressed: _loading ? null : _save,

                style: FilledButton.styleFrom(

                  backgroundColor: AppTheme.doctorColor,

                  minimumSize: const Size.fromHeight(52),

                ),

                child: _loading

                    ? const SizedBox(

                        height: 22,

                        width: 22,

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

      ),

    );

  }

}



class _ProfileSectionCard extends StatelessWidget {

  const _ProfileSectionCard({

    required this.title,

    required this.icon,

    required this.children,

  });



  final String title;

  final IconData icon;

  final List<Widget> children;



  @override

  Widget build(BuildContext context) {

    return Card(

      elevation: 0,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(16),

        side: BorderSide(color: Colors.grey.shade200),

      ),

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            Row(

              children: [

                Container(

                  padding: const EdgeInsets.all(8),

                  decoration: BoxDecoration(

                    color: AppTheme.doctorColor.withOpacity(0.12),

                    borderRadius: BorderRadius.circular(10),

                  ),

                  child: Icon(icon, color: AppTheme.doctorColor, size: 20),

                ),

                const SizedBox(width: 10),

                Expanded(

                  child: Text(

                    title,

                    style: const TextStyle(

                      fontSize: 16,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                ),

              ],

            ),

            const SizedBox(height: 16),

            ...children,

          ],

        ),

      ),

    );

  }

}

