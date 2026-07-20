import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/widgets/responsive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentRoute: '/dashboard',
      title: 'Dashboard',
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Welcome to the BF Apps Portal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepNavy,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an application to continue',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.slateText,
                  ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _AppCard(
                    title: 'Drawings App',
                    subtitle: 'BF Electrical Drawings',
                    icon: Icons.architecture_rounded,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
                    ),
                    iconBg: const Color(0xFFE0F2FE),
                    onTap: () => context.go('/dashboard/drawings'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _AppCard(
                    title: 'Motor Details',
                    subtitle: 'Name Plate Database',
                    icon: Icons.electric_meter_rounded,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                    ),
                    iconBg: const Color(0xFFCCFBF1),
                    onTap: () => context.go('/dashboard/motor-details'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _AppCard(
                    title: 'Shift Snags',
                    subtitle: 'PLC & Hardwire Solutions',
                    icon: Icons.warning_amber_rounded,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                    ),
                    iconBg: const Color(0xFFFFEDD5),
                    onTap: () => context.go('/dashboard/shift-snags'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _AppCard(
                    title: 'SMP',
                    subtitle: 'Standard Maintenance Procedure',
                    icon: Icons.menu_book_rounded,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
                    ),
                    iconBg: const Color(0xFFF3E8FF),
                    onTap: () => context.go('/dashboard/smp'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _AppCard(
                    title: 'Material Requisition',
                    subtitle: 'Plant Item Request Form',
                    icon: Icons.post_add_rounded,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF10B981), Color(0xFF047857)],
                    ),
                    iconBg: const Color(0xFFD1FAE5),
                    onTap: () => context.go('/dashboard/material-requisition'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _AppCard(
                    title: 'Settings/Parameters',
                    subtitle: 'Parameters & Config',
                    icon: Icons.settings_rounded,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF475569), Color(0xFF1E293B)],
                    ),
                    iconBg: const Color(0xFFF1F5F9),
                    onTap: () => context.go('/dashboard/settings'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final Color iconBg;
  final VoidCallback onTap;

  const _AppCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepNavy.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Opacity(
                opacity: 0.08,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.colors.last.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepNavy,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.slateText,
                        ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
