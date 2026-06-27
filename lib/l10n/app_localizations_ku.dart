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
  String get yourTurn => 'ئێستا نۆرەی تۆیە!';

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
  String get addSpecialty => 'بوار زیاد بکە';

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
  String get adminControlPanelHint => 'بەڕێوەبردنی دکتۆر، سکرتێر، نۆرینگە و بەشداریکردن';

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
  String get adminDoctorSearchHint => 'ناو، بوار، نۆرینگە، مۆبایل یان ئیمەیڵ...';

  @override
  String get doctorInformation => 'زانیاری دکتۆر';

  @override
  String get assignedSecretaries => 'سکرتێرە دیاریکراوەکان';

  @override
  String secretariesCount(int count) {
    return '$count سکرتێر';
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
}
