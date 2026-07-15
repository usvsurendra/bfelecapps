import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DrawingPdfPage extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const DrawingPdfPage({
    super.key,
    required this.title,
    this.pdfUrl = '',
  });

  @override
  State<DrawingPdfPage> createState() => _DrawingPdfPageState();
}

class _DrawingPdfPageState extends State<DrawingPdfPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {},
          onPageFinished: (_) {},
          onWebResourceError: (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load PDF: ${error.description}')),
              );
            }
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final pdfUrl = widget.pdfUrl.isEmpty ? 'about:blank' : widget.pdfUrl;

    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
        actions: [
          if (widget.pdfUrl.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded),
              tooltip: 'Open in browser',
              onPressed: () async {
                final uri = Uri.parse(widget.pdfUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
      body: widget.pdfUrl.isEmpty
          ? _buildEmptyState()
          : WebViewWidget(controller: _controller..loadRequest(Uri.parse(pdfUrl))),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepNavy,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'No PDF link available for this drawing.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppTheme.slateText),
            ),
          ],
        ),
      ),
    );
  }
}
