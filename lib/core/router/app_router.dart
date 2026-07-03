import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../auth/admin_routes.dart';
import '../../models/provider_catalog_mode.dart';
import '../../models/service_provider_type.dart';
import '../../presentation/screens/admin/create_doctor_screen.dart';
import '../../presentation/screens/admin/create_secretary_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/tabib_login_screen.dart';
import '../../presentation/screens/doctor/doctor_dashboard_screen.dart';
import '../../presentation/screens/doctor/doctor_profile_edit_screen.dart';
import '../../presentation/screens/doctor/owner_doctors_screen.dart';
import '../../presentation/screens/doctor/owner_doctor_detail_screen.dart';
import '../../presentation/screens/doctor/owner_clinics_screen.dart';
import '../../presentation/screens/doctor/owner_platform_screen.dart';
import '../../presentation/layouts/system_owner_shell.dart';
import '../../presentation/screens/owner/system_owner_overview_screen.dart';
import '../../presentation/screens/owner/owner_business_types_screen.dart';
import '../../presentation/screens/owner/owner_business_management_screen.dart';
import '../../presentation/screens/owner/owner_subscriptions_packages_screen.dart';
import '../../presentation/screens/owner/owner_audit_log_screen.dart';
import '../../presentation/screens/owner/owner_system_health_screen.dart';
import '../../presentation/screens/owner/owner_hub_screens.dart';
import '../../presentation/screens/owner/system_owner_module_placeholder_screen.dart';
import '../../presentation/screens/doctor/owner_staff_list_screen.dart';
import '../../presentation/screens/doctor/owner_stats_screen.dart';
import '../../presentation/screens/doctor/owner_subscriptions_screen.dart';
import '../../presentation/screens/doctor/owner_users_screen.dart';
import '../../presentation/screens/doctor/owner_admins_screen.dart';
import '../../presentation/screens/doctor/owner_patients_screen.dart';
import '../../presentation/screens/doctor/write_prescription_screen.dart';
import '../../presentation/screens/patient/appointment_booking_screen.dart';
import '../../presentation/screens/patient/doctor_detail_screen.dart';
import '../../presentation/screens/patient/doctor_list_screen.dart';
import '../../presentation/screens/patient/notifications_screen.dart';
import '../../presentation/screens/patient/advertisement_detail_screen.dart';
import '../../presentation/screens/patient/my_queues_screen.dart';
import '../../presentation/screens/patient/patient_profile_screen.dart';
import '../../presentation/screens/patient/patient_home_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/patient/queue_tracking_screen.dart';
import '../../presentation/screens/secretary/secretary_dashboard_screen.dart';
import '../../presentation/screens/settings/change_password_screen.dart';
import '../../presentation/screens/settings/favorites_screen.dart';
import '../../presentation/screens/settings/legal_content_screen.dart';
import '../../presentation/screens/settings/provider_settings_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/widgets/clinical_provider_guard.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../services/favorites_service.dart';

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
              catalogMode: ProviderCatalogMode.doctors,
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => TabibDoctorDetailScreen(
                  doctorId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/businesses',
            builder: (_, __) => const TabibDoctorListScreen(
              catalogMode: ProviderCatalogMode.businesses,
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => TabibDoctorDetailScreen(
                  doctorId: state.pathParameters['id']!,
                ),
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
            builder: (_, __) => const ClinicalProviderGuard(
              child: DoctorDashboardScreen(),
            ),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (_, __) => const ClinicalProviderGuard(
                  child: DoctorProfileEditScreen(),
                ),
              ),
              GoRoute(
                path: 'prescription/:patientId',
                builder: (_, state) => ClinicalProviderGuard(
                  child: WritePrescriptionScreen(
                    patientId: state.pathParameters['patientId']!,
                    patientName: state.uri.queryParameters['name'],
                  ),
                ),
              ),
            ],
          ),
          ShellRoute(
            builder: (context, state, child) {
              final path = state.matchedLocation;
              if (path == AdminRoutes.adminConsole) return child;
              if (!_auth.isSystemOwner) return child;
              return SystemOwnerShell(child: child);
            },
            routes: [
              GoRoute(
                path: '/owner',
                builder: (_, __) => const SystemOwnerOverviewScreen(),
                routes: [
              GoRoute(
                path: 'console',
                builder: (_, __) => const OwnerPlatformScreen(),
              ),
              GoRoute(
                path: 'create-doctor',
                builder: (_, __) => const CreateDoctorScreen(),
              ),
              GoRoute(
                path: 'create-secretary',
                builder: (_, __) => const CreateSecretaryScreen(),
              ),
              GoRoute(
                path: 'clinics',
                builder: (_, __) => const OwnerClinicsScreen(),
              ),
              GoRoute(
                path: 'users',
                builder: (_, __) => const OwnerUsersScreen(),
              ),
              GoRoute(
                path: 'patients',
                builder: (_, __) => const OwnerPatientsScreen(),
              ),
              GoRoute(
                path: 'admins',
                builder: (_, __) => const OwnerAdminsScreen(),
              ),
              GoRoute(
                path: 'doctors',
                builder: (_, __) => const OwnerDoctorsScreen(
                  catalogMode: ProviderCatalogMode.doctors,
                ),
                routes: [
                  GoRoute(
                    path: ':doctorId',
                    builder: (_, state) => OwnerDoctorDetailScreen(
                      doctorId: state.pathParameters['doctorId']!,
                      focusSecretaries:
                          state.uri.queryParameters['section'] ==
                              'secretaries',
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'businesses',
                builder: (_, state) {
                  final typeId = state.uri.queryParameters['type'];
                  final categoryKey = state.uri.queryParameters['category'];
                  return OwnerDoctorsScreen(
                    catalogMode: ProviderCatalogMode.businesses,
                    businessTypeId: typeId,
                    businessCategory:
                        BusinessCategory.fromStorage(categoryKey),
                  );
                },
              ),
              GoRoute(
                path: 'business-types',
                builder: (_, __) => const OwnerBusinessTypesScreen(),
              ),
              GoRoute(
                path: 'business-management',
                builder: (_, __) => const OwnerBusinessManagementScreen(),
              ),
              GoRoute(
                path: 'secretaries',
                builder: (_, __) => const OwnerStaffListScreen(
                  filter: OwnerStaffFilter.secretaries,
                ),
              ),
              GoRoute(
                path: 'stats',
                builder: (_, __) => const OwnerStatsScreen(),
              ),
              GoRoute(
                path: 'reports',
                builder: (_, __) => const OwnerReportsAnalyticsScreen(),
              ),
              GoRoute(
                path: 'analytics',
                builder: (_, __) => const OwnerStatsScreen(),
              ),
              GoRoute(
                path: 'subscriptions',
                builder: (_, __) => const OwnerSubscriptionsScreen(),
              ),
              GoRoute(
                path: 'subscriptions-packages',
                builder: (_, __) => const OwnerSubscriptionsPackagesScreen(),
              ),
              GoRoute(
                path: 'packages',
                builder: (context, __) => SystemOwnerModulePlaceholderScreen(
                  title: AppLocalizations.of(context).packageManagement,
                ),
              ),
              GoRoute(
                path: 'payments',
                builder: (_, __) => const OwnerPaymentsBillingScreen(),
              ),
              GoRoute(
                path: 'feedback',
                builder: (_, __) => const OwnerFeedbackSupportScreen(),
              ),
              GoRoute(
                path: 'notifications-admin',
                builder: (_, __) => const OwnerNotificationsCenterScreen(),
              ),
              GoRoute(
                path: 'system-health',
                builder: (_, __) => const OwnerSystemHealthScreen(),
              ),
              GoRoute(
                path: 'audit-log',
                builder: (_, __) => const OwnerAuditLogScreen(),
              ),
              GoRoute(
                path: 'security',
                builder: (_, __) => const OwnerSecurityCenterScreen(),
              ),
              GoRoute(
                path: 'backup',
                builder: (_, __) => const OwnerBackupRestoreScreen(),
              ),
              GoRoute(
                path: 'system-settings',
                builder: (_, __) => const OwnerSystemSettingsScreen(),
              ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/queue',
            builder: (_, state) => QueueTrackingScreen(
              entryId: state.uri.queryParameters['entryId'],
            ),
          ),
          GoRoute(
            path: '/my-queues',
            builder: (_, __) => const MyQueuesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const PatientProfileScreen(),
          ),
          GoRoute(
            path: '/ads/:id',
            builder: (_, state) => AdvertisementDetailScreen(
              adId: state.pathParameters['id']!,
            ),
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
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'password',
                builder: (_, __) => const ChangePasswordScreen(),
              ),
              GoRoute(
                path: 'favorites',
                builder: (_, state) => FavoritesScreen(
                  kind: state.uri.queryParameters['kind'] == 'business'
                      ? FavoriteKind.business
                      : FavoriteKind.doctor,
                ),
              ),
              GoRoute(
                path: 'provider',
                builder: (_, state) => ClinicalProviderGuard(
                  child: ProviderSettingsScreen(
                    initialSection: state.uri.queryParameters['section'],
                  ),
                ),
              ),
              GoRoute(
                path: 'legal',
                builder: (_, state) => LegalContentScreen(
                  document: state.uri.queryParameters['doc'] ?? 'about',
                ),
              ),
            ],
          ),
        ],
      );

  String? _redirect(BuildContext context, GoRouterState state) {
    if (!_appReady) return null;

    final loggedIn = _auth.isLoggedIn;
    final path = state.matchedLocation;
    final isPublic =
        path == '/splash' || path == '/login' || path == '/register';

    if (!loggedIn && !isPublic) return '/login';

    if (loggedIn &&
        (path == '/login' || path == '/register' || path == '/splash')) {
      if (_auth.isSystemOwner) return AdminRoutes.ownerHome;
      if (_auth.canAccessAdminPanel && !_auth.isClinicalProvider) {
        return AdminRoutes.adminConsole;
      }
      if (_auth.isClinicalProvider) return '/doctor';
      if (_auth.isSecretary) return '/secretary';
      return '/home';
    }

    if (loggedIn && _auth.isSystemOwner) {
      if (path == '/doctor' ||
          path.startsWith('/doctor/') ||
          path.startsWith('/settings/provider') ||
          path.startsWith('/settings/favorites') ||
          path == '/home' ||
          path.startsWith('/home/') ||
          path == '/secretary' ||
          path.startsWith('/secretary/')) {
        return AdminRoutes.ownerHome;
      }
    }

    if (loggedIn && AdminRoutes.isAdminRoute(path) && !_auth.canAccessAdminPanel) {
      if (_auth.isClinicalProvider) return '/doctor';
      if (_auth.isSecretary) return '/secretary';
      return '/home';
    }

    // Legacy admin URLs → new owner routes.
    if (loggedIn && path.startsWith('/doctor/platform')) {
      return path.replaceFirst('/doctor/platform', AdminRoutes.platformPrefix);
    }

    if (loggedIn && _auth.isPatient && path == '/doctor') {
      return '/home';
    }
    if (loggedIn && _auth.isPatient && path.startsWith('/secretary')) {
      return '/home';
    }
    if (loggedIn && _auth.isPatient && AdminRoutes.isAdminRoute(path)) {
      return '/home';
    }

    if (loggedIn && _auth.isClinicalProvider) {
      if (path.startsWith('/home') ||
          path.startsWith('/secretary') ||
          path == '/register' ||
          AdminRoutes.isAdminRoute(path)) {
        return '/doctor';
      }
    }

    if (loggedIn && _auth.isSecretary) {
      if (path.startsWith('/home') || path == '/register') {
        return '/secretary';
      }
      if (path == '/doctor') return '/secretary';
    }

    return null;
  }
}
