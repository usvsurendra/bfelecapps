import 'package:bf_elec_apps/features/auth/presentation/pages/login_page.dart';
import 'package:bf_elec_apps/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:bf_elec_apps/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:bf_elec_apps/features/drawings/presentation/pages/drawings_list_page.dart';
import 'package:bf_elec_apps/features/material_requisition/presentation/pages/material_requisition_page.dart';
import 'package:bf_elec_apps/features/motor_details/presentation/pages/motor_search_page.dart';
import 'package:bf_elec_apps/features/shift_snags/presentation/pages/shift_snags_page.dart';
import 'package:bf_elec_apps/features/smp/presentation/pages/smp_list_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordPage()),
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
    ],
  );
});
