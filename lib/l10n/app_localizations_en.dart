import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tabib';

  @override
  String get appSubtitle => 'Find doctors, book appointments, manage your health';

  @override
  String get patientApp => 'Patient App';

  @override
  String get patientAppSubtitle => 'Book a queue and track your position';

  @override
  String get staffApp => 'Doctor & Secretary App';

  @override
  String get staffAppSubtitle => 'Manage queues and patients';

  @override
  String get adminApp => 'Admin Panel';

  @override
  String get adminAppSubtitle => 'Manage clinics, doctors, and staff';

  @override
  String get patientLogin => 'Patient Login';

  @override
  String get staffLogin => 'Staff Login';

  @override
  String get adminLogin => 'Admin Login';

  @override
  String get loginPromptPatient => 'Enter your name and phone to start';

  @override
  String get loginPromptStaff => 'Sign in with your staff account';

  @override
  String get loginPromptAdmin => 'Sign in with admin credentials';

  @override
  String get patientName => 'Patient name';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get email => 'Email';

  @override
  String get emailOptional => 'Email (optional)';

  @override
  String get phoneOptional => 'Phone number (optional)';

  @override
  String get accountLoginMethod => 'Login method';

  @override
  String get emailOrPhone => 'Email or mobile number';

  @override
  String get emailOrPhoneHint => 'Enter your email or mobile number';

  @override
  String get phoneInUse => 'This phone number is already registered';

  @override
  String get password => 'Password';

  @override
  String get login => 'Sign in';

  @override
  String get logout => 'Sign out';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get invalidName => 'Enter your full name';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String get noActiveQueue => 'No active queue';

  @override
  String get bookQueueHint => 'Choose a doctor and book a queue';

  @override
  String get medicalSpecialties => 'Medical specialties';

  @override
  String get searchDoctors => 'Search doctors';

  @override
  String get searchHint => 'Doctor name, specialty, clinic...';

  @override
  String get myQueue => 'My queue';

  @override
  String get queueNumber => 'Queue number';

  @override
  String get peopleAhead => 'People ahead';

  @override
  String get waitTime => 'Estimated wait';

  @override
  String minutesShort(int minutes) {
    return '~$minutes min';
  }

  @override
  String get doctor => 'Doctor';

  @override
  String get specialty => 'Specialty';

  @override
  String get clinic => 'Clinic';

  @override
  String get location => 'Location';

  @override
  String get address => 'Address';

  @override
  String get phone => 'Phone';

  @override
  String get inQueue => 'In queue';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String yearsExperience(int years) {
    return '$years years experience';
  }

  @override
  String get info => 'Information';

  @override
  String get clinicLocationGps => 'Clinic location (GPS)';

  @override
  String get bookQueue => 'Book queue';

  @override
  String get alreadyHasQueue => 'You already have an active queue';

  @override
  String bookSuccess(int number) {
    return 'Queue booked! Number: $number';
  }

  @override
  String get bookFailed => 'Could not book queue';

  @override
  String get details => 'Details';

  @override
  String get currentQueue => 'Current queue';

  @override
  String get yourTurn => 'It\'s your turn!';

  @override
  String get waiting => 'Waiting';

  @override
  String get completed => 'Completed';

  @override
  String get cancelQueue => 'Cancel';

  @override
  String get queueCancelled => 'Queue cancelled';

  @override
  String get openGoogleMaps => 'Open in Google Maps';

  @override
  String get gpsDirections => 'GPS directions';

  @override
  String distanceKm(String km) {
    return 'Distance: $km km';
  }

  @override
  String get noDoctorsFound => 'No doctors found';

  @override
  String get doctorApp => 'Doctor App';

  @override
  String get secretaryApp => 'Secretary App';

  @override
  String get roleDoctor => 'Doctor';

  @override
  String get roleSecretary => 'Secretary';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get queueManagement => 'Queue management';

  @override
  String get currentPatient => 'Current patient';

  @override
  String get completeVisit => 'Complete visit';

  @override
  String get callNext => 'Call next';

  @override
  String get queueList => 'Queue list';

  @override
  String get noPatientsInQueue => 'No patients in queue';

  @override
  String get active => 'Active';

  @override
  String get nowServing => 'Now';

  @override
  String get manageQueue => 'Manage queue';

  @override
  String get language => 'Language';

  @override
  String get langKurdish => 'Kurdish (Sorani)';

  @override
  String get langArabic => 'Arabic';

  @override
  String get langEnglish => 'English';

  @override
  String get firebaseNotConfigured => 'Firebase is not configured';

  @override
  String get firebaseSetupHint => 'Run flutterfire configure and add your google-services files. See README.md.';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get manageClinics => 'Manage clinics';

  @override
  String get manageDoctors => 'Manage doctors';

  @override
  String get manageSpecialties => 'Manage specialties';

  @override
  String get manageStaff => 'Manage staff';

  @override
  String get manageQueues => 'Manage queues';

  @override
  String get addClinic => 'Add clinic';

  @override
  String get addDoctor => 'Add doctor';

  @override
  String get addSpecialty => 'Add specialty';

  @override
  String get addStaff => 'Add staff';

  @override
  String get nameKu => 'Name (Kurdish)';

  @override
  String get nameAr => 'Name (Arabic)';

  @override
  String get nameEn => 'Name (English)';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get actions => 'Actions';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String patientCount(int count) {
    return '$count patients';
  }

  @override
  String waitingCount(int count) {
    return '$count waiting';
  }

  @override
  String get selectDoctor => 'Select doctor';

  @override
  String get selectClinic => 'Select clinic';

  @override
  String get selectSpecialty => 'Select specialty';

  @override
  String get selectRole => 'Select role';

  @override
  String get rating => 'Rating';

  @override
  String get experienceYears => 'Years of experience';

  @override
  String get availableToday => 'Available today';

  @override
  String get bioKu => 'Bio (Kurdish)';

  @override
  String get bioAr => 'Bio (Arabic)';

  @override
  String get bioEn => 'Bio (English)';

  @override
  String get addressKu => 'Address (Kurdish)';

  @override
  String get addressAr => 'Address (Arabic)';

  @override
  String get addressEn => 'Address (English)';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get savedSuccessfully => 'Saved successfully';

  @override
  String get deletedSuccessfully => 'Deleted successfully';

  @override
  String get patientDashboard => 'Patient Dashboard';

  @override
  String get availableAppointments => 'Available appointments';

  @override
  String get noAppointmentsAvailable => 'No appointments available right now';

  @override
  String get appointmentDate => 'Appointment date';

  @override
  String get statusAvailable => 'Available';

  @override
  String get statusBooked => 'Booked';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get retry => 'Retry';

  @override
  String get register => 'Create account';

  @override
  String get registerPrompt => 'Create a patient account to book appointments';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get emailInUse => 'This email is already registered';

  @override
  String get weakPassword => 'Password must be at least 6 characters';

  @override
  String get home => 'Home';

  @override
  String get myAppointments => 'My appointments';

  @override
  String get allSpecialties => 'All';

  @override
  String get noAppointmentsYet => 'No appointments yet';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get bookAppointment => 'Book appointment';

  @override
  String get bookAppointmentSuccess => 'Appointment request sent successfully';

  @override
  String get bookAppointmentFailed => 'Could not book appointment';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectTime => 'Select time';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get notesHint => 'Describe your symptoms or reason for visit';

  @override
  String get confirmBooking => 'Confirm booking';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get doctorDashboard => 'Doctor Dashboard';

  @override
  String get pendingRequests => 'Pending';

  @override
  String get acceptedAppointments => 'Accepted';

  @override
  String get patientRecords => 'Patient records';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get writePrescription => 'Write prescription';

  @override
  String get diagnosis => 'Diagnosis';

  @override
  String get medications => 'Medications';

  @override
  String get prescriptionSaved => 'Prescription saved';

  @override
  String get noPatientRecords => 'No patient records';

  @override
  String get secretaryDashboard => 'Secretary Dashboard';

  @override
  String get manageAppointments => 'Appointments';

  @override
  String get registerPatient => 'Register patient';

  @override
  String get dailySchedule => 'Daily schedule';

  @override
  String get registerPatientPrompt => 'Register a new patient at the clinic';

  @override
  String get patientRegistered => 'Patient registered successfully';

  @override
  String get noAppointmentsToday => 'No appointments for this day';

  @override
  String get queueTracking => 'Queue tracking';

  @override
  String get currentQueueNumber => 'Current queue number';

  @override
  String get chatWithSecretary => 'Chat with secretary';

  @override
  String get chatWithClinic => 'Contact clinic';

  @override
  String get chatWithPatient => 'Chat with patient';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get markEntered => 'Mark entered';

  @override
  String get markAbsent => 'Mark absent';

  @override
  String get moveAppointmentUp => 'Move up';

  @override
  String get moveAppointmentDown => 'Move down';

  @override
  String get addFollowUp => 'Follow-up (Murajaa)';

  @override
  String get sendToExamination => 'Send to examination';

  @override
  String get statusArrived => 'Arrived';

  @override
  String get statusAbsent => 'Absent';

  @override
  String get statusInExamination => 'In examination';

  @override
  String get statusFollowUp => 'Follow-up';

  @override
  String get createDoctorAccount => 'Create doctor account';

  @override
  String get createDoctorAccountHint => 'Add a new doctor with login credentials';

  @override
  String get createSecretaryAccount => 'Create secretary account';

  @override
  String get createSecretaryAccountHint => 'Add a secretary linked to a doctor';

  @override
  String get linkedDoctor => 'Linked doctor';

  @override
  String get linkedDoctorRequired => 'Select the doctor this secretary assists';

  @override
  String get accountCreated => 'Account created successfully';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get manageProfile => 'Manage your profile';

  @override
  String get manageProfileHint => 'Update photo, bio, clinic details, and schedule';

  @override
  String get profilePhotoUrl => 'Profile photo URL';

  @override
  String get uploadPhoto => 'Upload photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get photoUploadHint => 'Pick a photo, crop it in a circle, then save. Large images are supported. You can also paste a URL below.';

  @override
  String get orPastePhotoUrl => 'Or paste image URL';

  @override
  String get photoTooLarge => 'Image could not be compressed enough. Try a smaller photo.';

  @override
  String get photoProcessingFailed => 'Could not process the selected image';

  @override
  String get cropProfilePhoto => 'Crop profile photo';

  @override
  String get cropProfilePhotoHint => 'Pinch to zoom and drag to position your photo inside the circle';

  @override
  String get photoPreview => 'Preview';

  @override
  String get photoPreviewHint => 'This is how patients will see your profile photo';

  @override
  String get usePhoto => 'Use photo';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get addClinicPhoto => 'Upload clinic photo';

  @override
  String get addClinicPhotoUrl => 'Add URL';

  @override
  String get clinicPhotoUploadHint => 'Clinic photos are optimized up to 1920×1080. Thumbnails are used in lists for faster loading.';

  @override
  String get workingHours => 'Working hours';

  @override
  String get workingHoursKu => 'Working hours (Kurdish)';

  @override
  String get workingHoursAr => 'Working hours (Arabic)';

  @override
  String get workingHoursEn => 'Working hours (English)';

  @override
  String get contactInfo => 'Contact information';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get professionalInfo => 'Professional details';

  @override
  String get clinicInfo => 'Clinic information';

  @override
  String get scheduleInfo => 'Schedule';

  @override
  String get aboutDoctor => 'About the doctor';

  @override
  String get academicDegree => 'Academic degree';

  @override
  String get academicDegreeKu => 'Degree (Kurdish)';

  @override
  String get academicDegreeAr => 'Degree (Arabic)';

  @override
  String get academicDegreeEn => 'Degree (English)';

  @override
  String get clinicNameKu => 'Clinic name (Kurdish)';

  @override
  String get clinicNameAr => 'Clinic name (Arabic)';

  @override
  String get clinicNameEn => 'Clinic name (English)';

  @override
  String get whatsappNumber => 'WhatsApp number';

  @override
  String get workingDays => 'Working days';

  @override
  String get languagesSpoken => 'Languages spoken';

  @override
  String get languagesHint => 'e.g. Kurdish, Arabic, English';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get openWhatsApp => 'Message on WhatsApp';

  @override
  String get fullName => 'Full name';

  @override
  String get viewPublicProfile => 'View public profile';

  @override
  String get viewPublicProfileHint => 'See how patients view your profile';

  @override
  String get availableTodayToggle => 'Available for appointments today';

  @override
  String get showToPatients => 'Show to patients';

  @override
  String get consultationFee => 'Consultation fee';

  @override
  String consultationFeeAmount(String amount) {
    return '$amount IQD';
  }

  @override
  String get clinicPhotos => 'Clinic photos';

  @override
  String get clinicPhotosHint => 'Paste an image URL and tap Add URL';

  @override
  String get live => 'LIVE';

  @override
  String get liveQueueProgress => 'Live queue updates automatically';

  @override
  String get patientsBeforeMe => 'Patients before me';

  @override
  String get appointmentStatusLabel => 'Appointment status';

  @override
  String get queueStatusWaiting => 'Waiting';

  @override
  String get queueStatusWithDoctor => 'With Doctor';

  @override
  String get queueStatusInDoctorRoom => 'In doctor room';

  @override
  String get queueStatusExamination => 'Examination';

  @override
  String get queueStatusReview => 'Review';

  @override
  String get queueStatusSentForTests => 'Sent for tests';

  @override
  String get queueStatusFollowUp => 'Follow up';

  @override
  String get queueStatusCompleted => 'Completed';

  @override
  String get queueStatusAbsent => 'Absent';

  @override
  String get queueStatusCancelled => 'Cancelled';

  @override
  String get returnToReview => 'Return to review';

  @override
  String get appointmentTime => 'Appointment time';

  @override
  String get noAssignedDoctor => 'No doctor assigned to this secretary account';

  @override
  String get queueNumberLabel => 'Queue #';

  @override
  String get queueNotifyFourRemaining => 'Almost your turn';

  @override
  String get queueNotifyFourRemainingBody => 'Only 4 patients remain before you.';

  @override
  String get queueNotifyTwoRemaining => 'Get ready';

  @override
  String get queueNotifyTwoRemainingBody => 'Only 2 patients remain before you.';

  @override
  String get queueNotifyYourTurn => 'Your turn now';

  @override
  String get queueNotifyYourTurnBody => 'Please proceed to the doctor room.';

  @override
  String get dayClosed => 'Closed';

  @override
  String get markDayOpen => 'Open';

  @override
  String get markDayClosed => 'Closed';

  @override
  String get addTimePeriod => 'Add time period';

  @override
  String get removeTimePeriod => 'Remove period';

  @override
  String get openingTime => 'Opens';

  @override
  String get closingTime => 'Closes';

  @override
  String get schedulePeriodInvalid => 'Closing time must be after opening time';

  @override
  String get schedulePeriodOverlap => 'Time periods cannot overlap';

  @override
  String get scheduleOpenDayNeedsPeriod => 'Add at least one time period for each open day';

  @override
  String get appointmentOutsideSchedule => 'Selected time is outside working hours';

  @override
  String get appointmentClosedDay => 'The doctor is not available on this day';

  @override
  String get noScheduleSet => 'No working schedule set';

  @override
  String get editWorkingSchedule => 'Edit working schedule';

  @override
  String get viewWorkingSchedule => 'Working schedule';

  @override
  String get adminControlPanel => 'Admin Control Panel';

  @override
  String get adminControlPanelHint => 'Manage clinics, users, and subscriptions';

  @override
  String get systemOwner => 'System Owner';

  @override
  String get viewAllDoctors => 'View all doctors';

  @override
  String get viewAllDoctorsHint => 'Browse and manage doctor accounts';

  @override
  String get viewAllDoctorsSubscriptionHint => 'Subscription plan, status, and renewals';

  @override
  String get viewAllSecretaries => 'View all secretaries';

  @override
  String get viewAllSecretariesHint => 'Browse and manage secretary accounts';

  @override
  String get viewAllClinics => 'View all clinics';

  @override
  String get viewAllClinicsHint => 'Browse and manage clinic records';

  @override
  String get activateDeactivateAccounts => 'Activate or deactivate staff accounts';

  @override
  String get accountActive => 'Active';

  @override
  String get accountInactive => 'Inactive';

  @override
  String get accountDeactivated => 'This account has been deactivated';

  @override
  String get manageSubscriptions => 'Manage subscriptions';

  @override
  String get manageSubscriptionsHint => 'Set clinic subscription plans and expiry';

  @override
  String get systemStatistics => 'System statistics';

  @override
  String get systemStatisticsHint => 'Platform-wide overview';

  @override
  String get totalDoctors => 'Total doctors';

  @override
  String get totalSecretaries => 'Total secretaries';

  @override
  String get totalClinics => 'Total clinics';

  @override
  String get activeSubscriptions => 'Active subscriptions';

  @override
  String get activeStaffAccounts => 'Active staff accounts';

  @override
  String get totalDoctorsListed => 'Doctors in catalog';

  @override
  String get noStaffAccounts => 'No staff accounts yet';

  @override
  String get createAccounts => 'Create accounts';

  @override
  String get viewAndManage => 'View and manage';

  @override
  String get subscriptionPlan => 'Subscription plan';

  @override
  String get subscriptionPlan1Month => '1 Month';

  @override
  String get subscriptionPlan2Months => '2 Months';

  @override
  String get subscriptionPlan3Months => '3 Months';

  @override
  String get subscriptionPlan6Months => '6 Months';

  @override
  String get subscriptionPlan12Months => '12 Months (1 Year)';

  @override
  String get subscriptionPlanFree => 'Free';

  @override
  String get subscriptionPlanBasic => 'Basic';

  @override
  String get subscriptionPlanPremium => 'Premium';

  @override
  String get subscriptionActive => 'Subscription active';

  @override
  String get subscriptionExpires => 'Expires';

  @override
  String get subscriptionStarted => 'Start date';

  @override
  String get subscriptionRemainingDays => 'Remaining days';

  @override
  String get subscriptionStatusActive => 'Active';

  @override
  String get subscriptionStatusExpiringSoon => 'Expiring soon';

  @override
  String get subscriptionStatusExpired => 'Expired';

  @override
  String subscriptionDaysRemaining(int days) {
    return '$days days left';
  }

  @override
  String subscriptionExpiredDaysAgo(int days) {
    return 'Expired $days days ago';
  }

  @override
  String get subscriptionExpiredTitle => 'Subscription Expired';

  @override
  String get subscriptionExpiredMessage => 'Your clinic subscription has expired. New appointments are disabled. Patient records remain available.';

  @override
  String subscriptionExpiringBanner(int days) {
    return 'Your subscription expires in $days days. Please renew soon.';
  }

  @override
  String get subscriptionBlocked => 'Cannot book — clinic subscription has expired.';

  @override
  String get renewSubscription => 'Renew subscription';

  @override
  String get subscriptionRenewed => 'Subscription renewed successfully';

  @override
  String get viewPatientRecords => 'View patient records';

  @override
  String get assignedDoctors => 'Doctors';

  @override
  String get filterAll => 'All';

  @override
  String get activateSubscription => 'Activate subscription';

  @override
  String get doctorProfile => 'Doctor profile';

  @override
  String get noExpiry => 'No expiry date';

  @override
  String get doctorManagement => 'Doctor management';

  @override
  String get doctorManagementHint => 'Search doctors, view profiles, and manage assigned secretaries';

  @override
  String get adminDoctorSearchHint => 'Name, specialty, clinic, mobile, or email...';

  @override
  String get doctorInformation => 'Doctor information';

  @override
  String get assignedSecretaries => 'Assigned secretaries';

  @override
  String secretariesCount(int count) {
    return '$count secretaries';
  }

  @override
  String doctorSecretarySingle(String name) {
    return 'Secretary: $name';
  }

  @override
  String doctorSecretariesMultiple(String names) {
    return 'Secretaries: $names';
  }

  @override
  String doctorSecretariesMultipleWithMore(String names, int more) {
    return 'Secretaries: $names (+$more more)';
  }

  @override
  String get transferSecretary => 'Transfer';

  @override
  String get transferSecretaryTitle => 'Transfer secretary';

  @override
  String transferSecretaryHint(String name) {
    return 'Move $name to another doctor';
  }

  @override
  String get transferredSuccessfully => 'Transferred successfully';

  @override
  String secretaryAssignedToDoctor(String doctorName) {
    return 'Assigned to: $doctorName';
  }

  @override
  String get addSecretary => 'Add secretary';

  @override
  String get editSecretary => 'Edit secretary';

  @override
  String get deleteSecretary => 'Delete secretary';

  @override
  String get deleteSecretaryConfirm => 'Remove this secretary account? This cannot be undone.';

  @override
  String get noSecretariesAssigned => 'No secretaries assigned to this doctor';

  @override
  String get loadMore => 'Load more';

  @override
  String pageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get itemsPerPage => 'Per page';

  @override
  String get notAvailable => '—';

  @override
  String get clinicName => 'Clinic name';

  @override
  String get status => 'Status';

  @override
  String get doctorName => 'Doctor name';

  @override
  String get businessName => 'Business name';

  @override
  String get businessProfile => 'Business profile';

  @override
  String get editBusinessProfile => 'Edit business profile';

  @override
  String get editDoctorProfile => 'Edit doctor profile';

  @override
  String get aboutBusiness => 'About the business';

  @override
  String get businessDashboard => 'Business dashboard';

  @override
  String get linkedBusiness => 'Linked business';

  @override
  String get accountType => 'Account type';

  @override
  String get accountTypeDoctor => 'Doctor';

  @override
  String get accountTypeBusiness => 'Business';

  @override
  String get createBusinessAccount => 'Create business account';

  @override
  String get createBusinessAccountHint => 'Add a healthcare business with login credentials';

  @override
  String get selectBusinessCategory => 'Business category';

  @override
  String get searchProviders => 'Search doctors & businesses';

  @override
  String get searchHintProviders => 'Name, specialty, business category, clinic...';

  @override
  String get businessCategoryClinic => 'Clinic';

  @override
  String get businessCategoryBeautyCenter => 'Beauty center';

  @override
  String get businessCategoryMedicalLaboratory => 'Medical laboratory';

  @override
  String get businessCategoryRadiologyCenter => 'Radiology center';

  @override
  String get businessCategoryPhysiotherapyCenter => 'Physiotherapy center';

  @override
  String get businessCategoryDentalCenter => 'Dental center';

  @override
  String get businessCategoryEyeCenter => 'Eye center';

  @override
  String get businessCategoryHearingCenter => 'Hearing center';

  @override
  String get businessCategoryVaccinationCenter => 'Vaccination center';

  @override
  String get businessCategoryBloodTestCenter => 'Blood test center';

  @override
  String get businessCategoryPharmacy => 'Pharmacy';

  @override
  String get businessCategoryOtherHealthcare => 'Other healthcare services';

  @override
  String get noSecretariesAssignedBusiness => 'No secretaries assigned to this business';

  @override
  String get doctorsSection => 'Doctors';

  @override
  String get clinicsHealthcareCenters => 'Clinics & Healthcare Centers';

  @override
  String get searchDoctorsOnly => 'Search by doctor name or specialty';

  @override
  String get searchBusinessesOnly => 'Search by business name';

  @override
  String get noBusinessesFound => 'No businesses found';

  @override
  String get allBusinessCategories => 'All categories';

  @override
  String get browseHealthcare => 'Browse healthcare';

  @override
  String get browseDoctorsHint => 'Find doctors and join their queue';

  @override
  String get browseBusinessesHint => 'Clinics, labs, pharmacies and more';

  @override
  String get selectQueueSlot => 'Select queue time slot';

  @override
  String get selectTimeSlotHint => 'Choose an available time slot for your visit';

  @override
  String get noQueueSlotsAvailable => 'No queue slots available right now';

  @override
  String get joinQueue => 'Join queue';

  @override
  String get queueSlot => 'Queue slot';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System default';

  @override
  String get accountSecurity => 'Account & security';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordHint => 'Update your login password';

  @override
  String get changePasswordDescription => 'Enter your current password and choose a new secure password. Only you can change your own password.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get passwordChangeUnavailable => 'Password change is not available for this account type';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get passwordSameAsCurrent => 'New password must be different from the current password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get accountInfoReadOnly => 'Account details';

  @override
  String get accountInfoReadOnlyHint => 'Email, phone, account type, and permissions are managed by your clinic administrator';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get queueNotifications => 'Queue notifications';

  @override
  String get sound => 'Sound';

  @override
  String get vibration => 'Vibration';

  @override
  String get patientPreferences => 'Patient preferences';

  @override
  String get favoriteDoctors => 'Favorite doctors';

  @override
  String get favoriteBusinesses => 'Favorite businesses';

  @override
  String get noFavoriteDoctors => 'No favorite doctors yet';

  @override
  String get noFavoriteBusinesses => 'No favorite businesses yet';

  @override
  String get doctorSettings => 'Doctor settings';

  @override
  String get businessSettings => 'Business settings';

  @override
  String get workingDaysAndHours => 'Working days & hours';

  @override
  String get queueSettings => 'Queue settings';

  @override
  String get profileVisibility => 'Profile visibility';

  @override
  String get contactVisibility => 'Contact visibility';

  @override
  String get whatsappVisibility => 'WhatsApp visibility';

  @override
  String get secretarySettings => 'Secretary settings';

  @override
  String get queueAutoRefresh => 'Auto-refresh queue';

  @override
  String get queueAutoRefreshHint => 'Keep the queue view updated in real time';

  @override
  String get privacySettings => 'Privacy';

  @override
  String get showInSearchResults => 'Show in search results';

  @override
  String get showInSearchResultsHint => 'Allow your profile to appear in patient search';

  @override
  String get shareUsageAnalytics => 'Share usage analytics';

  @override
  String get shareUsageAnalyticsHint => 'Help improve Tabib with anonymous usage data';

  @override
  String get supportAndLegal => 'Support & legal';

  @override
  String get about => 'About';

  @override
  String get helpAndSupport => 'Help & support';

  @override
  String get termsAndConditions => 'Terms & conditions';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get appVersion => 'App version';

  @override
  String get providerSettings => 'Provider settings';

  @override
  String get queueNotificationsProviderHint => 'Notify when patients join or move in the queue';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get patient => 'Patient';

  @override
  String get secretary => 'Secretary';

  @override
  String get admin => 'Admin';

  @override
  String get bio => 'Bio';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get degrees => 'Degrees';

  @override
  String get experience => 'Experience';

  @override
  String get error => 'Something went wrong';

  @override
  String get termsContent => 'By using Tabib you agree to follow clinic queue rules, respect healthcare staff, and use the app only for legitimate medical appointments and queue management. Misuse may result in account suspension.';

  @override
  String get privacyPolicyContent => 'Tabib collects only the data needed to manage queues, appointments, and clinic communication. Your information is not sold to third parties. Contact your clinic administrator for data access requests.';

  @override
  String aboutContent(String version) {
    return 'Tabib v$version — a modern healthcare queue and clinic management platform for patients, doctors, businesses, and secretaries.';
  }

  @override
  String helpContent(String email) {
    return 'Need help? Email us at $email or contact your clinic administrator for account and queue issues.';
  }

  @override
  String get accountStatusActive => 'Active';

  @override
  String get accountStatusSuspended => 'Suspended';

  @override
  String get accountStatusDisabled => 'Disabled';

  @override
  String get accountStatusExpiredSubscription => 'Expired subscription';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get changeAccountStatus => 'Change account status';

  @override
  String get accountSuspendedMessage => 'This account has been suspended. Contact your clinic administrator.';

  @override
  String get accountDisabledMessage => 'This account has been disabled. Contact your clinic administrator.';

  @override
  String get accountSubscriptionExpiredLoginMessage => 'Access is blocked because the clinic subscription has expired. Please renew to continue.';

  @override
  String get managePatients => 'Manage patients';

  @override
  String get managePatientsHint => 'View patient accounts and manage their status';

  @override
  String get manageAdmins => 'Manage admins';

  @override
  String get manageAdminsHint => 'Create admins and assign individual permissions';

  @override
  String get createAdminAccount => 'Create admin account';

  @override
  String get editAdminAccount => 'Edit admin account';

  @override
  String get deleteAdminAccount => 'Delete admin account';

  @override
  String get deleteAdminAccountConfirm => 'Remove this admin account? This cannot be undone.';

  @override
  String get noAdminAccounts => 'No admin accounts yet';

  @override
  String get adminPermissionsTitle => 'Permissions';

  @override
  String get adminPermissionsRequired => 'Select at least one permission';

  @override
  String get permManageDoctors => 'Manage doctors';

  @override
  String get permManageBusinesses => 'Manage businesses';

  @override
  String get permManageSecretaries => 'Manage secretaries';

  @override
  String get permManagePatients => 'Manage patients';

  @override
  String get permManageSubscriptions => 'Manage subscriptions';

  @override
  String get permViewReports => 'View reports';

  @override
  String get permSendNotifications => 'Send notifications';

  @override
  String get permResetPasswords => 'Reset passwords';

  @override
  String get permSuspendAccounts => 'Suspend accounts';

  @override
  String get permDeleteAccounts => 'Delete accounts';

  @override
  String get permManageCategories => 'Manage categories';

  @override
  String get permViewAnalytics => 'View analytics';

  @override
  String get permCreateAdmins => 'Create admins';

  @override
  String get permManageAdmins => 'Manage admins';
}
