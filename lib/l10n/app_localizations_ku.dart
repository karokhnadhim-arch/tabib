import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get appTitle => 'Tabib';

  @override
  String get appSubtitle => 'دکتۆر بدۆزەوە، نۆرە بگرە، چاودێری تەندروستیت بکە';

  @override
  String get patientApp => 'ئەپی نەخۆش';

  @override
  String get patientAppSubtitle => 'سرە بگرە و زانیاری سەرەکەت بزانە';

  @override
  String get staffApp => 'ئەپی دکتۆر و سکرتێر';

  @override
  String get staffAppSubtitle => 'بەڕێوەبردنی سەرە و نەخۆشەکان';

  @override
  String get adminApp => 'پانێڵی بەڕێوەبەر';

  @override
  String get adminAppSubtitle => 'بەڕێوەبردنی نۆرینگە، دکتۆر و کارمەند';

  @override
  String get patientLogin => 'چوونەژوورەوەی نەخۆش';

  @override
  String get staffLogin => 'چوونەژوورەوەی کارمەند';

  @override
  String get adminLogin => 'چوونەژوورەوەی بەڕێوەبەر';

  @override
  String get loginPromptPatient => 'ناو و ژمارەی مۆبایل بنووسە بۆ دەستپێکردن';

  @override
  String get loginPromptStaff => 'بە هەژماری کارمەند بچۆرە ژوورەوە';

  @override
  String get loginPromptAdmin => 'بە زانیاری بەڕێوەبەر بچۆرە ژوورەوە';

  @override
  String get patientName => 'ناوی نەخۆش';

  @override
  String get phoneNumber => 'ژمارەی مۆبایل';

  @override
  String get email => 'ئیمەیڵ';

  @override
  String get emailOptional => 'ئیمەیڵ (ئارەزوومەندانە)';

  @override
  String get phoneOptional => 'ژمارەی مۆبایل (ئارەزوومەندانە)';

  @override
  String get accountLoginMethod => 'شێوازی چوونەژوورەوە';

  @override
  String get emailOrPhone => 'ئیمەیڵ یان ژمارەی مۆبایل';

  @override
  String get emailOrPhoneHint => 'ئیمەیڵ یان ژمارەی مۆبایلەکەت بنووسە';

  @override
  String get phoneInUse => 'ئەم ژمارەی مۆبایلە پێشتر تۆمار کراوە';

  @override
  String get password => 'وشەی نهێنی';

  @override
  String get login => 'چوونەژوورەوە';

  @override
  String get logout => 'چوونەدەرەوە';

  @override
  String get invalidPhone => 'ژمارەی مۆبایل نادروستە';

  @override
  String get invalidCredentials => 'ئیمەیڵ یان وشەی نهێنی هەڵەیە';

  @override
  String get fieldRequired => 'ئەم خانەیە پێویستە';

  @override
  String get invalidEmail => 'ئیمەیڵێکی دروست بنووسە';

  @override
  String get invalidName => 'ناوی تەواوت بنووسە';

  @override
  String welcomeUser(String name) {
    return 'بەخێربێیت، $name';
  }

  @override
  String get noActiveQueue => 'هیچ سەرەی چالاک نییە';

  @override
  String get bookQueueHint => 'دکتۆر هەڵبژێرە و سرە بگرە';

  @override
  String get medicalSpecialties => 'بوارەکانی پزیشکی';

  @override
  String get searchDoctors => 'گەڕان بۆ دکتۆر';

  @override
  String get searchHint => 'ناوی دکتۆر، بوار، نۆرینگە...';

  @override
  String get myQueue => 'سەرەی من';

  @override
  String get queueNumber => 'ژمارەی سەرە';

  @override
  String get peopleAhead => 'لە پێشت';

  @override
  String get waitTime => 'کاتی چاوەڕوانی';

  @override
  String minutesShort(int minutes) {
    return '~$minutes خولەک';
  }

  @override
  String get doctor => 'دکتۆر';

  @override
  String get specialty => 'بوار';

  @override
  String get clinic => 'نۆرینگە';

  @override
  String get location => 'شوێن';

  @override
  String get address => 'ناونیشان';

  @override
  String get phone => 'تەلەفۆن';

  @override
  String get inQueue => 'لە سەرەدا';

  @override
  String get available => 'بەردەست';

  @override
  String get unavailable => 'نەبەردەست';

  @override
  String yearsExperience(int years) {
    return '$years ساڵ ئەزموون';
  }

  @override
  String get info => 'زانیاری';

  @override
  String get clinicLocationGps => 'شوێنی نۆرینگە (GPS)';

  @override
  String get bookQueue => 'سرە بگرە';

  @override
  String get alreadyHasQueue => 'پێشتر سەرەی چالاک هەیە';

  @override
  String bookSuccess(int number) {
    return 'سرە گرتن سەرکەوتوو! ژمارە: $number';
  }

  @override
  String get bookFailed => 'سرە گرتن سەرکەوتوو نەبوو';

  @override
  String get details => 'وردەکاری';

  @override
  String get currentQueue => 'سەرەی ئێستا';

  @override
  String get yourTurn => 'کاتەکەت';

  @override
  String get waiting => 'چاوەڕوانی';

  @override
  String get completed => 'تەواو';

  @override
  String get cancelQueue => 'هەڵوەشاندنەوە';

  @override
  String get queueCancelled => 'سەرە هەڵوەشێنرایەوە';

  @override
  String get openGoogleMaps => 'کردنەوە لە Google Maps';

  @override
  String get gpsDirections => 'ڕێگای GPS';

  @override
  String distanceKm(String km) {
    return 'دووری: $km km';
  }

  @override
  String get noDoctorsFound => 'هیچ دکتۆرێک نەدۆزرایەوە';

  @override
  String get doctorApp => 'ئەپی دکتۆر';

  @override
  String get secretaryApp => 'ئەپی سکرتێر';

  @override
  String get roleDoctor => 'دکتۆر';

  @override
  String get roleSecretary => 'سکرتێر';

  @override
  String get roleAdmin => 'بەڕێوەبەر';

  @override
  String get queueManagement => 'بەڕێوەبردنی سەرە';

  @override
  String get todaysQueue => 'سەرەی ئەمڕۆ';

  @override
  String get clinicalNotes => 'تێبینییە پزیشکییەکان';

  @override
  String get notesAutoSaved => 'خۆکار پاشەکەوت کرا';

  @override
  String get selectPatientFromQueue => 'نەخۆشێک لە سەرەی ئەمڕۆ هەڵبژێرە بۆ بینینی وردەکاری و نووسینی تێبینی.';

  @override
  String get doctorQueueViewOnlyHint => 'ڕیزبەندی سەرە و دۆخ لەلایەن سکرتێرەوە بەڕێوە دەچێت. تەنها دەتوانیت نەخۆش ببینیت و تێبینی پزیشکی بنووسیت.';

  @override
  String get visitCompletedReadOnly => 'سەردانەکە تەواو بوو. تێبینییەکان تەنها بۆ خوێندنەوە.';

  @override
  String get patientInformation => 'زانیاری نەخۆش';

  @override
  String get medicalHistory => 'مێژووی پزیشکی';

  @override
  String get noMedicalHistoryYet => 'هیچ تۆمارێکی پێشوو بۆ ئەم نەخۆشە نییە';

  @override
  String medicalHistoryEntryCount(int count) {
    return '$count ڕەچەتەی پێشوو';
  }

  @override
  String get recentVisits => 'سەردانە نوێیەکان';

  @override
  String get currentPatient => 'نەخۆشی ئێستا';

  @override
  String get completeVisit => 'تەواوکردن';

  @override
  String get callNext => 'بانگکردنی دواتر';

  @override
  String get queueList => 'لیستی سەرە';

  @override
  String get noPatientsInQueue => 'هیچ نەخۆش لە سەرەدا نییە';

  @override
  String get active => 'چالاک';

  @override
  String get nowServing => 'ئێستا';

  @override
  String get manageQueue => 'بەڕێوەبردنی سەرە';

  @override
  String get language => 'زمان';

  @override
  String get langKurdish => 'کوردی (سۆرانی)';

  @override
  String get langArabic => 'عەرەبی';

  @override
  String get langEnglish => 'ئینگلیزی';

  @override
  String get firebaseNotConfigured => 'Firebase ڕێکنەخراوە';

  @override
  String get firebaseSetupHint => 'flutterfire configure جێبەجێ بکە. README بخوێنەوە.';

  @override
  String get adminDashboard => 'داشبۆردی بەڕێوەبەرایەتی';

  @override
  String get manageClinics => 'بەڕێوەبردنی نۆرینگەکان';

  @override
  String get manageDoctors => 'بەڕێوەبردنی دکتۆرەکان';

  @override
  String get manageSpecialties => 'بەڕێوەبردنی بوارەکان';

  @override
  String get manageStaff => 'بەڕێوەبردنی کارمەند';

  @override
  String get manageQueues => 'بەڕێوەبردنی سەرەکان';

  @override
  String get addClinic => 'نۆرینگە زیاد بکە';

  @override
  String get addDoctor => 'دکتۆر زیاد بکە';

  @override
  String get addSpecialty => 'زیادکردنی تایبەتمەندی';

  @override
  String get addStaff => 'کارمەند زیاد بکە';

  @override
  String get nameKu => 'ناو (کوردی)';

  @override
  String get nameAr => 'ناو (عەرەبی)';

  @override
  String get nameEn => 'ناو (ئینگلیزی)';

  @override
  String get save => 'پاشەکەوت';

  @override
  String get delete => 'سڕینەوە';

  @override
  String get edit => 'دەستکاری';

  @override
  String get actions => 'کردارەکان';

  @override
  String get loading => 'بارکردن...';

  @override
  String get errorGeneric => 'هەڵەیەک ڕوویدا';

  @override
  String patientCount(int count) {
    return '$count نەخۆش';
  }

  @override
  String waitingCount(int count) {
    return '$count چاوەڕوان';
  }

  @override
  String get selectDoctor => 'دکتۆر هەڵبژێرە';

  @override
  String get selectClinic => 'نۆرینگە هەڵبژێرە';

  @override
  String get selectSpecialty => 'بوار هەڵبژێرە';

  @override
  String get selectRole => 'ڕۆڵ هەڵبژێرە';

  @override
  String get rating => 'هەڵسەنگاندن';

  @override
  String get experienceYears => 'ساڵانی ئەزموون';

  @override
  String get availableToday => 'بەردەستە ئەمڕۆ';

  @override
  String get bioKu => 'زانیاری (کوردی)';

  @override
  String get bioAr => 'زانیاری (عەرەبی)';

  @override
  String get bioEn => 'زانیاری (ئینگلیزی)';

  @override
  String get addressKu => 'ناونیشان (کوردی)';

  @override
  String get addressAr => 'ناونیشان (عەرەبی)';

  @override
  String get addressEn => 'ناونیشان (ئینگلیزی)';

  @override
  String get latitude => 'پانی';

  @override
  String get longitude => 'درێژی';

  @override
  String get savedSuccessfully => 'بە سەرکەوتوویی پاشەکەوت کرا';

  @override
  String get deletedSuccessfully => 'بە سەرکەوتوویی سڕایەوە';

  @override
  String get patientDashboard => 'داشبۆردی نەخۆش';

  @override
  String get availableAppointments => 'نۆرە بەردەستەکان';

  @override
  String get noAppointmentsAvailable => 'ئێستا هیچ نۆرەیەک بەردەست نییە';

  @override
  String get appointmentDate => 'ڕێکەوتی نۆرینگە';

  @override
  String get statusAvailable => 'بەردەست';

  @override
  String get statusBooked => 'گیراوە';

  @override
  String get statusCancelled => 'هەڵوەشێنراوە';

  @override
  String get retry => 'دووبارە هەوڵبدەرەوە';

  @override
  String get register => 'هەژمار دروست بکە';

  @override
  String get registerPrompt => 'هەژماری نەخۆش دروست بکە بۆ گرتنی نۆرە';

  @override
  String get confirmPassword => 'دووبارەکردنەوەی وشەی نهێنی';

  @override
  String get passwordMismatch => 'وشەی نهێنی هاوتا نییە';

  @override
  String get emailInUse => 'ئەم ئیمەیڵە پێشتر تۆمار کراوە';

  @override
  String get weakPassword => 'وشەی نهێنی لانیکەم ٦ پیت بێت';

  @override
  String get home => 'سەرەکی';

  @override
  String get myAppointments => 'نۆرەکانی من';

  @override
  String get allSpecialties => 'هەموو';

  @override
  String get noAppointmentsYet => 'هێشتا نۆرە نییە';

  @override
  String get statusPending => 'چاوەڕوان';

  @override
  String get statusAccepted => 'پەسەندکراو';

  @override
  String get statusRejected => 'ڕەتکراوە';

  @override
  String get bookAppointment => 'نۆرە بگرە';

  @override
  String get bookAppointmentSuccess => 'داواکاری نۆرە بە سەرکەوتوویی ناردرا';

  @override
  String get bookAppointmentFailed => 'نۆرە گرتن سەرکەوتوو نەبوو';

  @override
  String get selectDate => 'بەروار هەڵبژێرە';

  @override
  String get selectTime => 'کات هەڵبژێرە';

  @override
  String get notesOptional => 'تێبینی (ئارەزوومەند)';

  @override
  String get notesHint => 'نیشانەکان یان هۆکاری سەردان بنووسە';

  @override
  String get confirmBooking => 'پشتڕاستکردنەوەی نۆرە';

  @override
  String get notifications => 'ئاگاداریەکان';

  @override
  String get noNotifications => 'هیچ ئاگاداریەک نییە';

  @override
  String get doctorDashboard => 'داشبۆردی دکتۆر';

  @override
  String get pendingRequests => 'چاوەڕوان';

  @override
  String get acceptedAppointments => 'پەسەندکراو';

  @override
  String get patientRecords => 'تۆمارەکانی نەخۆش';

  @override
  String get accept => 'پەسەندکردن';

  @override
  String get reject => 'ڕەتکردنەوە';

  @override
  String get writePrescription => 'نووسینی ڕەچەتە';

  @override
  String get diagnosis => 'دەستنیشانکردن';

  @override
  String get medications => 'دەرمانەکان';

  @override
  String get prescriptionSaved => 'ڕەچەتە پاشەکەوت کرا';

  @override
  String get noPatientRecords => 'هیچ تۆماری نەخۆش نییە';

  @override
  String get secretaryDashboard => 'داشبۆردی سکرتێر';

  @override
  String get manageAppointments => 'نۆرەکان';

  @override
  String get registerPatient => 'تۆمارکردنی نەخۆش';

  @override
  String get dailySchedule => 'پلانی ڕۆژانە';

  @override
  String get registerPatientPrompt => 'نەخۆشی نوێ لە نۆرینگە تۆمار بکە';

  @override
  String get patientRegistered => 'نەخۆش بە سەرکەوتوویی تۆمار کرا';

  @override
  String get noAppointmentsToday => 'ئەم ڕۆژە نۆرە نییە';

  @override
  String get queueTracking => 'شوێنکەوتنی سەرە';

  @override
  String get currentQueueNumber => 'ژمارەی سەرەی ئێستا';

  @override
  String get chatWithSecretary => 'چات لەگەڵ سکرتێر';

  @override
  String get chatWithClinic => 'پەیوەندی بە نۆرینگە';

  @override
  String get chatWithPatient => 'چات لەگەڵ نەخۆش';

  @override
  String get typeMessage => 'پەیام بنووسە...';

  @override
  String get markEntered => 'هاتووە';

  @override
  String get markAbsent => 'نەهاتووە';

  @override
  String get moveAppointmentUp => 'بۆ سەرەوە';

  @override
  String get moveAppointmentDown => 'بۆ خوارەوە';

  @override
  String get addFollowUp => 'موراجەعە';

  @override
  String get sendToExamination => 'ناردن بۆ پشکنین';

  @override
  String get statusArrived => 'هاتووە';

  @override
  String get statusAbsent => 'نەهاتووە';

  @override
  String get statusInExamination => 'لە پشکنیندا';

  @override
  String get statusFollowUp => 'موراجەعە';

  @override
  String get createDoctorAccount => 'دروستکردنی هەژماری دکتۆر';

  @override
  String get createDoctorAccountHint => 'دکتۆری نوێ بە زانیاری چوونەژوورەوە زیاد بکە';

  @override
  String get createSecretaryAccount => 'دروستکردنی هەژماری سکرتێر';

  @override
  String get createSecretaryAccountHint => 'سکرتێرێک بەستراو بە دکتۆر زیاد بکە';

  @override
  String get linkedDoctor => 'دکتۆری بەستراو';

  @override
  String get linkedDoctorRequired => 'دکتۆرێک هەڵبژێرە کە ئەم سکرتێرە یارمەتی دەدات';

  @override
  String get accountCreated => 'هەژمار بە سەرکەوتوویی دروست کرا';

  @override
  String get editProfile => 'دەستکاری پڕۆفایل';

  @override
  String get manageProfile => 'بەڕێوەبردنی پڕۆفایل';

  @override
  String get manageProfileHint => 'وێنە، بایۆ، زانیاری نۆرینگە و خشتەی کار نوێ بکەرەوە';

  @override
  String get profilePhotoUrl => 'ناونیشانی وێنەی پڕۆفایل';

  @override
  String get uploadPhoto => 'بارکردنی وێنە';

  @override
  String get removePhoto => 'لابردنی وێنە';

  @override
  String get photoUploadHint => 'وێنەیەک هەڵبژێرە، لە بازنەیەکدا ببڕە، پاشان پاشەکەوت بکە. وێنە گەورەکان پشتگیری دەکرێن. دەتوانیت بەستەر لە خوارەوە بنووسیت.';

  @override
  String get orPastePhotoUrl => 'یان بەستەری وێنە بنووسە';

  @override
  String get photoTooLarge => 'نەتوانرا وێنەکە بەشێوەیەکی گونجاو پەست بکرێت. وێنەیەکی بچووکتر هەوڵ بدە';

  @override
  String get photoProcessingFailed => 'نەتوانرا وێنەی هەڵبژێردراو پرۆسێس بکرێت';

  @override
  String get cropProfilePhoto => 'بڕینی وێنەی پڕۆفایل';

  @override
  String get cropProfilePhotoHint => 'بۆ نزیککردنەوە پێچ بکە و بکێشە بۆ دانانی وێنەکەت لە ناو بازنەکە';

  @override
  String get photoPreview => 'پێشبینین';

  @override
  String get photoPreviewHint => 'نەخۆشەکان وێنەی پڕۆفایلت بەم شێوەیە دەبینن';

  @override
  String get usePhoto => 'بەکارهێنانی وێنە';

  @override
  String get zoomIn => 'نزیککردنەوە';

  @override
  String get zoomOut => 'دوورخستنەوە';

  @override
  String get addClinicPhoto => 'بارکردنی وێنەی نۆرینگە';

  @override
  String get addClinicPhotoUrl => 'زیادکردنی بەستەر';

  @override
  String get clinicPhotoUploadHint => 'وێنەکانی نۆرینگە تا 1920×1080 باش دەکرێن. وێنۆچکە لە لیستەکاندا بەکاردەهێنرێت بۆ خێرایی.';

  @override
  String get workingHours => 'کاتژمێری کار';

  @override
  String get workingHoursKu => 'کاتژمێری کار (کوردی)';

  @override
  String get workingHoursAr => 'کاتژمێری کار (عەرەبی)';

  @override
  String get workingHoursEn => 'کاتژمێری کار (ئینگلیزی)';

  @override
  String get contactInfo => 'زانیاری پەیوەندی';

  @override
  String get useCurrentLocation => 'شوێنی ئێستا بەکاربهێنە';

  @override
  String get personalInfo => 'زانیاری کەسی';

  @override
  String get professionalInfo => 'وردەکاری پیشەیی';

  @override
  String get clinicInfo => 'زانیاری نۆرینگە';

  @override
  String get scheduleInfo => 'خشتەی کار';

  @override
  String get aboutDoctor => 'دەربارەی دکتۆر';

  @override
  String get academicDegree => 'پلەی زانستی';

  @override
  String get academicDegreeKu => 'پلە (کوردی)';

  @override
  String get academicDegreeAr => 'پلە (عەرەبی)';

  @override
  String get academicDegreeEn => 'پلە (ئینگلیزی)';

  @override
  String get clinicNameKu => 'ناوی نۆرینگە (کوردی)';

  @override
  String get clinicNameAr => 'ناوی نۆرینگە (عەرەبی)';

  @override
  String get clinicNameEn => 'ناوی نۆرینگە (ئینگلیزی)';

  @override
  String get whatsappNumber => 'ژمارەی واتساپ';

  @override
  String get workingDays => 'ڕۆژەکانی کار';

  @override
  String get languagesSpoken => 'زمانە قسەکراوەکان';

  @override
  String get languagesHint => 'وەک: کوردی، عەرەبی، ئینگلیزی';

  @override
  String get dayMonday => 'دووشەممە';

  @override
  String get dayTuesday => 'سێشەممە';

  @override
  String get dayWednesday => 'چوارشەممە';

  @override
  String get dayThursday => 'پێنجشەممە';

  @override
  String get dayFriday => 'هەینی';

  @override
  String get daySaturday => 'شەممە';

  @override
  String get daySunday => 'یەکشەممە';

  @override
  String get openWhatsApp => 'نامە لە واتساپ';

  @override
  String get fullName => 'ناوی تەواو';

  @override
  String get viewPublicProfile => 'بینینی پڕۆفایلی گشتی';

  @override
  String get viewPublicProfileHint => 'بزانە نەخۆشەکان چۆن پڕۆفایلەکەت دەبینن';

  @override
  String get availableTodayToggle => 'ئەمڕۆ بەردەستە بۆ نۆرینگە';

  @override
  String get showToPatients => 'نیشاندان بە نەخۆش';

  @override
  String get consultationFee => 'تێچووی بینین';

  @override
  String consultationFeeAmount(String amount) {
    return '$amount د.ع';
  }

  @override
  String get clinicPhotos => 'وێنەکانی نۆرینگە';

  @override
  String get clinicPhotosHint => 'بەستەری وێنە بنووسە و «زیادکردنی بەستەر» بکە';

  @override
  String get live => 'ڕاستەوخۆ';

  @override
  String get liveQueueProgress => 'نۆرەکە بە شێوەی ڕاستەوخۆ نوێ دەبێتەوە';

  @override
  String get patientsBeforeMe => 'نەخۆش پێش من';

  @override
  String get appointmentStatusLabel => 'دۆخی نۆرینگە';

  @override
  String get queueStatusWaiting => 'چاوەڕوان';

  @override
  String get queueStatusWithDoctor => 'لەگەڵ دکتۆر';

  @override
  String get queueStatusInDoctorRoom => 'لە ژووری دکتۆر';

  @override
  String get queueStatusExamination => 'پشکنین';

  @override
  String get queueStatusReview => 'پێداچوونەوە';

  @override
  String get queueStatusSentForTests => 'نێردراوە بۆ پشکنین';

  @override
  String get queueStatusFollowUp => 'سەردانی دووبارە';

  @override
  String get queueStatusCompleted => 'تەواو';

  @override
  String get queueStatusAbsent => 'ئامادە نەبوو';

  @override
  String get queueStatusCancelled => 'هەڵوەشاوە';

  @override
  String get returnToReview => 'گەڕاندنەوە بۆ پێداچوونەوە';

  @override
  String get appointmentTime => 'کاتی چاوپێکەوتن';

  @override
  String get noAssignedDoctor => 'هیچ دکتۆرێک بەم هەژمارە نەبەستراوە';

  @override
  String get queueNumberLabel => 'ژمارەی دور';

  @override
  String get queueNotifyFourRemaining => 'نزیکە لە نۆرەکەت';

  @override
  String get queueNotifyFourRemainingBody => 'تەنها ٤ نەخۆش لە پێش تۆ ماوە.';

  @override
  String get queueNotifyTwoRemaining => 'ئامادە بە';

  @override
  String get queueNotifyTwoRemainingBody => 'تەنها ٢ نەخۆش لە پێش تۆ ماوە.';

  @override
  String get queueNotifyTenRemaining => 'نۆرەکەت نزیکە';

  @override
  String get queueNotifyTenRemainingBody => 'تەنها 10 نەخۆش ماوە پێش کاتەکەت. تکایە ئامادەبە.';

  @override
  String get queueNotifyFiveRemaining => 'بەرەو نۆرینگە بڕۆ';

  @override
  String get queueNotifyFiveRemainingBody => 'تەنها 5 نەخۆش ماوە پێش کاتەکەت. تکایە بەرەو نۆرینگە بڕۆ.';

  @override
  String get queueNotifyThreeRemaining => 'ئێستا بگە';

  @override
  String get queueNotifyThreeRemainingBody => 'کاتەکەت زۆر نزیکە. تکایە ئێستا بگەیتە نۆرینگە.';

  @override
  String get queueNotifyYourTurn => 'ئێستا نۆرەکەتە';

  @override
  String get queueNotifyYourTurnBody => 'تکایە بچۆ ژووری دکتۆر.';

  @override
  String get dayClosed => 'داخراو';

  @override
  String get markDayOpen => 'کراوە';

  @override
  String get markDayClosed => 'داخراو';

  @override
  String get addTimePeriod => 'زیادکردنی کات';

  @override
  String get removeTimePeriod => 'سڕینەوەی کات';

  @override
  String get openingTime => 'دەکرێتەوە';

  @override
  String get closingTime => 'دادەخرێت';

  @override
  String get schedulePeriodInvalid => 'کاتی داخستن دەبێت دوای کاتی کردنەوە بێت';

  @override
  String get schedulePeriodOverlap => 'کاتەکان نابێت لەسەر یەک بن';

  @override
  String get scheduleOpenDayNeedsPeriod => 'لە هەر ڕۆژێکی کراوەدا لانیکەم یەک کات زیاد بکە';

  @override
  String get appointmentOutsideSchedule => 'کاتی هەڵبژێردراو لە دەرەوەی کاتەکانی کارە';

  @override
  String get appointmentClosedDay => 'دکتۆر لەم ڕۆژەدا بەردەست نییە';

  @override
  String get noScheduleSet => 'خشتەی کار دیاری نەکراوە';

  @override
  String get editWorkingSchedule => 'دەستکاری خشتەی کار';

  @override
  String get viewWorkingSchedule => 'خشتەی کار';

  @override
  String get adminControlPanel => 'پانێڵی کۆنترۆڵی بەڕێوەبەر';

  @override
  String get adminControlPanelHint => 'بەڕێوەبردنی نۆرینگە، بەکارهێنەران و بەشداریکردنەکان';

  @override
  String get systemOwner => 'خاوەنی سیستەم';

  @override
  String get viewAllDoctors => 'هەموو دکتۆرەکان';

  @override
  String get viewAllDoctorsHint => 'گەڕان و بەڕێوەبردنی هەژمارەکانی دکتۆر';

  @override
  String get viewAllDoctorsSubscriptionHint => 'پلان، دۆخ و نوێکردنەوەی بەشداریکردن';

  @override
  String get viewAllSecretaries => 'هەموو سکرتێرەکان';

  @override
  String get viewAllSecretariesHint => 'گەڕان و بەڕێوەبردنی هەژمارەکانی سکرتێر';

  @override
  String get viewAllClinics => 'هەموو نۆرینگەکان';

  @override
  String get viewAllClinicsHint => 'گەڕان و بەڕێوەبردنی تۆمارەکانی نۆرینگە';

  @override
  String get activateDeactivateAccounts => 'چالاککردن یان ناچالاککردنی هەژمارەکان';

  @override
  String get accountActive => 'چالاک';

  @override
  String get accountInactive => 'ناچالاک';

  @override
  String get accountDeactivated => 'ئەم هەژمارە ناچالاک کراوە';

  @override
  String get manageSubscriptions => 'بەڕێوەبردنی بەشداریکردن';

  @override
  String get manageSubscriptionsHint => 'پلان و بەرواری بەسەرچوونی بەشداریکردنی نۆرینگە';

  @override
  String get systemStatistics => 'ئاماری سیستەم';

  @override
  String get systemStatisticsHint => 'پوختەی گشتی پلاتفۆرم';

  @override
  String get totalDoctors => 'کۆی دکتۆرەکان';

  @override
  String get totalSecretaries => 'کۆی سکرتێرەکان';

  @override
  String get totalClinics => 'کۆی نۆرینگەکان';

  @override
  String get activeSubscriptions => 'بەشداریکردنی چالاک';

  @override
  String get activeStaffAccounts => 'هەژمارە چالاکەکانی کارمەند';

  @override
  String get totalDoctorsListed => 'دکتۆر لە پێڕست';

  @override
  String get noStaffAccounts => 'هێشتا هیچ هەژمارێکی کارمەند نییە';

  @override
  String get createAccounts => 'دروستکردنی هەژمار';

  @override
  String get viewAndManage => 'بینین و بەڕێوەبردن';

  @override
  String get subscriptionPlan => 'پلانی بەشداریکردن';

  @override
  String get subscriptionPlan1Month => '١ مانگ';

  @override
  String get subscriptionPlan2Months => '٢ مانگ';

  @override
  String get subscriptionPlan3Months => '٣ مانگ';

  @override
  String get subscriptionPlan6Months => '٦ مانگ';

  @override
  String get subscriptionPlan12Months => '١٢ مانگ (١ ساڵ)';

  @override
  String get subscriptionPlanFree => 'بەخۆڕایی';

  @override
  String get subscriptionPlanBasic => 'ئاسایی';

  @override
  String get subscriptionPlanPremium => 'پریمیۆم';

  @override
  String get subscriptionActive => 'بەشداریکردن چالاکە';

  @override
  String get subscriptionExpires => 'بەسەردەچێت';

  @override
  String get subscriptionStarted => 'بەرواری دەستپێکردن';

  @override
  String get subscriptionRemainingDays => 'ڕۆژەکانی ماوە';

  @override
  String get subscriptionStatusActive => 'چالاک';

  @override
  String get subscriptionStatusExpiringSoon => 'بەزوویی بەسەردەچێت';

  @override
  String get subscriptionStatusExpired => 'بەسەرچووە';

  @override
  String subscriptionDaysRemaining(int days) {
    return '$days ڕۆژ ماوە';
  }

  @override
  String subscriptionExpiredDaysAgo(int days) {
    return 'پێش $days ڕۆژ بەسەرچووە';
  }

  @override
  String get subscriptionExpiredTitle => 'بەشداریکردن بەسەرچووە';

  @override
  String get subscriptionExpiredMessage => 'بەشداریکردنی نۆرینگەکەت بەسەرچووە. ناتوانیت نۆرەی نوێ دروست بکەیت. تۆمارەکانی نەخۆش بەردەستن بۆ خوێندنەوە.';

  @override
  String subscriptionExpiringBanner(int days) {
    return 'بەشداریکردنەکەت لە $days ڕۆژدا بەسەردەچێت. تکایە بەزوویی نوێی بکەرەوە.';
  }

  @override
  String get subscriptionBlocked => 'ناتوانیت نۆرە بگریت — بەشداریکردنی نۆرینگە بەسەرچووە.';

  @override
  String get renewSubscription => 'نوێکردنەوەی بەشداریکردن';

  @override
  String get subscriptionRenewed => 'بەشداریکردن بە سەرکەوتوویی نوێکرایەوە';

  @override
  String get viewPatientRecords => 'بینینی تۆمارەکانی نەخۆش';

  @override
  String get assignedDoctors => 'دکتۆرەکان';

  @override
  String get filterAll => 'هەموو';

  @override
  String get activateSubscription => 'چالاککردنی بەشداریکردن';

  @override
  String get doctorProfile => 'پڕۆفایلی دکتۆر';

  @override
  String get noExpiry => 'بەبێ بەرواری بەسەرچوون';

  @override
  String get doctorManagement => 'بەڕێوەبردنی دکتۆرەکان';

  @override
  String get doctorManagementHint => 'گەڕان، بینینی پڕۆفایل و بەڕێوەبردنی سکرتێرە دیاریکراوەکان';

  @override
  String get adminDoctorSearchHint => 'ناو، بوار، نۆرینگە، مۆبایل، ئیمەیڵ، یان کۆدی هەژمار (وەک DR-10025)...';

  @override
  String get accountCode => 'کۆدی هەژمار';

  @override
  String get doctorAccountCode => 'کۆدی هەژماری دکتۆر';

  @override
  String get doctorAccountCodeRequired => 'کۆدی هەژمارێکی دروست بنووسە و پشتڕاستی بکەرەوە';

  @override
  String get invalidDoctorAccountCode => 'هیچ دابینکەرێک بەم کۆدە نەدۆزرایەوە.';

  @override
  String get accountCodeFormatInvalid => 'کۆدێکی دروست بنووسە (وەک DR-10025 یان BZ-10001).';

  @override
  String get verifyAccountCode => 'پشتڕاستکردنەوە';

  @override
  String get secretaryLinkProviderPreview => 'دڵنیابوونەوە لە دابینکەری بەستراو';

  @override
  String doctorAccountCodeLabel(String code) {
    return 'کۆدی هەژماری دکتۆر: $code';
  }

  @override
  String linkedToAccountCode(String code) {
    return 'بەستراو بە: $code';
  }

  @override
  String get supportHistory => 'مێژووی پشتگیری';

  @override
  String get supportHistoryHint => 'نوێکردنەوەی بەشداریکردن، داواکاری پشتگیری، و تێبینی چارەسەرکردن بەپێی کۆدی هەژمار.';

  @override
  String get noSupportHistory => 'هێشتا چالاکی پشتگیری تۆمار نەکراوە.';

  @override
  String get doctorInformation => 'زانیاری دکتۆر';

  @override
  String get assignedSecretaries => 'سکرتێرە دیاریکراوەکان';

  @override
  String secretariesCount(int count) {
    return '$count سکرتێر';
  }

  @override
  String doctorSecretarySingle(String name) {
    return 'سکرتێر: $name';
  }

  @override
  String doctorSecretariesMultiple(String names) {
    return 'سکرتێرەکان: $names';
  }

  @override
  String doctorSecretariesMultipleWithMore(String names, int more) {
    return 'سکرتێرەکان: $names (+$more زیاتر)';
  }

  @override
  String get transferSecretary => 'گواستنەوە';

  @override
  String get transferSecretaryTitle => 'گواستنەوەی سکرتێر';

  @override
  String transferSecretaryHint(String name) {
    return 'گواستنەوەی $name بۆ دکتۆرێکی تر';
  }

  @override
  String get transferredSuccessfully => 'بە سەرکەوتوویی گواسترایەوە';

  @override
  String secretaryAssignedToDoctor(String doctorName) {
    return 'دیاریکراو بۆ: $doctorName';
  }

  @override
  String get addSecretary => 'سکرتێر زیاد بکە';

  @override
  String get editSecretary => 'دەستکاری سکرتێر';

  @override
  String get deleteSecretary => 'سڕینەوەی سکرتێر';

  @override
  String get deleteSecretaryConfirm => 'ئەم هەژمارەی سکرتێرە بسڕیتەوە؟ ناگەڕێتەوە.';

  @override
  String get noSecretariesAssigned => 'هیچ سکرتێرێک بۆ ئەم دکتۆرە دیاری نەکراوە';

  @override
  String get loadMore => 'زیاتر بار بکە';

  @override
  String pageOf(int current, int total) {
    return 'لاپەڕە $current لە $total';
  }

  @override
  String get itemsPerPage => 'بۆ هەر لاپەڕەیەک';

  @override
  String get notAvailable => '—';

  @override
  String get clinicName => 'ناوی نۆرینگە';

  @override
  String get status => 'دۆخ';

  @override
  String get doctorName => 'ناوی دکتۆر';

  @override
  String get businessName => 'ناوی کار';

  @override
  String get businessProfile => 'پرۆفایلی کار';

  @override
  String get editBusinessProfile => 'دەستکاری پرۆفایلی کار';

  @override
  String get editDoctorProfile => 'دەستکاری پرۆفایلی دکتۆر';

  @override
  String get aboutBusiness => 'دەربارەی کار';

  @override
  String get businessDashboard => 'داشبۆردی کار';

  @override
  String get linkedBusiness => 'کاری بەستراو';

  @override
  String get accountType => 'جۆری هەژمار';

  @override
  String get accountTypeDoctor => 'دکتۆر';

  @override
  String get accountTypeBusiness => 'کار';

  @override
  String get createBusinessAccount => 'دروستکردنی هەژماری کار';

  @override
  String get createBusinessAccountHint => 'کارێکی تەندروستی زیاد بکە لەگەڵ زانیاری چوونەژوورەوە';

  @override
  String get selectBusinessCategory => 'جۆری کار';

  @override
  String get searchProviders => 'گەڕان بۆ دکتۆر و کار';

  @override
  String get searchHintProviders => 'ناو، پسپۆڕی، جۆری کار، نۆرینگە...';

  @override
  String get businessCategoryClinic => 'نۆرینگە';

  @override
  String get businessCategoryBeautyCenter => 'سەنتەری جوانکاری';

  @override
  String get businessCategoryMedicalLaboratory => 'تاقیگەی پزیشکی';

  @override
  String get businessCategoryRadiologyCenter => 'سەنتەری تیشک';

  @override
  String get businessCategoryPhysiotherapyCenter => 'سەنتەری فیزیۆتێراپی';

  @override
  String get businessCategoryDentalCenter => 'سەنتەری ددان';

  @override
  String get businessCategoryEyeCenter => 'سەنتەری چاو';

  @override
  String get businessCategoryHearingCenter => 'سەنتەری بیستن';

  @override
  String get businessCategoryVaccinationCenter => 'سەنتەری کوتان';

  @override
  String get businessCategoryBloodTestCenter => 'سەنتەری تاقیکردنەوەی خوێن';

  @override
  String get businessCategoryPharmacy => 'دەرمانخانە';

  @override
  String get businessCategoryOtherHealthcare => 'خزمەتگوزاری تەندروستی تر';

  @override
  String get noSecretariesAssignedBusiness => 'هیچ سکرتێرێک بۆ ئەم کارە دیاری نەکراوە';

  @override
  String get doctorsSection => 'دکتۆرەکان';

  @override
  String get clinicsHealthcareCenters => 'نۆرینگە و ناوەندەکانی تەندروستی';

  @override
  String get searchDoctorsOnly => 'گەڕان بە ناوی دکتۆر یان پسپۆڕی';

  @override
  String get searchBusinessesOnly => 'گەڕان بە ناوی کار';

  @override
  String get noBusinessesFound => 'هیچ کارێک نەدۆزرایەوە';

  @override
  String get allBusinessCategories => 'هەموو جۆرەکان';

  @override
  String get browseHealthcare => 'گەڕان لە خزمەتگوزاری تەندروستی';

  @override
  String get browseDoctorsHint => 'دکتۆر بدۆزەوە و بچۆ ناو سەرە';

  @override
  String get browseBusinessesHint => 'نۆرینگە، تاقیگە، دەرمانخانە و زیاتر';

  @override
  String get selectQueueSlot => 'کاتی سەرە هەڵبژێرە';

  @override
  String get selectTimeSlotHint => 'کاتێکی بەردەست هەڵبژێرە بۆ سەردانت';

  @override
  String get noQueueSlotsAvailable => 'ئێستا هیچ کاتێکی سەرە بەردەست نییە';

  @override
  String get joinQueue => 'بچۆ ناو سەرە';

  @override
  String get queueSlot => 'کاتی سەرە';

  @override
  String get settings => 'ڕێکخستنەکان';

  @override
  String get appearance => 'ڕووکار';

  @override
  String get theme => 'ڕەنگ';

  @override
  String get themeLight => 'ڕووناک';

  @override
  String get themeDark => 'تاریک';

  @override
  String get themeSystem => 'سیستەم';

  @override
  String get accountSecurity => 'هەژمار و ئاسایش';

  @override
  String get changePassword => 'گۆڕینی وشەی نهێنی';

  @override
  String get changePasswordHint => 'وشەی نهێنی چوونەژوورەوە نوێ بکەرەوە';

  @override
  String get changePasswordDescription => 'وشەی نهێنی ئێستات بنووسە و دانەیەکی نوێ هەڵبژێرە. تەنها خۆت دەتوانیت وشەی نهێنی خۆت بگۆڕیت.';

  @override
  String get currentPassword => 'وشەی نهێنی ئێستا';

  @override
  String get newPassword => 'وشەی نهێنی نوێ';

  @override
  String get passwordChangeUnavailable => 'گۆڕینی وشەی نهێنی بۆ ئەم هەژمارە بەردەست نییە';

  @override
  String get passwordChangedSuccessfully => 'وشەی نهێنی بە سەرکەوتوویی گۆڕدرا';

  @override
  String get passwordSameAsCurrent => 'وشەی نهێنی نوێ دەبێت جیاواز بێت لە ئێستا';

  @override
  String get passwordsDoNotMatch => 'وشەکانی نهێنی یەک ناگرنەوە';

  @override
  String get accountInfoReadOnly => 'وردەکاری هەژمار';

  @override
  String get accountInfoReadOnlyHint => 'ئیمەیڵ، تەلەفۆن، جۆری هەژمار و دەسەڵاتەکان لەلایەن بەڕێوەبەری نۆرینگەوە بەڕێوە دەبرێن';

  @override
  String get pushNotifications => 'ئاگادارکردنەوەی پوش';

  @override
  String get queueNotifications => 'ئاگادارکردنەوەی سەرە';

  @override
  String get sound => 'دەنگ';

  @override
  String get vibration => 'لەرزین';

  @override
  String get patientPreferences => 'هەڵبژاردەکانی نەخۆش';

  @override
  String get favoriteDoctors => 'دکتۆرە دڵخوازەکان';

  @override
  String get favoriteBusinesses => 'کارە دڵخوازەکان';

  @override
  String get noFavoriteDoctors => 'هێشتا دکتۆری دڵخواز نییە';

  @override
  String get noFavoriteBusinesses => 'هێشتا کاری دڵخواز نییە';

  @override
  String get doctorSettings => 'ڕێکخستنی دکتۆر';

  @override
  String get businessSettings => 'ڕێکخستنی کار';

  @override
  String get workingDaysAndHours => 'ڕۆژ و کاتژمێری کار';

  @override
  String get queueSettings => 'ڕێکخستنی سەرە';

  @override
  String get profileVisibility => 'دیاربوونی پرۆفایل';

  @override
  String get contactVisibility => 'دیاربوونی پەیوەندی';

  @override
  String get whatsappVisibility => 'دیاربوونی واتساپ';

  @override
  String get secretarySettings => 'ڕێکخستنی سکرتێر';

  @override
  String get queueAutoRefresh => 'نوێکردنەوەی خۆکاری سەرە';

  @override
  String get queueAutoRefreshHint => 'دیمەنی سەرە بە شێوەی ڕاستەوخۆ نوێ بکەرەوە';

  @override
  String get privacySettings => 'تایبەتمەندی';

  @override
  String get showInSearchResults => 'نیشاندان لە گەڕان';

  @override
  String get showInSearchResultsHint => 'ڕێگە بدە پرۆفایلەکەت لە گەڕانی نەخۆشدا دەربکەوێت';

  @override
  String get shareUsageAnalytics => 'هاوبەشکردنی ئامار';

  @override
  String get shareUsageAnalyticsHint => 'یارمەتی باشترکردنی تەبیب بدە بە داتای نەناسراو';

  @override
  String get supportAndLegal => 'پاڵپشتی و یاسایی';

  @override
  String get about => 'دەربارە';

  @override
  String get helpAndSupport => 'یارمەتی و پاڵپشتی';

  @override
  String get termsAndConditions => 'مەرج و ڕێساکان';

  @override
  String get privacyPolicy => 'سیاسەتی تایبەتمەندی';

  @override
  String get appVersion => 'وەشانی ئەپ';

  @override
  String get providerSettings => 'ڕێکخستنی دابینکەر';

  @override
  String get queueNotificationsProviderHint => 'ئاگادار بکەرەوە کاتێک نەخۆش دەچێتە ناو سەرە';

  @override
  String get saveChanges => 'پاشەکەوتکردنی گۆڕانکاریەکان';

  @override
  String get patient => 'نەخۆش';

  @override
  String get secretary => 'سکرتێر';

  @override
  String get admin => 'بەڕێوەبەر';

  @override
  String get bio => 'ژیاننامە';

  @override
  String get profilePhoto => 'وێنەی پرۆفایل';

  @override
  String get degrees => 'پلەکان';

  @override
  String get experience => 'ئەزموون';

  @override
  String get error => 'هەڵەیەک ڕوویدا';

  @override
  String get termsContent => 'بە بەکارهێنانی تەبیب، ڕازیت بە پابەندبوون بە یاساکانی سەرەی نۆرینگە و ڕێزگرتن لە کارمەندانی تەندروستی.';

  @override
  String get privacyPolicyContent => 'تەبیب تەنها ئەو داتایە کۆدەکاتەوە کە پێویستە بۆ بەڕێوەبردنی سەرە و پەیوەندی نۆرینگە. زانیارییەکانت نافرۆشرێن.';

  @override
  String aboutContent(String version) {
    return 'تەبیب v$version — پلاتفۆرمێکی مۆدێرن بۆ سەرە و بەڕێوەبردنی نۆرینگەی تەندروستی.';
  }

  @override
  String helpContent(String email) {
    return 'پێویستت بە یارمەتییە؟ ئیمەیڵ بنێرە بۆ $email یان پەیوەندی بە بەڕێوەبەری نۆرینگەکەت بکە.';
  }

  @override
  String get accountStatusActive => 'چالاک';

  @override
  String get accountStatusSuspended => 'هەڵواسراو';

  @override
  String get accountStatusDisabled => 'ناچالاک';

  @override
  String get accountStatusExpiredSubscription => 'بەشداریکردن بەسەرچووە';

  @override
  String get allStatuses => 'هەموو دۆخەکان';

  @override
  String get changeAccountStatus => 'گۆڕینی دۆخی هەژمار';

  @override
  String get accountSuspendedMessage => 'ئەم هەژمارە هەڵواسراوە. پەیوەندی بە بەڕێوەبەری نۆرینگەکەت بکە.';

  @override
  String get accountDisabledMessage => 'ئەم هەژمارە ناچالاک کراوە. پەیوەندی بە بەڕێوەبەری نۆرینگەکەت بکە.';

  @override
  String get accountSubscriptionExpiredLoginMessage => 'دەستگەیشتن ڕاگیراوە چونکە بەشداریکردنی نۆرینگە بەسەرچووە. تکایە نوێی بکەرەوە.';

  @override
  String get managePatients => 'بەڕێوەبردنی نەخۆشەکان';

  @override
  String get managePatientsHint => 'بینینی هەژماری نەخۆش و بەڕێوەبردنی دۆخیان';

  @override
  String get manageAdmins => 'بەڕێوەبردنی بەڕێوەبەران';

  @override
  String get manageAdminsHint => 'دروستکردنی بەڕێوەبەر و دیاریکردنی مۆڵەتەکان';

  @override
  String get createAdminAccount => 'دروستکردنی هەژماری بەڕێوەبەر';

  @override
  String get editAdminAccount => 'دەستکاری هەژماری بەڕێوەبەر';

  @override
  String get deleteAdminAccount => 'سڕینەوەی هەژماری بەڕێوەبەر';

  @override
  String get deleteAdminAccountConfirm => 'ئەم هەژمارەی بەڕێوەبەرە بسڕیتەوە؟ ناگەڕێتەوە.';

  @override
  String get noAdminAccounts => 'هێشتا هیچ بەڕێوەبەرێک نییە';

  @override
  String get adminPermissionsTitle => 'مۆڵەتەکان';

  @override
  String get adminPermissionsRequired => 'لانیکەم یەک مۆڵەت هەڵبژێرە';

  @override
  String get permManageDoctors => 'بەڕێوەبردنی دکتۆرەکان';

  @override
  String get permManageBusinesses => 'بەڕێوەبردنی بازرگانییەکان';

  @override
  String get permManageSecretaries => 'بەڕێوەبردنی سکرتێرەکان';

  @override
  String get permManagePatients => 'بەڕێوەبردنی نەخۆشەکان';

  @override
  String get permManageSubscriptions => 'بەڕێوەبردنی بەشداریکردنەکان';

  @override
  String get permViewReports => 'بینینی ڕاپۆرتەکان';

  @override
  String get permSendNotifications => 'ناردنی ئاگاداریەکان';

  @override
  String get permResetPasswords => 'ڕێکخستنەوەی وشەی نهێنی';

  @override
  String get permSuspendAccounts => 'هەڵواسینی هەژمارەکان';

  @override
  String get permDeleteAccounts => 'سڕینەوەی هەژمارەکان';

  @override
  String get permManageCategories => 'بەڕێوەبردنی پۆلەکان';

  @override
  String get permViewAnalytics => 'بینینی شیکاریەکان';

  @override
  String get permCreateAdmins => 'دروستکردنی بەڕێوەبەر';

  @override
  String get permManageAdmins => 'بەڕێوەبردنی بەڕێوەبەران';

  @override
  String get systemOwnerDashboard => 'داشبۆردی خاوەنی سیستەم';

  @override
  String get systemOwnerDashboardHint => 'بەڕێوەبردنی پلاتفۆرم، بەکارهێنەران، بەشداریکردن و ڕێکخستنەکانی سیستەم.';

  @override
  String get systemOwnerModules => 'یەکەکانی بەڕێوەبردن';

  @override
  String get dashboardOverview => 'پوختەی داشبۆرد';

  @override
  String get businessManagement => 'بەڕێوەبردنی بازرگانی';

  @override
  String get secretaryManagement => 'بەڕێوەبردنی سکرتێرەکان';

  @override
  String get addNewSecretary => 'سکرتێری نوێ زیاد بکە';

  @override
  String get resetPassword => 'ڕێکخستنەوەی وشەی نهێنی';

  @override
  String get secretaryPasswordResetSuccess => 'وشەی نهێنی سکرتێر بە سەرکەوتوویی نوێکرایەوە';

  @override
  String get secretaryPasswordResetEmailSent => 'بەستەری ڕێکخستنەوەی وشەی نهێنی نێردرا بۆ سکرتێر';

  @override
  String get resetSecretaryPasswordFirebaseHint => 'ئیمەیڵێکی ڕێکخستنەوەی وشەی نهێنی دەنێردرێت بۆ ناونیشانی چوونەژوورەوەی سکرتێر.';

  @override
  String get enableAccount => 'چالاککردنی هەژمار';

  @override
  String get disableAccount => 'ناچالاککردنی هەژمار';

  @override
  String get unassignedSecretaries => 'سکرتێرە دیارینەکراوەکان';

  @override
  String get noSecretariesYet => 'هێشتا سکرتێر نییە';

  @override
  String get patientManagement => 'بەڕێوەبردنی نەخۆشەکان';

  @override
  String get subscriptionManagement => 'بەڕێوەبردنی بەشداریکردن';

  @override
  String get packageManagement => 'بەڕێوەبردنی پاکێجەکان';

  @override
  String get payments => 'پارەدانەکان';

  @override
  String get reports => 'ڕاپۆرتەکان';

  @override
  String get analytics => 'شیکاریەکان';

  @override
  String get systemSettings => 'ڕێکخستنەکانی سیستەم';

  @override
  String get moduleComingSoon => 'ئەم یەکەیە لە نوێکردنەوەی داهاتوو بەردەست دەبێت.';

  @override
  String get comingSoon => 'بەزووی';

  @override
  String get ownerNavSubscriptionsPackages => 'بەشداریکردن و پاکێجەکان';

  @override
  String get paymentsBilling => 'پارەدان و وەسڵ';

  @override
  String get feedbackSupport => 'فیدباک و پشتگیری';

  @override
  String get notificationsCenter => 'ناوەندی ئاگاداریەکان';

  @override
  String get reportsAnalytics => 'ڕاپۆرت و شیکاری';

  @override
  String get analyticsDashboard => 'داشبۆردی شیکاری';

  @override
  String get sessionManager => 'بەڕێوەبەری دانیشتن';

  @override
  String get sessionManagerHint => 'دانیشتنە چالاکەکان ببینە و کۆتایی پێ بێنە. ناتوانیت دانیشتنی ئێستات کۆتایی پێ بێنیت.';

  @override
  String get loggedInDevices => 'ئامێرە چوونەژوورەوەکان';

  @override
  String get recentlyLoggedInUsers => 'بەکارهێنەرانی نوێ چوونەژوورەوە';

  @override
  String get searchUsers => 'گەڕان بۆ بەکارهێنەر';

  @override
  String get loginTime => 'کاتی چوونەژوورەوە';

  @override
  String get lastActivity => 'دوایین چالاکی';

  @override
  String get browserDevice => 'وێبگەڕ / ئامێر';

  @override
  String get currentSession => 'دانیشتنی ئێستا';

  @override
  String get cannotTerminateCurrentSession => 'ناتوانیت دانیشتنی ئێستات کۆتایی پێ بێنیت';

  @override
  String get errorFilterCriticalOnly => 'تەنها گرنگ';

  @override
  String get allModules => 'هەموو یەکەکان';

  @override
  String get errorStatus => 'دۆخ';

  @override
  String get platformLabel => 'پلاتفۆرم';

  @override
  String get severity => 'گرنگی';

  @override
  String get backupInProgress => 'پاشەکەوتکردن لە جریانە';

  @override
  String get exportAuditLog => 'هەناردەی تۆماری وردبینی';

  @override
  String get auditLogExported => 'تۆماری وردبینی هەناردە کرا';

  @override
  String get queueAnalytics => 'شیکاری ڕیز';

  @override
  String get appointmentAnalytics => 'شیکاری چاوپێکەوتن';

  @override
  String get packageAnalytics => 'شیکاری پاکێج';

  @override
  String get suspendedPackages => 'Pakêjە هەڵواسراوەکان';

  @override
  String get revenueByPackage => 'داهات بەپێی پاکێج';

  @override
  String get avgServiceTime => 'ناوەندی کاتی خزمەتگوزاری';

  @override
  String get completedAppointments => 'چاوپێکەوتنە تەواوکراوەکان';

  @override
  String get cacheEfficiency => 'کارایی کاش';

  @override
  String get highCostOperationWarning => 'پێش بەردەوامبوون ئەم کارە بپشکنە — لەوانەیە تێچووی Firebase زیاد بکات';

  @override
  String get maintenanceAllowOwnerAdmin => 'خاوەن و بەڕێوەبەر دەتوانن لە کاتی چاکسازی دەستگەیشتن بە پلاتفۆرم بکەن';

  @override
  String get dashboardSectionNavigator => 'بچۆ بۆ بەش';

  @override
  String get viewFullMonitoringCenter => 'ناوەندی چاودێری تەواو بکەرەوە';

  @override
  String reportSavedToFile(String path) {
    return 'ڕاپۆرت پاشەکەوت کرا لە $path';
  }

  @override
  String get systemHealth => 'تەندروستی سیستەم';

  @override
  String get auditLog => 'تۆماری وردبینی';

  @override
  String get securityCenter => 'ناوەندی ئاسایش';

  @override
  String get backupRestore => 'پاشەکەوت و گەڕاندنەوە';

  @override
  String get totalBusinesses => 'کۆی بازرگانیەکان';

  @override
  String get totalPatients => 'کۆی نەخۆشەکان';

  @override
  String get activeUsersToday => 'بەکارهێنەرانی چالاک';

  @override
  String get expiredSubscriptions => 'بەشداریکردنی بەسەرچوو';

  @override
  String get revenueOverview => 'پوختەی داهات';

  @override
  String get newRegistrations => 'تۆمارکردنی نوێ';

  @override
  String get liveQueueStatistics => 'ئاماری ڕیزی ڕاستەوخۆ';

  @override
  String get queueWaiting => 'چاوەڕوان';

  @override
  String get queueInProgress => 'لە جێبەجێکردندا';

  @override
  String get quickActions => 'کردارە خێراکان';

  @override
  String get allBusinesses => 'هەموو بازرگانیەکان';

  @override
  String get allBusinessesHint => 'بینین و بەڕێوەبردنی هەموو دامەزراوەکان';

  @override
  String get businessCategoryBrowseHint => 'گەڕان لەم پۆلەدا';

  @override
  String get subscriptionPackagesHint => 'بەڕێوەبردنی پلان، نوێکردنەوە و ئاگاداری بەسەرچوون';

  @override
  String get createPackages => 'دروستکردنی پاکێج';

  @override
  String get createPackagesHint => 'پێناسەکردنی ئاستی بەشداریکردن';

  @override
  String get subscriptionPlanHint => 'کردنەوەی بەڕێوەبردنی بەشداریکردن';

  @override
  String get plan1Month => '١ مانگ';

  @override
  String get plan2Months => '٢ مانگ';

  @override
  String get plan3Months => '٣ مانگ';

  @override
  String get plan6Months => '٦ مانگ';

  @override
  String get plan12Months => '١٢ مانگ';

  @override
  String get activateSubscriptionHint => 'چالاککردنی پلانی نۆرینگە';

  @override
  String get renewSubscriptionHint => 'درێژکردنەوەی بەشداریکردن';

  @override
  String get suspendSubscription => 'هەڵواسینی بەشداریکردن';

  @override
  String get suspendSubscriptionHint => 'ڕاگرتنی کاتی دەستگەیشتن';

  @override
  String get remainingDays => 'ڕۆژە ماوەکان';

  @override
  String get remainingDaysHint => 'ڕۆژەکانی ماوە بۆ هەر نۆرینگەیەک';

  @override
  String get expirationAlerts => 'ئاگاداری بەسەرچوون';

  @override
  String get expirationAlertsHint => 'چاودێری نۆرینگە نزیکە بەسەرچوونەکان';

  @override
  String get paymentsBillingHint => 'وەسڵ، پارەدان و شێوازەکانی پارەدان';

  @override
  String get invoices => 'وەسڵەکان';

  @override
  String get invoicesHint => 'بینین و هەناردەکردنی وەسڵ';

  @override
  String get billingOverview => 'پوختەی وەسڵ';

  @override
  String get billingOverviewHint => 'کورتەی چالاکی پارەدان';

  @override
  String get paymentMethods => 'شێوازەکانی پارەدان';

  @override
  String get paymentMethodsHint => 'ڕێکخستنی شێوازە قبوڵکراوەکان';

  @override
  String get feedbackSupportHint => 'فیدباک و داواکاری پشتگیری';

  @override
  String get bugReports => 'ڕاپۆرتی هەڵە';

  @override
  String get bugReportsHint => 'کێشە ڕاپۆرتکراوەکان';

  @override
  String get featureRequests => 'داواکاری تایبەتمەندی';

  @override
  String get featureRequestsHint => 'ئایدیاکانی بەکارهێنەران';

  @override
  String get userFeedback => 'فیدباکی بەکارهێنەر';

  @override
  String get userFeedbackHint => 'فیدباکی گشتی پلاتفۆرم';

  @override
  String get supportConversations => 'گفتوگۆی پشتگیری';

  @override
  String get supportConversationsHint => 'پەیامەکانی بەکارهێنەران';

  @override
  String get notificationsCenterHint => 'ئاگاداری گشتی و سیستەم';

  @override
  String get broadcastNotifications => 'ئاگاداری گشتی';

  @override
  String get broadcastNotificationsHint => 'ناردنی ڕاگەیاندن بۆ هەموو';

  @override
  String get subscriptionReminders => 'بیرهێنەرەوەی بەشداریکردن';

  @override
  String get subscriptionRemindersHint => 'بیرهێنەرەوەی خۆکار';

  @override
  String get maintenanceAnnouncements => 'ڕاگەیاندنی چاکسازی';

  @override
  String get maintenanceAnnouncementsHint => 'ئاگاداری وەستاندنی خزمەتگوزاری';

  @override
  String get reportsAnalyticsHint => 'ڕاپۆرت و شیکاری گەشە';

  @override
  String get reportDaily => 'ڕاپۆرتی ڕۆژانە';

  @override
  String get reportDailyHint => 'چالاکی ئەمڕۆ';

  @override
  String get reportWeekly => 'ڕاپۆرتی هەفتانە';

  @override
  String get reportWeeklyHint => 'کورتەی ٧ ڕۆژ';

  @override
  String get reportMonthly => 'ڕاپۆرتی مانگانە';

  @override
  String get reportMonthlyHint => 'کورتەی ٣٠ ڕۆژ';

  @override
  String get reportYearly => 'ڕاپۆرتی ساڵانە';

  @override
  String get reportYearlyHint => 'کورتەی ساڵانە';

  @override
  String get queueStatistics => 'ئاماری ڕیز';

  @override
  String get queueStatisticsHint => 'کاتی چاوەڕوانی و قەبارەی ڕیز';

  @override
  String get appointmentStatistics => 'ئاماری چاوپێکەوتن';

  @override
  String get appointmentStatisticsHint => 'حجز و تەواوکردن';

  @override
  String get revenueStatistics => 'ئاماری داهات';

  @override
  String get revenueStatisticsHint => 'داهاتی بەشداریکردن';

  @override
  String get userGrowth => 'گەشەی بەکارهێنەر';

  @override
  String get userGrowthHint => 'بەکارهێنەری نوێ بە درێژایی کات';

  @override
  String get systemHealthHint => 'دۆخی ژێرخان و خزمەتگوزاری';

  @override
  String get firebaseStatus => 'دۆخی Firebase';

  @override
  String get statusConnected => 'پەیوەست و ڕێکخراو';

  @override
  String get statusDemoOrOffline => 'دۆخی دیمۆ یان ڕێکنەخراو';

  @override
  String get storageUsage => 'بەکارهێنانی بیرگە';

  @override
  String get databaseUsage => 'بەکارهێنانی داتابەیس';

  @override
  String get clinicsLabel => 'نۆرینگە';

  @override
  String get accountsLabel => 'هەژمار';

  @override
  String get errorLogs => 'تۆماری هەڵە';

  @override
  String get errorLogsHint => 'مێژووی هەڵەکانی ئەپ';

  @override
  String get crashReports => 'ڕاپۆرتی تێکچوون';

  @override
  String get crashReportsHint => 'کورتەی تێکچوونی کڕیار';

  @override
  String get performanceMonitoring => 'چاودێری کارایی';

  @override
  String get performanceMonitoringHint => 'خاوێنی و بار';

  @override
  String get noAuditEntries => 'هێشتا تۆماری وردبینی نییە';

  @override
  String get user => 'بەکارهێنەر';

  @override
  String get device => 'ئامێر';

  @override
  String get ipAddress => 'ناونیشانی IP';

  @override
  String get securityCenterHint => 'چالاکی چوونەژوورەوە و پاراستن';

  @override
  String get loginHistory => 'مێژووی چوونەژوورەوە';

  @override
  String get loginHistoryHint => 'چوونەژوورەوەی دوایی';

  @override
  String get activeSessions => 'دانیشتنە چالاکەکان';

  @override
  String get activeSessionsHint => 'ئامێرە چالاکەکان';

  @override
  String get failedLoginAttempts => 'هەوڵی چوونەژوورەوەی شکستخواردوو';

  @override
  String get failedLoginAttemptsHint => 'چوونەژوورەوەی گومانلێکراو';

  @override
  String get blockedAccounts => 'هەژماری بلۆککراو';

  @override
  String get blockedAccountsHint => 'هەژماری هەڵواسراو یان ناچالاک';

  @override
  String get passwordResetLogs => 'تۆماری نوێکردنەوەی وشەی نهێنی';

  @override
  String get passwordResetLogsHint => 'داواکاری نوێکردنەوەی دوایی';

  @override
  String get backupRestoreHint => 'پاراستن و گەڕاندنەوەی داتا';

  @override
  String get manualBackup => 'پاشەکەوتی دەستی';

  @override
  String get manualBackupHint => 'دروستکردنی پاشەکەوت بە داوا';

  @override
  String get automaticBackup => 'پاشەکەوتی خۆکار';

  @override
  String get automaticBackupHint => 'خشتەی پاشەکەوتی دووبارە';

  @override
  String get restoreData => 'گەڕاندنەوەی داتا';

  @override
  String get restoreDataHint => 'گەڕاندنەوە لە پاشەکەوت';

  @override
  String get systemSettingsHint => 'ڕێکخستنی گشتی پلاتفۆرم';

  @override
  String get languageSettingsHint => 'زمانە پشتگیریکراوەکان';

  @override
  String get themeSettingsHint => 'ڕووناک، تاریک و براندینگ';

  @override
  String get notificationSettingsHint => 'ڕێکخستنی ئاگاداری سیستەم';

  @override
  String get featureFlags => 'ئاڵای تایبەتمەندی';

  @override
  String get featureFlagsHint => 'چالاک/ناچالاککردنی تایبەتمەندی';

  @override
  String get maintenanceMode => 'دۆخی چاکسازی';

  @override
  String get maintenanceModeHint => 'وەستاندنی پلاتفۆرم بۆ چاکسازی';

  @override
  String get businessType => 'جۆری بازرگانی';

  @override
  String get addBusinessType => 'زیادکردنی جۆری بازرگانی';

  @override
  String get localizedTypeHint => 'ناوەکانی کوردی، عەرەبی و ئینگلیزی بنووسە (هەر سێکیان پێویستن). بەکارهێنەران ناوەکە بە زمانە هەڵبژێردراوەکەیان دەبینن.';

  @override
  String get translationRequired => 'ئەم وەرگێڕانە پێویستە';

  @override
  String get translationsIncomplete => 'وەرگێڕان کەمە — دەستکاری بکە بۆ زیادکردنی کوردی، عەرەبی و ئینگلیزی';

  @override
  String get typeToSearchOrCreate => 'بنووسە بۆ گەڕان یان دروستکردن';

  @override
  String get businessTypeSearchHint => 'لانیکەم ٢ پیت بنووسە بۆ گەڕان، یان جۆرێکی دواتر بەکارهاتوو هەڵبژێرە.';

  @override
  String get specialtySearchHint => 'لانیکەم ٢ پیت بنووسە بۆ گەڕان لە پسپۆڕییەکان.';

  @override
  String get noBusinessTypeFound => 'هیچ جۆرێکی بازرگانی نەدۆزرایەوە.';

  @override
  String get noSpecialtyFound => 'هیچ پسپۆڕییەک نەدۆزرایەوە.';

  @override
  String get createNewBusinessType => '+ جۆری بازرگانی نوێ دروست بکە';

  @override
  String get recentlyUsedBusinessTypes => 'دواتر بەکارهاتوو';

  @override
  String createNewType(String name) {
    return 'دروستکردنی \"$name\"';
  }

  @override
  String get completeProfileBanner => 'پرۆفایلەکەت تەواو بکە — ناوی نۆرینگە، ناونیشان، کاتژمێر، وێنە و زانیاری پەیوەندی زیاد بکە.';

  @override
  String get completeProfileAction => 'تەواوکردنی پرۆفایل';

  @override
  String get manageBusinessTypes => 'جۆرەکانی بازرگانی';

  @override
  String get manageBusinessTypesHint => 'دروستکردن، وەرگێڕان و چالاککردنی جۆرەکانی بازرگانی';

  @override
  String get editBusinessType => 'دەستکاری جۆری بازرگانی';

  @override
  String get businessTypeActive => 'چالاک';

  @override
  String get businessTypeActiveHint => 'جۆرە ناچالاکەکان بۆ نەخۆشەکان شاردراونەتەوە تا چالاک بکرێن و دابەش بکرێن';

  @override
  String get businessTypeDuplicate => 'ئەم جۆرە بازرگانییە پێشتر هەیە';

  @override
  String get noBusinessTypesYet => 'هێشتا جۆری بازرگانی نییە. یەکێک زیاد بکە.';

  @override
  String businessTypeAssignedCount(int count) {
    return '$count بازرگانی دابەشکراو';
  }

  @override
  String get allBusinessTypes => 'هەموو جۆرەکانی بازرگانی';

  @override
  String get iconName => 'ناوی ئایکۆن';

  @override
  String get myQueues => 'نۆرەکانم';

  @override
  String get sortClosestAppointment => 'نزیکترین کات';

  @override
  String get sortRecentlyJoined => 'دواتر بەشداربوو';

  @override
  String get sortDoctorName => 'ناوی دکتۆر';

  @override
  String get refresh => 'نوێکردنەوە';

  @override
  String get viewProfile => 'بینینی پرۆفایل';

  @override
  String get patientProfile => 'پرۆفایل';

  @override
  String get city => 'شار';

  @override
  String get genderOptional => 'ڕەگەز (ئارەزوومەندانە)';

  @override
  String get showProfilePhoto => 'وێنەی پرۆفایل پیشان بدە';

  @override
  String get showPhoneNumber => 'ژمارەی مۆبایل پیشان بدە';

  @override
  String get profileVisibleToVisitedOnly => 'پرۆفایل تەنها بۆ دامەزراوە سەردانکراوەکان';

  @override
  String get recentlyVisited => 'سەردانی دواتر';

  @override
  String get nearbyProviders => 'نزیک';

  @override
  String get recommendedDoctors => 'دکتۆرە پێشنیارکراوەکان';

  @override
  String get recommendedBusinesses => 'دامەزراوە پێشنیارکراوەکان';

  @override
  String get activeQueues => 'نۆرە چالاکەکان';

  @override
  String get advertisements => 'ڕیکلامەکان';

  @override
  String get enableLocation => 'شوێن چالاک بکە';

  @override
  String get locationRequiredForNearby => 'دەستڕاگەیشتن بە شوێن ڕێگە بدە بۆ بینینی دامەزراوە نزیکەکان.';

  @override
  String get alreadyInSameQueue => 'پێشتر لەم نۆرەیەدا بۆ ئەم کاتە تۆمارکراویت.';

  @override
  String get profileSaved => 'پرۆفایل پاشەکەوت کرا';

  @override
  String get saveFailed => 'پاشەکەوتکردن سەرکەوتوو نەبوو';

  @override
  String get uploadFailed => 'بارکردن سەرکەوتوو نەبوو';

  @override
  String get notSpecified => 'دیاری نەکراو';

  @override
  String get male => 'نێر';

  @override
  String get female => 'مێ';

  @override
  String get searchProvidersHint => 'دکتۆر، دامەزراوە، پسپۆڕی یان شار...';

  @override
  String get viewAll => 'هەمووی ببینە';

  @override
  String get bookAgain => 'دووبارە نۆرە بگرە';

  @override
  String get setCityForAds => 'شارەکەت لە پرۆفایل دابنێ بۆ بینینی پێشکەشکراوە تەندروستییە خۆجێییەکان.';

  @override
  String get advertisementDetails => 'ڕیکلام';

  @override
  String get advertisementNotFound => 'ئەم ڕیکلامە چیتر بەردەست نییە.';

  @override
  String get viewDetails => 'وردەکاری ببینە';

  @override
  String get currentServing => 'ئێستا ژمارە';

  @override
  String get queueStatusServing => 'لە خزمەتکردندا';

  @override
  String get queueStatusFinished => 'تەواو بوو';

  @override
  String get queueProgress => 'پێشکەوتنی نۆرە';

  @override
  String get sortQueueProgress => 'پێشکەوتنی نۆرە';

  @override
  String get nearbyHealthcareCenters => 'ناوەندە تەندروستییە نزیکەکان';

  @override
  String get recommendedHealthcareCenters => 'ناوەندە تەندروستییە پێشنیارکراوەکان';

  @override
  String get noNearbyProviders => 'هیچ دامەزراوەیەکی نزیک نەدۆزرایەوە.';

  @override
  String get callClinic => 'پەیوەندی بە نۆرینگە';

  @override
  String get openMap => 'نەخشە بکەرەوە';

  @override
  String get addToFavorites => 'زیادکردن بۆ دڵخواز';

  @override
  String get removeFromFavorites => 'لابردن لە دڵخواز';

  @override
  String get cancelQueueConfirm => 'دڵنیایت دەتەوێت ئەم نۆرەیە هەڵبوەشێنیتەوە؟';

  @override
  String get notNow => 'ئێستا نا';

  @override
  String get memberSince => 'ئەندام لە';

  @override
  String get completedVisits => 'سەردانە تەواوکراوەکان';

  @override
  String get upcomingAppointments => 'چاوپێکەوتنە داهاتووەکان';

  @override
  String get birthDate => 'ڕۆژی لەدایکبوون';

  @override
  String get bloodType => 'جۆری خوێن';

  @override
  String get emergencyContact => 'پەیوەندی فریاکەوتن';

  @override
  String get mobile => 'مۆبایل';

  @override
  String get profileStatistics => 'ئامارەکان';

  @override
  String get accountDetails => 'وردەکاری هەژمار';

  @override
  String get appearanceAndPrivacy => 'ڕووکار و تایبەتمەندی';

  @override
  String get noActiveQueuesOnProfile => 'هیچ نۆرەیەکی چالاکت نییە. پزیشک بگەڕێ بۆ بەشداریکردن لە نۆرە.';

  @override
  String get noFavoriteDoctorsYet => 'هێشتا هیچ پزیشکی دڵخوازت نییە. لەسەر دڵ لە پڕۆفایلی پزیشک دابگرە.';

  @override
  String get notificationSystemSettings => 'سیستەمی ئاگادariی زیرەک';

  @override
  String get notificationSystemSettingsHint => 'کەناڵەکان، ئاستی ئاگادari و قالبە فرەزمانەکان';

  @override
  String get notificationChannels => 'کەناڵەکانی ئاگادari';

  @override
  String get pushNotificationsOwnerHint => 'push بنێرە کاتێک نەخۆش ئەپەکەی هەیە';

  @override
  String get whatsappNotifications => 'واتساپ';

  @override
  String get smsNotifications => 'SMS';

  @override
  String get smsNotificationsHint => 'پێویستی بە دابینکەری SMS هەیە (لە demo دا خەیاڵی)';

  @override
  String get inAppNotifications => 'ناو ئەپ';

  @override
  String get queueAlertThresholds => 'ئاستی ئاگادariی نۆر';

  @override
  String get queueAlertThresholdsHint => 'ئاگادari بنێرە کاتێک ئەم ژمارەیە ماوە پێش کاتەکەیان';

  @override
  String get notificationTemplates => 'قالبەکانی ئaگادari';

  @override
  String get notificationTemplatesHint => 'PatientName و DoctorName و DelayMinutes و AppointmentTime وەک جێگیر بەکاربهێنە';

  @override
  String get notificationType => 'جۆری ئaگادari';

  @override
  String get templateVariablesHint => 'دەقی قالب لەگەڵ جێگیرەکان';

  @override
  String get saveTemplate => 'پاشەکەوتکردنی قالب';

  @override
  String get templateSaved => 'قالب پاشەکەوت کرا';

  @override
  String get reminderNotifications => 'ئaگادariی بیرخستنەوە';

  @override
  String get reminderNotificationsHint => 'بیرخستنەوەی نۆر و چاوپێکەوتن';

  @override
  String get preferredNotificationLanguage => 'زمانی ئaگادari';

  @override
  String get followAppLanguage => 'شوێن زمانی ئەپ بکەوە';

  @override
  String get preferredNotificationMethod => 'ڕێگای پەسندکراوی گەیاندن';

  @override
  String get notificationMethodAutomatic => 'خۆکار (باشترین بەردەست)';

  @override
  String get sentBy => 'نێردراوە لەلایەن';

  @override
  String get notificationOpened => 'کراوەتەوە';

  @override
  String get deliveryPending => 'چاوەڕوان';

  @override
  String get deliverySent => 'نێردرا';

  @override
  String get deliveryDelivered => 'گەیشت';

  @override
  String get deliveryFailed => 'سەرکەوتوو نەبوو';

  @override
  String get deliverySkipped => 'پەڕێندراو';

  @override
  String get missedTurnNotification => 'کات لەدەستچوو';

  @override
  String get doctorDelayNotification => 'دواکەوتنی پزیشک';

  @override
  String get appointmentConfirmed => 'چاوپێکەوتن پشتڕاستکرایەوە';

  @override
  String get appointmentRescheduled => 'چاوپێکەوتن گۆڕدرا';

  @override
  String get appointmentCancelled => 'چاوپێکەوتن هەڵوەشێندرایەوە';

  @override
  String get doctorUnavailable => 'پزیشک بەردەست نییە';

  @override
  String get clinicClosedUnexpectedly => 'داخستنی چاوەڕواننەکراو';

  @override
  String get recallPatient => 'بانگهێشتکردنەوەی نەخۆش';

  @override
  String get moveToEndOfQueue => 'گواستنەوە بۆ کۆتایی';

  @override
  String get cancelAppointment => 'هەڵوەشاندنەوەی چاوپێکەوتن';

  @override
  String get patientRecalled => 'نەخۆش گەڕێندرایەوە بۆ نۆر';

  @override
  String get patientMovedToEnd => 'نەخۆش گواسترایەوە بۆ کۆتایی نۆر';

  @override
  String get notifyDoctorDelay => 'ئaگادariی دواکەوتن بۆ چاوەڕوانەکان';

  @override
  String get notifyDelayShort => 'ئaگادari دواکەوتن';

  @override
  String get delayMinutes => 'دواکەوتن (خولەک)';

  @override
  String get sendNotification => 'ناردن';

  @override
  String get delayNotificationSent => 'ئaگادari دواکەوتن نێردرا بۆ چاوەڕوانەکان';

  @override
  String get contactActionCall => 'پەیوەندی';

  @override
  String get contactActionWhatsApp => 'واتساپ';

  @override
  String get contactActionSms => 'SMS';

  @override
  String get chooseMessageTemplate => 'پەیامێک هەڵبژێرە';

  @override
  String get contactTemplateQueueReminder => 'سڵاو، کاتەکەت لە نۆر نزیکە. تکایە ئامادەبە بۆ هاتنە نۆرینگە.';

  @override
  String get contactTemplateYourTurn => 'سڵاو، ئێستا کاتەکەتە. تکایە بچۆ ژوورەوەی ژووری پزیشک.';

  @override
  String get contactTemplateAppointmentReminder => 'سڵاو، ئەمە بیرخستنەوەیە بۆ چاوپێکەوتنەکەت.';

  @override
  String get contactTemplateFollowUp => 'سڵاو، تکایە پەیوەندی بە نۆرینگەوە بکە سەبارەت بە سەردانەکەت.';

  @override
  String get contactTemplateCustom => 'پەیامێکی تایبەت بنووسە';

  @override
  String get searchPatientsHint => 'گەڕان بە ناو یان ژمارەی مۆبایل';

  @override
  String get communicationAuditLog => 'تۆماری پەیوەندی کارمەندان';

  @override
  String get noCommunicationLogs => 'هێشتا هیچ پەیوەندییەک تۆمار نەکراوە.';

  @override
  String get monitoringCenterTitle => 'ناوەندی تەندروستی سیستەم و چاودێری';

  @override
  String get monitoringCenterHint => 'دۆخی ڕاستەوخۆی پلاتفۆرم، شیکاری، ئاسایش و چاودێری ژێرخان';

  @override
  String get liveStatistics => 'ئامارە ڕاستەوخۆکان';

  @override
  String get usersSection => 'بەکارهێنەران';

  @override
  String get totalUsers => 'کۆی بەکارهێنەران';

  @override
  String get onlineUsers => 'بەکارهێنەرانی سەرهێڵ';

  @override
  String get activeDoctors => 'دکتۆرە چالاکەکان';

  @override
  String get suspendedDoctors => 'دکتۆرە ڕاگیراوەکان';

  @override
  String get onlineDoctors => 'دکتۆرانی سەرهێڵ';

  @override
  String get secretariesSection => 'سکرتێرەکان';

  @override
  String get onlineSecretaries => 'سکرتێرانی سەرهێڵ';

  @override
  String get recentSecretaries => 'سکرتێرە نوێ زیادکراوەکان';

  @override
  String get businessesSection => 'بازرگانییەکان';

  @override
  String get beautyCenters => 'ناوەندەکانی جوانکاری';

  @override
  String get laboratories => 'تاقیگەکان';

  @override
  String get pharmacies => 'دەرمانخانەکان';

  @override
  String get otherHealthcare => 'ناوەندەکانی تری تەندروستی';

  @override
  String get patientsSection => 'نەخۆشەکان';

  @override
  String get onlinePatients => 'نەخۆشانی سەرهێڵ';

  @override
  String get newPatientsToday => 'نەخۆشی نوێی ئەمڕۆ';

  @override
  String get completedQueuesToday => 'دورەکانی تەواوکراوی ئەمڕۆ';

  @override
  String get cancelledQueues => 'دورە هەڵوەشاوەکان';

  @override
  String get avgWaitingTime => 'ناوەندی کاتی چاوەڕوانی';

  @override
  String get todaysAppointments => 'چاوپێکەوتنەکانی ئەمڕۆ';

  @override
  String get missedAppointments => 'چاوپێکەوتنە لەدەستچووەکان';

  @override
  String get cancelledAppointments => 'چاوپێکەوتنە هەڵوەشاوەکان';

  @override
  String get firebaseMonitoring => 'چاودێری Firebase';

  @override
  String get firestoreReads => 'کردارەکانی خوێندنەوەی Firestore';

  @override
  String get firestoreWrites => 'کردارەکانی نووسینی Firestore';

  @override
  String get imageStorageUsage => 'بەکارهێنانی هەڵگرتنی وێنە';

  @override
  String get responseTime => 'کاتی وەڵامدانەوە';

  @override
  String get cacheStatus => 'دۆخی کاش';

  @override
  String get lastSynchronization => 'دوایین هاوکاتکردن';

  @override
  String get storageUsagePercent => 'بەکارهێنانی هەڵگرتن';

  @override
  String get cpuUsage => 'بەکارهێنانی CPU';

  @override
  String get memoryUsage => 'بەکارهێنانی بیرگە';

  @override
  String get avgApiResponse => 'ناوەندی کاتی وەڵامی API';

  @override
  String get slowQueries => 'پرسیارە هێواشەکان';

  @override
  String get backgroundTasks => 'ئەرکەکانی پاشخان';

  @override
  String get cachePerformance => 'کارایی کاش';

  @override
  String get notificationMonitoring => 'چاودێری ئاگادارکردنەوە';

  @override
  String get pushSent => 'ئاگادارکردنەوەی پوش نێردراو';

  @override
  String get whatsappSent => 'پەیامی واتساپ نێردراو';

  @override
  String get smsSent => 'پەیامی SMS نێردراو';

  @override
  String get failedNotifications => 'ئاگادارکردنەوەی شکستخواردوو';

  @override
  String get pendingNotifications => 'ئاگادارکردنەوەی چاوەڕوان';

  @override
  String get advertisementMonitoring => 'چاودێری ڕێکلام';

  @override
  String get activeAdvertisements => 'ڕێکلامە چالاکەکان';

  @override
  String get scheduledAdvertisements => 'ڕێکلامە خشتەبەندکراوەکان';

  @override
  String get expiredAdvertisements => 'ڕێکلامە بەسەرچووەکان';

  @override
  String get adViews => 'بینینی ڕێکلام';

  @override
  String get adClicks => 'کلیکی ڕێکلام';

  @override
  String get clickRate => 'ڕێژەی کلیک';

  @override
  String get revenueDashboard => 'داشبۆردی داهات';

  @override
  String get monthlyRevenue => 'داهاتی مانگانە';

  @override
  String get annualRevenue => 'داهاتی ساڵانە';

  @override
  String get activePackages => 'پاکێجە چالاکەکان';

  @override
  String get packagesExpiringSoon => 'پاکێجە بەمزوانە بەسەردەچن';

  @override
  String get renewalsToday => 'نوێکردنەوەکانی ئەمڕۆ';

  @override
  String get lockedAccounts => 'هەژمارە داخراوەکان';

  @override
  String get suspiciousLogins => 'چالاکی چوونەژوورەوەی گوماناوی';

  @override
  String get terminateSession => 'کۆتایی هێنان بە دانیشتن';

  @override
  String get errorMonitoring => 'چاودێری هەڵە';

  @override
  String get logsExported => 'لۆگەکان بۆ کلیپبۆرد هەناردە کران';

  @override
  String get exportLogs => 'هەناردەی لۆگ';

  @override
  String get markFixed => 'نیشانکردن وەک چارەسەرکراو';

  @override
  String get ignoreError => 'پشتگوێخستن';

  @override
  String get lastBackup => 'دوایین پاشەکەوت';

  @override
  String get backupSize => 'قەبارەی پاشەکەوت';

  @override
  String get backupStatus => 'دۆخی پاشەکەوت';

  @override
  String get nextScheduledBackup => 'پاشەکەوتی خشتەبەندکراوی داهاتوو';

  @override
  String get backupCompleted => 'پاشەکەوت بە سەرکەوتوویی تەواو بوو';

  @override
  String get restoreBackupHint => 'گەڕاندنەوەی پاشەکەوت لە بەرهەمهێناندا بەردەستە';

  @override
  String get restoreBackup => 'گەڕاندنەوەی پاشەکەوت';

  @override
  String get backupReportDownloaded => 'ڕاپۆرتی پاشەکەوت داونلۆد کرا';

  @override
  String get downloadBackupReport => 'داونلۆدی ڕاپۆرتی پاشەکەوت';

  @override
  String get liveActivityFeed => 'تۆمارکردنی چالاکی ڕاستەوخۆ';

  @override
  String get dailyRegistrations => 'تۆمارکردنی ڕۆژانە';

  @override
  String get dailyQueues => 'دورەی ڕۆژانە';

  @override
  String get dailyAppointments => 'چاوپێکەوتنی ڕۆژانە';

  @override
  String get adPerformance => 'کارایی ڕێکلام';

  @override
  String get activeUsersChart => 'بەکارهێنەرانی چالاک';

  @override
  String get businessGrowth => 'گەشەی بازرگانی';

  @override
  String get reportExportedCsv => 'ڕاپۆرت وەک CSV هەناردە کرا';

  @override
  String get enableMaintenanceMode => 'چالاککردنی دۆخی چاکسازی';

  @override
  String get maintenanceMessage => 'پەیامی چاکسازی';

  @override
  String get systemHealthy => 'تەندروست';

  @override
  String get systemWarning => 'ئاگاداری';

  @override
  String get systemCritical => 'گرنگ';

  @override
  String get filterToday => 'ئەمڕۆ';

  @override
  String get filterThisWeek => 'ئەم هەفتەیە';

  @override
  String get filterThisMonth => 'ئەم مانگە';

  @override
  String get filterThisYear => 'ئەم ساڵە';

  @override
  String get filterCustomRange => 'مەودای تایبەت';

  @override
  String reportExported(String format) {
    return 'ڕاپۆرت وەک $format هەناردە کرا';
  }

  @override
  String get dashboardCachedData => 'نیشاندانی داتای کاشکراوی داشبۆرد';

  @override
  String get dashboardLiveDataUnavailable => 'داتای ڕاستەوخۆ بۆ ماوەیەک بەردەست نییە';

  @override
  String get dashboardLastSync => 'دوایین هاوکاتکردن';

  @override
  String get dashboardRefreshNow => 'نوێکردنەوەی ئێستا';

  @override
  String get dashboardRefreshing => 'نوێدەکرێتەوە…';

  @override
  String get dashboardChartsLoading => 'چارتەکان بار دەکرێن…';

  @override
  String get showActivityFeed => 'نیشاندانی تۆماری چالاکی';

  @override
  String get showReports => 'نیشاندانی ڕاپۆرتەکان';

  @override
  String get showAuditLog => 'نیشاندانی تۆماری پشکنین';

  @override
  String get messageSeen => 'بینراو';

  @override
  String get attachImage => 'وێنە هاوپێچ بکە';

  @override
  String userIsTyping(String userName) {
    return '$userName دەنووسێت…';
  }

  @override
  String get metricNotAvailable => 'بەردەست نییە';

  @override
  String get monitoringPhase1Hint => 'تەندروستی ڕاستەوخۆی ژێرخان — Firebase، کارایی و ئاگادارییە زیرەکەکان';

  @override
  String get ownerSmartAlerts => 'ئاگادارییە زیرەکەکانی خاوەن';

  @override
  String get noActiveAlerts => 'هیچ ئاگادارییەکی چالاکی ژێرخان نییە. هەموو سیستەمەکان بە شێوەیەکی ئاسایی کاردەکەن.';

  @override
  String get alertFirebaseDisconnected => 'Firebase پچڕاوە';

  @override
  String get alertBackupFailed => 'دوایین پاشەکەوت شکستی هێنا';

  @override
  String alertStorageHigh(String percent) {
    return 'بەکارهێنانی هەڵگرتن لە $percent%';
  }

  @override
  String get alertSlowResponse => 'کاتی وەڵامی API بەرز دۆزرایەوە';

  @override
  String get alertHighErrorRate => 'ڕێژەی بەرزی هەڵە دۆزرایەوە';

  @override
  String get alertPackageExpiresToday => 'پاکێجی بەشداریکردن ئەمڕۆ یان بەم نزیکانە بەسەردەچێت';

  @override
  String get alertNotificationServiceFailed => 'خزمەتگوزاری ئاگادارکردنەوە سەرکەوتوو نەبوو';

  @override
  String get systemHealthCardTitle => 'تەندروستی سیستەم';

  @override
  String get autoRefreshInterval => 'نوێکردنەوەی خۆکار';

  @override
  String autoRefreshSeconds(int seconds) {
    return 'هەر $seconds چ';
  }

  @override
  String get firebaseUsageWarningsTitle => 'ئاگاداری بەکارهێنانی Firebase';

  @override
  String firebaseUsageWarningReads(int count) {
    return 'خوێندنەوەی Firestore بەرزە ($count) — پێوانەی کۆکراو بەکاربهێنە';
  }

  @override
  String firebaseUsageWarningWrites(int count) {
    return 'نووسینی Firestore بەرزە ($count) — نوێکردنەوەکان کۆبکەرەوە';
  }

  @override
  String firebaseUsageWarningStorage(int percent) {
    return 'بەکارهێنانی کۆگا $percent% — پاککردنەوە یان بەرزکردنەوە';
  }

  @override
  String get monitoringPhase2Hint => 'ئامارە ڕاستەوخۆکانی پلاتفۆرم — هەر 60 چرکە جارێک لە ئامارە کۆکراوەکان نوێدەبێتەوە';

  @override
  String get activityFilterLastHour => 'کاتژمێری ڕابردوو';

  @override
  String get activityFilterAll => 'هەموو';

  @override
  String get activeToday => 'چالاک ئەمڕۆ';

  @override
  String get newRegistrationsToday => 'تۆمارکردنی نوێ ئەمڕۆ';

  @override
  String get secretariesWithoutDoctor => 'سکرتێر بەبێ پزیشک';

  @override
  String get waitingPatients => 'نەخۆشانی چاوەڕوان';

  @override
  String get expiredPackages => 'پاکێجە بەسەرچووەکان';

  @override
  String get cancelledQueuesToday => 'هەڵوەشاوە ئەمڕۆ';

  @override
  String get clinicsStat => 'کلینیکەکان';

  @override
  String get queuesSection => 'ڕیزەکان';

  @override
  String get appointmentsSection => 'چاوپێکەوتنەکان';

  @override
  String get noActivityEvents => 'هیچ ڕووداوێکی چالاکی بۆ ماوەی هەڵبژێردراو نییە';

  @override
  String waitingMinutesLabel(int minutes) {
    return '$minutes خولەک';
  }

  @override
  String get activityEventDoctorCreated => 'پزیشک دروستکرا';

  @override
  String get activityEventDoctorUpdated => 'پزیشک نوێکرایەوە';

  @override
  String get activityEventSecretaryAdded => 'سکرتێر زیادکرا';

  @override
  String get activityEventPatientRegistered => 'نەخۆش تۆمارکرا';

  @override
  String get activityEventBusinessCreated => 'بزنس دروستکرا';

  @override
  String get activityEventQueueJoined => 'بەشداری لە ڕیز';

  @override
  String get activityEventQueueCancelled => 'ڕیز هەڵوەشێنرایەوە';

  @override
  String get activityEventAppointmentBooked => 'چاوپێکەوتن حجزکرا';

  @override
  String get activityEventAppointmentCancelled => 'چاوپێکەوتن هەڵوەشێنرایەوە';

  @override
  String get activityEventAdvertisementCreated => 'ڕیکلام دروستکرا';

  @override
  String get activityEventPackageActivated => 'پاکێج چالاککرا';

  @override
  String get activityEventPackageRenewed => 'پاکێج نوێکرایەوە';

  @override
  String get activityEventLogin => 'چوونەژوورەوە';

  @override
  String get activityEventLogout => 'چوونەدەرەوە';

  @override
  String get monitoringPhase3AnalyticsHint => 'شیکاری کارا — چارتەکان بە شێوەی lazy بار دەکرێن و بەپێی ماوە هەڵدەگیرێن';

  @override
  String get filterYesterday => 'دوێنێ';

  @override
  String get filterLast7Days => '7 ڕۆژی ڕابردوو';

  @override
  String get doctorGrowthChart => 'گەشەی پزیشکان';

  @override
  String get queueWaitingTrends => 'ڕەوتی چاوەڕوانی ڕیز';

  @override
  String get todaysRevenue => 'داهاتی ئەمڕۆ';

  @override
  String get avgRevenuePerDoctor => 'ناوەندی داهات بۆ هەر پزیشک';

  @override
  String get advertisementRevenue => 'داهاتی ڕیکلام';

  @override
  String get lockedStatus => 'داخراو';

  @override
  String get lockUser => 'داخستنی بەکارهێنەر';

  @override
  String get unlockUser => 'کردنەوەی قوفڵی بەکارهێنەر';

  @override
  String get forceLogout => 'دەرچوونی ناچار';

  @override
  String get errorTypeLabel => 'جۆری هەڵە';

  @override
  String get stackTrace => 'شوێنپێی کۆد';

  @override
  String get deleteError => 'سڕینەوە';

  @override
  String get runManualBackup => 'پاشەکەوتی دەستی';

  @override
  String get backupHistory => 'مێژووی پاشەکەوت';

  @override
  String get auditSearchHint => 'گەڕان لە تۆماری پشکنین…';

  @override
  String get generateReports => 'دروستکردنی ڕاپۆرت';

  @override
  String get reportsFilterHint => 'ماوەیەک هەڵبژێرە، پاشان ئامارەکان هەناردە بکە';

  @override
  String get aiInsightsCenter => 'ناوەندی زیرەکی تێڕوانین';

  @override
  String get aiInsightsHint => 'پێشنیارە خۆکارەکان لە ئامارە کۆکراوەکان';

  @override
  String get priorityHigh => 'گرنگی بەرز';

  @override
  String get priorityMedium => 'گرنگی مامناوەند';

  @override
  String get priorityLow => 'گرنگی نزم';

  @override
  String get forecastDashboard => 'داشبۆردی پێشبینی';

  @override
  String get forecastNext7Days => '7 ڕۆژی داهاتوو';

  @override
  String get forecastNextMonth => 'مانگی داهاتوو';

  @override
  String get forecastNextYear => 'ساڵی داهاتوو';

  @override
  String get smartOwnerNotifications => 'ئاگادارییە زیرەکەکانی خاوەن';

  @override
  String get markAsRead => 'نیشانکردن وەک خوێندراو';

  @override
  String get archiveNotification => 'ئارکایڤ';

  @override
  String get firebaseCostOptimizer => 'باشترکەری تێچووی Firebase';

  @override
  String get estimatedMonthlyCost => 'تێچووی مانگانەی خەمڵاندراو';

  @override
  String get bandwidthUsage => 'بەکارهێنانی پانی باند';

  @override
  String get optimizationSuggestions => 'پێشنیارەکانی باشترکردن';

  @override
  String get globalSearchHint => 'گەڕان بۆ پزیشک، نەخۆش، بزنس، ڕیکلام، تۆماری پشکنین…';

  @override
  String get globalDashboardFilters => 'فلتەرە گشتییەکانی داشبۆرد';

  @override
  String get clearFilters => 'سڕینەوەی فلتەرەکان';

  @override
  String get filterByCity => 'شار';

  @override
  String get filterByBusiness => 'بزنس';

  @override
  String get filterByDoctor => 'پزیشک';

  @override
  String get filterByStatus => 'دۆخ';

  @override
  String get statusActive => 'چالاک';

  @override
  String get statusSuspended => 'هەڵواسراو';

  @override
  String filterScaleHint(String percent) {
    return 'نیشاندانی ~$percent% ئامارەکانی پلاتفۆرم بۆ فلتەرە هەڵبژێردراوەکان';
  }

  @override
  String get themeAndAppearance => 'ڕووکار و دیمەن';

  @override
  String get themeAppearanceHint => 'دیمەنی ناوەندی چاودێری بەکەسیکەرە';

  @override
  String get lightMode => 'ڕووناک';

  @override
  String get darkMode => 'تاریک';

  @override
  String get systemMode => 'سیستەم';

  @override
  String get accentColor => 'ڕەنگی تیشک';

  @override
  String get cardDensity => 'چڕی کارتی';

  @override
  String get compactMode => 'کۆمپاکت';

  @override
  String get comfortableMode => 'ئاسوودە';

  @override
  String get dashboardLayout => 'شێوازی داشبۆرد';

  @override
  String get layoutStandard => 'ستاندارد';

  @override
  String get layoutWide => 'پان';

  @override
  String get layoutFocused => 'ناوەندی';

  @override
  String get advancedSystemSettings => 'ڕێکخستنە پێشکەوتووەکانی سیستەم';

  @override
  String get useAggregatedMetrics => 'بەکارهێنانی بەڵگەی ئامارە کۆکراوەکان';

  @override
  String get warnBeforeExpensiveOps => 'ئاگادارکردنەوە پێش کارە گرانەکان';

  @override
  String get queueRealtimeEnabled => 'نوێکردنەوەی ڕاستەوخۆی ڕیز';

  @override
  String get autoCleanupListeners => 'پاککردنەوەی گوێگرە بەجێماوەکان';

  @override
  String get cityTargeting => 'ڕیکلامی ئامانجدار بە شار';

  @override
  String get renewalReminders => 'ئاگاداری نوێکردنەوەی پاکێج';

  @override
  String get autoBackup => 'پاشەکەوتی خۆکار';

  @override
  String get superOwner => 'سوپەر خاوەن';

  @override
  String get superOwnerDashboard => 'داشبۆردی سوپەر خاوەن';

  @override
  String get superOwnerDashboardHint => 'چاودێری هەموو ڕێکخراوەکان، داهاتی پلاتفۆرم و پلانی بەشداریکردن.';

  @override
  String get totalOrganizations => 'کۆی ڕێکخراوەکان';

  @override
  String get activeOrganizations => 'ڕێکخراوە چالاکەکان';

  @override
  String get suspendedOrganizations => 'ڕێکخراوە هەڵواسراوەکان';

  @override
  String get platformRevenue => 'داهاتی پلاتفۆرم';

  @override
  String get firebaseUsage => 'بەکارهێنانی Firebase';

  @override
  String get createOrganization => 'دروستکردنی ڕێکخراو';

  @override
  String get suspendOrganization => 'هەڵواسینی ڕێکخراو';

  @override
  String get deleteOrganization => 'سڕینەوەی ڕێکخراو';

  @override
  String get organizationName => 'ناوی ڕێکخراو';

  @override
  String get organizationSettings => 'ڕێکخستنەکانی ڕێکخراو';

  @override
  String get organizationSettingsHint => 'بەکەسیکردنی براند، زمان و یاساکان بۆ ڕێکخراوەکەت.';

  @override
  String get organizationBilling => 'وەسڵی ڕێکخراو';

  @override
  String get organizationBillingHint => 'پلان، سنوورەکانی بەکارهێنان و مێژووی پارەدان ببینە.';

  @override
  String get currentPlan => 'پلانی ئێستا';

  @override
  String get expirationDate => 'بەرواری بەسەرچوون';

  @override
  String get usageLimits => 'سنوورەکانی بەکارهێنان';

  @override
  String get upgradePlan => 'بەرزکردنەوەی پلان';

  @override
  String get paymentHistory => 'مێژووی پارەدان';

  @override
  String get whiteLabelReady => 'ئارکیتێکتور پشتگیری ئەپەکانی Android و iOS و Web بە براندی هەر ڕێکخراوێک دەکات لەسەر هەمان backend.';

  @override
  String get organizationCreated => 'ڕێکخراو دروستکرا';

  @override
  String get organizationSuspended => 'دۆخی ڕێکخراو نوێکرایەوە';

  @override
  String get organizationDeleted => 'ڕێکخراو سڕایەوە';

  @override
  String get globalStatistics => 'ئامارە گشتییەکان';

  @override
  String get manageOrganizations => 'بەڕێوەبردنی ڕێکخراوەکان';

  @override
  String get planTrial => 'تاقیکردنەوە';

  @override
  String get planMonthly => 'مانگانە';

  @override
  String get planAnnual => 'ساڵانە';

  @override
  String get planEnterprise => 'Enterprise';

  @override
  String get cancelLabel => 'پاشگەزبوونەوە';

  @override
  String get activate => 'چالاککردن';

  @override
  String get noDataAvailable => 'هیچ داتایەک نییە';

  @override
  String get primaryColor => 'ڕەنگی سەرەکی';

  @override
  String get branding => 'براند';

  @override
  String get rulesAndHours => 'یاسا و کاتژمێرەکان';

  @override
  String get queueRules => 'یاساکانی ڕیز';

  @override
  String get appointmentRules => 'یاساکانی چاوپێکەوتن';

  @override
  String get offlineMode => 'Offline';

  @override
  String get offlineModeHint => 'Offline — داتای پاشەکەوتکراو پیشان دەدرێت. کاتێک پەیوەندی گەڕایەوە هاوکات دەبێت.';

  @override
  String get offlineQueueHint => 'دوایین دۆخی ڕیز (offline)';

  @override
  String get syncingData => 'هاوکاتکردن…';

  @override
  String get searchMedicine => 'گەڕان بۆ دەرمان (ناوی گشتی یان بازرگانی)';

  @override
  String get dosage => 'ژەمە';

  @override
  String get frequency => 'دووبارەبوونەوە';

  @override
  String get duration => 'ماوە';

  @override
  String get lineNotesOptional => 'تێبینی زیادە (ئارەزوومەندانە)';

  @override
  String get favoriteMedicines => 'دەرمانە دڵخوازەکان';

  @override
  String get searchResults => 'ئەنجامەکانی گەڕان';

  @override
  String get addFavorite => 'زیادکردن بۆ دڵخواز';

  @override
  String get removeFavorite => 'لابردن لە دڵخواز';

  @override
  String get printPrescription => 'چاپکردنی ڕەچەتە';

  @override
  String get savePrescription => 'پاشەکەوتکردنی ڕەچەتە';

  @override
  String get printPrescriptionHint => 'ئارەزوومەندانە — دەقی ڕەچەتە کۆپی بکە بۆ هاوبەشکردن یان چاپ.';

  @override
  String get copyPrescription => 'کۆپی ڕەچەتە';

  @override
  String get copiedToClipboard => 'کۆپی کرا';

  @override
  String get prescriptionLines => 'ڕەچەتە';

  @override
  String get addMedicine => 'زیادکردنی دەرمان';

  @override
  String get updateLine => 'نوێکردنەوە';

  @override
  String get myPrescriptions => 'ڕەچەتەکانم';

  @override
  String get noPrescriptionsYet => 'هێشتا ڕەچەتە نییە';

  @override
  String get prescriptionAutoSaved => 'ڕەچەتە خۆکارانە پاشەکەوت کرا';

  @override
  String prescriptionMedicineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دەرمان',
      one: '1 دەرمان',
    );
    return '$_temp0';
  }

  @override
  String prescriptionRecordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ڕەچەتە',
      one: '1 ڕەچەتە',
    );
    return '$_temp0';
  }

  @override
  String get date => 'بەروار';

  @override
  String get requestInvestigation => 'داواکردنی پشکنین';

  @override
  String get searchInvestigation => 'گەڕان بۆ پشکنینی تاقیگە یان وێنەگرتن';

  @override
  String get requestedInvestigations => 'پشکنینە داواکراوەکان';

  @override
  String get investigationNote => 'تێبینی';

  @override
  String get investigationNoteHint => 'تێبینی ئارەزوومەندانە بۆ ئەم پشکنینە';

  @override
  String get investigationCategoryLaboratory => 'تاقیگە';

  @override
  String get investigationCategoryRadiology => 'تیشک';

  @override
  String get investigationCategoryCardiology => 'دڵ';

  @override
  String get investigationCategoryUltrasound => 'ئەلتراساوند';

  @override
  String get investigationCategoryOther => 'هیتر';

  @override
  String get pendingInvestigations => 'پشکنینە چاوەڕوانەکان';

  @override
  String andMoreInvestigations(int count) {
    return '+$count زیاتر';
  }

  @override
  String get myInvestigations => 'پشکنینەکانم';

  @override
  String get noPendingInvestigations => 'هیچ پشکنینێکی چاوەڕوان نییە';

  @override
  String investigationRequestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پشکنین',
      one: '1 پشکنین',
    );
    return '$_temp0';
  }

  @override
  String pendingInvestigationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پشکنینی چاوەڕوان',
      one: '1 پشکنینی چاوەڕوان',
    );
    return '$_temp0';
  }

  @override
  String get patientReturnedForReview => 'گەڕاوەتەوە بۆ پێداچوونەوە — ئەنجامی پشکنین ئامادەیە';

  @override
  String get inDoctorRoom => 'لە ژووری دکتۆر';

  @override
  String get patientReady => 'نەخۆش ئامادەیە';

  @override
  String get patientNotArrived => 'نەگەیشتووە';

  @override
  String get patientReadyForConsultation => 'ئامادەیە بۆ پشکنین';

  @override
  String get patientInsideDoctorRoom => 'لە ژووری دکتۆردایە';

  @override
  String get callToDoctorRoom => 'بانگکردن';

  @override
  String get markAsWaiting => 'نیشانکردن بە چاوەڕوان';

  @override
  String get editPatientInfo => 'دەستکاری نەخۆش';

  @override
  String get patientInfoUpdated => 'زانیاری نەخۆش نوێکرایەوە';

  @override
  String patientsInQueue(int count) {
    return '$count لە ڕیز';
  }

  @override
  String get addToQueue => 'زیادکردن بۆ ڕیز';

  @override
  String get addToQueueAfterRegister => 'خۆکار زیاد بکە بۆ ڕیزی ئەمڕۆ';

  @override
  String get searchExistingPatients => 'نەخۆشە تۆمارکراوەکان';

  @override
  String get alreadyInQueue => 'نەخۆش پێشتر لە ڕیزی ئەمڕۆیە';

  @override
  String get addedToQueue => 'زیادکرا بۆ ڕیز';

  @override
  String get noSearchResults => 'هیچ ئەنجامێک نییە';

  @override
  String get todayVisit => 'سەردانی ئەمڕۆ';

  @override
  String get todayAppointment => 'چاوپێکەوتنی ئەمڕۆ';

  @override
  String get noVisitToday => 'هیچ سەردانێک بۆ ئەمڕۆ دانەنراوە';

  @override
  String get viewQueueDetails => 'وردەکاری ڕیز ببینە';

  @override
  String get medicalRecords => 'تۆمارە پزیشکییەکان';

  @override
  String get medicalRecordsHint => 'ڕەچەتە و پشکنین و تێبینی دکتۆرەکەت';

  @override
  String get currentPrescription => 'ڕەچەتەی ئێستا';

  @override
  String get previousPrescriptions => 'ڕەچەتەی پێشوو';

  @override
  String get diagnosisHistory => 'مێژووی دەستنیشانکردن';

  @override
  String get investigationRequests => 'داواکاری پشکنین';

  @override
  String get investigationResults => 'ئەنجامی پشکنین';

  @override
  String get sharedClinicalNotes => 'تێبینییە پزیشکییەکان';

  @override
  String get noDiagnosisHistory => 'هێشتا مێژووی دەستنیشانکردن نییە';

  @override
  String get noClinicalNotesShared => 'دکتۆرەکەت هیچ تێبینییەکی پزیشکی بڵاونەکردووەتەوە';

  @override
  String get investigationStatusPending => 'چاوەڕوان';

  @override
  String get investigationStatusCompleted => 'تەواو';

  @override
  String get noCompletedInvestigations => 'هێشتا پشکنینی تەواوکراو نییە';

  @override
  String get noInvestigationsYet => 'هێشتا پشکنین نییە';

  @override
  String get downloadPdf => 'داگرتنی PDF';

  @override
  String get all => 'هەموو';

  @override
  String get pending => 'چاوەڕوان';

  @override
  String get patientSummary => 'پوختەی نەخۆش';

  @override
  String get printDocument => 'چاپکردن';

  @override
  String get prescriptionMedicineCopy => 'ڕەچەتەی دەرمان';

  @override
  String get prescriptionBosoleCopy => 'بۆسۆڵە';

  @override
  String get printInvestigationRequest => 'چاپکردنی داواکاری پشکنین';

  @override
  String get clinicalAdministration => 'بەڕێوەبردنی پزیشکی';

  @override
  String get clinicalAdministrationHint => 'داتابەیسی دەرمان و پشکنین، یاساکانی ڕیز، و قاڵبی ڕەچەتە';

  @override
  String get medicineDatabase => 'داتابەیسی دەرمان';

  @override
  String get medicineDatabaseHint => 'دروستکردن، دەستکاری، و ئەرشیفکردنی دەرمان بۆ ڕەچەتە';

  @override
  String get investigationDatabase => 'داتابەیسی پشکنین';

  @override
  String get investigationDatabaseHint => 'بەڕێوەبردنی پشکنینی تاقیگە و تیشک';

  @override
  String get prescriptionSettings => 'ڕێکخستنی ڕەچەتە';

  @override
  String get prescriptionSettingsHint => 'سەرپەڕ، پێنووس، و قاڵبی چاپی ڕەچەتە';

  @override
  String get queueSettingsHint => 'ژمارەکردنی ڕیز، ماوەی ڕاوێژ، و یاساکانی پیشاندان';

  @override
  String get genericName => 'ناوی گشتی';

  @override
  String get brandNames => 'ناوی بازرگانی (بە کۆما جیاکراوە)';

  @override
  String get strength => 'توندی';

  @override
  String get dosageForm => 'شێوەی دۆز';

  @override
  String get category => 'پۆل';

  @override
  String get archiveItem => 'ئەرشیف';

  @override
  String get restoreItem => 'گەڕاندنەوە';

  @override
  String get showArchived => 'ئەرشیفکراو پیشان بدە';

  @override
  String get activeOnly => 'تەنها چالاک';

  @override
  String get noMedicinesInDatabase => 'هێشتا دەرمانی تایبەت نییە. + بکە بۆ زیادکردن.';

  @override
  String get noInvestigationsInDatabase => 'هێشتا پشکنینی تایبەت نییە. + بکە بۆ زیادکردن.';

  @override
  String get addInvestigation => 'پشکنین زیاد بکە';

  @override
  String get investigationName => 'ناوی پشکنین';

  @override
  String get searchInvestigations => 'گەڕان لە پشکنین';

  @override
  String get consultationDurationDefault => 'ماوەی بنەڕەتی ڕاوێژ';

  @override
  String get autoAssignQueueNumbers => 'ژمارەی ڕیز خۆکار دابنێ';

  @override
  String get autoAssignQueueNumbersHint => 'ڕیز خۆکار ژمارەی داهاتوو وەردەگرێت';

  @override
  String get queueStartNumber => 'ژمارەی دەستپێکی ڕیز';

  @override
  String get showCompletedInQueue => 'تەواوکراوەکان لە ڕیزی سکرتێر پیشان بدە';

  @override
  String get prescriptionHeaderClinicName => 'سەرپەڕی ڕەچەتە — ناوی کلینیک';

  @override
  String get prescriptionHeaderAddress => 'سەرپەڕی ڕەچەتە — ناونیشان';

  @override
  String get prescriptionHeaderPhone => 'سەرپەڕی ڕەچەتە — تەلەفۆن';

  @override
  String get prescriptionFooterNote => 'تێبینی پێنووسی ڕەچەتە';

  @override
  String get prescriptionShowDiagnosis => 'دەستنیشانکردن لە ڕەچەتەی چاپکراودا پیشان بدە';

  @override
  String get departments => 'بەشەکان';

  @override
  String get consultationRooms => 'ژووری ڕاوێژ';

  @override
  String get addDepartment => 'بەش زیاد بکە';

  @override
  String get addRoom => 'ژوور زیاد بکە';

  @override
  String get clinicStructure => 'بەش و ژووری ڕاوێژ';

  @override
  String get mergePatients => 'یەکخستنی نەخۆش';

  @override
  String get mergePatientsHint => 'هەژماری دووبارە ناچالاک دەکرێت. تۆمارە پزیشکییەکان بە دەست پشکنین بکە.';

  @override
  String get selectPrimaryPatient => 'ئەم نەخۆشە بهێڵەوە';

  @override
  String get selectDuplicatePatient => 'یەکبخە و دووبارە ناچالاک بکە';

  @override
  String get patientsMerged => 'نەخۆشی دووبارە ناچالاک کرا';

  @override
  String get searchPatients => 'گەڕان بە ناو، تەلەفۆن، یان ئیمەیڵ';

  @override
  String get activePatients => 'چالاک';

  @override
  String get disabledPatients => 'ناچالاک';

  @override
  String get noPatientsFound => 'هیچ نەخۆشێک نەدۆزرایەوە';

  @override
  String get firebaseConfiguration => 'ڕێکخستنی Firebase';

  @override
  String get firebaseConfigurationHint => 'چاودێری بەکارهێنان و تەندروستی پەیوەندی Firebase';

  @override
  String get printerSettings => 'ڕێکخستنی چاپکەر';

  @override
  String get printerSettingsHint => 'سەرپەڕ و شێوازی چاپی ڕەچەتە';

  @override
  String get backupSettings => 'ڕێکخستنی پاشەکەوت';

  @override
  String get auditLogHint => 'مێژووی چالاکی نەگۆڕدراو — تەنها بۆ ژمارداری و ئاسایش.';

  @override
  String get auditTotalEvents => 'کۆی ڕووداوەکان';

  @override
  String get auditToday => 'ئەمڕۆ';

  @override
  String get auditLastSevenDays => '7 ڕۆژی ڕابردوو';

  @override
  String get auditModule => 'مۆدیول';

  @override
  String get auditModuleAuth => 'دڵنیاکردنەوە';

  @override
  String get auditModuleOwner => 'خاوەن';

  @override
  String get auditModuleSecretary => 'سکرتێر';

  @override
  String get auditModuleDoctor => 'دکتۆر';

  @override
  String get auditModulePatient => 'نەخۆش';

  @override
  String get auditModuleSystem => 'سیستەم';

  @override
  String get filterByDate => 'مەودای بەروار';

  @override
  String get exportPdf => 'هەناردەی PDF';

  @override
  String get exportExcel => 'هەناردەی Excel';

  @override
  String get exportCsv => 'هەناردەی CSV';

  @override
  String get role => 'ڕۆڵ';

  @override
  String get action => 'کردار';

  @override
  String get totalBackupCount => 'کۆی پاشەکەوت';

  @override
  String get latestRestoreDate => 'دوایین گەڕاندنەوە';

  @override
  String get openBackupDashboard => 'کردنەوەی داشبۆردی پاشەکەوت';

  @override
  String get noBackupsYet => 'هێشتا پاشەکەوت نییە.';

  @override
  String get backupFailed => 'پاشەکەوت سەرنەکەوت';

  @override
  String get backupType => 'جۆری پاشەکەوت';

  @override
  String get createdBy => 'دروستکراوە لەلایەن';

  @override
  String get downloadBackup => 'داگرتنی پاشەکەوت';

  @override
  String get backupDownloaded => 'پاشەکەوت داونلود کرا';

  @override
  String get backupCorrupted => 'پاشەکەوت تێکچووە یان ناگونجێت';

  @override
  String get confirmRestoreTitle => 'دڵنیاکردنەوەی گەڕاندنەوە';

  @override
  String confirmRestoreMessage(String size) {
    return 'گەڕاندنەوەی پاشەکەوت ($size)؟ پێویست بە ڕەزامەندی خاوەنە.';
  }

  @override
  String get restoreCompleted => 'گەڕاندنەوە تەواو بوو';

  @override
  String get restoreFailed => 'گەڕاندنەوە سەرنەکەوت';

  @override
  String get restoreInProgress => 'گەڕاندنەوە لە جێبەجێکردندایە';

  @override
  String get recoverLatestBackup => 'گەڕاندنەوە لە کۆتا پاشەکەوتی تەندروست';

  @override
  String get allergies => 'هەستیاری';

  @override
  String get noAllergiesRecorded => 'هیچ هەستیارییەک تۆمار نەکراوە';

  @override
  String get age => 'تەمەن';

  @override
  String get ageNotRecorded => 'تۆمار نەکراوە';

  @override
  String get completedToday => 'تەواوکراو ئەمڕۆ';

  @override
  String get activeQueueSection => 'نەخۆشە چالاکەکان';

  @override
  String get consultationWorkspace => 'ڕاوێژکاری';

  @override
  String get genderLabel => 'ڕەگەز';

  @override
  String get queueStatusInside => 'لەناو';

  @override
  String get arrivalTime => 'کاتی گەیشتن';

  @override
  String get searchQueueHint => 'گەڕان بە ناو یان ژمارەی نۆر';
}
