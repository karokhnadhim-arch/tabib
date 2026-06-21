import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ku')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tabib'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find doctors, book appointments, manage your health'**
  String get appSubtitle;

  /// No description provided for @patientApp.
  ///
  /// In en, this message translates to:
  /// **'Patient App'**
  String get patientApp;

  /// No description provided for @patientAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book a queue and track your position'**
  String get patientAppSubtitle;

  /// No description provided for @staffApp.
  ///
  /// In en, this message translates to:
  /// **'Doctor & Secretary App'**
  String get staffApp;

  /// No description provided for @staffAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage queues and patients'**
  String get staffAppSubtitle;

  /// No description provided for @adminApp.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminApp;

  /// No description provided for @adminAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage clinics, doctors, and staff'**
  String get adminAppSubtitle;

  /// No description provided for @patientLogin.
  ///
  /// In en, this message translates to:
  /// **'Patient Login'**
  String get patientLogin;

  /// No description provided for @staffLogin.
  ///
  /// In en, this message translates to:
  /// **'Staff Login'**
  String get staffLogin;

  /// No description provided for @adminLogin.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get adminLogin;

  /// No description provided for @loginPromptPatient.
  ///
  /// In en, this message translates to:
  /// **'Enter your name and phone to start'**
  String get loginPromptPatient;

  /// No description provided for @loginPromptStaff.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your staff account'**
  String get loginPromptStaff;

  /// No description provided for @loginPromptAdmin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with admin credentials'**
  String get loginPromptAdmin;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient name'**
  String get patientName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @invalidName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get invalidName;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeUser(String name);

  /// No description provided for @noActiveQueue.
  ///
  /// In en, this message translates to:
  /// **'No active queue'**
  String get noActiveQueue;

  /// No description provided for @bookQueueHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a doctor and book a queue'**
  String get bookQueueHint;

  /// No description provided for @medicalSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Medical specialties'**
  String get medicalSpecialties;

  /// No description provided for @searchDoctors.
  ///
  /// In en, this message translates to:
  /// **'Search doctors'**
  String get searchDoctors;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Doctor name, specialty, clinic...'**
  String get searchHint;

  /// No description provided for @myQueue.
  ///
  /// In en, this message translates to:
  /// **'My queue'**
  String get myQueue;

  /// No description provided for @queueNumber.
  ///
  /// In en, this message translates to:
  /// **'Queue number'**
  String get queueNumber;

  /// No description provided for @peopleAhead.
  ///
  /// In en, this message translates to:
  /// **'People ahead'**
  String get peopleAhead;

  /// No description provided for @waitTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated wait'**
  String get waitTime;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @clinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinic;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @inQueue.
  ///
  /// In en, this message translates to:
  /// **'In queue'**
  String get inQueue;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'{years} years experience'**
  String yearsExperience(int years);

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @clinicLocationGps.
  ///
  /// In en, this message translates to:
  /// **'Clinic location (GPS)'**
  String get clinicLocationGps;

  /// No description provided for @bookQueue.
  ///
  /// In en, this message translates to:
  /// **'Book queue'**
  String get bookQueue;

  /// No description provided for @alreadyHasQueue.
  ///
  /// In en, this message translates to:
  /// **'You already have an active queue'**
  String get alreadyHasQueue;

  /// No description provided for @bookSuccess.
  ///
  /// In en, this message translates to:
  /// **'Queue booked! Number: {number}'**
  String bookSuccess(int number);

  /// No description provided for @bookFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not book queue'**
  String get bookFailed;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @currentQueue.
  ///
  /// In en, this message translates to:
  /// **'Current queue'**
  String get currentQueue;

  /// No description provided for @yourTurn.
  ///
  /// In en, this message translates to:
  /// **'It\'s your turn!'**
  String get yourTurn;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelQueue.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelQueue;

  /// No description provided for @queueCancelled.
  ///
  /// In en, this message translates to:
  /// **'Queue cancelled'**
  String get queueCancelled;

  /// No description provided for @openGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get openGoogleMaps;

  /// No description provided for @gpsDirections.
  ///
  /// In en, this message translates to:
  /// **'GPS directions'**
  String get gpsDirections;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'Distance: {km} km'**
  String distanceKm(String km);

  /// No description provided for @noDoctorsFound.
  ///
  /// In en, this message translates to:
  /// **'No doctors found'**
  String get noDoctorsFound;

  /// No description provided for @doctorApp.
  ///
  /// In en, this message translates to:
  /// **'Doctor App'**
  String get doctorApp;

  /// No description provided for @secretaryApp.
  ///
  /// In en, this message translates to:
  /// **'Secretary App'**
  String get secretaryApp;

  /// No description provided for @roleDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get roleDoctor;

  /// No description provided for @roleSecretary.
  ///
  /// In en, this message translates to:
  /// **'Secretary'**
  String get roleSecretary;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @queueManagement.
  ///
  /// In en, this message translates to:
  /// **'Queue management'**
  String get queueManagement;

  /// No description provided for @currentPatient.
  ///
  /// In en, this message translates to:
  /// **'Current patient'**
  String get currentPatient;

  /// No description provided for @completeVisit.
  ///
  /// In en, this message translates to:
  /// **'Complete visit'**
  String get completeVisit;

  /// No description provided for @callNext.
  ///
  /// In en, this message translates to:
  /// **'Call next'**
  String get callNext;

  /// No description provided for @queueList.
  ///
  /// In en, this message translates to:
  /// **'Queue list'**
  String get queueList;

  /// No description provided for @noPatientsInQueue.
  ///
  /// In en, this message translates to:
  /// **'No patients in queue'**
  String get noPatientsInQueue;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @nowServing.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get nowServing;

  /// No description provided for @manageQueue.
  ///
  /// In en, this message translates to:
  /// **'Manage queue'**
  String get manageQueue;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @langKurdish.
  ///
  /// In en, this message translates to:
  /// **'Kurdish (Sorani)'**
  String get langKurdish;

  /// No description provided for @langArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get langArabic;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @firebaseNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Firebase is not configured'**
  String get firebaseNotConfigured;

  /// No description provided for @firebaseSetupHint.
  ///
  /// In en, this message translates to:
  /// **'Run flutterfire configure and add your google-services files. See README.md.'**
  String get firebaseSetupHint;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @manageClinics.
  ///
  /// In en, this message translates to:
  /// **'Manage clinics'**
  String get manageClinics;

  /// No description provided for @manageDoctors.
  ///
  /// In en, this message translates to:
  /// **'Manage doctors'**
  String get manageDoctors;

  /// No description provided for @manageSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Manage specialties'**
  String get manageSpecialties;

  /// No description provided for @manageStaff.
  ///
  /// In en, this message translates to:
  /// **'Manage staff'**
  String get manageStaff;

  /// No description provided for @manageQueues.
  ///
  /// In en, this message translates to:
  /// **'Manage queues'**
  String get manageQueues;

  /// No description provided for @addClinic.
  ///
  /// In en, this message translates to:
  /// **'Add clinic'**
  String get addClinic;

  /// No description provided for @addDoctor.
  ///
  /// In en, this message translates to:
  /// **'Add doctor'**
  String get addDoctor;

  /// No description provided for @addSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Add specialty'**
  String get addSpecialty;

  /// No description provided for @addStaff.
  ///
  /// In en, this message translates to:
  /// **'Add staff'**
  String get addStaff;

  /// No description provided for @nameKu.
  ///
  /// In en, this message translates to:
  /// **'Name (Kurdish)'**
  String get nameKu;

  /// No description provided for @nameAr.
  ///
  /// In en, this message translates to:
  /// **'Name (Arabic)'**
  String get nameAr;

  /// No description provided for @nameEn.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get nameEn;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @patientCount.
  ///
  /// In en, this message translates to:
  /// **'{count} patients'**
  String patientCount(int count);

  /// No description provided for @waitingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting'**
  String waitingCount(int count);

  /// No description provided for @selectDoctor.
  ///
  /// In en, this message translates to:
  /// **'Select doctor'**
  String get selectDoctor;

  /// No description provided for @selectClinic.
  ///
  /// In en, this message translates to:
  /// **'Select clinic'**
  String get selectClinic;

  /// No description provided for @selectSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Select specialty'**
  String get selectSpecialty;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select role'**
  String get selectRole;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @experienceYears.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get experienceYears;

  /// No description provided for @availableToday.
  ///
  /// In en, this message translates to:
  /// **'Available today'**
  String get availableToday;

  /// No description provided for @bioKu.
  ///
  /// In en, this message translates to:
  /// **'Bio (Kurdish)'**
  String get bioKu;

  /// No description provided for @bioAr.
  ///
  /// In en, this message translates to:
  /// **'Bio (Arabic)'**
  String get bioAr;

  /// No description provided for @bioEn.
  ///
  /// In en, this message translates to:
  /// **'Bio (English)'**
  String get bioEn;

  /// No description provided for @addressKu.
  ///
  /// In en, this message translates to:
  /// **'Address (Kurdish)'**
  String get addressKu;

  /// No description provided for @addressAr.
  ///
  /// In en, this message translates to:
  /// **'Address (Arabic)'**
  String get addressAr;

  /// No description provided for @addressEn.
  ///
  /// In en, this message translates to:
  /// **'Address (English)'**
  String get addressEn;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccessfully;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deletedSuccessfully;

  /// No description provided for @patientDashboard.
  ///
  /// In en, this message translates to:
  /// **'Patient Dashboard'**
  String get patientDashboard;

  /// No description provided for @availableAppointments.
  ///
  /// In en, this message translates to:
  /// **'Available appointments'**
  String get availableAppointments;

  /// No description provided for @noAppointmentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No appointments available right now'**
  String get noAppointmentsAvailable;

  /// No description provided for @appointmentDate.
  ///
  /// In en, this message translates to:
  /// **'Appointment date'**
  String get appointmentDate;

  /// No description provided for @statusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statusAvailable;

  /// No description provided for @statusBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get statusBooked;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register;

  /// No description provided for @registerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create a patient account to book appointments'**
  String get registerPrompt;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get emailInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get weakPassword;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @myAppointments.
  ///
  /// In en, this message translates to:
  /// **'My appointments'**
  String get myAppointments;

  /// No description provided for @allSpecialties.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allSpecialties;

  /// No description provided for @noAppointmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No appointments yet'**
  String get noAppointmentsYet;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book appointment'**
  String get bookAppointment;

  /// No description provided for @bookAppointmentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Appointment request sent successfully'**
  String get bookAppointmentSuccess;

  /// No description provided for @bookAppointmentFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not book appointment'**
  String get bookAppointmentFailed;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your symptoms or reason for visit'**
  String get notesHint;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get confirmBooking;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @doctorDashboard.
  ///
  /// In en, this message translates to:
  /// **'Doctor Dashboard'**
  String get doctorDashboard;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingRequests;

  /// No description provided for @acceptedAppointments.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get acceptedAppointments;

  /// No description provided for @patientRecords.
  ///
  /// In en, this message translates to:
  /// **'Patient records'**
  String get patientRecords;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @writePrescription.
  ///
  /// In en, this message translates to:
  /// **'Write prescription'**
  String get writePrescription;

  /// No description provided for @diagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosis;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @prescriptionSaved.
  ///
  /// In en, this message translates to:
  /// **'Prescription saved'**
  String get prescriptionSaved;

  /// No description provided for @noPatientRecords.
  ///
  /// In en, this message translates to:
  /// **'No patient records'**
  String get noPatientRecords;

  /// No description provided for @secretaryDashboard.
  ///
  /// In en, this message translates to:
  /// **'Secretary Dashboard'**
  String get secretaryDashboard;

  /// No description provided for @manageAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get manageAppointments;

  /// No description provided for @registerPatient.
  ///
  /// In en, this message translates to:
  /// **'Register patient'**
  String get registerPatient;

  /// No description provided for @dailySchedule.
  ///
  /// In en, this message translates to:
  /// **'Daily schedule'**
  String get dailySchedule;

  /// No description provided for @registerPatientPrompt.
  ///
  /// In en, this message translates to:
  /// **'Register a new patient at the clinic'**
  String get registerPatientPrompt;

  /// No description provided for @patientRegistered.
  ///
  /// In en, this message translates to:
  /// **'Patient registered successfully'**
  String get patientRegistered;

  /// No description provided for @noAppointmentsToday.
  ///
  /// In en, this message translates to:
  /// **'No appointments for this day'**
  String get noAppointmentsToday;

  /// No description provided for @queueTracking.
  ///
  /// In en, this message translates to:
  /// **'Queue tracking'**
  String get queueTracking;

  /// No description provided for @currentQueueNumber.
  ///
  /// In en, this message translates to:
  /// **'Current queue number'**
  String get currentQueueNumber;

  /// No description provided for @chatWithSecretary.
  ///
  /// In en, this message translates to:
  /// **'Chat with secretary'**
  String get chatWithSecretary;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @markEntered.
  ///
  /// In en, this message translates to:
  /// **'Mark entered'**
  String get markEntered;

  /// No description provided for @markAbsent.
  ///
  /// In en, this message translates to:
  /// **'Mark absent'**
  String get markAbsent;

  /// No description provided for @moveAppointmentUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveAppointmentUp;

  /// No description provided for @moveAppointmentDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveAppointmentDown;

  /// No description provided for @addFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up (Murajaa)'**
  String get addFollowUp;

  /// No description provided for @sendToExamination.
  ///
  /// In en, this message translates to:
  /// **'Send to examination'**
  String get sendToExamination;

  /// No description provided for @statusArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get statusArrived;

  /// No description provided for @statusAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get statusAbsent;

  /// No description provided for @statusInExamination.
  ///
  /// In en, this message translates to:
  /// **'In examination'**
  String get statusInExamination;

  /// No description provided for @statusFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get statusFollowUp;

  /// No description provided for @createDoctorAccount.
  ///
  /// In en, this message translates to:
  /// **'Create doctor account'**
  String get createDoctorAccount;

  /// No description provided for @createDoctorAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Add a new doctor with login credentials'**
  String get createDoctorAccountHint;

  /// No description provided for @createSecretaryAccount.
  ///
  /// In en, this message translates to:
  /// **'Create secretary account'**
  String get createSecretaryAccount;

  /// No description provided for @createSecretaryAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Add a secretary linked to a doctor'**
  String get createSecretaryAccountHint;

  /// No description provided for @linkedDoctor.
  ///
  /// In en, this message translates to:
  /// **'Linked doctor'**
  String get linkedDoctor;

  /// No description provided for @linkedDoctorRequired.
  ///
  /// In en, this message translates to:
  /// **'Select the doctor this secretary assists'**
  String get linkedDoctorRequired;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreated;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @manageProfile.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile'**
  String get manageProfile;

  /// No description provided for @manageProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Update photo, bio, clinic details, and schedule'**
  String get manageProfileHint;

  /// No description provided for @profilePhotoUrl.
  ///
  /// In en, this message translates to:
  /// **'Profile photo URL'**
  String get profilePhotoUrl;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get uploadPhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @photoUploadHint.
  ///
  /// In en, this message translates to:
  /// **'Pick an image from your device, or paste a URL below'**
  String get photoUploadHint;

  /// No description provided for @orPastePhotoUrl.
  ///
  /// In en, this message translates to:
  /// **'Or paste image URL'**
  String get orPastePhotoUrl;

  /// No description provided for @photoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image is too large (max 512 KB)'**
  String get photoTooLarge;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get workingHours;

  /// No description provided for @workingHoursKu.
  ///
  /// In en, this message translates to:
  /// **'Working hours (Kurdish)'**
  String get workingHoursKu;

  /// No description provided for @workingHoursAr.
  ///
  /// In en, this message translates to:
  /// **'Working hours (Arabic)'**
  String get workingHoursAr;

  /// No description provided for @workingHoursEn.
  ///
  /// In en, this message translates to:
  /// **'Working hours (English)'**
  String get workingHoursEn;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get contactInfo;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfo;

  /// No description provided for @professionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Professional details'**
  String get professionalInfo;

  /// No description provided for @clinicInfo.
  ///
  /// In en, this message translates to:
  /// **'Clinic information'**
  String get clinicInfo;

  /// No description provided for @scheduleInfo.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleInfo;

  /// No description provided for @aboutDoctor.
  ///
  /// In en, this message translates to:
  /// **'About the doctor'**
  String get aboutDoctor;

  /// No description provided for @academicDegree.
  ///
  /// In en, this message translates to:
  /// **'Academic degree'**
  String get academicDegree;

  /// No description provided for @academicDegreeKu.
  ///
  /// In en, this message translates to:
  /// **'Degree (Kurdish)'**
  String get academicDegreeKu;

  /// No description provided for @academicDegreeAr.
  ///
  /// In en, this message translates to:
  /// **'Degree (Arabic)'**
  String get academicDegreeAr;

  /// No description provided for @academicDegreeEn.
  ///
  /// In en, this message translates to:
  /// **'Degree (English)'**
  String get academicDegreeEn;

  /// No description provided for @clinicNameKu.
  ///
  /// In en, this message translates to:
  /// **'Clinic name (Kurdish)'**
  String get clinicNameKu;

  /// No description provided for @clinicNameAr.
  ///
  /// In en, this message translates to:
  /// **'Clinic name (Arabic)'**
  String get clinicNameAr;

  /// No description provided for @clinicNameEn.
  ///
  /// In en, this message translates to:
  /// **'Clinic name (English)'**
  String get clinicNameEn;

  /// No description provided for @whatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get whatsappNumber;

  /// No description provided for @workingDays.
  ///
  /// In en, this message translates to:
  /// **'Working days'**
  String get workingDays;

  /// No description provided for @languagesSpoken.
  ///
  /// In en, this message translates to:
  /// **'Languages spoken'**
  String get languagesSpoken;

  /// No description provided for @languagesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Kurdish, Arabic, English'**
  String get languagesHint;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySunday;

  /// No description provided for @openWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Message on WhatsApp'**
  String get openWhatsApp;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @viewPublicProfile.
  ///
  /// In en, this message translates to:
  /// **'View public profile'**
  String get viewPublicProfile;

  /// No description provided for @viewPublicProfileHint.
  ///
  /// In en, this message translates to:
  /// **'See how patients view your profile'**
  String get viewPublicProfileHint;

  /// No description provided for @availableTodayToggle.
  ///
  /// In en, this message translates to:
  /// **'Available for appointments today'**
  String get availableTodayToggle;

  /// No description provided for @showToPatients.
  ///
  /// In en, this message translates to:
  /// **'Show to patients'**
  String get showToPatients;

  /// No description provided for @consultationFee.
  ///
  /// In en, this message translates to:
  /// **'Consultation fee'**
  String get consultationFee;

  /// No description provided for @consultationFeeAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} IQD'**
  String consultationFeeAmount(String amount);

  /// No description provided for @clinicPhotos.
  ///
  /// In en, this message translates to:
  /// **'Clinic photos'**
  String get clinicPhotos;

  /// No description provided for @clinicPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Paste image URLs separated by commas'**
  String get clinicPhotosHint;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @liveQueueProgress.
  ///
  /// In en, this message translates to:
  /// **'Live queue updates automatically'**
  String get liveQueueProgress;

  /// No description provided for @patientsBeforeMe.
  ///
  /// In en, this message translates to:
  /// **'Patients before me'**
  String get patientsBeforeMe;

  /// No description provided for @appointmentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Appointment status'**
  String get appointmentStatusLabel;

  /// No description provided for @queueStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get queueStatusWaiting;

  /// No description provided for @queueStatusInDoctorRoom.
  ///
  /// In en, this message translates to:
  /// **'In doctor room'**
  String get queueStatusInDoctorRoom;

  /// No description provided for @queueStatusSentForTests.
  ///
  /// In en, this message translates to:
  /// **'Sent for tests'**
  String get queueStatusSentForTests;

  /// No description provided for @queueStatusFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow up'**
  String get queueStatusFollowUp;

  /// No description provided for @queueStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get queueStatusCompleted;

  /// No description provided for @queueStatusAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get queueStatusAbsent;

  /// No description provided for @queueStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get queueStatusCancelled;

  /// No description provided for @queueNotifyFourRemaining.
  ///
  /// In en, this message translates to:
  /// **'Almost your turn'**
  String get queueNotifyFourRemaining;

  /// No description provided for @queueNotifyFourRemainingBody.
  ///
  /// In en, this message translates to:
  /// **'Only 4 patients remain before you.'**
  String get queueNotifyFourRemainingBody;

  /// No description provided for @queueNotifyTwoRemaining.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get queueNotifyTwoRemaining;

  /// No description provided for @queueNotifyTwoRemainingBody.
  ///
  /// In en, this message translates to:
  /// **'Only 2 patients remain before you.'**
  String get queueNotifyTwoRemainingBody;

  /// No description provided for @queueNotifyYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn now'**
  String get queueNotifyYourTurn;

  /// No description provided for @queueNotifyYourTurnBody.
  ///
  /// In en, this message translates to:
  /// **'Please proceed to the doctor room.'**
  String get queueNotifyYourTurnBody;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'ku'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'ku': return AppLocalizationsKu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
