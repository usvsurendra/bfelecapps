import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/widgets/responsive_scaffold.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentRoute: '/dashboard',
      title: 'Dashboard',
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
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
                          onTap: () => context.push('/dashboard/drawings'),
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
                          onTap: () => context.push('/dashboard/motor-details'),
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
                          onTap: () => context.push('/dashboard/shift-snags'),
                        ),
                      ),
                      const SizedBox(width: 20),
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
                          onTap: () => context.push('/dashboard/material-requisition'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
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
                          onTap: () => context.push('/dashboard/settings'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  
                  // Pushes footer to the very bottom!
                  const Spacer(),
                  const SizedBox(height: 16),
                  const _DashboardFooter(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _DashboardFooter extends StatelessWidget {
  const _DashboardFooter();

  @override
  Widget build(BuildContext context) {
    final authorRow = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'Built with ',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        Icon(Icons.favorite, color: Colors.red, size: 13),
        Text(
          ' by ',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          'Surendra',
          style: TextStyle(
            color: AppTheme.accentCyan,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );

    final supportBadge = GestureDetector(
      onTap: () {
        Clipboard.setData(const ClipboardData(text: '9701347467'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Number copied to clipboard',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppTheme.accentCyan,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.accentCyan.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.support_agent_rounded,
                color: AppTheme.accentCyan, size: 15),
            const SizedBox(width: 6),
            const Text(
              'Technical Support  ',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              '9701347467',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.copy_rounded,
                color: AppTheme.accentCyan.withOpacity(0.6), size: 13),
          ],
        ),
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1D3A), Color(0xFF1A3A5C)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Glow divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.accentCyan.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),

          if (kIsWeb)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                authorRow,
                const SizedBox(width: 24),
                supportBadge,
              ],
            )
          else ...[
            authorRow,
            const SizedBox(height: 6),
            supportBadge,
          ],
        ],
      ),
    );
  }
}

// ─── App Card ─────────────────────────────────────────────────────────────────

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
        constraints: const BoxConstraints(minHeight: 180),
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepNavy,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
