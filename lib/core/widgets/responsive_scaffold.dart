import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/config/firebase_bootstrap.dart';
import 'package:bf_elec_apps/core/widgets/responsive_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/services.dart';

class ResponsiveScaffold extends ConsumerStatefulWidget {
  final Widget body;
  final String currentRoute;
  final String title;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.currentRoute,
    required this.title,
    this.floatingActionButton,
  });

  @override
  ConsumerState<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends ConsumerState<ResponsiveScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isSubRoute = widget.currentRoute != '/dashboard';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 1. If drawer is open on mobile, close it first
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          _scaffoldKey.currentState?.closeDrawer();
          return;
        }

        // 2. If navigator can pop (pushed sub-pages, dialogs)
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return;
        }

        // 3. If on a sub-route, navigate back to dashboard
        if (isSubRoute) {
          context.go('/dashboard');
          return;
        }

        // 4. If on dashboard, require double-tap back within 2s to exit
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Press back again to exit',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppTheme.deepNavy,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          return;
        }

        // Second press within 2s -> minimize/exit app safely
        SystemNavigator.pop();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.contentBg,
        floatingActionButton: widget.floatingActionButton,
        appBar: isDesktop
            ? null
            : AppBar(
                backgroundColor: AppTheme.sidebarBg,
                iconTheme: const IconThemeData(color: Colors.white),
                leading: isSubRoute
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        tooltip: 'Back',
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            context.go('/dashboard');
                          }
                        },
                      )
                    : null,
                title: Row(
                  children: [
                    if (!isSubRoute) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset('assets/icon_bfelec_app.png', width: 22, height: 22, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        isSubRoute ? widget.title : 'BFELECAPPS',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                    tooltip: 'Log Out',
                    onPressed: () async {
                      await safeAuth?.signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
        drawer: isDesktop ? null : Drawer(child: _buildSidebar()),
        body: Row(
          children: [
            if (isDesktop) _buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  if (isDesktop) _buildTopBar(),
                  Expanded(
                    child: Container(
                      color: AppTheme.contentBg,
                      child: widget.body,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E2048), Color(0xFF12113A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F4C81), Color(0xFF00B4D8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentCyan.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/icon_bfelec_app.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BFELECAPPS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'RINL',
                        style: TextStyle(
                          color: Color(0xFFA5B4FC),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSectionLabel('MODULES'),
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  index: -1,
                  route: '/dashboard',
                ),
                _buildNavItem(
                  icon: Icons.architecture_rounded,
                  label: 'Drawings',
                  index: 0,
                  route: '/dashboard/drawings',
                ),
                _buildNavItem(
                  icon: Icons.electric_meter_rounded,
                  label: 'Motor Details',
                  index: 1,
                  route: '/dashboard/motor-details',
                ),
                _buildNavItem(
                  icon: Icons.warning_amber_rounded,
                  label: 'Shift Snags',
                  index: 2,
                  route: '/dashboard/shift-snags',
                ),
                _buildSectionLabel('TOOLS'),
                _buildNavItem(
                  icon: Icons.post_add_rounded,
                  label: 'Material Requisition',
                  index: 3,
                  route: '/dashboard/material-requisition',
                ),
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings/Parameters',
                  index: 4,
                  route: '/dashboard/settings',
                ),
                _buildSectionLabel('ACCOUNT'),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile Settings',
                  index: 5,
                  route: '/profile',
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: AppTheme.sidebarLabel.withOpacity(0.3), margin: const EdgeInsets.symmetric(horizontal: 20)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, size: 18, color: AppTheme.sidebarInactive),
                        tooltip: 'Log Out',
                        onPressed: () async {
                          await safeAuth?.signOut();
                          // ignore: use_build_context_synchronously
                          if (context.mounted) context.go('/login');
                        },
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            color: AppTheme.sidebarInactive,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24), // Extra padding for system nav bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 16, 26, 6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.sidebarLabel,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required String route,
  }) {
    final isSelected = widget.currentRoute == route ||
        (index >= 0 && widget.currentRoute.contains(route.split('/').last));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.sidebarActiveBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.indigoAccent.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (!ResponsiveLayout.isDesktop(context)) {
              Navigator.of(context).pop();
            }
            context.go(route);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : AppTheme.sidebarInactive,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.sidebarInactive,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppTheme.pureWhite,
        border: Border(bottom: BorderSide(color: AppTheme.borderGray, width: 1)),
      ),
      child: Row(
        children: [
          Text(
            'Home',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.slate.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.slate.withOpacity(0.5)),
          ),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.slate,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          StreamBuilder<User?>(
            stream: safeUserChanges(),
            builder: (context, snapshot) {
              final photoUrl = snapshot.data?.photoURL;
              final name = snapshot.data?.displayName ?? snapshot.data?.email;
              return Row(
                children: [
                  if (name != null && name.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.slate,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  _buildUserAvatar(photoUrl),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

Widget _buildUserAvatar(String? photoUrl) {
    return GestureDetector(
      onTap: () => context.go('/profile'),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.lightGray,
          border: Border.all(color: AppTheme.borderGray, width: 1),
        ),
        child: ClipOval(
          child: (photoUrl != null && photoUrl.isNotEmpty)
              ? Image.network(
                  photoUrl,
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: AppTheme.mediumGray,
                  ),
                )
              : const Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: AppTheme.mediumGray,
                ),
        ),
      ),
    );
  }
}
