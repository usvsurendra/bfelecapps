import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialRequisitionPage extends StatelessWidget {
  const MaterialRequisitionPage({super.key});

  static const String _formUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSe0pyUdCV9d9RwiAPTwms6vVuQkcMlQnxl7ijKaw8klo_iA9g/viewform?pli=1&pli=1';

  Future<void> _openForm() async {
    final uri = Uri.parse(_formUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: const Text('Material Requisition Form'),
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.successGreen, const Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.successGreen.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.post_add_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Material Requisition Form',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Submit items required for plant use through the official material requisition form.',
              style: TextStyle(
                color: AppTheme.slateText,
                fontSize: 15,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderGray),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepNavy.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Instructions',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkText,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '1. Tap the button below to open the requisition form.\n'
                    '2. Fill in the required item details accurately.\n'
                    '3. Submit the form for processing.\n'
                    '4. You will receive a confirmation after submission.',
                    style: TextStyle(
                      color: AppTheme.slateText,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _openForm,
                icon: const Icon(Icons.open_in_browser_rounded),
                label: const Text('Open Material Requisition Form'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                  foregroundColor: AppTheme.pureWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
