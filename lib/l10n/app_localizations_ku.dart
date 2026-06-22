import 'app_localizations.dart';

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([super.locale = 'ku']);

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
  String get adminDashboard => 'داشبۆردی بەڕێوەبەر';

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
  String get photoUploadHint => 'وێنەیەک لە ئامێرەکەت هەڵبژێرە، یان بەستەر لە خوارەوە بنووسە';

  @override
  String get orPastePhotoUrl => 'یان بەستەری وێنە بنووسە';

  @override
  String get photoTooLarge => 'وێنەکە زۆر گەورەیە (زۆرترین 512 KB)';

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
  String get dayMonday => 'دووش';

  @override
  String get dayTuesday => 'سێش';

  @override
  String get dayWednesday => 'چوار';

  @override
  String get dayThursday => 'پێنج';

  @override
  String get dayFriday => 'هەینی';

  @override
  String get daySaturday => 'شەم';

  @override
  String get daySunday => 'یەک';

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
  String get clinicPhotosHint => 'بەستەری وێنەکان بە فاریزە جیا بکەرەوە';

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
  String get queueStatusInDoctorRoom => 'لە ژووری دکتۆر';

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
}
