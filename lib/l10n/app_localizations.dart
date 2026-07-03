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

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get phoneOptional;

  /// No description provided for @accountLoginMethod.
  ///
  /// In en, this message translates to:
  /// **'Login method'**
  String get accountLoginMethod;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or mobile number'**
  String get emailOrPhone;

  /// No description provided for @emailOrPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or mobile number'**
  String get emailOrPhoneHint;

  /// No description provided for @phoneInUse.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered'**
  String get phoneInUse;

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
  /// **'Your turn'**
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

  /// No description provided for @chatWithClinic.
  ///
  /// In en, this message translates to:
  /// **'Contact clinic'**
  String get chatWithClinic;

  /// No description provided for @chatWithPatient.
  ///
  /// In en, this message translates to:
  /// **'Chat with patient'**
  String get chatWithPatient;

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
  /// **'Pick a photo, crop it in a circle, then save. Large images are supported. You can also paste a URL below.'**
  String get photoUploadHint;

  /// No description provided for @orPastePhotoUrl.
  ///
  /// In en, this message translates to:
  /// **'Or paste image URL'**
  String get orPastePhotoUrl;

  /// No description provided for @photoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image could not be compressed enough. Try a smaller photo.'**
  String get photoTooLarge;

  /// No description provided for @photoProcessingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not process the selected image'**
  String get photoProcessingFailed;

  /// No description provided for @cropProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Crop profile photo'**
  String get cropProfilePhoto;

  /// No description provided for @cropProfilePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom and drag to position your photo inside the circle'**
  String get cropProfilePhotoHint;

  /// No description provided for @photoPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get photoPreview;

  /// No description provided for @photoPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'This is how patients will see your profile photo'**
  String get photoPreviewHint;

  /// No description provided for @usePhoto.
  ///
  /// In en, this message translates to:
  /// **'Use photo'**
  String get usePhoto;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @addClinicPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload clinic photo'**
  String get addClinicPhoto;

  /// No description provided for @addClinicPhotoUrl.
  ///
  /// In en, this message translates to:
  /// **'Add URL'**
  String get addClinicPhotoUrl;

  /// No description provided for @clinicPhotoUploadHint.
  ///
  /// In en, this message translates to:
  /// **'Clinic photos are optimized up to 1920×1080. Thumbnails are used in lists for faster loading.'**
  String get clinicPhotoUploadHint;

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
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
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
  /// **'Paste an image URL and tap Add URL'**
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

  /// No description provided for @queueStatusWithDoctor.
  ///
  /// In en, this message translates to:
  /// **'With Doctor'**
  String get queueStatusWithDoctor;

  /// No description provided for @queueStatusInDoctorRoom.
  ///
  /// In en, this message translates to:
  /// **'In doctor room'**
  String get queueStatusInDoctorRoom;

  /// No description provided for @queueStatusExamination.
  ///
  /// In en, this message translates to:
  /// **'Examination'**
  String get queueStatusExamination;

  /// No description provided for @queueStatusReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get queueStatusReview;

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

  /// No description provided for @returnToReview.
  ///
  /// In en, this message translates to:
  /// **'Return to review'**
  String get returnToReview;

  /// No description provided for @appointmentTime.
  ///
  /// In en, this message translates to:
  /// **'Appointment time'**
  String get appointmentTime;

  /// No description provided for @noAssignedDoctor.
  ///
  /// In en, this message translates to:
  /// **'No doctor assigned to this secretary account'**
  String get noAssignedDoctor;

  /// No description provided for @queueNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Queue #'**
  String get queueNumberLabel;

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

  /// No description provided for @queueNotifyTenRemaining.
  ///
  /// In en, this message translates to:
  /// **'Almost your turn'**
  String get queueNotifyTenRemaining;

  /// No description provided for @queueNotifyTenRemainingBody.
  ///
  /// In en, this message translates to:
  /// **'Only 10 patients remain before your turn. Please prepare to come.'**
  String get queueNotifyTenRemainingBody;

  /// No description provided for @queueNotifyFiveRemaining.
  ///
  /// In en, this message translates to:
  /// **'Head to the clinic'**
  String get queueNotifyFiveRemaining;

  /// No description provided for @queueNotifyFiveRemainingBody.
  ///
  /// In en, this message translates to:
  /// **'Only 5 patients remain before your turn. Please head toward the clinic.'**
  String get queueNotifyFiveRemainingBody;

  /// No description provided for @queueNotifyThreeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Arrive now'**
  String get queueNotifyThreeRemaining;

  /// No description provided for @queueNotifyThreeRemainingBody.
  ///
  /// In en, this message translates to:
  /// **'Your turn is very close. Please arrive at the clinic now.'**
  String get queueNotifyThreeRemainingBody;

  /// No description provided for @queueNotifyYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn now'**
  String get queueNotifyYourTurn;

  /// No description provided for @queueNotifyYourTurnBody.
  ///
  /// In en, this message translates to:
  /// **'It is now your turn. Please proceed to the doctor\'s room.'**
  String get queueNotifyYourTurnBody;

  /// No description provided for @dayClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get dayClosed;

  /// No description provided for @markDayOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get markDayOpen;

  /// No description provided for @markDayClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get markDayClosed;

  /// No description provided for @addTimePeriod.
  ///
  /// In en, this message translates to:
  /// **'Add time period'**
  String get addTimePeriod;

  /// No description provided for @removeTimePeriod.
  ///
  /// In en, this message translates to:
  /// **'Remove period'**
  String get removeTimePeriod;

  /// No description provided for @openingTime.
  ///
  /// In en, this message translates to:
  /// **'Opens'**
  String get openingTime;

  /// No description provided for @closingTime.
  ///
  /// In en, this message translates to:
  /// **'Closes'**
  String get closingTime;

  /// No description provided for @schedulePeriodInvalid.
  ///
  /// In en, this message translates to:
  /// **'Closing time must be after opening time'**
  String get schedulePeriodInvalid;

  /// No description provided for @schedulePeriodOverlap.
  ///
  /// In en, this message translates to:
  /// **'Time periods cannot overlap'**
  String get schedulePeriodOverlap;

  /// No description provided for @scheduleOpenDayNeedsPeriod.
  ///
  /// In en, this message translates to:
  /// **'Add at least one time period for each open day'**
  String get scheduleOpenDayNeedsPeriod;

  /// No description provided for @appointmentOutsideSchedule.
  ///
  /// In en, this message translates to:
  /// **'Selected time is outside working hours'**
  String get appointmentOutsideSchedule;

  /// No description provided for @appointmentClosedDay.
  ///
  /// In en, this message translates to:
  /// **'The doctor is not available on this day'**
  String get appointmentClosedDay;

  /// No description provided for @noScheduleSet.
  ///
  /// In en, this message translates to:
  /// **'No working schedule set'**
  String get noScheduleSet;

  /// No description provided for @editWorkingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit working schedule'**
  String get editWorkingSchedule;

  /// No description provided for @viewWorkingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Working schedule'**
  String get viewWorkingSchedule;

  /// No description provided for @adminControlPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Control Panel'**
  String get adminControlPanel;

  /// No description provided for @adminControlPanelHint.
  ///
  /// In en, this message translates to:
  /// **'Manage clinics, users, and subscriptions'**
  String get adminControlPanelHint;

  /// No description provided for @systemOwner.
  ///
  /// In en, this message translates to:
  /// **'System Owner'**
  String get systemOwner;

  /// No description provided for @viewAllDoctors.
  ///
  /// In en, this message translates to:
  /// **'View all doctors'**
  String get viewAllDoctors;

  /// No description provided for @viewAllDoctorsHint.
  ///
  /// In en, this message translates to:
  /// **'Browse and manage doctor accounts'**
  String get viewAllDoctorsHint;

  /// No description provided for @viewAllDoctorsSubscriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Subscription plan, status, and renewals'**
  String get viewAllDoctorsSubscriptionHint;

  /// No description provided for @viewAllSecretaries.
  ///
  /// In en, this message translates to:
  /// **'View all secretaries'**
  String get viewAllSecretaries;

  /// No description provided for @viewAllSecretariesHint.
  ///
  /// In en, this message translates to:
  /// **'Browse and manage secretary accounts'**
  String get viewAllSecretariesHint;

  /// No description provided for @viewAllClinics.
  ///
  /// In en, this message translates to:
  /// **'View all clinics'**
  String get viewAllClinics;

  /// No description provided for @viewAllClinicsHint.
  ///
  /// In en, this message translates to:
  /// **'Browse and manage clinic records'**
  String get viewAllClinicsHint;

  /// No description provided for @activateDeactivateAccounts.
  ///
  /// In en, this message translates to:
  /// **'Activate or deactivate staff accounts'**
  String get activateDeactivateAccounts;

  /// No description provided for @accountActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get accountActive;

  /// No description provided for @accountInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get accountInactive;

  /// No description provided for @accountDeactivated.
  ///
  /// In en, this message translates to:
  /// **'This account has been deactivated'**
  String get accountDeactivated;

  /// No description provided for @manageSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Manage subscriptions'**
  String get manageSubscriptions;

  /// No description provided for @manageSubscriptionsHint.
  ///
  /// In en, this message translates to:
  /// **'Set clinic subscription plans and expiry'**
  String get manageSubscriptionsHint;

  /// No description provided for @systemStatistics.
  ///
  /// In en, this message translates to:
  /// **'System statistics'**
  String get systemStatistics;

  /// No description provided for @systemStatisticsHint.
  ///
  /// In en, this message translates to:
  /// **'Platform-wide overview'**
  String get systemStatisticsHint;

  /// No description provided for @totalDoctors.
  ///
  /// In en, this message translates to:
  /// **'Total doctors'**
  String get totalDoctors;

  /// No description provided for @totalSecretaries.
  ///
  /// In en, this message translates to:
  /// **'Total secretaries'**
  String get totalSecretaries;

  /// No description provided for @totalClinics.
  ///
  /// In en, this message translates to:
  /// **'Total clinics'**
  String get totalClinics;

  /// No description provided for @activeSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Active subscriptions'**
  String get activeSubscriptions;

  /// No description provided for @activeStaffAccounts.
  ///
  /// In en, this message translates to:
  /// **'Active staff accounts'**
  String get activeStaffAccounts;

  /// No description provided for @totalDoctorsListed.
  ///
  /// In en, this message translates to:
  /// **'Doctors in catalog'**
  String get totalDoctorsListed;

  /// No description provided for @noStaffAccounts.
  ///
  /// In en, this message translates to:
  /// **'No staff accounts yet'**
  String get noStaffAccounts;

  /// No description provided for @createAccounts.
  ///
  /// In en, this message translates to:
  /// **'Create accounts'**
  String get createAccounts;

  /// No description provided for @viewAndManage.
  ///
  /// In en, this message translates to:
  /// **'View and manage'**
  String get viewAndManage;

  /// No description provided for @subscriptionPlan.
  ///
  /// In en, this message translates to:
  /// **'Subscription plan'**
  String get subscriptionPlan;

  /// No description provided for @subscriptionPlan1Month.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get subscriptionPlan1Month;

  /// No description provided for @subscriptionPlan2Months.
  ///
  /// In en, this message translates to:
  /// **'2 Months'**
  String get subscriptionPlan2Months;

  /// No description provided for @subscriptionPlan3Months.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get subscriptionPlan3Months;

  /// No description provided for @subscriptionPlan6Months.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get subscriptionPlan6Months;

  /// No description provided for @subscriptionPlan12Months.
  ///
  /// In en, this message translates to:
  /// **'12 Months (1 Year)'**
  String get subscriptionPlan12Months;

  /// No description provided for @subscriptionPlanFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get subscriptionPlanFree;

  /// No description provided for @subscriptionPlanBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get subscriptionPlanBasic;

  /// No description provided for @subscriptionPlanPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get subscriptionPlanPremium;

  /// No description provided for @subscriptionActive.
  ///
  /// In en, this message translates to:
  /// **'Subscription active'**
  String get subscriptionActive;

  /// No description provided for @subscriptionExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get subscriptionExpires;

  /// No description provided for @subscriptionStarted.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get subscriptionStarted;

  /// No description provided for @subscriptionRemainingDays.
  ///
  /// In en, this message translates to:
  /// **'Remaining days'**
  String get subscriptionRemainingDays;

  /// No description provided for @subscriptionStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get subscriptionStatusActive;

  /// No description provided for @subscriptionStatusExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get subscriptionStatusExpiringSoon;

  /// No description provided for @subscriptionStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get subscriptionStatusExpired;

  /// No description provided for @subscriptionDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String subscriptionDaysRemaining(int days);

  /// No description provided for @subscriptionExpiredDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Expired {days} days ago'**
  String subscriptionExpiredDaysAgo(int days);

  /// No description provided for @subscriptionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Expired'**
  String get subscriptionExpiredTitle;

  /// No description provided for @subscriptionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your clinic subscription has expired. New appointments are disabled. Patient records remain available.'**
  String get subscriptionExpiredMessage;

  /// No description provided for @subscriptionExpiringBanner.
  ///
  /// In en, this message translates to:
  /// **'Your subscription expires in {days} days. Please renew soon.'**
  String subscriptionExpiringBanner(int days);

  /// No description provided for @subscriptionBlocked.
  ///
  /// In en, this message translates to:
  /// **'Cannot book — clinic subscription has expired.'**
  String get subscriptionBlocked;

  /// No description provided for @renewSubscription.
  ///
  /// In en, this message translates to:
  /// **'Renew subscription'**
  String get renewSubscription;

  /// No description provided for @subscriptionRenewed.
  ///
  /// In en, this message translates to:
  /// **'Subscription renewed successfully'**
  String get subscriptionRenewed;

  /// No description provided for @viewPatientRecords.
  ///
  /// In en, this message translates to:
  /// **'View patient records'**
  String get viewPatientRecords;

  /// No description provided for @assignedDoctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get assignedDoctors;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @activateSubscription.
  ///
  /// In en, this message translates to:
  /// **'Activate subscription'**
  String get activateSubscription;

  /// No description provided for @doctorProfile.
  ///
  /// In en, this message translates to:
  /// **'Doctor profile'**
  String get doctorProfile;

  /// No description provided for @noExpiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry date'**
  String get noExpiry;

  /// No description provided for @doctorManagement.
  ///
  /// In en, this message translates to:
  /// **'Doctor management'**
  String get doctorManagement;

  /// No description provided for @doctorManagementHint.
  ///
  /// In en, this message translates to:
  /// **'Search doctors, view profiles, and manage assigned secretaries'**
  String get doctorManagementHint;

  /// No description provided for @adminDoctorSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name, specialty, clinic, mobile, email, or account code (e.g. DR-10025)...'**
  String get adminDoctorSearchHint;

  /// No description provided for @accountCode.
  ///
  /// In en, this message translates to:
  /// **'Account code'**
  String get accountCode;

  /// No description provided for @doctorAccountCode.
  ///
  /// In en, this message translates to:
  /// **'Doctor account code'**
  String get doctorAccountCode;

  /// No description provided for @doctorAccountCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter and verify a valid provider account code'**
  String get doctorAccountCodeRequired;

  /// No description provided for @invalidDoctorAccountCode.
  ///
  /// In en, this message translates to:
  /// **'No provider found with this account code.'**
  String get invalidDoctorAccountCode;

  /// No description provided for @accountCodeFormatInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid account code (e.g. DR-10025 or BZ-10001).'**
  String get accountCodeFormatInvalid;

  /// No description provided for @verifyAccountCode.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyAccountCode;

  /// No description provided for @secretaryLinkProviderPreview.
  ///
  /// In en, this message translates to:
  /// **'Confirm linked provider'**
  String get secretaryLinkProviderPreview;

  /// No description provided for @doctorAccountCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor Account Code: {code}'**
  String doctorAccountCodeLabel(String code);

  /// No description provided for @linkedToAccountCode.
  ///
  /// In en, this message translates to:
  /// **'Linked to: {code}'**
  String linkedToAccountCode(String code);

  /// No description provided for @supportHistory.
  ///
  /// In en, this message translates to:
  /// **'Support history'**
  String get supportHistory;

  /// No description provided for @supportHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Subscription renewals, support requests, and troubleshooting notes tied to this account code.'**
  String get supportHistoryHint;

  /// No description provided for @noSupportHistory.
  ///
  /// In en, this message translates to:
  /// **'No support activity recorded yet.'**
  String get noSupportHistory;

  /// No description provided for @doctorInformation.
  ///
  /// In en, this message translates to:
  /// **'Doctor information'**
  String get doctorInformation;

  /// No description provided for @assignedSecretaries.
  ///
  /// In en, this message translates to:
  /// **'Assigned secretaries'**
  String get assignedSecretaries;

  /// No description provided for @secretariesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} secretaries'**
  String secretariesCount(int count);

  /// No description provided for @doctorSecretarySingle.
  ///
  /// In en, this message translates to:
  /// **'Secretary: {name}'**
  String doctorSecretarySingle(String name);

  /// No description provided for @doctorSecretariesMultiple.
  ///
  /// In en, this message translates to:
  /// **'Secretaries: {names}'**
  String doctorSecretariesMultiple(String names);

  /// No description provided for @doctorSecretariesMultipleWithMore.
  ///
  /// In en, this message translates to:
  /// **'Secretaries: {names} (+{more} more)'**
  String doctorSecretariesMultipleWithMore(String names, int more);

  /// No description provided for @transferSecretary.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferSecretary;

  /// No description provided for @transferSecretaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer secretary'**
  String get transferSecretaryTitle;

  /// No description provided for @transferSecretaryHint.
  ///
  /// In en, this message translates to:
  /// **'Move {name} to another doctor'**
  String transferSecretaryHint(String name);

  /// No description provided for @transferredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transferred successfully'**
  String get transferredSuccessfully;

  /// No description provided for @secretaryAssignedToDoctor.
  ///
  /// In en, this message translates to:
  /// **'Assigned to: {doctorName}'**
  String secretaryAssignedToDoctor(String doctorName);

  /// No description provided for @addSecretary.
  ///
  /// In en, this message translates to:
  /// **'Add secretary'**
  String get addSecretary;

  /// No description provided for @editSecretary.
  ///
  /// In en, this message translates to:
  /// **'Edit secretary'**
  String get editSecretary;

  /// No description provided for @deleteSecretary.
  ///
  /// In en, this message translates to:
  /// **'Delete secretary'**
  String get deleteSecretary;

  /// No description provided for @deleteSecretaryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this secretary account? This cannot be undone.'**
  String get deleteSecretaryConfirm;

  /// No description provided for @noSecretariesAssigned.
  ///
  /// In en, this message translates to:
  /// **'No secretaries assigned to this doctor'**
  String get noSecretariesAssigned;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOf(int current, int total);

  /// No description provided for @itemsPerPage.
  ///
  /// In en, this message translates to:
  /// **'Per page'**
  String get itemsPerPage;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get notAvailable;

  /// No description provided for @clinicName.
  ///
  /// In en, this message translates to:
  /// **'Clinic name'**
  String get clinicName;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @doctorName.
  ///
  /// In en, this message translates to:
  /// **'Doctor name'**
  String get doctorName;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @businessProfile.
  ///
  /// In en, this message translates to:
  /// **'Business profile'**
  String get businessProfile;

  /// No description provided for @editBusinessProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit business profile'**
  String get editBusinessProfile;

  /// No description provided for @editDoctorProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit doctor profile'**
  String get editDoctorProfile;

  /// No description provided for @aboutBusiness.
  ///
  /// In en, this message translates to:
  /// **'About the business'**
  String get aboutBusiness;

  /// No description provided for @businessDashboard.
  ///
  /// In en, this message translates to:
  /// **'Business dashboard'**
  String get businessDashboard;

  /// No description provided for @linkedBusiness.
  ///
  /// In en, this message translates to:
  /// **'Linked business'**
  String get linkedBusiness;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get accountType;

  /// No description provided for @accountTypeDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get accountTypeDoctor;

  /// No description provided for @accountTypeBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get accountTypeBusiness;

  /// No description provided for @createBusinessAccount.
  ///
  /// In en, this message translates to:
  /// **'Create business account'**
  String get createBusinessAccount;

  /// No description provided for @createBusinessAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Add a healthcare business with login credentials'**
  String get createBusinessAccountHint;

  /// No description provided for @selectBusinessCategory.
  ///
  /// In en, this message translates to:
  /// **'Business category'**
  String get selectBusinessCategory;

  /// No description provided for @searchProviders.
  ///
  /// In en, this message translates to:
  /// **'Search doctors & businesses'**
  String get searchProviders;

  /// No description provided for @searchHintProviders.
  ///
  /// In en, this message translates to:
  /// **'Name, specialty, business category, clinic...'**
  String get searchHintProviders;

  /// No description provided for @businessCategoryClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get businessCategoryClinic;

  /// No description provided for @businessCategoryBeautyCenter.
  ///
  /// In en, this message translates to:
  /// **'Beauty center'**
  String get businessCategoryBeautyCenter;

  /// No description provided for @businessCategoryMedicalLaboratory.
  ///
  /// In en, this message translates to:
  /// **'Medical laboratory'**
  String get businessCategoryMedicalLaboratory;

  /// No description provided for @businessCategoryRadiologyCenter.
  ///
  /// In en, this message translates to:
  /// **'Radiology center'**
  String get businessCategoryRadiologyCenter;

  /// No description provided for @businessCategoryPhysiotherapyCenter.
  ///
  /// In en, this message translates to:
  /// **'Physiotherapy center'**
  String get businessCategoryPhysiotherapyCenter;

  /// No description provided for @businessCategoryDentalCenter.
  ///
  /// In en, this message translates to:
  /// **'Dental center'**
  String get businessCategoryDentalCenter;

  /// No description provided for @businessCategoryEyeCenter.
  ///
  /// In en, this message translates to:
  /// **'Eye center'**
  String get businessCategoryEyeCenter;

  /// No description provided for @businessCategoryHearingCenter.
  ///
  /// In en, this message translates to:
  /// **'Hearing center'**
  String get businessCategoryHearingCenter;

  /// No description provided for @businessCategoryVaccinationCenter.
  ///
  /// In en, this message translates to:
  /// **'Vaccination center'**
  String get businessCategoryVaccinationCenter;

  /// No description provided for @businessCategoryBloodTestCenter.
  ///
  /// In en, this message translates to:
  /// **'Blood test center'**
  String get businessCategoryBloodTestCenter;

  /// No description provided for @businessCategoryPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get businessCategoryPharmacy;

  /// No description provided for @businessCategoryOtherHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Other healthcare services'**
  String get businessCategoryOtherHealthcare;

  /// No description provided for @noSecretariesAssignedBusiness.
  ///
  /// In en, this message translates to:
  /// **'No secretaries assigned to this business'**
  String get noSecretariesAssignedBusiness;

  /// No description provided for @doctorsSection.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctorsSection;

  /// No description provided for @clinicsHealthcareCenters.
  ///
  /// In en, this message translates to:
  /// **'Clinics & Healthcare Centers'**
  String get clinicsHealthcareCenters;

  /// No description provided for @searchDoctorsOnly.
  ///
  /// In en, this message translates to:
  /// **'Search by doctor name or specialty'**
  String get searchDoctorsOnly;

  /// No description provided for @searchBusinessesOnly.
  ///
  /// In en, this message translates to:
  /// **'Search by business name'**
  String get searchBusinessesOnly;

  /// No description provided for @noBusinessesFound.
  ///
  /// In en, this message translates to:
  /// **'No businesses found'**
  String get noBusinessesFound;

  /// No description provided for @allBusinessCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allBusinessCategories;

  /// No description provided for @browseHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Browse healthcare'**
  String get browseHealthcare;

  /// No description provided for @browseDoctorsHint.
  ///
  /// In en, this message translates to:
  /// **'Find doctors and join their queue'**
  String get browseDoctorsHint;

  /// No description provided for @browseBusinessesHint.
  ///
  /// In en, this message translates to:
  /// **'Clinics, labs, pharmacies and more'**
  String get browseBusinessesHint;

  /// No description provided for @selectQueueSlot.
  ///
  /// In en, this message translates to:
  /// **'Select queue time slot'**
  String get selectQueueSlot;

  /// No description provided for @selectTimeSlotHint.
  ///
  /// In en, this message translates to:
  /// **'Choose an available time slot for your visit'**
  String get selectTimeSlotHint;

  /// No description provided for @noQueueSlotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No queue slots available right now'**
  String get noQueueSlotsAvailable;

  /// No description provided for @joinQueue.
  ///
  /// In en, this message translates to:
  /// **'Join queue'**
  String get joinQueue;

  /// No description provided for @queueSlot.
  ///
  /// In en, this message translates to:
  /// **'Queue slot'**
  String get queueSlot;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account & security'**
  String get accountSecurity;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Update your login password'**
  String get changePasswordHint;

  /// No description provided for @changePasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and choose a new secure password. Only you can change your own password.'**
  String get changePasswordDescription;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @passwordChangeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Password change is not available for this account type'**
  String get passwordChangeUnavailable;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @passwordSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from the current password'**
  String get passwordSameAsCurrent;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @accountInfoReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get accountInfoReadOnly;

  /// No description provided for @accountInfoReadOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Email, phone, account type, and permissions are managed by your clinic administrator'**
  String get accountInfoReadOnlyHint;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @queueNotifications.
  ///
  /// In en, this message translates to:
  /// **'Queue notifications'**
  String get queueNotifications;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @patientPreferences.
  ///
  /// In en, this message translates to:
  /// **'Patient preferences'**
  String get patientPreferences;

  /// No description provided for @favoriteDoctors.
  ///
  /// In en, this message translates to:
  /// **'Favorite doctors'**
  String get favoriteDoctors;

  /// No description provided for @favoriteBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Favorite businesses'**
  String get favoriteBusinesses;

  /// No description provided for @noFavoriteDoctors.
  ///
  /// In en, this message translates to:
  /// **'No favorite doctors yet'**
  String get noFavoriteDoctors;

  /// No description provided for @noFavoriteBusinesses.
  ///
  /// In en, this message translates to:
  /// **'No favorite businesses yet'**
  String get noFavoriteBusinesses;

  /// No description provided for @doctorSettings.
  ///
  /// In en, this message translates to:
  /// **'Doctor settings'**
  String get doctorSettings;

  /// No description provided for @businessSettings.
  ///
  /// In en, this message translates to:
  /// **'Business settings'**
  String get businessSettings;

  /// No description provided for @workingDaysAndHours.
  ///
  /// In en, this message translates to:
  /// **'Working days & hours'**
  String get workingDaysAndHours;

  /// No description provided for @queueSettings.
  ///
  /// In en, this message translates to:
  /// **'Queue settings'**
  String get queueSettings;

  /// No description provided for @profileVisibility.
  ///
  /// In en, this message translates to:
  /// **'Profile visibility'**
  String get profileVisibility;

  /// No description provided for @contactVisibility.
  ///
  /// In en, this message translates to:
  /// **'Contact visibility'**
  String get contactVisibility;

  /// No description provided for @whatsappVisibility.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp visibility'**
  String get whatsappVisibility;

  /// No description provided for @secretarySettings.
  ///
  /// In en, this message translates to:
  /// **'Secretary settings'**
  String get secretarySettings;

  /// No description provided for @queueAutoRefresh.
  ///
  /// In en, this message translates to:
  /// **'Auto-refresh queue'**
  String get queueAutoRefresh;

  /// No description provided for @queueAutoRefreshHint.
  ///
  /// In en, this message translates to:
  /// **'Keep the queue view updated in real time'**
  String get queueAutoRefreshHint;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacySettings;

  /// No description provided for @showInSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Show in search results'**
  String get showInSearchResults;

  /// No description provided for @showInSearchResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Allow your profile to appear in patient search'**
  String get showInSearchResultsHint;

  /// No description provided for @shareUsageAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Share usage analytics'**
  String get shareUsageAnalytics;

  /// No description provided for @shareUsageAnalyticsHint.
  ///
  /// In en, this message translates to:
  /// **'Help improve Tabib with anonymous usage data'**
  String get shareUsageAnalyticsHint;

  /// No description provided for @supportAndLegal.
  ///
  /// In en, this message translates to:
  /// **'Support & legal'**
  String get supportAndLegal;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpAndSupport;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @providerSettings.
  ///
  /// In en, this message translates to:
  /// **'Provider settings'**
  String get providerSettings;

  /// No description provided for @queueNotificationsProviderHint.
  ///
  /// In en, this message translates to:
  /// **'Notify when patients join or move in the queue'**
  String get queueNotificationsProviderHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @secretary.
  ///
  /// In en, this message translates to:
  /// **'Secretary'**
  String get secretary;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @degrees.
  ///
  /// In en, this message translates to:
  /// **'Degrees'**
  String get degrees;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @termsContent.
  ///
  /// In en, this message translates to:
  /// **'By using Tabib you agree to follow clinic queue rules, respect healthcare staff, and use the app only for legitimate medical appointments and queue management. Misuse may result in account suspension.'**
  String get termsContent;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Tabib collects only the data needed to manage queues, appointments, and clinic communication. Your information is not sold to third parties. Contact your clinic administrator for data access requests.'**
  String get privacyPolicyContent;

  /// No description provided for @aboutContent.
  ///
  /// In en, this message translates to:
  /// **'Tabib v{version} — a modern healthcare queue and clinic management platform for patients, doctors, businesses, and secretaries.'**
  String aboutContent(String version);

  /// No description provided for @helpContent.
  ///
  /// In en, this message translates to:
  /// **'Need help? Email us at {email} or contact your clinic administrator for account and queue issues.'**
  String helpContent(String email);

  /// No description provided for @accountStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get accountStatusActive;

  /// No description provided for @accountStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get accountStatusSuspended;

  /// No description provided for @accountStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get accountStatusDisabled;

  /// No description provided for @accountStatusExpiredSubscription.
  ///
  /// In en, this message translates to:
  /// **'Expired subscription'**
  String get accountStatusExpiredSubscription;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get allStatuses;

  /// No description provided for @changeAccountStatus.
  ///
  /// In en, this message translates to:
  /// **'Change account status'**
  String get changeAccountStatus;

  /// No description provided for @accountSuspendedMessage.
  ///
  /// In en, this message translates to:
  /// **'This account has been suspended. Contact your clinic administrator.'**
  String get accountSuspendedMessage;

  /// No description provided for @accountDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled. Contact your clinic administrator.'**
  String get accountDisabledMessage;

  /// No description provided for @accountSubscriptionExpiredLoginMessage.
  ///
  /// In en, this message translates to:
  /// **'Access is blocked because the clinic subscription has expired. Please renew to continue.'**
  String get accountSubscriptionExpiredLoginMessage;

  /// No description provided for @managePatients.
  ///
  /// In en, this message translates to:
  /// **'Manage patients'**
  String get managePatients;

  /// No description provided for @managePatientsHint.
  ///
  /// In en, this message translates to:
  /// **'View patient accounts and manage their status'**
  String get managePatientsHint;

  /// No description provided for @manageAdmins.
  ///
  /// In en, this message translates to:
  /// **'Manage admins'**
  String get manageAdmins;

  /// No description provided for @manageAdminsHint.
  ///
  /// In en, this message translates to:
  /// **'Create admins and assign individual permissions'**
  String get manageAdminsHint;

  /// No description provided for @createAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Create admin account'**
  String get createAdminAccount;

  /// No description provided for @editAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit admin account'**
  String get editAdminAccount;

  /// No description provided for @deleteAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete admin account'**
  String get deleteAdminAccount;

  /// No description provided for @deleteAdminAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this admin account? This cannot be undone.'**
  String get deleteAdminAccountConfirm;

  /// No description provided for @noAdminAccounts.
  ///
  /// In en, this message translates to:
  /// **'No admin accounts yet'**
  String get noAdminAccounts;

  /// No description provided for @adminPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get adminPermissionsTitle;

  /// No description provided for @adminPermissionsRequired.
  ///
  /// In en, this message translates to:
  /// **'Select at least one permission'**
  String get adminPermissionsRequired;

  /// No description provided for @permManageDoctors.
  ///
  /// In en, this message translates to:
  /// **'Manage doctors'**
  String get permManageDoctors;

  /// No description provided for @permManageBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Manage businesses'**
  String get permManageBusinesses;

  /// No description provided for @permManageSecretaries.
  ///
  /// In en, this message translates to:
  /// **'Manage secretaries'**
  String get permManageSecretaries;

  /// No description provided for @permManagePatients.
  ///
  /// In en, this message translates to:
  /// **'Manage patients'**
  String get permManagePatients;

  /// No description provided for @permManageSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Manage subscriptions'**
  String get permManageSubscriptions;

  /// No description provided for @permViewReports.
  ///
  /// In en, this message translates to:
  /// **'View reports'**
  String get permViewReports;

  /// No description provided for @permSendNotifications.
  ///
  /// In en, this message translates to:
  /// **'Send notifications'**
  String get permSendNotifications;

  /// No description provided for @permResetPasswords.
  ///
  /// In en, this message translates to:
  /// **'Reset passwords'**
  String get permResetPasswords;

  /// No description provided for @permSuspendAccounts.
  ///
  /// In en, this message translates to:
  /// **'Suspend accounts'**
  String get permSuspendAccounts;

  /// No description provided for @permDeleteAccounts.
  ///
  /// In en, this message translates to:
  /// **'Delete accounts'**
  String get permDeleteAccounts;

  /// No description provided for @permManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get permManageCategories;

  /// No description provided for @permViewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View analytics'**
  String get permViewAnalytics;

  /// No description provided for @permCreateAdmins.
  ///
  /// In en, this message translates to:
  /// **'Create admins'**
  String get permCreateAdmins;

  /// No description provided for @permManageAdmins.
  ///
  /// In en, this message translates to:
  /// **'Manage admins'**
  String get permManageAdmins;

  /// No description provided for @systemOwnerDashboard.
  ///
  /// In en, this message translates to:
  /// **'System Owner Dashboard'**
  String get systemOwnerDashboard;

  /// No description provided for @systemOwnerDashboardHint.
  ///
  /// In en, this message translates to:
  /// **'Manage the platform, users, subscriptions, and system settings.'**
  String get systemOwnerDashboardHint;

  /// No description provided for @systemOwnerModules.
  ///
  /// In en, this message translates to:
  /// **'Administrative modules'**
  String get systemOwnerModules;

  /// No description provided for @dashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'Dashboard overview'**
  String get dashboardOverview;

  /// No description provided for @businessManagement.
  ///
  /// In en, this message translates to:
  /// **'Business management'**
  String get businessManagement;

  /// No description provided for @secretaryManagement.
  ///
  /// In en, this message translates to:
  /// **'Secretary management'**
  String get secretaryManagement;

  /// No description provided for @addNewSecretary.
  ///
  /// In en, this message translates to:
  /// **'Add new secretary'**
  String get addNewSecretary;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @secretaryPasswordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Secretary password updated successfully'**
  String get secretaryPasswordResetSuccess;

  /// No description provided for @secretaryPasswordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'A password reset link was sent to the secretary'**
  String get secretaryPasswordResetEmailSent;

  /// No description provided for @resetSecretaryPasswordFirebaseHint.
  ///
  /// In en, this message translates to:
  /// **'A password reset email will be sent to the secretary\'s login address.'**
  String get resetSecretaryPasswordFirebaseHint;

  /// No description provided for @enableAccount.
  ///
  /// In en, this message translates to:
  /// **'Enable account'**
  String get enableAccount;

  /// No description provided for @disableAccount.
  ///
  /// In en, this message translates to:
  /// **'Disable account'**
  String get disableAccount;

  /// No description provided for @unassignedSecretaries.
  ///
  /// In en, this message translates to:
  /// **'Unassigned secretaries'**
  String get unassignedSecretaries;

  /// No description provided for @noSecretariesYet.
  ///
  /// In en, this message translates to:
  /// **'No secretaries yet'**
  String get noSecretariesYet;

  /// No description provided for @patientManagement.
  ///
  /// In en, this message translates to:
  /// **'Patient management'**
  String get patientManagement;

  /// No description provided for @subscriptionManagement.
  ///
  /// In en, this message translates to:
  /// **'Subscription management'**
  String get subscriptionManagement;

  /// No description provided for @packageManagement.
  ///
  /// In en, this message translates to:
  /// **'Package management'**
  String get packageManagement;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System settings'**
  String get systemSettings;

  /// No description provided for @moduleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This module will be available in a future update.'**
  String get moduleComingSoon;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @ownerNavSubscriptionsPackages.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions & packages'**
  String get ownerNavSubscriptionsPackages;

  /// No description provided for @paymentsBilling.
  ///
  /// In en, this message translates to:
  /// **'Payments & billing'**
  String get paymentsBilling;

  /// No description provided for @feedbackSupport.
  ///
  /// In en, this message translates to:
  /// **'Feedback & support'**
  String get feedbackSupport;

  /// No description provided for @notificationsCenter.
  ///
  /// In en, this message translates to:
  /// **'Notifications center'**
  String get notificationsCenter;

  /// No description provided for @reportsAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Reports & analytics'**
  String get reportsAnalytics;

  /// No description provided for @systemHealth.
  ///
  /// In en, this message translates to:
  /// **'System health'**
  String get systemHealth;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get auditLog;

  /// No description provided for @securityCenter.
  ///
  /// In en, this message translates to:
  /// **'Security center'**
  String get securityCenter;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupRestore;

  /// No description provided for @totalBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Total businesses'**
  String get totalBusinesses;

  /// No description provided for @totalPatients.
  ///
  /// In en, this message translates to:
  /// **'Total patients'**
  String get totalPatients;

  /// No description provided for @activeUsersToday.
  ///
  /// In en, this message translates to:
  /// **'Active users'**
  String get activeUsersToday;

  /// No description provided for @expiredSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Expired subscriptions'**
  String get expiredSubscriptions;

  /// No description provided for @revenueOverview.
  ///
  /// In en, this message translates to:
  /// **'Revenue overview'**
  String get revenueOverview;

  /// No description provided for @newRegistrations.
  ///
  /// In en, this message translates to:
  /// **'New registrations'**
  String get newRegistrations;

  /// No description provided for @liveQueueStatistics.
  ///
  /// In en, this message translates to:
  /// **'Live queue statistics'**
  String get liveQueueStatistics;

  /// No description provided for @queueWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get queueWaiting;

  /// No description provided for @queueInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get queueInProgress;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @allBusinesses.
  ///
  /// In en, this message translates to:
  /// **'All businesses'**
  String get allBusinesses;

  /// No description provided for @allBusinessesHint.
  ///
  /// In en, this message translates to:
  /// **'View and manage every business on the platform'**
  String get allBusinessesHint;

  /// No description provided for @businessCategoryBrowseHint.
  ///
  /// In en, this message translates to:
  /// **'Browse providers in this category'**
  String get businessCategoryBrowseHint;

  /// No description provided for @subscriptionPackagesHint.
  ///
  /// In en, this message translates to:
  /// **'Manage clinic plans, renewals, and expiration alerts'**
  String get subscriptionPackagesHint;

  /// No description provided for @createPackages.
  ///
  /// In en, this message translates to:
  /// **'Create packages'**
  String get createPackages;

  /// No description provided for @createPackagesHint.
  ///
  /// In en, this message translates to:
  /// **'Define subscription tiers for clinics'**
  String get createPackagesHint;

  /// No description provided for @subscriptionPlanHint.
  ///
  /// In en, this message translates to:
  /// **'Open subscription management for this plan'**
  String get subscriptionPlanHint;

  /// No description provided for @plan1Month.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get plan1Month;

  /// No description provided for @plan2Months.
  ///
  /// In en, this message translates to:
  /// **'2 months'**
  String get plan2Months;

  /// No description provided for @plan3Months.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get plan3Months;

  /// No description provided for @plan6Months.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get plan6Months;

  /// No description provided for @plan12Months.
  ///
  /// In en, this message translates to:
  /// **'12 months'**
  String get plan12Months;

  /// No description provided for @activateSubscriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enable a clinic subscription plan'**
  String get activateSubscriptionHint;

  /// No description provided for @renewSubscriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Extend an existing clinic subscription'**
  String get renewSubscriptionHint;

  /// No description provided for @suspendSubscription.
  ///
  /// In en, this message translates to:
  /// **'Suspend subscription'**
  String get suspendSubscription;

  /// No description provided for @suspendSubscriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Temporarily block subscription access'**
  String get suspendSubscriptionHint;

  /// No description provided for @remainingDays.
  ///
  /// In en, this message translates to:
  /// **'Remaining days'**
  String get remainingDays;

  /// No description provided for @remainingDaysHint.
  ///
  /// In en, this message translates to:
  /// **'View days left on each clinic plan'**
  String get remainingDaysHint;

  /// No description provided for @expirationAlerts.
  ///
  /// In en, this message translates to:
  /// **'Expiration alerts'**
  String get expirationAlerts;

  /// No description provided for @expirationAlertsHint.
  ///
  /// In en, this message translates to:
  /// **'Monitor clinics nearing expiry'**
  String get expirationAlertsHint;

  /// No description provided for @paymentsBillingHint.
  ///
  /// In en, this message translates to:
  /// **'Invoices, billing, and payment methods'**
  String get paymentsBillingHint;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @invoicesHint.
  ///
  /// In en, this message translates to:
  /// **'View and export platform invoices'**
  String get invoicesHint;

  /// No description provided for @billingOverview.
  ///
  /// In en, this message translates to:
  /// **'Billing overview'**
  String get billingOverview;

  /// No description provided for @billingOverviewHint.
  ///
  /// In en, this message translates to:
  /// **'Summary of platform billing activity'**
  String get billingOverviewHint;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethods;

  /// No description provided for @paymentMethodsHint.
  ///
  /// In en, this message translates to:
  /// **'Configure accepted payment methods'**
  String get paymentMethodsHint;

  /// No description provided for @feedbackSupportHint.
  ///
  /// In en, this message translates to:
  /// **'User feedback and support requests'**
  String get feedbackSupportHint;

  /// No description provided for @bugReports.
  ///
  /// In en, this message translates to:
  /// **'Bug reports'**
  String get bugReports;

  /// No description provided for @bugReportsHint.
  ///
  /// In en, this message translates to:
  /// **'Review reported software issues'**
  String get bugReportsHint;

  /// No description provided for @featureRequests.
  ///
  /// In en, this message translates to:
  /// **'Feature requests'**
  String get featureRequests;

  /// No description provided for @featureRequestsHint.
  ///
  /// In en, this message translates to:
  /// **'Ideas submitted by users'**
  String get featureRequestsHint;

  /// No description provided for @userFeedback.
  ///
  /// In en, this message translates to:
  /// **'User feedback'**
  String get userFeedback;

  /// No description provided for @userFeedbackHint.
  ///
  /// In en, this message translates to:
  /// **'General platform feedback'**
  String get userFeedbackHint;

  /// No description provided for @supportConversations.
  ///
  /// In en, this message translates to:
  /// **'Support conversations'**
  String get supportConversations;

  /// No description provided for @supportConversationsHint.
  ///
  /// In en, this message translates to:
  /// **'Messages with users needing help'**
  String get supportConversationsHint;

  /// No description provided for @notificationsCenterHint.
  ///
  /// In en, this message translates to:
  /// **'Broadcast and system notifications'**
  String get notificationsCenterHint;

  /// No description provided for @broadcastNotifications.
  ///
  /// In en, this message translates to:
  /// **'Broadcast notifications'**
  String get broadcastNotifications;

  /// No description provided for @broadcastNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Send announcements to all users'**
  String get broadcastNotificationsHint;

  /// No description provided for @subscriptionReminders.
  ///
  /// In en, this message translates to:
  /// **'Subscription reminders'**
  String get subscriptionReminders;

  /// No description provided for @subscriptionRemindersHint.
  ///
  /// In en, this message translates to:
  /// **'Automated renewal reminders'**
  String get subscriptionRemindersHint;

  /// No description provided for @maintenanceAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Maintenance announcements'**
  String get maintenanceAnnouncements;

  /// No description provided for @maintenanceAnnouncementsHint.
  ///
  /// In en, this message translates to:
  /// **'Scheduled downtime notices'**
  String get maintenanceAnnouncementsHint;

  /// No description provided for @reportsAnalyticsHint.
  ///
  /// In en, this message translates to:
  /// **'Platform reports and growth analytics'**
  String get reportsAnalyticsHint;

  /// No description provided for @reportDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily report'**
  String get reportDaily;

  /// No description provided for @reportDailyHint.
  ///
  /// In en, this message translates to:
  /// **'Today\'s platform activity'**
  String get reportDailyHint;

  /// No description provided for @reportWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly report'**
  String get reportWeekly;

  /// No description provided for @reportWeeklyHint.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days summary'**
  String get reportWeeklyHint;

  /// No description provided for @reportMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly report'**
  String get reportMonthly;

  /// No description provided for @reportMonthlyHint.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days summary'**
  String get reportMonthlyHint;

  /// No description provided for @reportYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly report'**
  String get reportYearly;

  /// No description provided for @reportYearlyHint.
  ///
  /// In en, this message translates to:
  /// **'Annual platform summary'**
  String get reportYearlyHint;

  /// No description provided for @queueStatistics.
  ///
  /// In en, this message translates to:
  /// **'Queue statistics'**
  String get queueStatistics;

  /// No description provided for @queueStatisticsHint.
  ///
  /// In en, this message translates to:
  /// **'Waiting times and queue volume'**
  String get queueStatisticsHint;

  /// No description provided for @appointmentStatistics.
  ///
  /// In en, this message translates to:
  /// **'Appointment statistics'**
  String get appointmentStatistics;

  /// No description provided for @appointmentStatisticsHint.
  ///
  /// In en, this message translates to:
  /// **'Bookings and completion rates'**
  String get appointmentStatisticsHint;

  /// No description provided for @revenueStatistics.
  ///
  /// In en, this message translates to:
  /// **'Revenue statistics'**
  String get revenueStatistics;

  /// No description provided for @revenueStatisticsHint.
  ///
  /// In en, this message translates to:
  /// **'Subscription and payment revenue'**
  String get revenueStatisticsHint;

  /// No description provided for @userGrowth.
  ///
  /// In en, this message translates to:
  /// **'User growth'**
  String get userGrowth;

  /// No description provided for @userGrowthHint.
  ///
  /// In en, this message translates to:
  /// **'New users over time'**
  String get userGrowthHint;

  /// No description provided for @systemHealthHint.
  ///
  /// In en, this message translates to:
  /// **'Infrastructure and service status'**
  String get systemHealthHint;

  /// No description provided for @firebaseStatus.
  ///
  /// In en, this message translates to:
  /// **'Firebase status'**
  String get firebaseStatus;

  /// No description provided for @statusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected and configured'**
  String get statusConnected;

  /// No description provided for @statusDemoOrOffline.
  ///
  /// In en, this message translates to:
  /// **'Demo mode or not configured'**
  String get statusDemoOrOffline;

  /// No description provided for @storageUsage.
  ///
  /// In en, this message translates to:
  /// **'Storage usage'**
  String get storageUsage;

  /// No description provided for @databaseUsage.
  ///
  /// In en, this message translates to:
  /// **'Database usage'**
  String get databaseUsage;

  /// No description provided for @clinicsLabel.
  ///
  /// In en, this message translates to:
  /// **'clinics'**
  String get clinicsLabel;

  /// No description provided for @accountsLabel.
  ///
  /// In en, this message translates to:
  /// **'accounts'**
  String get accountsLabel;

  /// No description provided for @errorLogs.
  ///
  /// In en, this message translates to:
  /// **'Error logs'**
  String get errorLogs;

  /// No description provided for @errorLogsHint.
  ///
  /// In en, this message translates to:
  /// **'Application error history'**
  String get errorLogsHint;

  /// No description provided for @crashReports.
  ///
  /// In en, this message translates to:
  /// **'Crash reports'**
  String get crashReports;

  /// No description provided for @crashReportsHint.
  ///
  /// In en, this message translates to:
  /// **'Client crash summaries'**
  String get crashReportsHint;

  /// No description provided for @performanceMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Performance monitoring'**
  String get performanceMonitoring;

  /// No description provided for @performanceMonitoringHint.
  ///
  /// In en, this message translates to:
  /// **'Latency and load metrics'**
  String get performanceMonitoringHint;

  /// No description provided for @noAuditEntries.
  ///
  /// In en, this message translates to:
  /// **'No audit entries yet'**
  String get noAuditEntries;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP address'**
  String get ipAddress;

  /// No description provided for @securityCenterHint.
  ///
  /// In en, this message translates to:
  /// **'Login activity and account protection'**
  String get securityCenterHint;

  /// No description provided for @loginHistory.
  ///
  /// In en, this message translates to:
  /// **'Login history'**
  String get loginHistory;

  /// No description provided for @loginHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Recent sign-in events'**
  String get loginHistoryHint;

  /// No description provided for @activeSessions.
  ///
  /// In en, this message translates to:
  /// **'Active sessions'**
  String get activeSessions;

  /// No description provided for @activeSessionsHint.
  ///
  /// In en, this message translates to:
  /// **'Devices currently signed in'**
  String get activeSessionsHint;

  /// No description provided for @failedLoginAttempts.
  ///
  /// In en, this message translates to:
  /// **'Failed login attempts'**
  String get failedLoginAttempts;

  /// No description provided for @failedLoginAttemptsHint.
  ///
  /// In en, this message translates to:
  /// **'Blocked or suspicious sign-ins'**
  String get failedLoginAttemptsHint;

  /// No description provided for @blockedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Blocked accounts'**
  String get blockedAccounts;

  /// No description provided for @blockedAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'Suspended and disabled accounts'**
  String get blockedAccountsHint;

  /// No description provided for @passwordResetLogs.
  ///
  /// In en, this message translates to:
  /// **'Password reset logs'**
  String get passwordResetLogs;

  /// No description provided for @passwordResetLogsHint.
  ///
  /// In en, this message translates to:
  /// **'Recent password reset requests'**
  String get passwordResetLogsHint;

  /// No description provided for @backupRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Protect and restore platform data'**
  String get backupRestoreHint;

  /// No description provided for @manualBackup.
  ///
  /// In en, this message translates to:
  /// **'Manual backup'**
  String get manualBackup;

  /// No description provided for @manualBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Create an on-demand backup'**
  String get manualBackupHint;

  /// No description provided for @automaticBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup'**
  String get automaticBackup;

  /// No description provided for @automaticBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Schedule recurring backups'**
  String get automaticBackupHint;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore data'**
  String get restoreData;

  /// No description provided for @restoreDataHint.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup snapshot'**
  String get restoreDataHint;

  /// No description provided for @systemSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Platform-wide configuration'**
  String get systemSettingsHint;

  /// No description provided for @languageSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Default and supported languages'**
  String get languageSettingsHint;

  /// No description provided for @themeSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Light, dark, and branding options'**
  String get themeSettingsHint;

  /// No description provided for @notificationSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'System notification defaults'**
  String get notificationSettingsHint;

  /// No description provided for @featureFlags.
  ///
  /// In en, this message translates to:
  /// **'Feature flags'**
  String get featureFlags;

  /// No description provided for @featureFlagsHint.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable platform features'**
  String get featureFlagsHint;

  /// No description provided for @maintenanceMode.
  ///
  /// In en, this message translates to:
  /// **'Maintenance mode'**
  String get maintenanceMode;

  /// No description provided for @maintenanceModeHint.
  ///
  /// In en, this message translates to:
  /// **'Take the platform offline for maintenance'**
  String get maintenanceModeHint;

  /// No description provided for @businessType.
  ///
  /// In en, this message translates to:
  /// **'Business type'**
  String get businessType;

  /// No description provided for @addBusinessType.
  ///
  /// In en, this message translates to:
  /// **'Add business type'**
  String get addBusinessType;

  /// No description provided for @localizedTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Kurdish, Arabic, and English names (all three required). Users see the label in their selected language.'**
  String get localizedTypeHint;

  /// No description provided for @translationRequired.
  ///
  /// In en, this message translates to:
  /// **'This translation is required'**
  String get translationRequired;

  /// No description provided for @translationsIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Missing translations — edit to add Kurdish, Arabic, and English'**
  String get translationsIncomplete;

  /// No description provided for @typeToSearchOrCreate.
  ///
  /// In en, this message translates to:
  /// **'Type to search or create'**
  String get typeToSearchOrCreate;

  /// No description provided for @businessTypeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to search, or pick a recently used type below.'**
  String get businessTypeSearchHint;

  /// No description provided for @specialtySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to search specialties.'**
  String get specialtySearchHint;

  /// No description provided for @noBusinessTypeFound.
  ///
  /// In en, this message translates to:
  /// **'No Business Type found.'**
  String get noBusinessTypeFound;

  /// No description provided for @noSpecialtyFound.
  ///
  /// In en, this message translates to:
  /// **'No specialty found.'**
  String get noSpecialtyFound;

  /// No description provided for @createNewBusinessType.
  ///
  /// In en, this message translates to:
  /// **'+ Create New Business Type'**
  String get createNewBusinessType;

  /// No description provided for @recentlyUsedBusinessTypes.
  ///
  /// In en, this message translates to:
  /// **'Recently used'**
  String get recentlyUsedBusinessTypes;

  /// No description provided for @createNewType.
  ///
  /// In en, this message translates to:
  /// **'Create \"{name}\"'**
  String createNewType(String name);

  /// No description provided for @completeProfileBanner.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile — add clinic name, address, hours, photos, and contact details.'**
  String get completeProfileBanner;

  /// No description provided for @completeProfileAction.
  ///
  /// In en, this message translates to:
  /// **'Complete profile'**
  String get completeProfileAction;

  /// No description provided for @manageBusinessTypes.
  ///
  /// In en, this message translates to:
  /// **'Business types'**
  String get manageBusinessTypes;

  /// No description provided for @manageBusinessTypesHint.
  ///
  /// In en, this message translates to:
  /// **'Create, translate, and enable centralized business types'**
  String get manageBusinessTypesHint;

  /// No description provided for @editBusinessType.
  ///
  /// In en, this message translates to:
  /// **'Edit business type'**
  String get editBusinessType;

  /// No description provided for @businessTypeActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get businessTypeActive;

  /// No description provided for @businessTypeActiveHint.
  ///
  /// In en, this message translates to:
  /// **'Inactive types are hidden from patients until enabled and assigned'**
  String get businessTypeActiveHint;

  /// No description provided for @businessTypeDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This business type already exists'**
  String get businessTypeDuplicate;

  /// No description provided for @noBusinessTypesYet.
  ///
  /// In en, this message translates to:
  /// **'No business types yet. Add one to get started.'**
  String get noBusinessTypesYet;

  /// No description provided for @businessTypeAssignedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} businesses assigned'**
  String businessTypeAssignedCount(int count);

  /// No description provided for @allBusinessTypes.
  ///
  /// In en, this message translates to:
  /// **'All business types'**
  String get allBusinessTypes;

  /// No description provided for @iconName.
  ///
  /// In en, this message translates to:
  /// **'Icon name'**
  String get iconName;

  /// No description provided for @myQueues.
  ///
  /// In en, this message translates to:
  /// **'My queues'**
  String get myQueues;

  /// No description provided for @sortClosestAppointment.
  ///
  /// In en, this message translates to:
  /// **'Closest appointment'**
  String get sortClosestAppointment;

  /// No description provided for @sortRecentlyJoined.
  ///
  /// In en, this message translates to:
  /// **'Recently joined'**
  String get sortRecentlyJoined;

  /// No description provided for @sortDoctorName.
  ///
  /// In en, this message translates to:
  /// **'Doctor name'**
  String get sortDoctorName;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @patientProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get patientProfile;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @genderOptional.
  ///
  /// In en, this message translates to:
  /// **'Gender (optional)'**
  String get genderOptional;

  /// No description provided for @showProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Show profile photo'**
  String get showProfilePhoto;

  /// No description provided for @showPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Show phone number'**
  String get showPhoneNumber;

  /// No description provided for @profileVisibleToVisitedOnly.
  ///
  /// In en, this message translates to:
  /// **'Profile visible only to visited providers'**
  String get profileVisibleToVisitedOnly;

  /// No description provided for @recentlyVisited.
  ///
  /// In en, this message translates to:
  /// **'Recently visited'**
  String get recentlyVisited;

  /// No description provided for @nearbyProviders.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearbyProviders;

  /// No description provided for @recommendedDoctors.
  ///
  /// In en, this message translates to:
  /// **'Recommended doctors'**
  String get recommendedDoctors;

  /// No description provided for @recommendedBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Recommended businesses'**
  String get recommendedBusinesses;

  /// No description provided for @activeQueues.
  ///
  /// In en, this message translates to:
  /// **'Active queues'**
  String get activeQueues;

  /// No description provided for @advertisements.
  ///
  /// In en, this message translates to:
  /// **'Advertisements'**
  String get advertisements;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get enableLocation;

  /// No description provided for @locationRequiredForNearby.
  ///
  /// In en, this message translates to:
  /// **'Allow location access to see nearby providers.'**
  String get locationRequiredForNearby;

  /// No description provided for @alreadyInSameQueue.
  ///
  /// In en, this message translates to:
  /// **'You are already in this queue for the selected time.'**
  String get alreadyInSameQueue;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes'**
  String get saveFailed;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @searchProvidersHint.
  ///
  /// In en, this message translates to:
  /// **'Doctor, business, specialty, or city...'**
  String get searchProvidersHint;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @bookAgain.
  ///
  /// In en, this message translates to:
  /// **'Book again'**
  String get bookAgain;

  /// No description provided for @setCityForAds.
  ///
  /// In en, this message translates to:
  /// **'Set your city in Profile to see local health offers.'**
  String get setCityForAds;

  /// No description provided for @advertisementDetails.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get advertisementDetails;

  /// No description provided for @advertisementNotFound.
  ///
  /// In en, this message translates to:
  /// **'This advertisement is no longer available.'**
  String get advertisementNotFound;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @currentServing.
  ///
  /// In en, this message translates to:
  /// **'Now serving'**
  String get currentServing;

  /// No description provided for @queueStatusServing.
  ///
  /// In en, this message translates to:
  /// **'Serving'**
  String get queueStatusServing;

  /// No description provided for @queueStatusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get queueStatusFinished;

  /// No description provided for @queueProgress.
  ///
  /// In en, this message translates to:
  /// **'Queue progress'**
  String get queueProgress;

  /// No description provided for @sortQueueProgress.
  ///
  /// In en, this message translates to:
  /// **'Queue progress'**
  String get sortQueueProgress;

  /// No description provided for @nearbyHealthcareCenters.
  ///
  /// In en, this message translates to:
  /// **'Nearby healthcare centers'**
  String get nearbyHealthcareCenters;

  /// No description provided for @recommendedHealthcareCenters.
  ///
  /// In en, this message translates to:
  /// **'Recommended healthcare centers'**
  String get recommendedHealthcareCenters;

  /// No description provided for @noNearbyProviders.
  ///
  /// In en, this message translates to:
  /// **'No nearby providers found in your area.'**
  String get noNearbyProviders;

  /// No description provided for @callClinic.
  ///
  /// In en, this message translates to:
  /// **'Call clinic'**
  String get callClinic;

  /// No description provided for @openMap.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get openMap;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @cancelQueueConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this queue?'**
  String get cancelQueueConfirm;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @completedVisits.
  ///
  /// In en, this message translates to:
  /// **'Completed visits'**
  String get completedVisits;

  /// No description provided for @upcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming appointments'**
  String get upcomingAppointments;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get birthDate;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood type'**
  String get bloodType;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get emergencyContact;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @profileStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get profileStatistics;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get accountDetails;

  /// No description provided for @appearanceAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Appearance & privacy'**
  String get appearanceAndPrivacy;

  /// No description provided for @noActiveQueuesOnProfile.
  ///
  /// In en, this message translates to:
  /// **'You have no active queues. Browse doctors to join a queue.'**
  String get noActiveQueuesOnProfile;

  /// No description provided for @noFavoriteDoctorsYet.
  ///
  /// In en, this message translates to:
  /// **'No favorite doctors yet. Tap the heart on a doctor profile.'**
  String get noFavoriteDoctorsYet;

  /// No description provided for @notificationSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Smart notification system'**
  String get notificationSystemSettings;

  /// No description provided for @notificationSystemSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Channels, queue thresholds, and multilingual templates'**
  String get notificationSystemSettingsHint;

  /// No description provided for @notificationChannels.
  ///
  /// In en, this message translates to:
  /// **'Notification channels'**
  String get notificationChannels;

  /// No description provided for @pushNotificationsOwnerHint.
  ///
  /// In en, this message translates to:
  /// **'Send push when the patient has the app installed'**
  String get pushNotificationsOwnerHint;

  /// No description provided for @whatsappNotifications.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsappNotifications;

  /// No description provided for @smsNotifications.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get smsNotifications;

  /// No description provided for @smsNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Requires clinic SMS provider (simulated in demo)'**
  String get smsNotificationsHint;

  /// No description provided for @inAppNotifications.
  ///
  /// In en, this message translates to:
  /// **'In-app'**
  String get inAppNotifications;

  /// No description provided for @queueAlertThresholds.
  ///
  /// In en, this message translates to:
  /// **'Queue alert thresholds'**
  String get queueAlertThresholds;

  /// No description provided for @queueAlertThresholdsHint.
  ///
  /// In en, this message translates to:
  /// **'Notify patients when this many people remain before their turn'**
  String get queueAlertThresholdsHint;

  /// No description provided for @notificationTemplates.
  ///
  /// In en, this message translates to:
  /// **'Notification templates'**
  String get notificationTemplates;

  /// No description provided for @notificationTemplatesHint.
  ///
  /// In en, this message translates to:
  /// **'Use PatientName, DoctorName, DelayMinutes, and AppointmentTime as placeholders in curly braces'**
  String get notificationTemplatesHint;

  /// No description provided for @notificationType.
  ///
  /// In en, this message translates to:
  /// **'Notification type'**
  String get notificationType;

  /// No description provided for @templateVariablesHint.
  ///
  /// In en, this message translates to:
  /// **'Template body with placeholders'**
  String get templateVariablesHint;

  /// No description provided for @saveTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save template'**
  String get saveTemplate;

  /// No description provided for @templateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get templateSaved;

  /// No description provided for @reminderNotifications.
  ///
  /// In en, this message translates to:
  /// **'Reminder notifications'**
  String get reminderNotifications;

  /// No description provided for @reminderNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Queue and appointment reminders'**
  String get reminderNotificationsHint;

  /// No description provided for @preferredNotificationLanguage.
  ///
  /// In en, this message translates to:
  /// **'Notification language'**
  String get preferredNotificationLanguage;

  /// No description provided for @followAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Follow app language'**
  String get followAppLanguage;

  /// No description provided for @preferredNotificationMethod.
  ///
  /// In en, this message translates to:
  /// **'Preferred delivery method'**
  String get preferredNotificationMethod;

  /// No description provided for @notificationMethodAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic (best available)'**
  String get notificationMethodAutomatic;

  /// No description provided for @sentBy.
  ///
  /// In en, this message translates to:
  /// **'Sent by'**
  String get sentBy;

  /// No description provided for @notificationOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get notificationOpened;

  /// No description provided for @deliveryPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get deliveryPending;

  /// No description provided for @deliverySent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get deliverySent;

  /// No description provided for @deliveryDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveryDelivered;

  /// No description provided for @deliveryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get deliveryFailed;

  /// No description provided for @deliverySkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get deliverySkipped;

  /// No description provided for @missedTurnNotification.
  ///
  /// In en, this message translates to:
  /// **'Missed turn'**
  String get missedTurnNotification;

  /// No description provided for @doctorDelayNotification.
  ///
  /// In en, this message translates to:
  /// **'Doctor delay'**
  String get doctorDelayNotification;

  /// No description provided for @appointmentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Appointment confirmed'**
  String get appointmentConfirmed;

  /// No description provided for @appointmentRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Appointment rescheduled'**
  String get appointmentRescheduled;

  /// No description provided for @appointmentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled'**
  String get appointmentCancelled;

  /// No description provided for @doctorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Doctor unavailable'**
  String get doctorUnavailable;

  /// No description provided for @clinicClosedUnexpectedly.
  ///
  /// In en, this message translates to:
  /// **'Clinic closed unexpectedly'**
  String get clinicClosedUnexpectedly;

  /// No description provided for @recallPatient.
  ///
  /// In en, this message translates to:
  /// **'Recall patient'**
  String get recallPatient;

  /// No description provided for @moveToEndOfQueue.
  ///
  /// In en, this message translates to:
  /// **'Move to end'**
  String get moveToEndOfQueue;

  /// No description provided for @cancelAppointment.
  ///
  /// In en, this message translates to:
  /// **'Cancel appointment'**
  String get cancelAppointment;

  /// No description provided for @patientRecalled.
  ///
  /// In en, this message translates to:
  /// **'Patient recalled to queue'**
  String get patientRecalled;

  /// No description provided for @patientMovedToEnd.
  ///
  /// In en, this message translates to:
  /// **'Patient moved to end of queue'**
  String get patientMovedToEnd;

  /// No description provided for @notifyDoctorDelay.
  ///
  /// In en, this message translates to:
  /// **'Notify waiting patients of delay'**
  String get notifyDoctorDelay;

  /// No description provided for @notifyDelayShort.
  ///
  /// In en, this message translates to:
  /// **'Delay alert'**
  String get notifyDelayShort;

  /// No description provided for @delayMinutes.
  ///
  /// In en, this message translates to:
  /// **'Delay (minutes)'**
  String get delayMinutes;

  /// No description provided for @sendNotification.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendNotification;

  /// No description provided for @delayNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Delay notification sent to waiting patients'**
  String get delayNotificationSent;

  /// No description provided for @contactActionCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get contactActionCall;

  /// No description provided for @contactActionWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get contactActionWhatsApp;

  /// No description provided for @contactActionSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get contactActionSms;

  /// No description provided for @chooseMessageTemplate.
  ///
  /// In en, this message translates to:
  /// **'Choose a message'**
  String get chooseMessageTemplate;

  /// No description provided for @contactTemplateQueueReminder.
  ///
  /// In en, this message translates to:
  /// **'Hello, your turn in the queue is approaching. Please prepare to come to the clinic.'**
  String get contactTemplateQueueReminder;

  /// No description provided for @contactTemplateYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Hello, it is now your turn. Please proceed to the doctor\'s room.'**
  String get contactTemplateYourTurn;

  /// No description provided for @contactTemplateAppointmentReminder.
  ///
  /// In en, this message translates to:
  /// **'Hello, this is a reminder about your upcoming appointment.'**
  String get contactTemplateAppointmentReminder;

  /// No description provided for @contactTemplateFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Hello, please contact the clinic regarding your recent visit.'**
  String get contactTemplateFollowUp;

  /// No description provided for @contactTemplateCustom.
  ///
  /// In en, this message translates to:
  /// **'Write a custom message'**
  String get contactTemplateCustom;

  /// No description provided for @searchPatientsHint.
  ///
  /// In en, this message translates to:
  /// **'Search patients by name or phone'**
  String get searchPatientsHint;

  /// No description provided for @communicationAuditLog.
  ///
  /// In en, this message translates to:
  /// **'Staff communication log'**
  String get communicationAuditLog;

  /// No description provided for @noCommunicationLogs.
  ///
  /// In en, this message translates to:
  /// **'No staff communication attempts recorded yet.'**
  String get noCommunicationLogs;
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
