import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/widgets/responsive_layout.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const String apkAssetPath = 'downloads/bf-elec-apps-latest.apk';
  static const String apkVersionLabel = 'v1.0.0';
  static const String supportPhone = '9701347467';

  static Uri get apkUri => Uri.base.resolve(apkAssetPath);

  static const List<_WelcomeFeature> _features = [
    _WelcomeFeature(
      title: 'Drawings',
      subtitle: 'Area-wise BF electrical drawings',
      icon: Icons.architecture_rounded,
      colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
    ),
    _WelcomeFeature(
      title: 'Motor Details',
      subtitle: 'Name plate database with filters',
      icon: Icons.electric_meter_rounded,
      colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
    ),
    _WelcomeFeature(
      title: 'Shift Snags',
      subtitle: 'PLC and hardwire troubleshooting',
      icon: Icons.warning_amber_rounded,
      colors: [Color(0xFFF97316), Color(0xFFEA580C)],
    ),
    _WelcomeFeature(
      title: 'Material Requisition',
      subtitle: 'Plant item request form',
      icon: Icons.post_add_rounded,
      colors: [Color(0xFF10B981), Color(0xFF047857)],
    ),
    _WelcomeFeature(
      title: 'Settings',
      subtitle: 'Parameters and configuration',
      icon: Icons.settings_rounded,
      colors: [Color(0xFF475569), Color(0xFF1E293B)],
    ),
    _WelcomeFeature(
      title: 'Profile',
      subtitle: 'Account and profile photo',
      icon: Icons.person_rounded,
      colors: [Color(0xFF6366F1), Color(0xFF1E2048)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.contentBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Hero(isDesktop: isDesktop)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 48 : 20,
                isDesktop ? 48 : 28,
                isDesktop ? 48 : 20,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is inside',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.deepNavy,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _FeatureGrid(isDesktop: isDesktop),
                  const SizedBox(height: 32),
                  _DownloadPanel(isDesktop: isDesktop),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final bool isDesktop;

  const _Hero({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final headline = Text(
      'Blast Furnace Electrical Apps',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
    );

    final tagline = Text(
      'Drawings, motor name plates, shift snags and material requisition for BF1, BF2, BF3, BHS and AUX areas.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.78),
        fontSize: isDesktop ? 16 : 14,
        height: 1.6,
      ),
    );

    final actions = Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go('/splash'),
          icon: const Icon(Icons.launch_rounded),
          label: const Text('Open Web App'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentCyan,
            foregroundColor: AppTheme.deepNavy,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        if (kIsWeb)
          OutlinedButton.icon(
            onPressed: () => _openApk(context),
            icon: const Icon(Icons.android_rounded),
            label: const Text('Download Android App'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, isDesktop ? 64 : 40, 24, isDesktop ? 64 : 40),
      decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isDesktop ? 112 : 88,
                height: isDesktop ? 112 : 88,
                decoration: BoxDecoration(
                  gradient: AppTheme.surfaceGlow,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentCyan.withValues(alpha: 0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/icon_bfelec_app.png',
                    fit: BoxFit.cover,
                    width: isDesktop ? 88 : 68,
                    height: isDesktop ? 88 : 68,
                  ),
                ),
              ),
              SizedBox(height: isDesktop ? 28 : 20),
              const Text(
                'BFELECAPPS',
                style: TextStyle(
                  color: AppTheme.accentCyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.5,
                ),
              ),
              const SizedBox(height: 10),
              headline,
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: tagline,
              ),
              SizedBox(height: isDesktop ? 32 : 24),
              actions,
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final bool isDesktop;

  const _FeatureGrid({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final columns = isDesktop ? 3 : 1;
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isDesktop ? 2.6 : 3.4,
      children: [
        for (final feature in WelcomePage._features) _FeatureCard(feature: feature),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _WelcomeFeature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: feature.colors),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(feature.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  feature.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.deepNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  feature.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.slateText,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadPanel extends StatelessWidget {
  final bool isDesktop;

  const _DownloadPanel({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1D3A), Color(0xFF1A3A5C)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: isDesktop ? MainAxisSize.min : MainAxisSize.max,
            children: [
              const Icon(Icons.android_rounded, color: AppTheme.accentCyan, size: 30),
              const SizedBox(width: 12),
              Text(
                'Android app',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 20 : 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  WelcomePage.apkVersionLabel,
                  style: const TextStyle(
                    color: AppTheme.accentCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Install the Android build to use the apps offline on a plant device or mobile. The same modules are available on this website.',
            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13.5,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          if (kIsWeb) ...[
            SizedBox(
              width: isDesktop ? 280 : double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openApk(context),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download APK'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  foregroundColor: AppTheme.deepNavy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SelectableText(
              WelcomePage.apkUri.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 11.5,
              ),
            ),
          ] else
            const Text(
              'Open this page on a browser to download the APK.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.support_agent_rounded, color: AppTheme.accentCyan, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Technical Support  ',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: WelcomePage.supportPhone));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Number copied to clipboard',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: AppTheme.accentCyan,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  WelcomePage.supportPhone,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.copy_rounded, color: Colors.white.withValues(alpha: 0.6), size: 14),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _openApk(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final uri = WelcomePage.apkUri;
  var started = false;
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    started = await launchUrl(uri);
  }
  if (!started) {
    await Clipboard.setData(ClipboardData(text: uri.toString()));
    messenger.showSnackBar(
      SnackBar(
        content: const Text(
          'Download link copied to clipboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.accentCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _WelcomeFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const _WelcomeFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}