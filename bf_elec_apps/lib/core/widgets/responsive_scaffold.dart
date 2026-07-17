import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  int _getSelectedIndex() {
    final route = widget.currentRoute;
    if (route.contains('drawings')) return 0;
    if (route.contains('motor')) return 1;
    if (route.contains('shift')) return 2;
    if (route.contains('smp')) return 3;
    if (route.contains('material')) return 4;
    if (route.contains('profile')) return 5;
    return -1;
  }

  void _onItemTapped(int index) {
    final routes = [
      '/dashboard/drawings',
      '/dashboard/motor-details',
      '/dashboard/shift-snags',
      '/dashboard/smp',
      '/dashboard/material-requisition',
      '/profile',
    ];
    if (index < routes.length) context.go(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.contentBg,
      floatingActionButton: widget.floatingActionButton,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppTheme.sidebarBg,
              title: Row(
                children: [
                  const Icon(Icons.factory_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'BFELECAPPS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                  onPressed: () => context.go('/login'),
                ),
              ],
            ),
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
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: AppTheme.sidebarBg,
                border: Border(top: BorderSide(color: Color(0xFF2D2D6B), width: 1)),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _getSelectedIndex() >= 5 ? 0 : _getSelectedIndex(),
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.architecture_rounded), label: 'Drawings'),
                  BottomNavigationBarItem(icon: Icon(Icons.electric_meter_rounded), label: 'Motors'),
                  BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), label: 'Snags'),
                  BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'SMP'),
                  BottomNavigationBarItem(icon: Icon(Icons.post_add_rounded), label: 'Requisition'),
                  BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
                ],
                backgroundColor: AppTheme.sidebarBg,
                selectedItemColor: const Color(0xFFA5B4FC),
                unselectedItemColor: AppTheme.sidebarInactive,
                elevation: 0,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
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
                  child: const Icon(Icons.factory_rounded, size: 24, color: Colors.white),
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
                  icon: Icons.menu_book_rounded,
                  label: 'SMP',
                  index: 3,
                  route: '/dashboard/smp',
                ),
                _buildNavItem(
                  icon: Icons.post_add_rounded,
                  label: 'Material Requisition',
                  index: 4,
                  route: '/dashboard/material-requisition',
                ),
                _buildSectionLabel('ACCOUNT'),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile Settings',
                  index: 5,
                  route: '/profile',
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppTheme.sidebarLabel.withOpacity(0.3), margin: const EdgeInsets.symmetric(horizontal: 20)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, size: 18, color: AppTheme.sidebarInactive),
                  tooltip: 'Log Out',
                  onPressed: () => context.go('/login'),
                ),
                const SizedBox(width: 8),
                Expanded(
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
          onTap: () => context.go(route),
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
        ],
      ),
    );
  }
}
