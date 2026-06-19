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
  String get appointmentDate => 'Date & time';

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
}
