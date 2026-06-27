import 'app_localizations.dart';

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Tabib';

  @override
  String get appSubtitle => 'ابحث عن طبيب، احجز موعداً، راقب صحتك';

  @override
  String get patientApp => 'تطبيق المريض';

  @override
  String get patientAppSubtitle => 'احجز دورك وتابع موقعك';

  @override
  String get staffApp => 'تطبيق الطبيب والسكرتير';

  @override
  String get staffAppSubtitle => 'إدارة الدور والمرضى';

  @override
  String get adminApp => 'لوحة الإدارة';

  @override
  String get adminAppSubtitle => 'إدارة العيادات والأطباء والموظفين';

  @override
  String get patientLogin => 'تسجيل دخول المريض';

  @override
  String get staffLogin => 'تسجيل دخول الموظف';

  @override
  String get adminLogin => 'تسجيل دخول المدير';

  @override
  String get loginPromptPatient => 'أدخل اسمك ورقم هاتفك للبدء';

  @override
  String get loginPromptStaff => 'سجّل الدخول بحساب الموظف';

  @override
  String get loginPromptAdmin => 'سجّل الدخول ببيانات المدير';

  @override
  String get patientName => 'اسم المريض';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailOptional => 'البريد الإلكتروني (اختياري)';

  @override
  String get phoneOptional => 'رقم الهاتف (اختياري)';

  @override
  String get accountLoginMethod => 'طريقة تسجيل الدخول';

  @override
  String get emailOrPhone => 'البريد الإلكتروني أو رقم الهاتف';

  @override
  String get emailOrPhoneHint => 'أدخل بريدك الإلكتروني أو رقم هاتفك';

  @override
  String get phoneInUse => 'رقم الهاتف مسجل مسبقاً';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get invalidPhone => 'رقم الهاتف غير صحيح';

  @override
  String get invalidCredentials => 'البريد أو كلمة المرور غير صحيحة';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get invalidEmail => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String get invalidName => 'أدخل اسمك الكامل';

  @override
  String welcomeUser(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get noActiveQueue => 'لا يوجد دور نشط';

  @override
  String get bookQueueHint => 'اختر طبيباً واحجز دوراً';

  @override
  String get medicalSpecialties => 'التخصصات الطبية';

  @override
  String get searchDoctors => 'البحث عن أطباء';

  @override
  String get searchHint => 'اسم الطبيب، التخصص، العيادة...';

  @override
  String get myQueue => 'دوري';

  @override
  String get queueNumber => 'رقم الدور';

  @override
  String get peopleAhead => 'أمامك';

  @override
  String get waitTime => 'وقت الانتظار';

  @override
  String minutesShort(int minutes) {
    return '~$minutes دقيقة';
  }

  @override
  String get doctor => 'طبيب';

  @override
  String get specialty => 'التخصص';

  @override
  String get clinic => 'العيادة';

  @override
  String get location => 'الموقع';

  @override
  String get address => 'العنوان';

  @override
  String get phone => 'الهاتف';

  @override
  String get inQueue => 'في الدور';

  @override
  String get available => 'متاح';

  @override
  String get unavailable => 'غير متاح';

  @override
  String yearsExperience(int years) {
    return '$years سنوات خبرة';
  }

  @override
  String get info => 'معلومات';

  @override
  String get clinicLocationGps => 'موقع العيادة (GPS)';

  @override
  String get bookQueue => 'احجز دوراً';

  @override
  String get alreadyHasQueue => 'لديك دور نشط بالفعل';

  @override
  String bookSuccess(int number) {
    return 'تم الحجز! الرقم: $number';
  }

  @override
  String get bookFailed => 'تعذر الحجز';

  @override
  String get details => 'التفاصيل';

  @override
  String get currentQueue => 'الدور الحالي';

  @override
  String get yourTurn => 'دورك الآن!';

  @override
  String get waiting => 'في الانتظار';

  @override
  String get completed => 'مكتمل';

  @override
  String get cancelQueue => 'إلغاء';

  @override
  String get queueCancelled => 'تم إلغاء الدور';

  @override
  String get openGoogleMaps => 'فتح في Google Maps';

  @override
  String get gpsDirections => 'اتجاهات GPS';

  @override
  String distanceKm(String km) {
    return 'المسافة: $km كم';
  }

  @override
  String get noDoctorsFound => 'لم يتم العثور على أطباء';

  @override
  String get doctorApp => 'تطبيق الطبيب';

  @override
  String get secretaryApp => 'تطبيق السكرتير';

  @override
  String get roleDoctor => 'طبيب';

  @override
  String get roleSecretary => 'سكرتير';

  @override
  String get roleAdmin => 'مدير';

  @override
  String get queueManagement => 'إدارة الدور';

  @override
  String get currentPatient => 'المريض الحالي';

  @override
  String get completeVisit => 'إنهاء الزيارة';

  @override
  String get callNext => 'استدعاء التالي';

  @override
  String get queueList => 'قائمة الدور';

  @override
  String get noPatientsInQueue => 'لا يوجد مرضى في الدور';

  @override
  String get active => 'نشط';

  @override
  String get nowServing => 'الآن';

  @override
  String get manageQueue => 'إدارة الدور';

  @override
  String get language => 'اللغة';

  @override
  String get langKurdish => 'الكردية (السورانية)';

  @override
  String get langArabic => 'العربية';

  @override
  String get langEnglish => 'الإنجليزية';

  @override
  String get firebaseNotConfigured => 'Firebase غير مُعد';

  @override
  String get firebaseSetupHint => 'شغّل flutterfire configure. راجع README.';

  @override
  String get adminDashboard => 'لوحة المدير';

  @override
  String get manageClinics => 'إدارة العيادات';

  @override
  String get manageDoctors => 'إدارة الأطباء';

  @override
  String get manageSpecialties => 'إدارة التخصصات';

  @override
  String get manageStaff => 'إدارة الموظفين';

  @override
  String get manageQueues => 'إدارة الأدوار';

  @override
  String get addClinic => 'إضافة عيادة';

  @override
  String get addDoctor => 'إضافة طبيب';

  @override
  String get addSpecialty => 'إضافة تخصص';

  @override
  String get addStaff => 'إضافة موظف';

  @override
  String get nameKu => 'الاسم (كردي)';

  @override
  String get nameAr => 'الاسم (عربي)';

  @override
  String get nameEn => 'الاسم (إنجليزي)';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get actions => 'إجراءات';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get errorGeneric => 'حدث خطأ';

  @override
  String patientCount(int count) {
    return '$count مريض';
  }

  @override
  String waitingCount(int count) {
    return '$count في الانتظار';
  }

  @override
  String get selectDoctor => 'اختر طبيباً';

  @override
  String get selectClinic => 'اختر عيادة';

  @override
  String get selectSpecialty => 'اختر تخصصاً';

  @override
  String get selectRole => 'اختر الدور';

  @override
  String get rating => 'التقييم';

  @override
  String get experienceYears => 'سنوات الخبرة';

  @override
  String get availableToday => 'متاح اليوم';

  @override
  String get bioKu => 'السيرة (كردي)';

  @override
  String get bioAr => 'السيرة (عربي)';

  @override
  String get bioEn => 'السيرة (إنجليزي)';

  @override
  String get addressKu => 'العنوان (كردي)';

  @override
  String get addressAr => 'العنوان (عربي)';

  @override
  String get addressEn => 'العنوان (إنجليزي)';

  @override
  String get latitude => 'خط العرض';

  @override
  String get longitude => 'خط الطول';

  @override
  String get savedSuccessfully => 'تم الحفظ بنجاح';

  @override
  String get deletedSuccessfully => 'تم الحذف بنجاح';

  @override
  String get patientDashboard => 'لوحة المريض';

  @override
  String get availableAppointments => 'المواعيد المتاحة';

  @override
  String get noAppointmentsAvailable => 'لا توجد مواعيد متاحة حالياً';

  @override
  String get appointmentDate => 'تاريخ الموعد';

  @override
  String get statusAvailable => 'متاح';

  @override
  String get statusBooked => 'محجوز';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get registerPrompt => 'أنشئ حساب مريض لحجز المواعيد';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get emailInUse => 'هذا البريد مسجّل مسبقاً';

  @override
  String get weakPassword => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get home => 'الرئيسية';

  @override
  String get myAppointments => 'مواعيدي';

  @override
  String get allSpecialties => 'الكل';

  @override
  String get noAppointmentsYet => 'لا توجد مواعيد بعد';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get bookAppointment => 'حجز موعد';

  @override
  String get bookAppointmentSuccess => 'تم إرسال طلب الموعد بنجاح';

  @override
  String get bookAppointmentFailed => 'تعذّر حجز الموعد';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get notesHint => 'صف أعراضك أو سبب الزيارة';

  @override
  String get confirmBooking => 'تأكيد الحجز';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get doctorDashboard => 'لوحة الطبيب';

  @override
  String get pendingRequests => 'قيد الانتظار';

  @override
  String get acceptedAppointments => 'مقبولة';

  @override
  String get patientRecords => 'سجلات المرضى';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get writePrescription => 'كتابة وصفة';

  @override
  String get diagnosis => 'التشخيص';

  @override
  String get medications => 'الأدوية';

  @override
  String get prescriptionSaved => 'تم حفظ الوصفة';

  @override
  String get noPatientRecords => 'لا توجد سجلات مرضى';

  @override
  String get secretaryDashboard => 'لوحة السكرتير';

  @override
  String get manageAppointments => 'المواعيد';

  @override
  String get registerPatient => 'تسجيل مريض';

  @override
  String get dailySchedule => 'جدول اليوم';

  @override
  String get registerPatientPrompt => 'سجّل مريضاً جديداً في العيادة';

  @override
  String get patientRegistered => 'تم تسجيل المريض بنجاح';

  @override
  String get noAppointmentsToday => 'لا توجد مواعيد لهذا اليوم';

  @override
  String get queueTracking => 'تتبع السرعة';

  @override
  String get currentQueueNumber => 'رقم السرعة الحالي';

  @override
  String get chatWithSecretary => 'محادثة مع السكرتير';

  @override
  String get typeMessage => 'اكتب رسالة...';

  @override
  String get markEntered => 'وصل';

  @override
  String get markAbsent => 'غائب';

  @override
  String get moveAppointmentUp => 'نقل لأعلى';

  @override
  String get moveAppointmentDown => 'نقل لأسفل';

  @override
  String get addFollowUp => 'مراجعة';

  @override
  String get sendToExamination => 'إرسال للفحص';

  @override
  String get statusArrived => 'وصل';

  @override
  String get statusAbsent => 'غائب';

  @override
  String get statusInExamination => 'في الفحص';

  @override
  String get statusFollowUp => 'مراجعة';

  @override
  String get createDoctorAccount => 'إنشاء حساب طبيب';

  @override
  String get createDoctorAccountHint => 'إضافة طبيب جديد ببيانات الدخول';

  @override
  String get createSecretaryAccount => 'إنشاء حساب سكرتير';

  @override
  String get createSecretaryAccountHint => 'إضافة سكرتير مرتبط بطبيب';

  @override
  String get linkedDoctor => 'الطبيب المرتبط';

  @override
  String get linkedDoctorRequired => 'اختر الطبيب الذي يساعده السكرتير';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get manageProfile => 'إدارة الملف الشخصي';

  @override
  String get manageProfileHint => 'تحديث الصورة والسيرة ومعلومات العيادة والجدول';

  @override
  String get profilePhotoUrl => 'رابط صورة الملف الشخصي';

  @override
  String get uploadPhoto => 'رفع صورة';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get photoUploadHint => 'اختر صورة، قصّها داخل دائرة، ثم احفظ. الصور الكبيرة مدعومة. يمكنك أيضاً لصق رابط أدناه';

  @override
  String get orPastePhotoUrl => 'أو الصق رابط الصورة';

  @override
  String get photoTooLarge => 'تعذر ضغط الصورة بشكل كافٍ. جرّب صورة أصغر';

  @override
  String get photoProcessingFailed => 'تعذر معالجة الصورة المحددة';

  @override
  String get cropProfilePhoto => 'قص صورة الملف الشخصي';

  @override
  String get cropProfilePhotoHint => 'قرّب/بعّد بالقرص واسحب لوضع الصورة داخل الدائرة';

  @override
  String get photoPreview => 'معاينة';

  @override
  String get photoPreviewHint => 'هكذا سيرى المرضى صورتك الشخصية';

  @override
  String get usePhoto => 'استخدام الصورة';

  @override
  String get zoomIn => 'تكبير';

  @override
  String get zoomOut => 'تصغير';

  @override
  String get addClinicPhoto => 'رفع صورة العيادة';

  @override
  String get addClinicPhotoUrl => 'إضافة رابط';

  @override
  String get clinicPhotoUploadHint => 'يتم تحسين صور العيادة حتى 1920×1080. تُستخدم الصور المصغرة في القوائم لتسريع التحميل.';

  @override
  String get workingHours => 'ساعات العمل';

  @override
  String get workingHoursKu => 'ساعات العمل (كردي)';

  @override
  String get workingHoursAr => 'ساعات العمل (عربي)';

  @override
  String get workingHoursEn => 'ساعات العمل (إنجليزي)';

  @override
  String get contactInfo => 'معلومات الاتصال';

  @override
  String get useCurrentLocation => 'استخدام الموقع الحالي';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get professionalInfo => 'التفاصيل المهنية';

  @override
  String get clinicInfo => 'معلومات العيادة';

  @override
  String get scheduleInfo => 'جدول العمل';

  @override
  String get aboutDoctor => 'عن الطبيب';

  @override
  String get academicDegree => 'الدرجة العلمية';

  @override
  String get academicDegreeKu => 'الدرجة (كردي)';

  @override
  String get academicDegreeAr => 'الدرجة (عربي)';

  @override
  String get academicDegreeEn => 'الدرجة (إنجليزي)';

  @override
  String get clinicNameKu => 'اسم العيادة (كردي)';

  @override
  String get clinicNameAr => 'اسم العيادة (عربي)';

  @override
  String get clinicNameEn => 'اسم العيادة (إنجليزي)';

  @override
  String get whatsappNumber => 'رقم واتساب';

  @override
  String get workingDays => 'أيام العمل';

  @override
  String get languagesSpoken => 'اللغات المتحدثة';

  @override
  String get languagesHint => 'مثال: كردي، عربي، إنجليزي';

  @override
  String get dayMonday => 'الإثنين';

  @override
  String get dayTuesday => 'الثلاثاء';

  @override
  String get dayWednesday => 'الأربعاء';

  @override
  String get dayThursday => 'الخميس';

  @override
  String get dayFriday => 'الجمعة';

  @override
  String get daySaturday => 'السبت';

  @override
  String get daySunday => 'الأحد';

  @override
  String get openWhatsApp => 'مراسلة على واتساب';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get viewPublicProfile => 'عرض الملف العام';

  @override
  String get viewPublicProfileHint => 'شاهد كيف يرى المرضى ملفك';

  @override
  String get availableTodayToggle => 'متاح للمواعيد اليوم';

  @override
  String get showToPatients => 'إظهار للمرضى';

  @override
  String get consultationFee => 'رسوم الاستشارة';

  @override
  String consultationFeeAmount(String amount) {
    return '$amount د.ع';
  }

  @override
  String get clinicPhotos => 'صور العيادة';

  @override
  String get clinicPhotosHint => 'الصق رابط الصورة ثم اضغط إضافة رابط';

  @override
  String get live => 'مباشر';

  @override
  String get liveQueueProgress => 'تحديثات الطابور تلقائياً';

  @override
  String get patientsBeforeMe => 'المرضى قبلي';

  @override
  String get appointmentStatusLabel => 'حالة الموعد';

  @override
  String get queueStatusWaiting => 'انتظار';

  @override
  String get queueStatusWithDoctor => 'مع الطبيب';

  @override
  String get queueStatusInDoctorRoom => 'في غرفة الطبيب';

  @override
  String get queueStatusExamination => 'فحص';

  @override
  String get queueStatusReview => 'مراجعة';

  @override
  String get queueStatusSentForTests => 'أُرسل للفحوصات';

  @override
  String get queueStatusFollowUp => 'مراجعة';

  @override
  String get queueStatusCompleted => 'مكتمل';

  @override
  String get queueStatusAbsent => 'غائب';

  @override
  String get queueStatusCancelled => 'ملغى';

  @override
  String get returnToReview => 'إرجاع للمراجعة';

  @override
  String get appointmentTime => 'وقت الموعد';

  @override
  String get noAssignedDoctor => 'لا يوجد طبيب مرتبط بهذا الحساب';

  @override
  String get queueNumberLabel => 'رقم الدور';

  @override
  String get queueNotifyFourRemaining => 'اقترب دورك';

  @override
  String get queueNotifyFourRemainingBody => 'بقي 4 مرضى قبلك.';

  @override
  String get queueNotifyTwoRemaining => 'استعد';

  @override
  String get queueNotifyTwoRemainingBody => 'بقي مريضان قبلك.';

  @override
  String get queueNotifyYourTurn => 'دورك الآن';

  @override
  String get queueNotifyYourTurnBody => 'تفضل إلى غرفة الطبيب.';

  @override
  String get dayClosed => 'مغلق';

  @override
  String get markDayOpen => 'مفتوح';

  @override
  String get markDayClosed => 'مغلق';

  @override
  String get addTimePeriod => 'إضافة فترة';

  @override
  String get removeTimePeriod => 'حذف الفترة';

  @override
  String get openingTime => 'يفتح';

  @override
  String get closingTime => 'يغلق';

  @override
  String get schedulePeriodInvalid => 'وقت الإغلاق يجب أن يكون بعد وقت الفتح';

  @override
  String get schedulePeriodOverlap => 'لا يمكن أن تتداخل الفترات الزمنية';

  @override
  String get scheduleOpenDayNeedsPeriod => 'أضف فترة واحدة على الأقل لكل يوم مفتوح';

  @override
  String get appointmentOutsideSchedule => 'الوقت المحدد خارج ساعات العمل';

  @override
  String get appointmentClosedDay => 'الطبيب غير متاح في هذا اليوم';

  @override
  String get noScheduleSet => 'لم يتم تحديد جدول العمل';

  @override
  String get editWorkingSchedule => 'تعديل جدول العمل';

  @override
  String get viewWorkingSchedule => 'جدول العمل';

  @override
  String get adminControlPanel => 'لوحة تحكم المدير';

  @override
  String get adminControlPanelHint => 'إدارة الأطباء والسكرتaries والعيادات والاشتراكات';

  @override
  String get systemOwner => 'مالك النظام';

  @override
  String get viewAllDoctors => 'عرض جميع الأطباء';

  @override
  String get viewAllDoctorsHint => 'تصفح وإدارة حسابات الأطباء';

  @override
  String get viewAllSecretaries => 'عرض جميع السكرتaries';

  @override
  String get viewAllSecretariesHint => 'تصفح وإدارة حسابات السكرتaries';

  @override
  String get viewAllClinics => 'عرض جميع العيادات';

  @override
  String get viewAllClinicsHint => 'تصفح وإدارة سجلات العيادات';

  @override
  String get activateDeactivateAccounts => 'تفعيل أو تعطيل حسابات الموظفين';

  @override
  String get accountActive => 'نشط';

  @override
  String get accountInactive => 'غير نشط';

  @override
  String get accountDeactivated => 'تم تعطيل هذا الحساب';

  @override
  String get manageSubscriptions => 'إدارة الاشتراكات';

  @override
  String get manageSubscriptionsHint => 'تعيين خطط اشتراك العيادات وتاريخ الانتهاء';

  @override
  String get systemStatistics => 'إحصائيات النظام';

  @override
  String get systemStatisticsHint => 'نظرة عامة على المنصة';

  @override
  String get totalDoctors => 'إجمالي الأطباء';

  @override
  String get totalSecretaries => 'إجمالي السكرتaries';

  @override
  String get totalClinics => 'إجمالي العيادات';

  @override
  String get activeSubscriptions => 'الاشتراكات النشطة';

  @override
  String get activeStaffAccounts => 'حسابات الموظفين النشطة';

  @override
  String get totalDoctorsListed => 'الأطباء في الدليل';

  @override
  String get noStaffAccounts => 'لا توجد حسابات موظفين بعد';

  @override
  String get createAccounts => 'إنشاء حسابات';

  @override
  String get viewAndManage => 'عرض وإدارة';

  @override
  String get subscriptionPlan => 'خطة الاشتراك';

  @override
  String get subscriptionPlanFree => 'مجاني';

  @override
  String get subscriptionPlanBasic => 'أساسي';

  @override
  String get subscriptionPlanPremium => 'مميز';

  @override
  String get subscriptionActive => 'الاشتراك نشط';

  @override
  String get subscriptionExpires => 'ينتهي';

  @override
  String get noExpiry => 'بدون تاريخ انتهاء';
}
