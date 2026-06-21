import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/admin_login_screen.dart';
import '../../presentation/screens/admin/create_doctor_screen.dart';
import '../../presentation/screens/admin/create_secretary_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/tabib_login_screen.dart';
import '../../presentation/screens/doctor/doctor_dashboard_screen.dart';
import '../../presentation/screens/doctor/doctor_profile_edit_screen.dart';
import '../../presentation/screens/doctor/write_prescription_screen.dart';
import '../../presentation/screens/patient/appointment_booking_screen.dart';
import '../../presentation/screens/patient/doctor_detail_screen.dart';
import '../../presentation/screens/patient/doctor_list_screen.dart';
import '../../presentation/screens/patient/notifications_screen.dart';
import '../../presentation/screens/patient/patient_home_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/patient/queue_tracking_screen.dart';
import '../../presentation/screens/secretary/secretary_dashboard_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

class AppRouter {
  AppRouter({
    required AuthService authService,
    required bool appReady,
  })  : _auth = authService,
        _appReady = appReady;

  final AuthService _auth;
  final bool _appReady;

  GoRouter get router => GoRouter(
        initialLocation: '/splash',
        refreshListenable: _auth,
        redirect: _redirect,
        routes: [
          GoRoute(
            path: '/splash',
            builder: (_, __) => const SplashScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) => const TabibLoginScreen(),
          ),
          GoRoute(
            path: '/register',
            builder: (_, __) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (_, __) => const PatientHomeScreen(),
          ),
          GoRoute(
            path: '/doctors',
            builder: (context, state) => TabibDoctorListScreen(
              initialSpecialtyId: state.uri.queryParameters['specialty'],
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => TabibDoctorDetailScreen(
                  doctorId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'book',
                    builder: (_, state) => AppointmentBookingScreen(
                      doctorId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/book/:doctorId',
            builder: (_, state) => AppointmentBookingScreen(
              doctorId: state.pathParameters['doctorId']!,
            ),
          ),
          GoRoute(
            path: '/appointments',
            builder: (_, __) => const AppointmentHistoryScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/doctor',
            builder: (_, __) => const DoctorDashboardScreen(),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (_, __) => const DoctorProfileEditScreen(),
              ),
              GoRoute(
                path: 'prescription/:patientId',
                builder: (_, state) => WritePrescriptionScreen(
                  patientId: state.pathParameters['patientId']!,
                  patientName: state.uri.queryParameters['name'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/queue',
            builder: (_, __) => const QueueTrackingScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (_, state) => ChatScreen(
              clinicId: state.uri.queryParameters['clinicId'] ?? 'clinic_erbil_1',
              patientId: state.uri.queryParameters['patientId'] ?? '',
              patientName: state.uri.queryParameters['name'],
            ),
          ),
          GoRoute(
            path: '/secretary',
            builder: (_, __) => const SecretaryDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/login',
            builder: (_, __) => const AdminLoginScreen(),
          ),
          GoRoute(
            path: '/admin',
            builder: (_, __) => const AdminDashboardScreen(),
            routes: [
              GoRoute(
                path: 'create-doctor',
                builder: (_, __) => const CreateDoctorScreen(),
              ),
              GoRoute(
                path: 'create-secretary',
                builder: (_, __) => const CreateSecretaryScreen(),
              ),
            ],
          ),
        ],
      );

  String? _redirect(BuildContext context, GoRouterState state) {
    if (!_appReady) return null;

    final loggedIn = _auth.isLoggedIn;
    final path = state.matchedLocation;
    final isPublic = path == '/splash' ||
        path == '/login' ||
        path == '/register' ||
        path == '/admin/login';

    if (!loggedIn && !isPublic) return '/login';

    if (loggedIn && (path == '/login' || path == '/register' || path == '/splash' || path == '/admin/login')) {
      if (_auth.isAdmin) return '/admin';
      if (_auth.isDoctor) return '/doctor';
      if (_auth.isSecretary) return '/secretary';
      return '/home';
    }

    if (loggedIn && _auth.isPatient && path == '/doctor') {
      return '/home';
    }
    if (loggedIn && _auth.isPatient && path.startsWith('/secretary')) {
      return '/home';
    }
    if (loggedIn && _auth.isPatient && path.startsWith('/admin')) {
      return '/home';
    }

    if (loggedIn && _auth.isAdmin) {
      if (path.startsWith('/home') ||
          path.startsWith('/doctor') ||
          path.startsWith('/secretary') ||
          path == '/register') {
        return '/admin';
      }
    }

    if (loggedIn && _auth.isDoctor) {
      if (path.startsWith('/home') ||
          path.startsWith('/secretary') ||
          path.startsWith('/admin') ||
          path == '/register') {
        return '/doctor';
      }
    }

    if (loggedIn && _auth.isSecretary) {
      if (path.startsWith('/home') || path == '/register' || path.startsWith('/admin')) {
        return '/secretary';
      }
      if (path == '/doctor') return '/secretary';
    }

    return null;
  }
}
