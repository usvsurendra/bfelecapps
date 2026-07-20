import 'package:flutter/material.dart';
import 'package:bf_elec_apps/features/auth/presentation/pages/splash_page.dart';
import 'package:bf_elec_apps/features/auth/presentation/pages/login_page.dart';
import 'package:bf_elec_apps/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:bf_elec_apps/features/auth/presentation/pages/profile_settings_page.dart';
import 'package:bf_elec_apps/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:bf_elec_apps/features/drawings/presentation/pages/drawings_list_page.dart';
import 'package:bf_elec_apps/features/material_requisition/presentation/pages/material_requisition_page.dart';
import 'package:bf_elec_apps/features/motors/presentation/pages/motor_search_page.dart';
import 'package:bf_elec_apps/features/motors/presentation/pages/motor_details_page.dart';
import 'package:bf_elec_apps/features/motors/data/models/motor_model.dart';
import 'package:bf_elec_apps/features/shift_snags/presentation/pages/shift_snags_page.dart';
import 'package:bf_elec_apps/features/smp/presentation/pages/smp_list_page.dart';
import 'package:bf_elec_apps/features/settings/presentation/pages/settings_list_page.dart';
import 'package:bf_elec_apps/features/settings/presentation/pages/settings_detail_page.dart';
import 'package:bf_elec_apps/features/settings/domain/models/settings_item.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      ),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordPage()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileSettingsPage()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/dashboard/drawings',
        builder: (context, state) => const DrawingsListPage(),
      ),
      GoRoute(
        path: '/dashboard/motor-details',
        builder: (context, state) => const MotorSearchPage(),
      ),
      GoRoute(
        path: '/motors/details',
        builder: (context, state) {
          final motor = state.extra as MotorModel;
          return MotorDetailsPage(motor: motor);
        },
      ),
      GoRoute(
        path: '/dashboard/shift-snags',
        builder: (context, state) => const ShiftSnagsPage(),
      ),
      GoRoute(
        path: '/dashboard/smp',
        builder: (context, state) => const SmpListPage(),
      ),
      GoRoute(
        path: '/dashboard/material-requisition',
        builder: (context, state) => const MaterialRequisitionPage(),
      ),
      GoRoute(
        path: '/dashboard/settings',
        builder: (context, state) => const SettingsListPage(),
      ),
      GoRoute(
        path: '/dashboard/settings/detail',
        builder: (context, state) {
          final item = state.extra as SettingsItem;
          return SettingsDetailPage(item: item);
        },
      ),
    ],
  );
});
