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
  String get yourTurn => 'Your turn';

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
  String get queueNotifyTenRemaining => 'Almost your turn';

  @override
  String get queueNotifyTenRemainingBody => 'Only 10 patients remain before your turn. Please prepare to come.';

  @override
  String get queueNotifyFiveRemaining => 'Head to the clinic';

  @override
  String get queueNotifyFiveRemainingBody => 'Only 5 patients remain before your turn. Please head toward the clinic.';

  @override
  String get queueNotifyThreeRemaining => 'Arrive now';

  @override
  String get queueNotifyThreeRemainingBody => 'Your turn is very close. Please arrive at the clinic now.';

  @override
  String get queueNotifyYourTurn => 'Your turn now';

  @override
  String get queueNotifyYourTurnBody => 'It is now your turn. Please proceed to the doctor\'s room.';

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
  String get adminDoctorSearchHint => 'Name, specialty, clinic, mobile, email, or account code (e.g. DR-10025)...';

  @override
  String get accountCode => 'Account code';

  @override
  String get doctorAccountCode => 'Doctor account code';

  @override
  String get doctorAccountCodeRequired => 'Enter and verify a valid provider account code';

  @override
  String get invalidDoctorAccountCode => 'No provider found with this account code.';

  @override
  String get accountCodeFormatInvalid => 'Enter a valid account code (e.g. DR-10025 or BZ-10001).';

  @override
  String get verifyAccountCode => 'Verify';

  @override
  String get secretaryLinkProviderPreview => 'Confirm linked provider';

  @override
  String doctorAccountCodeLabel(String code) {
    return 'Doctor Account Code: $code';
  }

  @override
  String linkedToAccountCode(String code) {
    return 'Linked to: $code';
  }

  @override
  String get supportHistory => 'Support history';

  @override
  String get supportHistoryHint => 'Subscription renewals, support requests, and troubleshooting notes tied to this account code.';

  @override
  String get noSupportHistory => 'No support activity recorded yet.';

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

  @override
  String get systemOwnerDashboard => 'System Owner Dashboard';

  @override
  String get systemOwnerDashboardHint => 'Manage the platform, users, subscriptions, and system settings.';

  @override
  String get systemOwnerModules => 'Administrative modules';

  @override
  String get dashboardOverview => 'Dashboard overview';

  @override
  String get businessManagement => 'Business management';

  @override
  String get secretaryManagement => 'Secretary management';

  @override
  String get addNewSecretary => 'Add new secretary';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get secretaryPasswordResetSuccess => 'Secretary password updated successfully';

  @override
  String get secretaryPasswordResetEmailSent => 'A password reset link was sent to the secretary';

  @override
  String get resetSecretaryPasswordFirebaseHint => 'A password reset email will be sent to the secretary\'s login address.';

  @override
  String get enableAccount => 'Enable account';

  @override
  String get disableAccount => 'Disable account';

  @override
  String get unassignedSecretaries => 'Unassigned secretaries';

  @override
  String get noSecretariesYet => 'No secretaries yet';

  @override
  String get patientManagement => 'Patient management';

  @override
  String get subscriptionManagement => 'Subscription management';

  @override
  String get packageManagement => 'Package management';

  @override
  String get payments => 'Payments';

  @override
  String get reports => 'Reports';

  @override
  String get analytics => 'Analytics';

  @override
  String get systemSettings => 'System settings';

  @override
  String get moduleComingSoon => 'This module will be available in a future update.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get ownerNavSubscriptionsPackages => 'Subscriptions & packages';

  @override
  String get paymentsBilling => 'Payments & billing';

  @override
  String get feedbackSupport => 'Feedback & support';

  @override
  String get notificationsCenter => 'Notifications center';

  @override
  String get reportsAnalytics => 'Reports & analytics';

  @override
  String get systemHealth => 'System health';

  @override
  String get auditLog => 'Audit log';

  @override
  String get securityCenter => 'Security center';

  @override
  String get backupRestore => 'Backup & restore';

  @override
  String get totalBusinesses => 'Total businesses';

  @override
  String get totalPatients => 'Total patients';

  @override
  String get activeUsersToday => 'Active users';

  @override
  String get expiredSubscriptions => 'Expired subscriptions';

  @override
  String get revenueOverview => 'Revenue overview';

  @override
  String get newRegistrations => 'New registrations';

  @override
  String get liveQueueStatistics => 'Live queue statistics';

  @override
  String get queueWaiting => 'Waiting';

  @override
  String get queueInProgress => 'In progress';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get allBusinesses => 'All businesses';

  @override
  String get allBusinessesHint => 'View and manage every business on the platform';

  @override
  String get businessCategoryBrowseHint => 'Browse providers in this category';

  @override
  String get subscriptionPackagesHint => 'Manage clinic plans, renewals, and expiration alerts';

  @override
  String get createPackages => 'Create packages';

  @override
  String get createPackagesHint => 'Define subscription tiers for clinics';

  @override
  String get subscriptionPlanHint => 'Open subscription management for this plan';

  @override
  String get plan1Month => '1 month';

  @override
  String get plan2Months => '2 months';

  @override
  String get plan3Months => '3 months';

  @override
  String get plan6Months => '6 months';

  @override
  String get plan12Months => '12 months';

  @override
  String get activateSubscriptionHint => 'Enable a clinic subscription plan';

  @override
  String get renewSubscriptionHint => 'Extend an existing clinic subscription';

  @override
  String get suspendSubscription => 'Suspend subscription';

  @override
  String get suspendSubscriptionHint => 'Temporarily block subscription access';

  @override
  String get remainingDays => 'Remaining days';

  @override
  String get remainingDaysHint => 'View days left on each clinic plan';

  @override
  String get expirationAlerts => 'Expiration alerts';

  @override
  String get expirationAlertsHint => 'Monitor clinics nearing expiry';

  @override
  String get paymentsBillingHint => 'Invoices, billing, and payment methods';

  @override
  String get invoices => 'Invoices';

  @override
  String get invoicesHint => 'View and export platform invoices';

  @override
  String get billingOverview => 'Billing overview';

  @override
  String get billingOverviewHint => 'Summary of platform billing activity';

  @override
  String get paymentMethods => 'Payment methods';

  @override
  String get paymentMethodsHint => 'Configure accepted payment methods';

  @override
  String get feedbackSupportHint => 'User feedback and support requests';

  @override
  String get bugReports => 'Bug reports';

  @override
  String get bugReportsHint => 'Review reported software issues';

  @override
  String get featureRequests => 'Feature requests';

  @override
  String get featureRequestsHint => 'Ideas submitted by users';

  @override
  String get userFeedback => 'User feedback';

  @override
  String get userFeedbackHint => 'General platform feedback';

  @override
  String get supportConversations => 'Support conversations';

  @override
  String get supportConversationsHint => 'Messages with users needing help';

  @override
  String get notificationsCenterHint => 'Broadcast and system notifications';

  @override
  String get broadcastNotifications => 'Broadcast notifications';

  @override
  String get broadcastNotificationsHint => 'Send announcements to all users';

  @override
  String get subscriptionReminders => 'Subscription reminders';

  @override
  String get subscriptionRemindersHint => 'Automated renewal reminders';

  @override
  String get maintenanceAnnouncements => 'Maintenance announcements';

  @override
  String get maintenanceAnnouncementsHint => 'Scheduled downtime notices';

  @override
  String get reportsAnalyticsHint => 'Platform reports and growth analytics';

  @override
  String get reportDaily => 'Daily report';

  @override
  String get reportDailyHint => 'Today\'s platform activity';

  @override
  String get reportWeekly => 'Weekly report';

  @override
  String get reportWeeklyHint => 'Last 7 days summary';

  @override
  String get reportMonthly => 'Monthly report';

  @override
  String get reportMonthlyHint => 'Last 30 days summary';

  @override
  String get reportYearly => 'Yearly report';

  @override
  String get reportYearlyHint => 'Annual platform summary';

  @override
  String get queueStatistics => 'Queue statistics';

  @override
  String get queueStatisticsHint => 'Waiting times and queue volume';

  @override
  String get appointmentStatistics => 'Appointment statistics';

  @override
  String get appointmentStatisticsHint => 'Bookings and completion rates';

  @override
  String get revenueStatistics => 'Revenue statistics';

  @override
  String get revenueStatisticsHint => 'Subscription and payment revenue';

  @override
  String get userGrowth => 'User growth';

  @override
  String get userGrowthHint => 'New users over time';

  @override
  String get systemHealthHint => 'Infrastructure and service status';

  @override
  String get firebaseStatus => 'Firebase status';

  @override
  String get statusConnected => 'Connected and configured';

  @override
  String get statusDemoOrOffline => 'Demo mode or not configured';

  @override
  String get storageUsage => 'Storage usage';

  @override
  String get databaseUsage => 'Database usage';

  @override
  String get clinicsLabel => 'clinics';

  @override
  String get accountsLabel => 'accounts';

  @override
  String get errorLogs => 'Error logs';

  @override
  String get errorLogsHint => 'Application error history';

  @override
  String get crashReports => 'Crash reports';

  @override
  String get crashReportsHint => 'Client crash summaries';

  @override
  String get performanceMonitoring => 'Performance monitoring';

  @override
  String get performanceMonitoringHint => 'Latency and load metrics';

  @override
  String get noAuditEntries => 'No audit entries yet';

  @override
  String get user => 'User';

  @override
  String get device => 'Device';

  @override
  String get ipAddress => 'IP address';

  @override
  String get securityCenterHint => 'Login activity and account protection';

  @override
  String get loginHistory => 'Login history';

  @override
  String get loginHistoryHint => 'Recent sign-in events';

  @override
  String get activeSessions => 'Active sessions';

  @override
  String get activeSessionsHint => 'Devices currently signed in';

  @override
  String get failedLoginAttempts => 'Failed login attempts';

  @override
  String get failedLoginAttemptsHint => 'Blocked or suspicious sign-ins';

  @override
  String get blockedAccounts => 'Blocked accounts';

  @override
  String get blockedAccountsHint => 'Suspended and disabled accounts';

  @override
  String get passwordResetLogs => 'Password reset logs';

  @override
  String get passwordResetLogsHint => 'Recent password reset requests';

  @override
  String get backupRestoreHint => 'Protect and restore platform data';

  @override
  String get manualBackup => 'Manual backup';

  @override
  String get manualBackupHint => 'Create an on-demand backup';

  @override
  String get automaticBackup => 'Automatic backup';

  @override
  String get automaticBackupHint => 'Schedule recurring backups';

  @override
  String get restoreData => 'Restore data';

  @override
  String get restoreDataHint => 'Restore from a backup snapshot';

  @override
  String get systemSettingsHint => 'Platform-wide configuration';

  @override
  String get languageSettingsHint => 'Default and supported languages';

  @override
  String get themeSettingsHint => 'Light, dark, and branding options';

  @override
  String get notificationSettingsHint => 'System notification defaults';

  @override
  String get featureFlags => 'Feature flags';

  @override
  String get featureFlagsHint => 'Enable or disable platform features';

  @override
  String get maintenanceMode => 'Maintenance mode';

  @override
  String get maintenanceModeHint => 'Take the platform offline for maintenance';

  @override
  String get businessType => 'Business type';

  @override
  String get addBusinessType => 'Add business type';

  @override
  String get localizedTypeHint => 'Enter Kurdish, Arabic, and English names (all three required). Users see the label in their selected language.';

  @override
  String get translationRequired => 'This translation is required';

  @override
  String get translationsIncomplete => 'Missing translations — edit to add Kurdish, Arabic, and English';

  @override
  String get typeToSearchOrCreate => 'Type to search or create';

  @override
  String get businessTypeSearchHint => 'Type at least 2 characters to search, or pick a recently used type below.';

  @override
  String get specialtySearchHint => 'Type at least 2 characters to search specialties.';

  @override
  String get noBusinessTypeFound => 'No Business Type found.';

  @override
  String get noSpecialtyFound => 'No specialty found.';

  @override
  String get createNewBusinessType => '+ Create New Business Type';

  @override
  String get recentlyUsedBusinessTypes => 'Recently used';

  @override
  String createNewType(String name) {
    return 'Create \"$name\"';
  }

  @override
  String get completeProfileBanner => 'Complete your profile — add clinic name, address, hours, photos, and contact details.';

  @override
  String get completeProfileAction => 'Complete profile';

  @override
  String get manageBusinessTypes => 'Business types';

  @override
  String get manageBusinessTypesHint => 'Create, translate, and enable centralized business types';

  @override
  String get editBusinessType => 'Edit business type';

  @override
  String get businessTypeActive => 'Active';

  @override
  String get businessTypeActiveHint => 'Inactive types are hidden from patients until enabled and assigned';

  @override
  String get businessTypeDuplicate => 'This business type already exists';

  @override
  String get noBusinessTypesYet => 'No business types yet. Add one to get started.';

  @override
  String businessTypeAssignedCount(int count) {
    return '$count businesses assigned';
  }

  @override
  String get allBusinessTypes => 'All business types';

  @override
  String get iconName => 'Icon name';

  @override
  String get myQueues => 'My queues';

  @override
  String get sortClosestAppointment => 'Closest appointment';

  @override
  String get sortRecentlyJoined => 'Recently joined';

  @override
  String get sortDoctorName => 'Doctor name';

  @override
  String get refresh => 'Refresh';

  @override
  String get viewProfile => 'View profile';

  @override
  String get patientProfile => 'Profile';

  @override
  String get city => 'City';

  @override
  String get genderOptional => 'Gender (optional)';

  @override
  String get showProfilePhoto => 'Show profile photo';

  @override
  String get showPhoneNumber => 'Show phone number';

  @override
  String get profileVisibleToVisitedOnly => 'Profile visible only to visited providers';

  @override
  String get recentlyVisited => 'Recently visited';

  @override
  String get nearbyProviders => 'Nearby';

  @override
  String get recommendedDoctors => 'Recommended doctors';

  @override
  String get recommendedBusinesses => 'Recommended businesses';

  @override
  String get activeQueues => 'Active queues';

  @override
  String get advertisements => 'Advertisements';

  @override
  String get enableLocation => 'Enable location';

  @override
  String get locationRequiredForNearby => 'Allow location access to see nearby providers.';

  @override
  String get alreadyInSameQueue => 'You are already in this queue for the selected time.';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get saveFailed => 'Could not save changes';

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get searchProvidersHint => 'Doctor, business, specialty, or city...';

  @override
  String get viewAll => 'View all';

  @override
  String get bookAgain => 'Book again';

  @override
  String get setCityForAds => 'Set your city in Profile to see local health offers.';

  @override
  String get advertisementDetails => 'Advertisement';

  @override
  String get advertisementNotFound => 'This advertisement is no longer available.';

  @override
  String get viewDetails => 'View details';

  @override
  String get currentServing => 'Now serving';

  @override
  String get queueStatusServing => 'Serving';

  @override
  String get queueStatusFinished => 'Finished';

  @override
  String get queueProgress => 'Queue progress';

  @override
  String get sortQueueProgress => 'Queue progress';

  @override
  String get nearbyHealthcareCenters => 'Nearby healthcare centers';

  @override
  String get recommendedHealthcareCenters => 'Recommended healthcare centers';

  @override
  String get noNearbyProviders => 'No nearby providers found in your area.';

  @override
  String get callClinic => 'Call clinic';

  @override
  String get openMap => 'Open map';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get cancelQueueConfirm => 'Are you sure you want to cancel this queue?';

  @override
  String get notNow => 'Not now';

  @override
  String get memberSince => 'Member since';

  @override
  String get completedVisits => 'Completed visits';

  @override
  String get upcomingAppointments => 'Upcoming appointments';

  @override
  String get birthDate => 'Birth date';

  @override
  String get bloodType => 'Blood type';

  @override
  String get emergencyContact => 'Emergency contact';

  @override
  String get mobile => 'Mobile';

  @override
  String get profileStatistics => 'Statistics';

  @override
  String get accountDetails => 'Account details';

  @override
  String get appearanceAndPrivacy => 'Appearance & privacy';

  @override
  String get noActiveQueuesOnProfile => 'You have no active queues. Browse doctors to join a queue.';

  @override
  String get noFavoriteDoctorsYet => 'No favorite doctors yet. Tap the heart on a doctor profile.';

  @override
  String get notificationSystemSettings => 'Smart notification system';

  @override
  String get notificationSystemSettingsHint => 'Channels, queue thresholds, and multilingual templates';

  @override
  String get notificationChannels => 'Notification channels';

  @override
  String get pushNotificationsOwnerHint => 'Send push when the patient has the app installed';

  @override
  String get whatsappNotifications => 'WhatsApp';

  @override
  String get smsNotifications => 'SMS';

  @override
  String get smsNotificationsHint => 'Requires clinic SMS provider (simulated in demo)';

  @override
  String get inAppNotifications => 'In-app';

  @override
  String get queueAlertThresholds => 'Queue alert thresholds';

  @override
  String get queueAlertThresholdsHint => 'Notify patients when this many people remain before their turn';

  @override
  String get notificationTemplates => 'Notification templates';

  @override
  String get notificationTemplatesHint => 'Use PatientName, DoctorName, DelayMinutes, and AppointmentTime as placeholders in curly braces';

  @override
  String get notificationType => 'Notification type';

  @override
  String get templateVariablesHint => 'Template body with placeholders';

  @override
  String get saveTemplate => 'Save template';

  @override
  String get templateSaved => 'Template saved';

  @override
  String get reminderNotifications => 'Reminder notifications';

  @override
  String get reminderNotificationsHint => 'Queue and appointment reminders';

  @override
  String get preferredNotificationLanguage => 'Notification language';

  @override
  String get followAppLanguage => 'Follow app language';

  @override
  String get preferredNotificationMethod => 'Preferred delivery method';

  @override
  String get notificationMethodAutomatic => 'Automatic (best available)';

  @override
  String get sentBy => 'Sent by';

  @override
  String get notificationOpened => 'Opened';

  @override
  String get deliveryPending => 'Pending';

  @override
  String get deliverySent => 'Sent';

  @override
  String get deliveryDelivered => 'Delivered';

  @override
  String get deliveryFailed => 'Failed';

  @override
  String get deliverySkipped => 'Skipped';

  @override
  String get missedTurnNotification => 'Missed turn';

  @override
  String get doctorDelayNotification => 'Doctor delay';

  @override
  String get appointmentConfirmed => 'Appointment confirmed';

  @override
  String get appointmentRescheduled => 'Appointment rescheduled';

  @override
  String get appointmentCancelled => 'Appointment cancelled';

  @override
  String get doctorUnavailable => 'Doctor unavailable';

  @override
  String get clinicClosedUnexpectedly => 'Clinic closed unexpectedly';

  @override
  String get recallPatient => 'Recall patient';

  @override
  String get moveToEndOfQueue => 'Move to end';

  @override
  String get cancelAppointment => 'Cancel appointment';

  @override
  String get patientRecalled => 'Patient recalled to queue';

  @override
  String get patientMovedToEnd => 'Patient moved to end of queue';

  @override
  String get notifyDoctorDelay => 'Notify waiting patients of delay';

  @override
  String get notifyDelayShort => 'Delay alert';

  @override
  String get delayMinutes => 'Delay (minutes)';

  @override
  String get sendNotification => 'Send';

  @override
  String get delayNotificationSent => 'Delay notification sent to waiting patients';

  @override
  String get contactActionCall => 'Call';

  @override
  String get contactActionWhatsApp => 'WhatsApp';

  @override
  String get contactActionSms => 'SMS';

  @override
  String get chooseMessageTemplate => 'Choose a message';

  @override
  String get contactTemplateQueueReminder => 'Hello, your turn in the queue is approaching. Please prepare to come to the clinic.';

  @override
  String get contactTemplateYourTurn => 'Hello, it is now your turn. Please proceed to the doctor\'s room.';

  @override
  String get contactTemplateAppointmentReminder => 'Hello, this is a reminder about your upcoming appointment.';

  @override
  String get contactTemplateFollowUp => 'Hello, please contact the clinic regarding your recent visit.';

  @override
  String get contactTemplateCustom => 'Write a custom message';

  @override
  String get searchPatientsHint => 'Search patients by name or phone';

  @override
  String get communicationAuditLog => 'Staff communication log';

  @override
  String get noCommunicationLogs => 'No staff communication attempts recorded yet.';

  @override
  String get monitoringCenterTitle => 'System Health & Monitoring Center';

  @override
  String get monitoringCenterHint => 'Live platform status, analytics, security, and infrastructure monitoring';

  @override
  String get liveStatistics => 'Live statistics';

  @override
  String get usersSection => 'Users';

  @override
  String get totalUsers => 'Total users';

  @override
  String get onlineUsers => 'Online users';

  @override
  String get activeDoctors => 'Active doctors';

  @override
  String get suspendedDoctors => 'Suspended doctors';

  @override
  String get onlineDoctors => 'Online doctors';

  @override
  String get secretariesSection => 'Secretaries';

  @override
  String get onlineSecretaries => 'Online secretaries';

  @override
  String get recentSecretaries => 'Recently added secretaries';

  @override
  String get businessesSection => 'Businesses';

  @override
  String get beautyCenters => 'Beauty centers';

  @override
  String get laboratories => 'Laboratories';

  @override
  String get pharmacies => 'Pharmacies';

  @override
  String get otherHealthcare => 'Other healthcare centers';

  @override
  String get patientsSection => 'Patients';

  @override
  String get onlinePatients => 'Online patients';

  @override
  String get newPatientsToday => 'New patients today';

  @override
  String get completedQueuesToday => 'Completed queues today';

  @override
  String get cancelledQueues => 'Cancelled queues';

  @override
  String get avgWaitingTime => 'Average waiting time';

  @override
  String get todaysAppointments => 'Today\'s appointments';

  @override
  String get missedAppointments => 'Missed appointments';

  @override
  String get cancelledAppointments => 'Cancelled appointments';

  @override
  String get firebaseMonitoring => 'Firebase monitoring';

  @override
  String get firestoreReads => 'Firestore read operations';

  @override
  String get firestoreWrites => 'Firestore write operations';

  @override
  String get imageStorageUsage => 'Image storage usage';

  @override
  String get responseTime => 'Response time';

  @override
  String get cacheStatus => 'Cache status';

  @override
  String get lastSynchronization => 'Last synchronization';

  @override
  String get storageUsagePercent => 'Storage usage';

  @override
  String get cpuUsage => 'CPU usage';

  @override
  String get memoryUsage => 'Memory usage';

  @override
  String get avgApiResponse => 'Average API response time';

  @override
  String get slowQueries => 'Slow queries';

  @override
  String get backgroundTasks => 'Background tasks';

  @override
  String get cachePerformance => 'Cache performance';

  @override
  String get notificationMonitoring => 'Notification monitoring';

  @override
  String get pushSent => 'Push notifications sent';

  @override
  String get whatsappSent => 'WhatsApp messages sent';

  @override
  String get smsSent => 'SMS messages sent';

  @override
  String get failedNotifications => 'Failed notifications';

  @override
  String get pendingNotifications => 'Pending notifications';

  @override
  String get advertisementMonitoring => 'Advertisement monitoring';

  @override
  String get activeAdvertisements => 'Active advertisements';

  @override
  String get scheduledAdvertisements => 'Scheduled advertisements';

  @override
  String get expiredAdvertisements => 'Expired advertisements';

  @override
  String get adViews => 'Advertisement views';

  @override
  String get adClicks => 'Advertisement clicks';

  @override
  String get clickRate => 'Click rate';

  @override
  String get revenueDashboard => 'Revenue dashboard';

  @override
  String get monthlyRevenue => 'Monthly revenue';

  @override
  String get annualRevenue => 'Annual revenue';

  @override
  String get activePackages => 'Active packages';

  @override
  String get packagesExpiringSoon => 'Packages expiring soon';

  @override
  String get renewalsToday => 'Renewals today';

  @override
  String get lockedAccounts => 'Locked accounts';

  @override
  String get suspiciousLogins => 'Suspicious login activity';

  @override
  String get terminateSession => 'Terminate session';

  @override
  String get errorMonitoring => 'Error monitoring';

  @override
  String get logsExported => 'Logs exported to clipboard';

  @override
  String get exportLogs => 'Export logs';

  @override
  String get markFixed => 'Mark as fixed';

  @override
  String get ignoreError => 'Ignore';

  @override
  String get lastBackup => 'Last backup';

  @override
  String get backupSize => 'Backup size';

  @override
  String get backupStatus => 'Backup status';

  @override
  String get nextScheduledBackup => 'Next scheduled backup';

  @override
  String get backupCompleted => 'Backup completed successfully';

  @override
  String get restoreBackupHint => 'Restore from backup is available in production deployments';

  @override
  String get restoreBackup => 'Restore backup';

  @override
  String get backupReportDownloaded => 'Backup report downloaded';

  @override
  String get downloadBackupReport => 'Download backup report';

  @override
  String get liveActivityFeed => 'Live activity feed';

  @override
  String get dailyRegistrations => 'Daily registrations';

  @override
  String get dailyQueues => 'Daily queues';

  @override
  String get dailyAppointments => 'Daily appointments';

  @override
  String get adPerformance => 'Advertisement performance';

  @override
  String get activeUsersChart => 'Active users';

  @override
  String get businessGrowth => 'Business growth';

  @override
  String get reportExportedCsv => 'Report exported as CSV';

  @override
  String get enableMaintenanceMode => 'Enable maintenance mode';

  @override
  String get maintenanceMessage => 'Maintenance message';

  @override
  String get systemHealthy => 'Healthy';

  @override
  String get systemWarning => 'Warning';

  @override
  String get systemCritical => 'Critical';

  @override
  String get filterToday => 'Today';

  @override
  String get filterThisWeek => 'This week';

  @override
  String get filterThisMonth => 'This month';

  @override
  String get filterThisYear => 'This year';

  @override
  String get filterCustomRange => 'Custom range';

  @override
  String reportExported(String format) {
    return 'Report exported as $format';
  }

  @override
  String get dashboardCachedData => 'Showing cached dashboard data';

  @override
  String get dashboardLiveDataUnavailable => 'Live data is temporarily unavailable';

  @override
  String get dashboardLastSync => 'Last synchronized';

  @override
  String get dashboardRefreshNow => 'Refresh now';

  @override
  String get dashboardRefreshing => 'Refreshing…';

  @override
  String get dashboardChartsLoading => 'Loading charts…';

  @override
  String get showActivityFeed => 'Show activity feed';

  @override
  String get showReports => 'Show reports';

  @override
  String get showAuditLog => 'Show audit log';

  @override
  String get messageSeen => 'Seen';

  @override
  String get attachImage => 'Attach image';

  @override
  String userIsTyping(String userName) {
    return '$userName is typing…';
  }

  @override
  String get metricNotAvailable => 'N/A';

  @override
  String get monitoringPhase1Hint => 'Live infrastructure health — Firebase, performance, and smart alerts';

  @override
  String get ownerSmartAlerts => 'Smart owner alerts';

  @override
  String get noActiveAlerts => 'No active infrastructure alerts. All systems operating normally.';

  @override
  String get alertFirebaseDisconnected => 'Firebase is disconnected';

  @override
  String get alertBackupFailed => 'Last backup failed';

  @override
  String alertStorageHigh(String percent) {
    return 'Storage usage is at $percent%';
  }

  @override
  String get alertSlowResponse => 'High API response time detected';

  @override
  String get alertHighErrorRate => 'High application error rate detected';

  @override
  String get monitoringPhase2Hint => 'Live platform statistics — auto-refreshes every 60 seconds from aggregated metrics';

  @override
  String get activityFilterLastHour => 'Last hour';

  @override
  String get activityFilterAll => 'All';

  @override
  String get activeToday => 'Active today';

  @override
  String get newRegistrationsToday => 'New registrations today';

  @override
  String get secretariesWithoutDoctor => 'Secretaries without doctor';

  @override
  String get waitingPatients => 'Waiting patients';

  @override
  String get expiredPackages => 'Expired packages';

  @override
  String get cancelledQueuesToday => 'Cancelled today';

  @override
  String get clinicsStat => 'Clinics';

  @override
  String get queuesSection => 'Queues';

  @override
  String get appointmentsSection => 'Appointments';

  @override
  String get noActivityEvents => 'No activity events for the selected period';

  @override
  String waitingMinutesLabel(int minutes) {
    return '$minutes min';
  }

  @override
  String get activityEventDoctorCreated => 'Doctor created';

  @override
  String get activityEventDoctorUpdated => 'Doctor updated';

  @override
  String get activityEventSecretaryAdded => 'Secretary added';

  @override
  String get activityEventPatientRegistered => 'Patient registered';

  @override
  String get activityEventBusinessCreated => 'Business created';

  @override
  String get activityEventQueueJoined => 'Queue joined';

  @override
  String get activityEventQueueCancelled => 'Queue cancelled';

  @override
  String get activityEventAppointmentBooked => 'Appointment booked';

  @override
  String get activityEventAppointmentCancelled => 'Appointment cancelled';

  @override
  String get activityEventAdvertisementCreated => 'Advertisement created';

  @override
  String get activityEventPackageActivated => 'Package activated';

  @override
  String get activityEventPackageRenewed => 'Package renewed';

  @override
  String get activityEventLogin => 'Login';

  @override
  String get activityEventLogout => 'Logout';

  @override
  String get monitoringPhase3AnalyticsHint => 'Interactive analytics — charts load lazily and cache per date range';

  @override
  String get filterYesterday => 'Yesterday';

  @override
  String get filterLast7Days => 'Last 7 days';

  @override
  String get doctorGrowthChart => 'Doctor growth';

  @override
  String get queueWaitingTrends => 'Queue waiting trends';

  @override
  String get todaysRevenue => 'Today\'s revenue';

  @override
  String get avgRevenuePerDoctor => 'Average revenue per doctor';

  @override
  String get advertisementRevenue => 'Advertisement revenue';

  @override
  String get lockedStatus => 'Locked';

  @override
  String get lockUser => 'Lock user';

  @override
  String get unlockUser => 'Unlock user';

  @override
  String get forceLogout => 'Force logout';

  @override
  String get errorTypeLabel => 'Error type';

  @override
  String get stackTrace => 'Stack trace';

  @override
  String get deleteError => 'Delete';

  @override
  String get runManualBackup => 'Run manual backup';

  @override
  String get backupHistory => 'Backup history';

  @override
  String get auditSearchHint => 'Search audit log…';

  @override
  String get generateReports => 'Generate reports';

  @override
  String get reportsFilterHint => 'Select a date range, then export platform metrics';

  @override
  String get aiInsightsCenter => 'AI Insights Center';

  @override
  String get aiInsightsHint => 'Automated recommendations from aggregated platform metrics';

  @override
  String get priorityHigh => 'High priority';

  @override
  String get priorityMedium => 'Medium priority';

  @override
  String get priorityLow => 'Low priority';

  @override
  String get forecastDashboard => 'Forecast dashboard';

  @override
  String get forecastNext7Days => 'Next 7 days';

  @override
  String get forecastNextMonth => 'Next month';

  @override
  String get forecastNextYear => 'Next year';

  @override
  String get smartOwnerNotifications => 'Smart owner notifications';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get archiveNotification => 'Archive';

  @override
  String get firebaseCostOptimizer => 'Firebase cost optimizer';

  @override
  String get estimatedMonthlyCost => 'Estimated monthly cost';

  @override
  String get bandwidthUsage => 'Bandwidth usage';

  @override
  String get optimizationSuggestions => 'Optimization suggestions';

  @override
  String get globalSearchHint => 'Search doctors, patients, businesses, ads, audit logs…';

  @override
  String get globalDashboardFilters => 'Global dashboard filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get filterByCity => 'City';

  @override
  String get filterByBusiness => 'Business';

  @override
  String get filterByDoctor => 'Doctor';

  @override
  String get filterByStatus => 'Status';

  @override
  String get statusActive => 'Active';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String filterScaleHint(String percent) {
    return 'Showing ~$percent% of platform metrics for selected filters';
  }

  @override
  String get themeAndAppearance => 'Theme & appearance';

  @override
  String get themeAppearanceHint => 'Customize the monitoring center look and feel';

  @override
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

  @override
  String get systemMode => 'System';

  @override
  String get accentColor => 'Accent color';

  @override
  String get cardDensity => 'Card density';

  @override
  String get compactMode => 'Compact';

  @override
  String get comfortableMode => 'Comfortable';

  @override
  String get dashboardLayout => 'Dashboard layout';

  @override
  String get layoutStandard => 'Standard';

  @override
  String get layoutWide => 'Wide';

  @override
  String get layoutFocused => 'Focused';

  @override
  String get advancedSystemSettings => 'Advanced system settings';

  @override
  String get useAggregatedMetrics => 'Use aggregated metrics documents';

  @override
  String get warnBeforeExpensiveOps => 'Warn before expensive operations';

  @override
  String get queueRealtimeEnabled => 'Real-time queue updates';

  @override
  String get autoCleanupListeners => 'Auto-cleanup idle listeners';

  @override
  String get cityTargeting => 'City-targeted advertisements';

  @override
  String get renewalReminders => 'Package renewal reminders';

  @override
  String get autoBackup => 'Automatic backups';

  @override
  String get superOwner => 'Super Owner';

  @override
  String get superOwnerDashboard => 'Super Owner Dashboard';

  @override
  String get superOwnerDashboardHint => 'Monitor all organizations, platform revenue, and subscription plans.';

  @override
  String get totalOrganizations => 'Total organizations';

  @override
  String get activeOrganizations => 'Active organizations';

  @override
  String get suspendedOrganizations => 'Suspended organizations';

  @override
  String get platformRevenue => 'Platform revenue';

  @override
  String get firebaseUsage => 'Firebase usage';

  @override
  String get createOrganization => 'Create organization';

  @override
  String get suspendOrganization => 'Suspend organization';

  @override
  String get deleteOrganization => 'Delete organization';

  @override
  String get organizationName => 'Organization name';

  @override
  String get organizationSettings => 'Organization settings';

  @override
  String get organizationSettingsHint => 'Customize branding, language, and rules for your organization.';

  @override
  String get organizationBilling => 'Organization billing';

  @override
  String get organizationBillingHint => 'View your plan, usage limits, and payment history.';

  @override
  String get currentPlan => 'Current plan';

  @override
  String get expirationDate => 'Expiration date';

  @override
  String get usageLimits => 'Usage limits';

  @override
  String get upgradePlan => 'Upgrade plan';

  @override
  String get paymentHistory => 'Payment history';

  @override
  String get whiteLabelReady => 'Architecture supports per-organization white-label Android, iOS, and Web apps on the same backend.';

  @override
  String get organizationCreated => 'Organization created';

  @override
  String get organizationSuspended => 'Organization status updated';

  @override
  String get organizationDeleted => 'Organization deleted';

  @override
  String get globalStatistics => 'Global statistics';

  @override
  String get manageOrganizations => 'Manage organizations';

  @override
  String get planTrial => 'Trial';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get planAnnual => 'Annual';

  @override
  String get planEnterprise => 'Enterprise';

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get activate => 'Activate';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get primaryColor => 'Primary color';

  @override
  String get branding => 'Branding';

  @override
  String get rulesAndHours => 'Rules & hours';

  @override
  String get queueRules => 'Queue rules';

  @override
  String get appointmentRules => 'Appointment rules';
}
