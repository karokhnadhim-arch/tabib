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
  String get yourTurn => 'دورك';

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
  String get chatWithClinic => 'التواصل مع العيادة';

  @override
  String get chatWithPatient => 'محادثة مع المريض';

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
  String get queueNotifyTenRemaining => 'اقترب دورك';

  @override
  String get queueNotifyTenRemainingBody => 'بقي 10 مرضى قبل دورك. يرجى الاستعداد للحضور.';

  @override
  String get queueNotifyFiveRemaining => 'توجه إلى العيادة';

  @override
  String get queueNotifyFiveRemainingBody => 'بقي 5 مرضى قبل دورك. يرجى التوجه إلى العيادة.';

  @override
  String get queueNotifyThreeRemaining => 'احضر الآن';

  @override
  String get queueNotifyThreeRemainingBody => 'دورك قريب جداً. يرجى الوصول إلى العيادة الآن.';

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
  String get adminControlPanelHint => 'إدارة العيادات والمستخدمين والاشتراكات';

  @override
  String get systemOwner => 'مالك النظام';

  @override
  String get viewAllDoctors => 'عرض جميع الأطباء';

  @override
  String get viewAllDoctorsHint => 'تصفح وإدارة حسابات الأطباء';

  @override
  String get viewAllDoctorsSubscriptionHint => 'خطة الاشتراك والحالة والتجديد';

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
  String get subscriptionPlan1Month => 'شهر واحد';

  @override
  String get subscriptionPlan2Months => 'شهران';

  @override
  String get subscriptionPlan3Months => '3 أشهر';

  @override
  String get subscriptionPlan6Months => '6 أشهر';

  @override
  String get subscriptionPlan12Months => '12 شهراً (سنة واحدة)';

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
  String get subscriptionStarted => 'تاريخ البدء';

  @override
  String get subscriptionRemainingDays => 'الأيام المتبقية';

  @override
  String get subscriptionStatusActive => 'نشط';

  @override
  String get subscriptionStatusExpiringSoon => 'ينتهي قريباً';

  @override
  String get subscriptionStatusExpired => 'منتهي';

  @override
  String subscriptionDaysRemaining(int days) {
    return 'متبقي $days يوم';
  }

  @override
  String subscriptionExpiredDaysAgo(int days) {
    return 'انتهى منذ $days يوم';
  }

  @override
  String get subscriptionExpiredTitle => 'انتهى الاشتراك';

  @override
  String get subscriptionExpiredMessage => 'انتهى اشتراك العيادة. لا يمكن إنشاء مواعيد جديدة. السجلات متاحة للقراءة.';

  @override
  String subscriptionExpiringBanner(int days) {
    return 'ينتهي اشتراكك خلال $days يوم. يرجى التجديد قريباً.';
  }

  @override
  String get subscriptionBlocked => 'لا يمكن الحجز — انتهى اشتراك العيادة.';

  @override
  String get renewSubscription => 'تجديد الاشتراك';

  @override
  String get subscriptionRenewed => 'تم تجديد الاشتراك بنجاح';

  @override
  String get viewPatientRecords => 'عرض سجلات المرضى';

  @override
  String get assignedDoctors => 'الأطباء';

  @override
  String get filterAll => 'الكل';

  @override
  String get activateSubscription => 'تفعيل الاشتراك';

  @override
  String get doctorProfile => 'ملف الطبيب';

  @override
  String get noExpiry => 'بدون تاريخ انتهاء';

  @override
  String get doctorManagement => 'إدارة الأطباء';

  @override
  String get doctorManagementHint => 'بحث الأطباء وعرض الملفات وإدارة السكرتaries المعينين';

  @override
  String get adminDoctorSearchHint => 'الاسم، التخصص، العيادة، الجوال، البريد، أو رمز الحساب (مثل DR-10025)...';

  @override
  String get accountCode => 'رمز الحساب';

  @override
  String get doctorAccountCode => 'رمز حساب الطبيب';

  @override
  String get doctorAccountCodeRequired => 'أدخل رمز حساب صالحاً وتحقق منه';

  @override
  String get invalidDoctorAccountCode => 'لم يتم العثور على مقدم خدمة بهذا الرمز.';

  @override
  String get accountCodeFormatInvalid => 'أدخل رمزاً صالحاً (مثل DR-10025 أو BZ-10001).';

  @override
  String get verifyAccountCode => 'تحقق';

  @override
  String get secretaryLinkProviderPreview => 'تأكيد مقدم الخدمة المرتبط';

  @override
  String doctorAccountCodeLabel(String code) {
    return 'رمز حساب الطبيب: $code';
  }

  @override
  String linkedToAccountCode(String code) {
    return 'مرتبط بـ: $code';
  }

  @override
  String get supportHistory => 'سجل الدعم';

  @override
  String get supportHistoryHint => 'تجديد الاشتراك وطلبات الدعم وملاحظات استكشاف الأخطاء المرتبطة برمز الحساب.';

  @override
  String get noSupportHistory => 'لا يوجد نشاط دعم مسجل بعد.';

  @override
  String get doctorInformation => 'معلومات الطبيب';

  @override
  String get assignedSecretaries => 'السكرتaries المعينون';

  @override
  String secretariesCount(int count) {
    return '$count سكرتaries';
  }

  @override
  String doctorSecretarySingle(String name) {
    return 'سكرتير: $name';
  }

  @override
  String doctorSecretariesMultiple(String names) {
    return 'سكرتaries: $names';
  }

  @override
  String doctorSecretariesMultipleWithMore(String names, int more) {
    return 'سكرتaries: $names (+$more أخرى)';
  }

  @override
  String get transferSecretary => 'نقل';

  @override
  String get transferSecretaryTitle => 'نقل السكرتير';

  @override
  String transferSecretaryHint(String name) {
    return 'نقل $name إلى طبيب آخر';
  }

  @override
  String get transferredSuccessfully => 'تم النقل بنجاح';

  @override
  String secretaryAssignedToDoctor(String doctorName) {
    return 'معين لـ: $doctorName';
  }

  @override
  String get addSecretary => 'إضافة سكرتير';

  @override
  String get editSecretary => 'تعديل السكرتير';

  @override
  String get deleteSecretary => 'حذف السكرتير';

  @override
  String get deleteSecretaryConfirm => 'إزالة حساب هذا السكرتير؟ لا يمكن التراجع.';

  @override
  String get noSecretariesAssigned => 'لا يوجد سكرتaries معينون لهذا الطبيب';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String pageOf(int current, int total) {
    return 'صفحة $current من $total';
  }

  @override
  String get itemsPerPage => 'لكل صفحة';

  @override
  String get notAvailable => '—';

  @override
  String get clinicName => 'اسم العيادة';

  @override
  String get status => 'الحالة';

  @override
  String get doctorName => 'اسم الطبيب';

  @override
  String get businessName => 'اسم المنشأة';

  @override
  String get businessProfile => 'ملف المنشأة';

  @override
  String get editBusinessProfile => 'تعديل ملف المنشأة';

  @override
  String get editDoctorProfile => 'تعديل ملف الطبيب';

  @override
  String get aboutBusiness => 'عن المنشأة';

  @override
  String get businessDashboard => 'لوحة المنشأة';

  @override
  String get linkedBusiness => 'المنشأة المرتبطة';

  @override
  String get accountType => 'نوع الحساب';

  @override
  String get accountTypeDoctor => 'طبيب';

  @override
  String get accountTypeBusiness => 'منشأة';

  @override
  String get createBusinessAccount => 'إنشاء حساب منشأة';

  @override
  String get createBusinessAccountHint => 'إضافة منشأة رعاية صحية مع بيانات الدخول';

  @override
  String get selectBusinessCategory => 'فئة المنشأة';

  @override
  String get searchProviders => 'البحث عن أطباء ومنشآت';

  @override
  String get searchHintProviders => 'الاسم، التخصص، فئة المنشأة، العيادة...';

  @override
  String get businessCategoryClinic => 'عيادة';

  @override
  String get businessCategoryBeautyCenter => 'مركز تجميل';

  @override
  String get businessCategoryMedicalLaboratory => 'مختبر طبي';

  @override
  String get businessCategoryRadiologyCenter => 'مركز أشعة';

  @override
  String get businessCategoryPhysiotherapyCenter => 'مركز علاج طبيعي';

  @override
  String get businessCategoryDentalCenter => 'مركز أسنان';

  @override
  String get businessCategoryEyeCenter => 'مركز عيون';

  @override
  String get businessCategoryHearingCenter => 'مركز سمع';

  @override
  String get businessCategoryVaccinationCenter => 'مركز تطعيم';

  @override
  String get businessCategoryBloodTestCenter => 'مركز فحص دم';

  @override
  String get businessCategoryPharmacy => 'صيدلية';

  @override
  String get businessCategoryOtherHealthcare => 'خدمات صحية أخرى';

  @override
  String get noSecretariesAssignedBusiness => 'لا يوجد سكرتير معين لهذه المنشأة';

  @override
  String get doctorsSection => 'الأطباء';

  @override
  String get clinicsHealthcareCenters => 'العيادات ومراكز الرعاية الصحية';

  @override
  String get searchDoctorsOnly => 'البحث باسم الطبيب أو التخصص';

  @override
  String get searchBusinessesOnly => 'البحث باسم المنشأة';

  @override
  String get noBusinessesFound => 'لم يتم العثور على منشآت';

  @override
  String get allBusinessCategories => 'جميع الفئات';

  @override
  String get browseHealthcare => 'تصفح الرعاية الصحية';

  @override
  String get browseDoctorsHint => 'ابحث عن الأطباء وانضم إلى الدور';

  @override
  String get browseBusinessesHint => 'عيادات، مختبرات، صيدليات والمزيد';

  @override
  String get selectQueueSlot => 'اختر وقت الدور';

  @override
  String get selectTimeSlotHint => 'اختر وقتًا متاحًا لزيارتك';

  @override
  String get noQueueSlotsAvailable => 'لا توجد أوقات دور متاحة حاليًا';

  @override
  String get joinQueue => 'انضم إلى الدور';

  @override
  String get queueSlot => 'وقت الدور';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'افتراضي النظام';

  @override
  String get accountSecurity => 'الحساب والأمان';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get changePasswordHint => 'تحديث كلمة مرور تسجيل الدخول';

  @override
  String get changePasswordDescription => 'أدخل كلمة المرور الحالية واختر كلمة مرور جديدة. يمكنك تغيير كلمة مرورك فقط.';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get passwordChangeUnavailable => 'تغيير كلمة المرور غير متاح لهذا الحساب';

  @override
  String get passwordChangedSuccessfully => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get passwordSameAsCurrent => 'يجب أن تكون كلمة المرور الجديدة مختلفة عن الحالية';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get accountInfoReadOnly => 'تفاصيل الحساب';

  @override
  String get accountInfoReadOnlyHint => 'البريد والهاتف ونوع الحساب والصلاحيات يديرها مسؤول العيادة';

  @override
  String get pushNotifications => 'إشعارات الدفع';

  @override
  String get queueNotifications => 'إشعارات الدور';

  @override
  String get sound => 'الصوت';

  @override
  String get vibration => 'الاهتزاز';

  @override
  String get patientPreferences => 'تفضيلات المريض';

  @override
  String get favoriteDoctors => 'الأطباء المفضلون';

  @override
  String get favoriteBusinesses => 'المنشآت المفضلة';

  @override
  String get noFavoriteDoctors => 'لا يوجد أطباء مفضلون بعد';

  @override
  String get noFavoriteBusinesses => 'لا توجد منشآت مفضلة بعد';

  @override
  String get doctorSettings => 'إعدادات الطبيب';

  @override
  String get businessSettings => 'إعدادات المنشأة';

  @override
  String get workingDaysAndHours => 'أيام وساعات العمل';

  @override
  String get queueSettings => 'إعدادات الدور';

  @override
  String get profileVisibility => 'ظهور الملف الشخصي';

  @override
  String get contactVisibility => 'ظهور بيانات الاتصال';

  @override
  String get whatsappVisibility => 'ظهور واتساب';

  @override
  String get secretarySettings => 'إعدادات السكرتير';

  @override
  String get queueAutoRefresh => 'تحديث الدور تلقائياً';

  @override
  String get queueAutoRefreshHint => 'إبقاء عرض الدور محدثاً في الوقت الفعلي';

  @override
  String get privacySettings => 'الخصوصية';

  @override
  String get showInSearchResults => 'الظهور في نتائج البحث';

  @override
  String get showInSearchResultsHint => 'السماح بظهور ملفك في بحث المرضى';

  @override
  String get shareUsageAnalytics => 'مشاركة إحصائيات الاستخدام';

  @override
  String get shareUsageAnalyticsHint => 'ساعد في تحسين تطبيب ببيانات مجهولة';

  @override
  String get supportAndLegal => 'الدعم والقانون';

  @override
  String get about => 'حول التطبيق';

  @override
  String get helpAndSupport => 'المساعدة والدعم';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get providerSettings => 'إعدادات مقدم الخدمة';

  @override
  String get queueNotificationsProviderHint => 'إشعار عند انضمام المرضى أو تحركهم في الدور';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get patient => 'مريض';

  @override
  String get secretary => 'سكرتير';

  @override
  String get admin => 'مسؤول';

  @override
  String get bio => 'نبذة';

  @override
  String get profilePhoto => 'صورة الملف';

  @override
  String get degrees => 'الشهادات';

  @override
  String get experience => 'الخبرة';

  @override
  String get error => 'حدث خطأ';

  @override
  String get termsContent => 'باستخدام تطبيب، فإنك توافق على الالتزام بقواعد دور العيادة واحترام طاقم الرعاية الصحية.';

  @override
  String get privacyPolicyContent => 'يجمع تطبيب البيانات اللازمة فقط لإدارة الدور والتواصل مع العيادة. لا تُباع معلوماتك لأطراف ثالثة.';

  @override
  String aboutContent(String version) {
    return 'تطبيب v$version — منصة حديثة لإدارة الدور والعيادات.';
  }

  @override
  String helpContent(String email) {
    return 'تحتاج مساعدة؟ راسلنا على $email أو تواصل مع مسؤول عيادتك.';
  }

  @override
  String get accountStatusActive => 'نشط';

  @override
  String get accountStatusSuspended => 'موقوف';

  @override
  String get accountStatusDisabled => 'معطل';

  @override
  String get accountStatusExpiredSubscription => 'اشتراك منتهٍ';

  @override
  String get allStatuses => 'كل الحالات';

  @override
  String get changeAccountStatus => 'تغيير حالة الحساب';

  @override
  String get accountSuspendedMessage => 'تم تعليق هذا الحساب. تواصل مع مسؤول العيادة.';

  @override
  String get accountDisabledMessage => 'تم تعطيل هذا الحساب. تواصل مع مسؤول العيادة.';

  @override
  String get accountSubscriptionExpiredLoginMessage => 'تم حظر الوصول لأن اشتراك العيادة منتهٍ. يرجى التجديد للمتابعة.';

  @override
  String get managePatients => 'إدارة المرضى';

  @override
  String get managePatientsHint => 'عرض حسابات المرضى وإدارة حالتها';

  @override
  String get manageAdmins => 'إدارة المسؤولين';

  @override
  String get manageAdminsHint => 'إنشاء مسؤولين وتعيين الصلاحيات';

  @override
  String get createAdminAccount => 'إنشاء حساب مسؤول';

  @override
  String get editAdminAccount => 'تعديل حساب المسؤول';

  @override
  String get deleteAdminAccount => 'حذف حساب المسؤول';

  @override
  String get deleteAdminAccountConfirm => 'إزالة حساب المسؤول؟ لا يمكن التراجع.';

  @override
  String get noAdminAccounts => 'لا يوجد مسؤولون بعد';

  @override
  String get adminPermissionsTitle => 'الصلاحيات';

  @override
  String get adminPermissionsRequired => 'اختر صلاحية واحدة على الأقل';

  @override
  String get permManageDoctors => 'إدارة الأطباء';

  @override
  String get permManageBusinesses => 'إدارة الأعمال';

  @override
  String get permManageSecretaries => 'إدارة السكرتارية';

  @override
  String get permManagePatients => 'إدارة المرضى';

  @override
  String get permManageSubscriptions => 'إدارة الاشتراكات';

  @override
  String get permViewReports => 'عرض التقارير';

  @override
  String get permSendNotifications => 'إرسال الإشعارات';

  @override
  String get permResetPasswords => 'إعادة تعيين كلمات المرور';

  @override
  String get permSuspendAccounts => 'تعليق الحسابات';

  @override
  String get permDeleteAccounts => 'حذف الحسابات';

  @override
  String get permManageCategories => 'إدارة الفئات';

  @override
  String get permViewAnalytics => 'عرض التحليلات';

  @override
  String get permCreateAdmins => 'إنشاء مسؤولين';

  @override
  String get permManageAdmins => 'إدارة المسؤولين';

  @override
  String get systemOwnerDashboard => 'لوحة مالك النظام';

  @override
  String get systemOwnerDashboardHint => 'إدارة المنصة والمستخدمين والاشتراكات وإعدادات النظام.';

  @override
  String get systemOwnerModules => 'الوحدات الإدارية';

  @override
  String get dashboardOverview => 'نظرة عامة';

  @override
  String get businessManagement => 'إدارة الأعمال';

  @override
  String get secretaryManagement => 'إدارة السكرتارية';

  @override
  String get addNewSecretary => 'إضافة سكرتير جديد';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get secretaryPasswordResetSuccess => 'تم تحديث كلمة مرور السكرتير بنجاح';

  @override
  String get secretaryPasswordResetEmailSent => 'تم إرسال رابط إعادة تعيين كلمة المرور إلى السكرتير';

  @override
  String get resetSecretaryPasswordFirebaseHint => 'سيتم إرسال بريد إلكتروني لإعادة تعيين كلمة المرور إلى عنوان تسجيل دخول السكرتير.';

  @override
  String get enableAccount => 'تفعيل الحساب';

  @override
  String get disableAccount => 'تعطيل الحساب';

  @override
  String get unassignedSecretaries => 'سكرتارية غير معيّنة';

  @override
  String get noSecretariesYet => 'لا يوجد سكرتارية بعد';

  @override
  String get patientManagement => 'إدارة المرضى';

  @override
  String get subscriptionManagement => 'إدارة الاشتراكات';

  @override
  String get packageManagement => 'إدارة الباقات';

  @override
  String get payments => 'المدفوعات';

  @override
  String get reports => 'التقارير';

  @override
  String get analytics => 'التحليلات';

  @override
  String get systemSettings => 'إعدادات النظام';

  @override
  String get moduleComingSoon => 'ستتوفر هذه الوحدة في تحديث قادم.';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get ownerNavSubscriptionsPackages => 'الاشتراكات والباقات';

  @override
  String get paymentsBilling => 'المدفوعات والفوترة';

  @override
  String get feedbackSupport => 'الملاحظات والدعم';

  @override
  String get notificationsCenter => 'مركز الإشعارات';

  @override
  String get reportsAnalytics => 'التقارير والتحليلات';

  @override
  String get systemHealth => 'صحة النظام';

  @override
  String get auditLog => 'سجل التدقيق';

  @override
  String get securityCenter => 'مركز الأمان';

  @override
  String get backupRestore => 'النسخ الاحتياطي والاستعادة';

  @override
  String get totalBusinesses => 'إجمالي الأعمال';

  @override
  String get totalPatients => 'إجمالي المرضى';

  @override
  String get activeUsersToday => 'المستخدمون النشطون';

  @override
  String get expiredSubscriptions => 'اشتراكات منتهية';

  @override
  String get revenueOverview => 'نظرة على الإيرادات';

  @override
  String get newRegistrations => 'تسجيلات جديدة';

  @override
  String get liveQueueStatistics => 'إحصائيات الطابور المباشرة';

  @override
  String get queueWaiting => 'في الانتظار';

  @override
  String get queueInProgress => 'قيد المعالجة';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get allBusinesses => 'جميع الأعمال';

  @override
  String get allBusinessesHint => 'عرض وإدارة جميع منشآت الرعاية الصحية';

  @override
  String get businessCategoryBrowseHint => 'تصفح مقدمي الخدمة في هذه الفئة';

  @override
  String get subscriptionPackagesHint => 'إدارة خطط العيادات والتجديد والتنبيهات';

  @override
  String get createPackages => 'إنشاء باقات';

  @override
  String get createPackagesHint => 'تحديد مستويات الاشتراك للعيادات';

  @override
  String get subscriptionPlanHint => 'فتح إدارة الاشتراك لهذه الخطة';

  @override
  String get plan1Month => 'شهر واحد';

  @override
  String get plan2Months => 'شهران';

  @override
  String get plan3Months => '3 أشهر';

  @override
  String get plan6Months => '6 أشهر';

  @override
  String get plan12Months => '12 شهراً';

  @override
  String get activateSubscriptionHint => 'تفعيل خطة اشتراك العيادة';

  @override
  String get renewSubscriptionHint => 'تمديد اشتراك العيادة';

  @override
  String get suspendSubscription => 'تعليق الاشتراك';

  @override
  String get suspendSubscriptionHint => 'إيقاف الوصول مؤقتاً';

  @override
  String get remainingDays => 'الأيام المتبقية';

  @override
  String get remainingDaysHint => 'عرض الأيام المتبقية لكل عيادة';

  @override
  String get expirationAlerts => 'تنبيهات الانتهاء';

  @override
  String get expirationAlertsHint => 'متابعة العيادات قرب الانتهاء';

  @override
  String get paymentsBillingHint => 'الفواتير والفوترة وطرق الدفع';

  @override
  String get invoices => 'الفواتير';

  @override
  String get invoicesHint => 'عرض وتصدير فواتير المنصة';

  @override
  String get billingOverview => 'نظرة على الفوترة';

  @override
  String get billingOverviewHint => 'ملخص نشاط الفوترة';

  @override
  String get paymentMethods => 'طرق الدفع';

  @override
  String get paymentMethodsHint => 'تكوين طرق الدفع المقبولة';

  @override
  String get feedbackSupportHint => 'ملاحظات المستخدمين وطلبات الدعم';

  @override
  String get bugReports => 'تقارير الأخطاء';

  @override
  String get bugReportsHint => 'مراجعة المشاكل المبلغ عنها';

  @override
  String get featureRequests => 'طلبات الميزات';

  @override
  String get featureRequestsHint => 'أفكار مقدمة من المستخدمين';

  @override
  String get userFeedback => 'ملاحظات المستخدمين';

  @override
  String get userFeedbackHint => 'ملاحظات عامة عن المنصة';

  @override
  String get supportConversations => 'محادثات الدعم';

  @override
  String get supportConversationsHint => 'رسائل المستخدمين المحتاجين للمساعدة';

  @override
  String get notificationsCenterHint => 'الإشعارات العامة وإشعارات النظام';

  @override
  String get broadcastNotifications => 'إشعارات عامة';

  @override
  String get broadcastNotificationsHint => 'إرسال إعلانات لجميع المستخدمين';

  @override
  String get subscriptionReminders => 'تذكيرات الاشتراك';

  @override
  String get subscriptionRemindersHint => 'تذكيرات التجديد التلقائية';

  @override
  String get maintenanceAnnouncements => 'إعلانات الصيانة';

  @override
  String get maintenanceAnnouncementsHint => 'إشعارات التوقف المجدول';

  @override
  String get reportsAnalyticsHint => 'تقارير المنصة وتحليلات النمو';

  @override
  String get reportDaily => 'تقرير يومي';

  @override
  String get reportDailyHint => 'نشاط اليوم';

  @override
  String get reportWeekly => 'تقرير أسبوعي';

  @override
  String get reportWeeklyHint => 'ملخص آخر 7 أيام';

  @override
  String get reportMonthly => 'تقرير شهري';

  @override
  String get reportMonthlyHint => 'ملخص آخر 30 يوماً';

  @override
  String get reportYearly => 'تقرير سنوي';

  @override
  String get reportYearlyHint => 'ملخص سنوي للمنصة';

  @override
  String get queueStatistics => 'إحصائيات الطابور';

  @override
  String get queueStatisticsHint => 'أوقات الانتظار وحجم الطابور';

  @override
  String get appointmentStatistics => 'إحصائيات المواعيد';

  @override
  String get appointmentStatisticsHint => 'الحجوزات ومعدلات الإكمال';

  @override
  String get revenueStatistics => 'إحصائيات الإيرادات';

  @override
  String get revenueStatisticsHint => 'إيرادات الاشتراكات والمدفوعات';

  @override
  String get userGrowth => 'نمو المستخدمين';

  @override
  String get userGrowthHint => 'مستخدمون جدد بمرور الوقت';

  @override
  String get systemHealthHint => 'حالة البنية التحتية والخدمات';

  @override
  String get firebaseStatus => 'حالة Firebase';

  @override
  String get statusConnected => 'متصل ومُعد';

  @override
  String get statusDemoOrOffline => 'وضع تجريبي أو غير مُعد';

  @override
  String get storageUsage => 'استخدام التخزين';

  @override
  String get databaseUsage => 'استخدام قاعدة البيانات';

  @override
  String get clinicsLabel => 'عيادات';

  @override
  String get accountsLabel => 'حسابات';

  @override
  String get errorLogs => 'سجلات الأخطاء';

  @override
  String get errorLogsHint => 'سجل أخطاء التطبيق';

  @override
  String get crashReports => 'تقارير الأعطال';

  @override
  String get crashReportsHint => 'ملخصات أعطال العميل';

  @override
  String get performanceMonitoring => 'مراقبة الأداء';

  @override
  String get performanceMonitoringHint => 'زمن الاستجابة والحمل';

  @override
  String get noAuditEntries => 'لا توجد سجلات تدقيق بعد';

  @override
  String get user => 'المستخدم';

  @override
  String get device => 'الجهاز';

  @override
  String get ipAddress => 'عنوان IP';

  @override
  String get securityCenterHint => 'نشاط تسجيل الدخول وحماية الحسابات';

  @override
  String get loginHistory => 'سجل تسجيل الدخول';

  @override
  String get loginHistoryHint => 'أحداث تسجيل الدخول الأخيرة';

  @override
  String get activeSessions => 'الجلسات النشطة';

  @override
  String get activeSessionsHint => 'الأجهزة المسجلة حالياً';

  @override
  String get failedLoginAttempts => 'محاولات دخول فاشلة';

  @override
  String get failedLoginAttemptsHint => 'تسجيلات دخول مشبوهة';

  @override
  String get blockedAccounts => 'حسابات محظورة';

  @override
  String get blockedAccountsHint => 'حسابات معلقة أو معطلة';

  @override
  String get passwordResetLogs => 'سجل إعادة تعيين كلمة المرور';

  @override
  String get passwordResetLogsHint => 'طلبات إعادة التعيين الأخيرة';

  @override
  String get backupRestoreHint => 'حماية واستعادة بيانات المنصة';

  @override
  String get manualBackup => 'نسخ احتياطي يدوي';

  @override
  String get manualBackupHint => 'إنشاء نسخة احتياطية عند الطلب';

  @override
  String get automaticBackup => 'نسخ احتياطي تلقائي';

  @override
  String get automaticBackupHint => 'جدولة نسخ احتياطية دورية';

  @override
  String get restoreData => 'استعادة البيانات';

  @override
  String get restoreDataHint => 'استعادة من لقطة احتياطية';

  @override
  String get systemSettingsHint => 'إعدادات المنصة العامة';

  @override
  String get languageSettingsHint => 'اللغات الافتراضية والمدعومة';

  @override
  String get themeSettingsHint => 'الوضع الفاتح والداكن والعلامة التجارية';

  @override
  String get notificationSettingsHint => 'إعدادات إشعارات النظام الافتراضية';

  @override
  String get featureFlags => 'أعلام الميزات';

  @override
  String get featureFlagsHint => 'تفعيل أو تعطيل ميزات المنصة';

  @override
  String get maintenanceMode => 'وضع الصيانة';

  @override
  String get maintenanceModeHint => 'إيقاف المنصة للصيانة';

  @override
  String get businessType => 'نوع المنشأة';

  @override
  String get addBusinessType => 'إضافة نوع منشأة';

  @override
  String get localizedTypeHint => 'أدخل الأسماء بالكردية والعربية والإنجليزية (الثلاثة مطلوبة). يرى المستخدمون التسمية بلغتهم المختارة.';

  @override
  String get translationRequired => 'هذا الترجمة مطلوبة';

  @override
  String get translationsIncomplete => 'ترجمات ناقصة — عدّل لإضافة الكردية والعربية والإنجليزية';

  @override
  String get typeToSearchOrCreate => 'اكتب للبحث أو الإنشاء';

  @override
  String get businessTypeSearchHint => 'اكتب حرفين على الأقل للبحث، أو اختر نوعاً مستخدماً مؤخراً.';

  @override
  String get specialtySearchHint => 'اكتب حرفين على الأقل للبحث في التخصصات.';

  @override
  String get noBusinessTypeFound => 'لم يتم العثور على نوع منشأة.';

  @override
  String get noSpecialtyFound => 'لم يتم العثور على تخصص.';

  @override
  String get createNewBusinessType => '+ إنشاء نوع منشأة جديد';

  @override
  String get recentlyUsedBusinessTypes => 'المستخدمة مؤخراً';

  @override
  String createNewType(String name) {
    return 'إنشاء \"$name\"';
  }

  @override
  String get completeProfileBanner => 'أكمل ملفك — أضف اسم العيادة والعنوان وساعات العمل والصور وبيانات الاتصال.';

  @override
  String get completeProfileAction => 'إكمال الملف';

  @override
  String get manageBusinessTypes => 'أنواع المنشآت';

  @override
  String get manageBusinessTypesHint => 'إنشاء وترجمة وتفعيل أنواع المنشآت المركزية';

  @override
  String get editBusinessType => 'تعديل نوع المنشأة';

  @override
  String get businessTypeActive => 'نشط';

  @override
  String get businessTypeActiveHint => 'الأنواع غير النشطة مخفية عن المرضى حتى يتم تفعيلها وربطها بحساب';

  @override
  String get businessTypeDuplicate => 'نوع المنشأة هذا موجود مسبقاً';

  @override
  String get noBusinessTypesYet => 'لا توجد أنواع منشآت بعد. أضف نوعاً للبدء.';

  @override
  String businessTypeAssignedCount(int count) {
    return '$count منشأة مرتبطة';
  }

  @override
  String get allBusinessTypes => 'جميع أنواع المنشآت';

  @override
  String get iconName => 'اسم الأيقونة';

  @override
  String get myQueues => 'طوابيري';

  @override
  String get sortClosestAppointment => 'أقرب موعد';

  @override
  String get sortRecentlyJoined => 'انضممت مؤخراً';

  @override
  String get sortDoctorName => 'اسم الطبيب';

  @override
  String get refresh => 'تحديث';

  @override
  String get viewProfile => 'عرض الملف';

  @override
  String get patientProfile => 'الملف الشخصي';

  @override
  String get city => 'المدينة';

  @override
  String get genderOptional => 'الجنس (اختياري)';

  @override
  String get showProfilePhoto => 'إظهار صورة الملف';

  @override
  String get showPhoneNumber => 'إظهار رقم الهاتف';

  @override
  String get profileVisibleToVisitedOnly => 'الملف مرئي فقط للمنشآت التي زرتها';

  @override
  String get recentlyVisited => 'زرت مؤخراً';

  @override
  String get nearbyProviders => 'بالقرب منك';

  @override
  String get recommendedDoctors => 'أطباء موصى بهم';

  @override
  String get recommendedBusinesses => 'منشآت موصى بها';

  @override
  String get activeQueues => 'طوابير نشطة';

  @override
  String get advertisements => 'إعلانات';

  @override
  String get enableLocation => 'تفعيل الموقع';

  @override
  String get locationRequiredForNearby => 'اسمح بالوصول إلى الموقع لرؤية المنشآت القريبة.';

  @override
  String get alreadyInSameQueue => 'أنت مسجل بالفعل في هذا الطابور لنفس الوقت.';

  @override
  String get profileSaved => 'تم حفظ الملف';

  @override
  String get saveFailed => 'تعذر حفظ التغييرات';

  @override
  String get uploadFailed => 'فشل الرفع';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get searchProvidersHint => 'طبيب، منشأة، تخصص، أو مدينة...';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get bookAgain => 'احجز مرة أخرى';

  @override
  String get setCityForAds => 'حدد مدينتك في الملف الشخصي لعرض العروض الصحية المحلية.';

  @override
  String get advertisementDetails => 'إعلان';

  @override
  String get advertisementNotFound => 'هذا الإعلان لم يعد متاحاً.';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get currentServing => 'الدور الحالي';

  @override
  String get queueStatusServing => 'قيد الخدمة';

  @override
  String get queueStatusFinished => 'منتهي';

  @override
  String get queueProgress => 'تقدم الطابور';

  @override
  String get sortQueueProgress => 'تقدم الطابور';

  @override
  String get nearbyHealthcareCenters => 'مراكز صحية قريبة';

  @override
  String get recommendedHealthcareCenters => 'مراكز صحية موصى بها';

  @override
  String get noNearbyProviders => 'لم يتم العثور على منشآت قريبة في منطقتك.';

  @override
  String get callClinic => 'اتصل بالعيادة';

  @override
  String get openMap => 'فتح الخريطة';

  @override
  String get addToFavorites => 'إضافة إلى المفضلة';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String get cancelQueueConfirm => 'هل أنت متأكد من إلغاء هذا الطابور؟';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get memberSince => 'عضو منذ';

  @override
  String get completedVisits => 'الزيارات المكتملة';

  @override
  String get upcomingAppointments => 'المواعيد القادمة';

  @override
  String get birthDate => 'تاريخ الميلاد';

  @override
  String get bloodType => 'فصيلة الدم';

  @override
  String get emergencyContact => 'جهة اتصال للطوارئ';

  @override
  String get mobile => 'الجوال';

  @override
  String get profileStatistics => 'الإحصائيات';

  @override
  String get accountDetails => 'تفاصيل الحساب';

  @override
  String get appearanceAndPrivacy => 'المظهر والخصوصية';

  @override
  String get noActiveQueuesOnProfile => 'لا توجد طوابير نشطة. تصفح الأطباء للانضمام إلى طابور.';

  @override
  String get noFavoriteDoctorsYet => 'لا يوجد أطباء مفضلون بعد. اضغط على القلب في ملف الطبيب.';

  @override
  String get notificationSystemSettings => 'نظام الإشعارات الذكي';

  @override
  String get notificationSystemSettingsHint => 'القنوات وعتبات الطابور والقوالب متعددة اللغات';

  @override
  String get notificationChannels => 'قنوات الإشعار';

  @override
  String get pushNotificationsOwnerHint => 'إرسال إشعار push عند تثبيت التطبيق';

  @override
  String get whatsappNotifications => 'واتساب';

  @override
  String get smsNotifications => 'رسائل SMS';

  @override
  String get smsNotificationsHint => 'يتطلب مزود SMS للعيادة (محاكاة في العرض)';

  @override
  String get inAppNotifications => 'داخل التطبيق';

  @override
  String get queueAlertThresholds => 'عتبات تنبيه الطابور';

  @override
  String get queueAlertThresholdsHint => 'إشعار المرضى عند بقاء هذا العدد قبل دورهم';

  @override
  String get notificationTemplates => 'قوالب الإشعارات';

  @override
  String get notificationTemplatesHint => 'استخدم PatientName و DoctorName و DelayMinutes و AppointmentTime كعناصر نائبة بين أقواس';

  @override
  String get notificationType => 'نوع الإشعار';

  @override
  String get templateVariablesHint => 'نص القالب مع العناصر النائبة';

  @override
  String get saveTemplate => 'حفظ القالب';

  @override
  String get templateSaved => 'تم حفظ القالب';

  @override
  String get reminderNotifications => 'تذكيرات المواعيد';

  @override
  String get reminderNotificationsHint => 'تذكيرات الطابور والمواعيد';

  @override
  String get preferredNotificationLanguage => 'لغة الإشعارات';

  @override
  String get followAppLanguage => 'اتباع لغة التطبيق';

  @override
  String get preferredNotificationMethod => 'طريقة الإرسال المفضلة';

  @override
  String get notificationMethodAutomatic => 'تلقائي (أفضل متاح)';

  @override
  String get sentBy => 'أرسل بواسطة';

  @override
  String get notificationOpened => 'تم الفتح';

  @override
  String get deliveryPending => 'قيد الانتظار';

  @override
  String get deliverySent => 'تم الإرسال';

  @override
  String get deliveryDelivered => 'تم التسليم';

  @override
  String get deliveryFailed => 'فشل';

  @override
  String get deliverySkipped => 'تم التخطي';

  @override
  String get missedTurnNotification => 'فات الدور';

  @override
  String get doctorDelayNotification => 'تأخر الطبيب';

  @override
  String get appointmentConfirmed => 'تم تأكيد الموعد';

  @override
  String get appointmentRescheduled => 'تم إعادة جدولة الموعد';

  @override
  String get appointmentCancelled => 'تم إلغاء الموعد';

  @override
  String get doctorUnavailable => 'الطبيب غير متاح';

  @override
  String get clinicClosedUnexpectedly => 'إغلاق مفاجئ للعيادة';

  @override
  String get recallPatient => 'استدعاء المريض';

  @override
  String get moveToEndOfQueue => 'نقل إلى النهاية';

  @override
  String get cancelAppointment => 'إلغاء الموعد';

  @override
  String get patientRecalled => 'تم استدعاء المريض إلى الطابور';

  @override
  String get patientMovedToEnd => 'تم نقل المريض إلى نهاية الطابور';

  @override
  String get notifyDoctorDelay => 'إشعار المرضى بتأخر الطبيب';

  @override
  String get notifyDelayShort => 'تنبيه تأخير';

  @override
  String get delayMinutes => 'التأخير (دقائق)';

  @override
  String get sendNotification => 'إرسال';

  @override
  String get delayNotificationSent => 'تم إرسال إشعار التأخير للمرضى المنتظرين';

  @override
  String get contactActionCall => 'اتصال';

  @override
  String get contactActionWhatsApp => 'واتساب';

  @override
  String get contactActionSms => 'رسالة SMS';

  @override
  String get chooseMessageTemplate => 'اختر رسالة';

  @override
  String get contactTemplateQueueReminder => 'مرحباً، يقترب دورك في الطابور. يرجى الاستعداد للحضور إلى العيادة.';

  @override
  String get contactTemplateYourTurn => 'مرحباً، حان دورك الآن. يرجى التوجه إلى غرفة الطبيب.';

  @override
  String get contactTemplateAppointmentReminder => 'مرحباً، هذا تذكير بموعدك القادم.';

  @override
  String get contactTemplateFollowUp => 'مرحباً، يرجى التواصل مع العيادة بخصوص زيارتك الأخيرة.';

  @override
  String get contactTemplateCustom => 'اكتب رسالة مخصصة';

  @override
  String get searchPatientsHint => 'ابحث عن المرضى بالاسم أو الهاتف';

  @override
  String get communicationAuditLog => 'سجل تواصل الموظفين';

  @override
  String get noCommunicationLogs => 'لا توجد محاولات تواصل مسجلة بعد.';
}
