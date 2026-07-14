import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawingPdfPage extends StatelessWidget {
  final String title;
  final String pdfUrl;

  const DrawingPdfPage({
    super.key,
    required this.title,
    this.pdfUrl = '',
  });

  Future<void> _openInBrowser() async {
    if (pdfUrl.isEmpty) return;
    final uri = Uri.parse(pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
        actions: [
          if (pdfUrl.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded),
              tooltip: 'Open in browser',
              onPressed: _openInBrowser,
            ),
        ],
      ),
      body: pdfUrl.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepNavy,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PDF Document',
                      style: TextStyle(color: AppTheme.slateText, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _openInBrowser,
                        icon: const Icon(Icons.open_in_browser_rounded),
                        label: const Text('Open Drawing PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: AppTheme.pureWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.error_outline_rounded, size: 40, color: AppTheme.mediumGray),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No PDF link available for\n$title',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: AppTheme.slateText, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
    );
  }
}
